//
//  XBAMPObjC - XBAMPTests.m
//  Copyright 2013 xissburg. All rights reserved.
//
//  Created by: xiss burg
//

    // Class under test
#import "XBAMP.h"
#import "GCDAsyncSocket.h"

#import <GHUnitIOS/GHUnit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface XBAMP (Test)

- (GCDAsyncSocket *)socket;
- (NSData *)dataToCallCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters askTag:(NSUInteger)askTag;
- (NSData *)dataForResponse:(NSDictionary *)response toCommand:(XBAMPCommand *)command answerTag:(NSUInteger)answerTag;
- (NSData *)dataForError:(XBAMPError *)ampError withTag:(NSUInteger)tag;

@end


@interface XBAMPTests : GHAsyncTestCase
@end

@implementation XBAMPTests
{
    XBAMP *amp;
    GCDAsyncSocket *mockSocket;
}

- (void)setUp
{
    [super setUp];
    mockSocket = mock([GCDAsyncSocket class]);
    amp = [[XBAMP alloc] initWithSocket:mockSocket];
}

- (void)testConnect
{
    [given([mockSocket isConnected]) willReturnBool:YES];

    GHAssertTrue([amp isConnected], nil);
}

- (void)testDisconnect
{
    [given([mockSocket isConnected]) willReturnBool:NO];
    
    [amp closeConnection];
    
    GHAssertFalse([amp isConnected], nil);
}

- (void)testDataToCallCommand
{
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0xff codeString:@"ZERO_DIVISION" description:@"Zero float division"];
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"someCommand" parameterTypes:@{@"intParam": [[XBAMPInteger alloc] init], @"stringParam": [[XBAMPString alloc] init]} responseTypes:@{@"arrayResult": [[XBAMPArray alloc] init]} errors:@[ampError]];
    NSData *data = [amp dataToCallCommand:command withParameters:@{@"intParam": @26, @"stringParam": @"xissburg"} askTag:23];
    
    ushort length = 0;
    NSUInteger i = 0;
    
    [data getBytes:&length length:sizeof(ushort)];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)4, nil);
    
    i += sizeof(ushort);
    NSData *subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"_ask", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)2, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"23", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)8, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"_command", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)11, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"someCommand", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)11, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"stringParam", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)8, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"xissburg", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)8, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"intParam", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)2, nil);
    
    i += sizeof(ushort);
    subdata = [data subdataWithRange:NSMakeRange(i, length)];
    GHAssertEqualStrings(@"26", [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding], nil);
    
    i += length;
    [data getBytes:&length range:NSMakeRange(i, sizeof(ushort))];
    length = ntohs(length);
    GHAssertEquals(length, (ushort)0, nil);
    
    i += sizeof(ushort);
    GHAssertEquals(i, data.length, nil);
}

- (void)testCallCommand
{
    [self prepare];
    
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0xff codeString:@"ZERO_DIVISION" description:@"Zero float division"];
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"someCommand" parameterTypes:@{@"intParam": [[XBAMPInteger alloc] init], @"stringParam": [[XBAMPString alloc] init]} responseTypes:@{@"arrayResult": [[XBAMPArray alloc] initWithElementType:[[XBAMPString alloc] init]]} errors:@[ampError]];
    NSArray *responseArray = @[@"xiss", @"burg"];
    
    [amp callCommand:command withParameters:@{@"intParam": @1, @"stringParam": @"xissburg"} success:^(NSDictionary *response) {
        GHAssertEqualObjects(response[@"arrayResult"], responseArray, nil);
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCallCommand)];
    } failure:nil];
    
    // manually provide the answer data to force it to process each chunk of bytes
    NSData *data = [amp dataForResponse:@{@"arrayResult": responseArray} toCommand:command answerTag:0];
    
    int i = 0; // _answer
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 7)] withTag:4];
    
    i += 7; // 0
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // arrayResult
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 11)] withTag:4];
    
    i += 11; // the array itself
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 12)] withTag:5];
    
    i += 12; // zero, EOF, should invoke the callCommand's success block above with the proper response
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (void)testHandleCommand
{
    [self prepare];
    
    XBAMPFloat *ampFloat = [[XBAMPFloat alloc] init];
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0xff codeString:@"INVALID_PARAMETERS" description:@"Invalid parameters. Expected x1, y1, z1, x2, y2, z2, all of type float."];

    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"cross" parameterTypes:@{@"x1": ampFloat, @"y1": ampFloat, @"z1": ampFloat, @"x2": ampFloat, @"y2": ampFloat, @"z2": ampFloat} responseTypes:@{@"x": ampFloat, @"y": ampFloat, @"z": ampFloat} errors:@[ampError]];
    
    [amp handleCommand:command withBlock:^NSDictionary *(NSDictionary *parameters, NSString *socketId, XBAMPError **ampError) {
        float x1 = [parameters[@"x1"] floatValue];
        float y1 = [parameters[@"y1"] floatValue];
        float z1 = [parameters[@"z1"] floatValue];
        float x2 = [parameters[@"x2"] floatValue];
        float y2 = [parameters[@"y2"] floatValue];
        float z2 = [parameters[@"z2"] floatValue];
        float x = y1*z2 - z1*y2;
        float y = z1*x2 - x1*z2;
        float z = x1*y2 - y1*x2;
        
        GHAssertEqualsWithAccuracy(x, 0.f, 0.0001f, nil);
        GHAssertEqualsWithAccuracy(y, 0.f, 0.0001f, nil);
        GHAssertEqualsWithAccuracy(z, 1.f, 0.0001f, nil);
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testHandleCommand)];

        return @{@"x": @(x), @"y": @(y), @"z": @(z)};
    }];
    
    NSData *data = [amp dataToCallCommand:command withParameters:@{@"x1": @1, @"y1": @0, @"z1": @0, @"x2": @0, @"y2": @1, @"z2": @0} askTag:1];
    
    int i = 0; // _ask
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 4)] withTag:4];
    
    i += 4; // 1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // _command
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 8)] withTag:4];
    
    i += 8; // cross
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 5)] withTag:5];
    
    i += 5; // x1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:4];
    
    i += 2; // 1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // y1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:4];
    
    i += 2; // 0
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // z1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:4];
    
    i += 2; // 0
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // x2
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:4];
    
    i += 2; // 0
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // y2
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:4];
    
    i += 2; // 1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // z2
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:4];
    
    i += 2; // 0
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // zero, EOF, should invoke the handler
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (void)testHandleCommandWithSelector
{
    [self prepare];
    
    XBAMPFloat *ampFloat = [[XBAMPFloat alloc] init];
    
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"sub" parameterTypes:@{@"a": ampFloat, @"b": ampFloat} responseTypes:@{@"x": ampFloat} errors:nil];
    
    [amp handleCommand:command withTarget:self selector:@selector(subtractWithParameters:error:)];
    
    NSData *data = [amp dataToCallCommand:command withParameters:@{@"a": @3, @"b": @4} askTag:1];
    
    int i = 0; // _ask
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 4)] withTag:4];
    
    i += 4; // 1
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // _command
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 8)] withTag:4];
    
    i += 8; // add
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 3)] withTag:5];
    
    i += 3; // a
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:4];
    
    i += 1; // 3
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // b
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:4];
    
    i += 1; // 4
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // zero, EOF, should invoke the handler
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (NSDictionary *)subtractWithParameters:(NSDictionary *)parameters error:(XBAMPError **)error
{
    CGFloat a = [parameters[@"a"] floatValue];
    CGFloat b = [parameters[@"b"] floatValue];
    CGFloat result = a - b;
    
    GHAssertEqualsWithAccuracy(result, -1.f, 0.0001f, nil);
    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testHandleCommandWithSelector)];

    return @{@"x": @(a - b)};
}

- (void)testError
{
    [self prepare];
    
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0xff codeString:@"SOME_ERROR" description:@"Just testing the error mechanism"];
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"errorCommand" parameterTypes:nil responseTypes:nil errors:@[ampError]];

    [amp callCommand:command withParameters:@{@"intParam": @1, @"stringParam": @"xissburg"} success:nil failure:^(XBAMPError *ampErrorB) {
        GHAssertEquals(ampError.code, ampErrorB.code, nil);
        GHAssertEqualStrings(ampError.codeString, ampErrorB.codeString, nil);
        GHAssertEqualStrings(ampError.errorDescription, ampErrorB.errorDescription, nil);
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testError)];
    }];
    
    // manually provide the answer data to force it to process each chunk of bytes
    NSData *data = [amp dataForError:ampError withTag:0];
    
    int i = 0; // _error
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 6)] withTag:4];
    
    i += 6; // 0
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 1)] withTag:5];
    
    i += 1; // _error_code
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 11)] withTag:4];
    
    i += 11; // SOME_ERROR
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 10)] withTag:5];
    
    i += 10; // _error_description
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 18)] withTag:4];
    
    i += 18; // Just testing the error mechanism
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:3];
    
    i += 2;
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 32)] withTag:5];
    
    i += 32; // zero, EOF, should invoke the callCommand's success block above with the proper response
    [amp socket:amp.socket didReadData:[data subdataWithRange:NSMakeRange(i, 2)] withTag:2];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

// The python server must be running for this test to pass. Go into the XBAMPObjCTests directory and run twistd -y server.tac
- (void)testPythonServer
{
    [self prepare];
    
    XBAMPString *ampString = [[XBAMPString alloc] init];
    XBAMPCommand *sendMessageCommand = [[XBAMPCommand alloc] initWithName:@"SendMessage" parameterTypes:@{@"message": ampString} responseTypes:nil errors:nil];
    XBAMP *ampClient = [[XBAMP alloc] init];
    [ampClient handleCommand:sendMessageCommand withBlock:^NSDictionary *(NSDictionary *parameters, NSString *socketId, XBAMPError **ampError) {
        NSLog(@"%@", parameters[@"message"]);
        return nil;
    }];
    
    [ampClient connectToHost:@"localhost" port:25683 success:^{
        [ampClient callCommand:sendMessageCommand withParameters:@{@"message": @"Hi there!"} success:^(NSDictionary *response) {
            [ampClient closeConnection];
            [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testPythonServer)];
        } failure:^(XBAMPError *ampError) {
            NSLog(@"%@", ampError);
        }];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}

- (void)testServer
{
    [self prepare];
    
    XBAMPString *ampString = [[XBAMPString alloc] init];
    NSMutableArray *socketIds = [[NSMutableArray alloc] init];
    
    XBAMPCommand *sendMessageCommand = [[XBAMPCommand alloc] initWithName:@"sendMessage" parameterTypes:@{@"message": ampString} responseTypes:nil errors:nil];
    
    // Setup server
    XBAMP *ampServer = [[XBAMP alloc] init];
    __weak XBAMP *weakAmpServer = ampServer;
    
    [ampServer setDidAcceptNewSocket:^(NSString *socketId) {
        [socketIds addObject:socketId];
        NSString *message = [NSString stringWithFormat:@"<User with id %@ has joined the chat>", socketId];
        for (NSString *sId in socketIds) {
            [weakAmpServer callCommand:sendMessageCommand withParameters:@{@"message": message} socketId:sId success:nil failure:^(XBAMPError *ampError) {
                NSLog(@"%@", ampError);
            }];
        }
    }];
    
    [ampServer setDidCloseConnection:^(NSString *socketId) {
        [socketIds removeObject:socketId];
        NSString *message = [NSString stringWithFormat:@"<User with id %@ left>", socketId];
        for (NSString *sId in socketIds) {
            [weakAmpServer callCommand:sendMessageCommand withParameters:@{@"message": message} socketId:sId success:nil failure:^(XBAMPError *ampError) {
                NSLog(@"%@", ampError);
            }];
        }
    }];
    
    [ampServer handleCommand:sendMessageCommand withBlock:^NSDictionary *(NSDictionary *parameters, NSString *socketId, XBAMPError **error) {
        NSString *message = [NSString stringWithFormat:@"%@: %@", socketIds, parameters[@"message"]];
        for (NSString *sId in socketIds) {
            [weakAmpServer callCommand:sendMessageCommand withParameters:@{@"message": message} socketId:sId success:nil failure:^(XBAMPError *ampError) {
                NSLog(@"%@", ampError);
            }];
        }
        return nil;
    }];
    
    // Setup client
    XBAMP *ampClient = [[XBAMP alloc] init];
    
    [ampClient handleCommand:sendMessageCommand withBlock:^NSDictionary *(NSDictionary *parameters, NSString *socketId, XBAMPError **ampError) {
        NSLog(@"%@", parameters[@"message"]);
        return nil;
    }];
    
    NSError *error = nil;
    if (![ampServer acceptOnPort:23564 error:&error]) {
        NSLog(@"%@", error);
    }
    
    [ampClient connectToHost:@"localhost" port:23564 success:^{
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [ampClient callCommand:sendMessageCommand withParameters:@{@"message": @"Hello"} success:^(NSDictionary *response) {
                [ampClient closeConnection];
                [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testServer)];
            } failure:^(XBAMPError *ampError) {
                NSLog(@"%@", error);
            }];
        });
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1000];
}

@end
