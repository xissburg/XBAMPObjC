//
//  XBAMP.h
//  XBAMPObjC
//
//  Created by xissburg on 8/22/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "XBAMPCommand.h"

/**
 The command handler block.
 
 @param parameters A dictionary that maps strings (parameter names) to objects.
 @param socketId The id of the socket that the command should be handled for. If the XBAMP instance is a client, then this value should be nil.
 @param ampError If the invocation of the command fails, it should assign a XBAMPError instance to this parameter and return nil.
 
 @return The response dictionary, or nil in case of an error.
 */
typedef NSDictionary *(^XBAMPCommandHandler)(NSDictionary *parameters, NSString *socketId, XBAMPError **ampError);

/**
 The XBAMP class is capable of connecting to an AMP server or to accept connections from AMP clients. After connected, it can send
 and receive remote commands.
 */
@interface XBAMP : NSObject <GCDAsyncSocketDelegate>

/**
 Returns whether this instance is connected to a server or whether it is accepting connections.
 */
@property (nonatomic, readonly, getter = isConnected) BOOL connected;

/**
 Block invoked when a connection is closed/lost. The socketId is not nil only if this is accepting new connections.
 */
@property (nonatomic, copy) void (^didCloseConnection)(NSString *socketId);

/**
 Block invoked when a new socket is accepted.
 */
@property (nonatomic, copy) void (^didAcceptNewSocket)(NSString *socketId);

/**
 Initializes an instance with an existing socket.
 
 @param socket The socket this instance should use to communicate with the other end.
 
 @return A XBAMP instance initialized with the given socket.
 */
- (id)initWithSocket:(GCDAsyncSocket *)socket;

/**
 Attempts to connect to an AMP server.
 
 @param hostname The hostname to connect to.
 @param port The port to connect to.
 @param success A block that is invoked if the connection is established successfully.
 @param error A block that is invoked if it fails to connect.
 */
- (void)connectToHost:(NSString *)hostname port:(NSUInteger)port success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 Starts to accept connections at a given port.
 
 @param port The port to listen to connections.
 @param errPtr A pointer to NSError where the possible error will be stored.
 
 @return Returns YES if successful, NO if it fails.
 */
- (BOOL)acceptOnPort:(NSUInteger)port error:(NSError *__autoreleasing *)errPtr;

/**
 Closes the connection.
 */
- (void)closeConnection;

/**
 Calls a command on the other end.
 
 @param command A command that specifies the parameter types, response types, possible errors, among other things.
 @param parameters A dictionary that maps parameter names to objects.
 @param success A block that is invoked if the request is successful. It receives the response in its single parameter that is a dictionary
    that maps names to objects according to the command's responseTypes
 @param failure A block that is invoked on failure.
 */
- (void)callCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *response))success failure:(void (^)(XBAMPError *ampError))failure;

/**
 Calls a command on the other end. This method is intended to be called on clients, that is, if the XBAMP instance is acting as a server.
 
 @param command A command that specifies the parameter types, response types, possible errors, among other things.
 @param parameters A dictionary that maps parameter names to objects.
 @param socketId The id of the socket to send the request to.
 @param success A block that is invoked if the request is successful. It receives the response in its single parameter that is a dictionary
    that maps names to objects according to the command's responseTypes
 @param failure A block that is invoked on failure.
 */
- (void)callCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters socketId:(NSString *)socketId success:(void (^)(NSDictionary *response))success failure:(void (^)(XBAMPError *ampError))failure;

/**
 Assigns a block to handle a given command.
 
 @param command The command to handle invocations for.
 @param block The block that should be called whenever the given command is received.
 */
- (void)handleCommand:(XBAMPCommand *)command withBlock:(XBAMPCommandHandler)block;

/**
 Specifies a selector to be called on a target whenever a given command is called. The selector receives the following parameters:
 
 - parameters (NSDictionary *): A dictionary that maps strings (parameter names) to objects.
 
 - socketId (NSString *) (optional): The id of the socket that the command should be handled for. If the XBAMP instance is a client, then this value should be nil.
 
 - ampError (XBAMPError **): If the invocation of the command fails, it should assign a XBAMPError instance to this parameter and return nil.
 
 The selector should return an NSDictionary instance containing the response.
 
 @param command The command to handle invocations for.
 @param target The target for the selector.
 @param selector The selector that should be called on target whenever the given command is received.
 */
- (void)handleCommand:(XBAMPCommand *)command withTarget:(id)target selector:(SEL)selector;

@end
