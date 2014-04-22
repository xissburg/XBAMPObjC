//
//  XBAMP.m
//  XBAMPObjC
//
//  Created by xissburg on 8/22/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMP.h"
#import <objc/runtime.h>
#import <objc/message.h>

/**
 AMP keywords.
 */
#define kAMPAskKey @"_ask"
#define kAMPCommandKey @"_command"
#define kAMPAnswerKey @"_answer"
#define kAMPErrorKey @"_error"
#define kAMPErrorCodeKey @"_error_code"
#define kAMPErrorDescriptionKey @"_error_description"

/**
 Keys for blocks added to the socket that are called in its delegate implementation.
 */
static char kConnectBlockKey;
static char kDisconnectBlockKey;

/**
 Key used to obtain and store the socketId out of a GCDAsyncSocket instance. This is not nil only for sockets provided in the 
 socket:didAcceptNewSocket: method.
 */
static char kSocketIdKey;

/**
 Tags for uniquely identifying reads and writes in the AsyncSocket delegate methods.
 */
enum {
    kWriteDataTag = 1,
    kReadAMPKeyLengthTag,
    kReadAMPValueLengthTag,
    kReadAMPKeyTag,
    kReadAMPValueTag
};

/**
 This class stores all the stuff that is necessary while processing a reply from a previous asynchronous call.
 */
@interface XBAMPTagContext : NSObject

@property (nonatomic, strong) XBAMPCommand *command;
@property (nonatomic, strong) void (^success)(NSDictionary *);
@property (nonatomic, strong) void (^failure)(XBAMPError *);

@end

@implementation XBAMPTagContext

- (id)initWithCommand:(XBAMPCommand *)command success:(void (^)(NSDictionary *response))success failure:(void (^)(XBAMPError *ampError))failure
{
    self = [super init];
    if (self) {
        self.command = command;
        self.success = success;
        self.failure = failure;
    }
    return self;
}

@end

@interface XBAMP ()

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableDictionary *clientSockets;
@property (nonatomic, assign) NSUInteger tagCounter;
@property (nonatomic, assign) NSUInteger currentCallTag;
@property (nonatomic, copy) NSData *askKeyData;
@property (nonatomic, copy) NSData *commandKeyData;
@property (nonatomic, copy) NSData *answerKeyData;
@property (nonatomic, copy) NSData *errorKeyData;
@property (nonatomic, copy) NSData *errorCodeKeyData;
@property (nonatomic, copy) NSData *errorDescriptionKeyData;
@property (nonatomic, strong) NSMutableDictionary *currentPacketDictionary;
@property (nonatomic, copy) NSString *currentKey;
@property (nonatomic, strong) NSMutableDictionary *tagContextsDictionary;
@property (nonatomic, strong) NSMutableDictionary *handlerBlocksDictionary;
@property (nonatomic, strong) NSMutableDictionary *handlerSelectorsDictionary;
@property (nonatomic, strong) NSMutableDictionary *commandsDictionary;

@end

@implementation XBAMP

- (id)init
{
    return [self initWithSocket:[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()]];
}

- (id)initWithSocket:(GCDAsyncSocket *)socket
{
    self = [super init];
    if (self) {
        self.socket = socket;
        self.clientSockets = [[NSMutableDictionary alloc] init];
        self.tagCounter = 0;
        self.askKeyData = [kAMPAskKey dataUsingEncoding:NSUTF8StringEncoding];
        self.commandKeyData = [kAMPCommandKey dataUsingEncoding:NSUTF8StringEncoding];
        self.answerKeyData = [kAMPAnswerKey dataUsingEncoding:NSUTF8StringEncoding];
        self.errorKeyData = [kAMPErrorKey dataUsingEncoding:NSUTF8StringEncoding];
        self.errorCodeKeyData = [kAMPErrorCodeKey dataUsingEncoding:NSUTF8StringEncoding];
        self.errorDescriptionKeyData = [kAMPErrorDescriptionKey dataUsingEncoding:NSUTF8StringEncoding];
        self.tagContextsDictionary = [[NSMutableDictionary alloc] init];
        self.handlerBlocksDictionary = [[NSMutableDictionary alloc] init];
        self.handlerSelectorsDictionary = [[NSMutableDictionary alloc] init];
        self.commandsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (BOOL)isConnected
{
    return [self.socket isConnected];
}

#pragma mark - Methods

- (void)connectToHost:(NSString *)hostname port:(NSUInteger)port success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
{
    objc_setAssociatedObject(self.socket, &kConnectBlockKey, success, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self.socket, &kDisconnectBlockKey, failure, OBJC_ASSOCIATION_COPY);
    NSError *error = nil;
    if (![self.socket connectToHost:hostname onPort:port error:&error] && failure) {
        failure(error);
    }
}

- (BOOL)acceptOnPort:(NSUInteger)port error:(NSError *__autoreleasing *)errPtr
{
    return [self.socket acceptOnPort:port error:errPtr];
}

- (void)closeConnection
{
    [self.socket disconnect];
}

- (void)callCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *))success failure:(void (^)(XBAMPError *ampError))failure
{
    [self callCommand:command withParameters:parameters socket:self.socket success:success failure:failure];
}

- (void)callCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters socketId:(NSString *)socketId success:(void (^)(NSDictionary *response))success failure:(void (^)(XBAMPError *ampError))failure
{
    GCDAsyncSocket *socket = self.clientSockets[socketId];
    [self callCommand:command withParameters:parameters socket:socket success:success failure:failure];
}

- (void)callCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters socket:(GCDAsyncSocket *)socket success:(void (^)(NSDictionary *response))success failure:(void (^)(XBAMPError *ampError))failure
{
    NSData *data = [self dataToCallCommand:command withParameters:parameters askTag:self.tagCounter];
    
    if (command.requiresAnswer) {
        XBAMPTagContext *tagContext = [[XBAMPTagContext alloc] initWithCommand:command success:success failure:failure];
        self.tagContextsDictionary[@(self.tagCounter)] = tagContext;
        self.tagCounter++;
    }
    
    [socket writeData:data withTimeout:-1 tag:kWriteDataTag];
}

- (void)handleCommand:(XBAMPCommand *)command withBlock:(XBAMPCommandHandler)block
{
    self.commandsDictionary[command.name] = command;
    self.handlerBlocksDictionary[command.name] = [block copy];
    [self.handlerSelectorsDictionary removeObjectForKey:command.name];
}

- (void)handleCommand:(XBAMPCommand *)command withTarget:(id)target selector:(SEL)selector
{
    self.commandsDictionary[command.name] = command;
    self.handlerSelectorsDictionary[command.name] = @[target, NSStringFromSelector(selector)];
    [self.handlerBlocksDictionary removeObjectForKey:command.name];
}

#pragma mark - Private Methods

- (void)appendLengthAndData:(NSData *)data toMutableData:(NSMutableData *)mutableData
{
    unsigned short length = htons((unsigned short)data.length);
    [mutableData appendBytes:&length length:sizeof(unsigned short)];
    [mutableData appendData:data];
}

- (void)processPacketDictionary:(NSDictionary *)dictionary forSocket:(GCDAsyncSocket *)socket
{
    if (dictionary[kAMPCommandKey]) {
        NSData *commandData = dictionary[kAMPCommandKey];
        NSString *commandName = [[NSString alloc] initWithData:commandData encoding:NSUTF8StringEncoding];
        XBAMPCommand *command = self.commandsDictionary[commandName];
        
        if (command) {
            NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
            [mutableDictionary removeObjectsForKeys:@[kAMPCommandKey, kAMPAskKey]];
            NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in mutableDictionary) {
                NSData *valueData = mutableDictionary[key];
                XBAMPType *ampType = command.parameterTypes[key];
                id value = [ampType decodeData:valueData];
                parametersDictionary[key] = value;
            }
            
            NSString *socketId = objc_getAssociatedObject(socket, &kSocketIdKey);
            XBAMPError *ampError = nil;
            NSDictionary *response = nil;
            
            XBAMPCommandHandler block = self.handlerBlocksDictionary[commandName];
            NSArray *targetSelectorPair = self.handlerSelectorsDictionary[commandName];
            
            if (block) {
                response = block(parametersDictionary, socketId, &ampError);
            }
            else if (targetSelectorPair) {
                id target = targetSelectorPair[0];
                SEL selector = NSSelectorFromString(targetSelectorPair[1]);
                Method method = class_getInstanceMethod([target class], selector);
                const char *encoding = method_getTypeEncoding(method);
                NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:encoding];
                NSUInteger parameterCount = signature.numberOfArguments - 2; // Remove self and _cmd from count
                
                if (parameterCount == 3) {
                    response = objc_msgSend(target, selector, parametersDictionary, socketId, &ampError);
                }
                else { // The selector doesn't receive the socketId parameter in this case.
                    response = objc_msgSend(target, selector, parametersDictionary, &ampError);
                }
            }
            else {
                NSAssert(NO, @"Command assigned without a block or selector handler.");
            }
            
            if (command.requiresAnswer) {
                NSData *askData = dictionary[kAMPAskKey];
                NSString *ask = [[NSString alloc] initWithData:askData encoding:NSUTF8StringEncoding];
                if (response != nil) {
                    [self sendResponse:response forTag:ask.integerValue socket:socket command:command];
                }
                else if (ampError != nil) {
                    [self sendError:ampError forTag:ask.integerValue socket:socket command:command];
                }
            }
        }
        else {
            NSData *askData = dictionary[kAMPAskKey];
            if (askData) {
                NSString *ask = [[NSString alloc] initWithData:askData encoding:NSUTF8StringEncoding];
                XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0 codeString:@"UNHANDLED" description:[NSString stringWithFormat:@"Unhandled Command: '%@'", commandName]];
                [self sendError:ampError forTag:ask.integerValue socket:socket command:command];
            }
        }
    }
    else if (dictionary[kAMPAnswerKey]) {
        NSData *tagData = dictionary[kAMPAnswerKey];
        NSString *tagString = [[NSString alloc] initWithData:tagData encoding:NSUTF8StringEncoding];
        NSUInteger tag = tagString.integerValue;
        XBAMPTagContext *tagContext = self.tagContextsDictionary[@(tag)];
        [self.tagContextsDictionary removeObjectForKey:@(tag)];
        
        if (tagContext.success) {
            NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
            [mutableDictionary removeObjectForKey:kAMPAnswerKey];
            NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in mutableDictionary) {
                NSData *valueData = mutableDictionary[key];
                XBAMPType *ampType = tagContext.command.responseTypes[key];
                id value = [ampType decodeData:valueData];
                responseDictionary[key] = value;
            }
            
            tagContext.success(responseDictionary);
        }
    }
    else if (dictionary[kAMPErrorKey]) {
        NSData *tagData = dictionary[kAMPErrorKey];
        NSString *tagString = [[NSString alloc] initWithData:tagData encoding:NSUTF8StringEncoding];
        NSUInteger tag = tagString.integerValue;
        XBAMPTagContext *tagContext = self.tagContextsDictionary[@(tag)];
        [self.tagContextsDictionary removeObjectForKey:@(tag)];
        
        if (tagContext.failure) {
            NSData *errorCodeData = dictionary[kAMPErrorCodeKey];
            NSString *errorCodeString = [[NSString alloc] initWithData:errorCodeData encoding:NSUTF8StringEncoding];
            NSData *errorDescriptionData = dictionary[kAMPErrorDescriptionKey];
            NSString *errorDescriptionString = [[NSString alloc] initWithData:errorDescriptionData encoding:NSUTF8StringEncoding];
            
            NSUInteger index = NSNotFound;
            
            if (tagContext.command.errors.count > 0) {
                index = [tagContext.command.errors indexOfObjectPassingTest:^BOOL(XBAMPError *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj.codeString isEqualToString:errorCodeString]) {
                        *stop = YES;
                        return YES;
                    }
                    return NO;
                }];
            }
            
            if (index != NSNotFound) {
                XBAMPError *ampError = tagContext.command.errors[index];
                tagContext.failure(ampError);
            }
            else {
                XBAMPError *ampError = [[XBAMPError alloc] initWithCode:kXBAMPUnknownErrorCode codeString:errorCodeString description:errorDescriptionString];
                tagContext.failure(ampError);
            }
        }
    }
}

- (void)sendResponse:(NSDictionary *)response forTag:(NSUInteger)tag command:(XBAMPCommand *)command
{
    [self sendResponse:response forTag:tag socket:self.socket command:command];
}

- (void)sendResponse:(NSDictionary *)response forTag:(NSUInteger)tag socketId:(NSString *)socketId command:(XBAMPCommand *)command
{
    GCDAsyncSocket *socket = self.clientSockets[socketId];
    [self sendResponse:response forTag:tag socket:socket command:command];
}

- (void)sendResponse:(NSDictionary *)response forTag:(NSUInteger)tag socket:(GCDAsyncSocket *)socket command:(XBAMPCommand *)command
{
    NSData *responseData = [self dataForResponse:response toCommand:command answerTag:tag];
    [socket writeData:responseData withTimeout:-1 tag:kWriteDataTag];
}

- (void)sendError:(XBAMPError *)ampError forTag:(NSUInteger)tag socket:(GCDAsyncSocket *)socket command:(XBAMPCommand *)command
{
    NSData *errorData = [self dataForError:ampError withTag:tag];
    [socket writeData:errorData withTimeout:-1 tag:kWriteDataTag];
}

- (NSData *)dataToCallCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters askTag:(NSUInteger)askTag
{
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    
    if (command.requiresAnswer) {
        NSString *askTagString = [@(askTag) stringValue];
        NSData *askTagData = [askTagString dataUsingEncoding:NSUTF8StringEncoding];
        [self appendLengthAndData:self.askKeyData toMutableData:mutableData];
        [self appendLengthAndData:askTagData toMutableData:mutableData];
    }
    
    [self appendLengthAndData:self.commandKeyData toMutableData:mutableData];
    [self appendLengthAndData:[command.name dataUsingEncoding:NSUTF8StringEncoding] toMutableData:mutableData];
    
    for (NSString *key in [command.parameterTypes allKeys]) {
        id value = parameters[key];
        if (value) {
            XBAMPType *ampType = command.parameterTypes[key];
            NSData *valueData = [ampType encodeObject:value];
            [self appendLengthAndData:[key dataUsingEncoding:NSUTF8StringEncoding] toMutableData:mutableData];
            [self appendLengthAndData:valueData toMutableData:mutableData];
        }
    }
    
    unsigned short zero = 0;
    [mutableData appendBytes:&zero length:sizeof(unsigned short)];
    
    return [mutableData copy];
}

- (NSData *)dataForResponse:(NSDictionary *)response toCommand:(XBAMPCommand *)command answerTag:(NSUInteger)answerTag
{
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    NSString *answerTagString = [@(answerTag) stringValue];
    NSData *answerTagData = [answerTagString dataUsingEncoding:NSUTF8StringEncoding];
    [self appendLengthAndData:self.answerKeyData toMutableData:mutableData];
    [self appendLengthAndData:answerTagData toMutableData:mutableData];
    
    for (NSString *key in response.allKeys) {
        id value = response[key];
        XBAMPType *ampType = command.responseTypes[key];
        NSData *valueData = [ampType encodeObject:value];
        [self appendLengthAndData:[key dataUsingEncoding:NSUTF8StringEncoding] toMutableData:mutableData];
        [self appendLengthAndData:valueData toMutableData:mutableData];
    }
    
    unsigned short zero = 0;
    [mutableData appendBytes:&zero length:sizeof(unsigned short)];
    
    return [mutableData copy];
}

- (NSData *)dataForError:(XBAMPError *)ampError withTag:(NSUInteger)tag
{
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    NSData *tagData = [[@(tag) stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    [self appendLengthAndData:self.errorKeyData toMutableData:mutableData];
    [self appendLengthAndData:tagData toMutableData:mutableData];
    
    NSData *errorCodeData = [ampError.codeString dataUsingEncoding:NSUTF8StringEncoding];
    [self appendLengthAndData:self.errorCodeKeyData toMutableData:mutableData];
    [self appendLengthAndData:errorCodeData toMutableData:mutableData];
    
    NSData *errorDescriptionData = [ampError.errorDescription dataUsingEncoding:NSUTF8StringEncoding];
    [self appendLengthAndData:self.errorDescriptionKeyData toMutableData:mutableData];
    [self appendLengthAndData:errorDescriptionData toMutableData:mutableData];
    
    unsigned short zero = 0;
    [mutableData appendBytes:&zero length:sizeof(unsigned short)];
    
    return [mutableData copy];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSString *socketId = [[NSUUID UUID] UUIDString];
    self.clientSockets[socketId] = newSocket;
    objc_setAssociatedObject(newSocket, &kSocketIdKey, socketId, OBJC_ASSOCIATION_COPY);
    if (self.didAcceptNewSocket) {
        self.didAcceptNewSocket(socketId);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    void (^success)(void) = objc_getAssociatedObject(sock, &kConnectBlockKey);
    if (success) {
        success();
    }
    
    objc_setAssociatedObject(sock, &kConnectBlockKey, nil, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(sock, &kDisconnectBlockKey, nil, OBJC_ASSOCIATION_COPY);

    // Perform the first read to initiate the continuous chain of reads
    [sock readDataToLength:sizeof(unsigned short) withTimeout:-1 tag:kReadAMPKeyLengthTag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == kReadAMPKeyLengthTag || tag == kReadAMPValueLengthTag) {
        unsigned short length = 0;
        [data getBytes:&length length:sizeof(unsigned short)];
        length = ntohs(length);
        
        if (tag == kReadAMPKeyLengthTag && length == 0) {
            [self processPacketDictionary:self.currentPacketDictionary forSocket:sock];
            self.currentPacketDictionary = nil;
            [sock readDataToLength:sizeof(unsigned short) withTimeout:-1 tag:kReadAMPKeyLengthTag];
        }
        else if (length > 0) {
            [sock readDataToLength:length withTimeout:-1 tag:tag == kReadAMPKeyLengthTag? kReadAMPKeyTag: kReadAMPValueTag];
        }
        else {
            [sock readDataToLength:sizeof(unsigned short) withTimeout:-1 tag:kReadAMPKeyLengthTag];
        }
    }
    else if (tag == kReadAMPKeyTag) {
        self.currentKey = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // Read the length of the next value
        [sock readDataToLength:sizeof(unsigned short) withTimeout:-1 tag:kReadAMPValueLengthTag];
    }
    else if (tag == kReadAMPValueTag) {
        if (self.currentPacketDictionary == nil) {
            self.currentPacketDictionary = [[NSMutableDictionary alloc] init];
        }
        self.currentPacketDictionary[self.currentKey] = data;
        
        // Read the length of the next key
        [sock readDataToLength:sizeof(unsigned short) withTimeout:-1 tag:kReadAMPKeyLengthTag];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    void (^failure)(NSError *) = objc_getAssociatedObject(sock, &kDisconnectBlockKey);
    if (failure) {
        failure(err);
    }
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    if (self.didCloseConnection) {
        NSString *socketId = objc_getAssociatedObject(sock, &kSocketIdKey);
        self.didCloseConnection(socketId);
    }
}

@end
