//
//  XBAMPObjC.h
//  XBAMPObjC
//
//  Created by xissburg on 8/22/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "XBAMPCommand.h"

@interface XBAMPObjC : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, readonly, getter = isConnected) BOOL connected;
@property (nonatomic, copy) void (^didCloseConnection)(void);

- (id)initWithSocket:(GCDAsyncSocket *)socket;
- (void)connectToHost:(NSString *)hostname port:(NSUInteger)port success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)closeConnection;
- (void)callCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
- (void)handleCommand:(XBAMPCommand *)command withBlock:(NSDictionary *(^)(NSDictionary *parameters))block;

@end
