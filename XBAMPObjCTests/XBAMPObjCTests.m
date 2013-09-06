//
//  XBAMPObjC - XBAMPObjCTests.m
//  Copyright 2013 xissburg. All rights reserved.
//
//  Created by: xiss burg
//

    // Class under test
#import "XBAMPObjC.h"
#import "GCDAsyncSocket.h"

#import <GHUnitIOS/GHUnit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface XBAMPObjC (Test)

- (GCDAsyncSocket *)socket;
- (NSData *)dataToCallCommand:(XBAMPCommand *)command withParameters:(NSDictionary *)parameters askTag:(NSUInteger)askTag;

@end


@interface XBAMPObjCTests : GHAsyncTestCase
@end

@implementation XBAMPObjCTests
{
    XBAMPObjC *ampObjC;
    GCDAsyncSocket *mockSocket;
}

- (void)setUp
{
    [super setUp];
    mockSocket = mock([GCDAsyncSocket class]);
    ampObjC = [[XBAMPObjC alloc] initWithSocket:mockSocket];
}

- (void)testConnect
{
    [given([mockSocket isConnected]) willReturnBool:YES];

    GHAssertTrue([ampObjC isConnected], nil);
}

- (void)testDisconnect
{
    [given([mockSocket isConnected]) willReturnBool:NO];
    
    [ampObjC closeConnection];
    
    GHAssertFalse([ampObjC isConnected], nil);
}

- (void)testDataToCallCommand
{
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0xff codeString:@"ZERO_DIVISION" description:@"Zero float division"];
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"someCommand" parameterTypes:@{@"intParam": [[XBAMPInteger alloc] init], @"stringParam": [[XBAMPString alloc] init]} responseTypes:@{@"arrayResult": [[XBAMPArray alloc] init]} errors:@[ampError]];
    NSData *data = [ampObjC dataToCallCommand:command withParameters:@{@"intParam": @26, @"stringParam": @"xissburg"} askTag:23];
    
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

/*
- (void)testCallCommand
{
    [self prepare];
    
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:0xff codeString:@"ZERO_DIVISION" description:@"Zero float division"];
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"command" parameterTypes:@{@"intParam": [[XBAMPInteger alloc] init], @"stringParam": [[XBAMPString alloc] init]} responseTypes:@{@"arrayResult": [[XBAMPArray alloc] init]} errors:@[ampError]];
    [ampObjC callCommand:command withParameters:@{@"intParam": @1, @"stringParam": @"xissburg"} success:^(NSDictionary *response) {
        GHAssertTrue([response[@"arrayResult"] isKindOfClass:[NSArray class]], nil);
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCallCommand)];
    } failure:nil];
    
    ampObjC.socket.delegate socket:ampObjC.socket didReadData:<#(NSData *)#> withTag:<#(long)#>
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
}*/

@end
