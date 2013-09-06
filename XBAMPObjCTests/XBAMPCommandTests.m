//
//  XBAMPObjC - XBAMPCommandTests.m
//  Copyright 2013 xissburg. All rights reserved.
//
//  Created by: xissburg
//

#import "XBAMPCommand.h"

#import <GHUnitIOS/GHUnit.h>


@interface XBAMPCommandTests : GHTestCase
@end

@implementation XBAMPCommandTests

- (void)testInitialization
{
    XBAMPInteger *ampInteger = [[XBAMPInteger alloc] init];
    XBAMPBytes *ampBytes = [[XBAMPBytes alloc] init];
    XBAMPDate *ampDate = [[XBAMPDate alloc] init];
    XBAMPError *ampError = [[XBAMPError alloc] initWithCode:1 codeString:@"ERROR" description:@"This is an error"];
    XBAMPCommand *command = [[XBAMPCommand alloc] initWithName:@"command" parameterTypes:@{@"intParam": ampInteger, @"bytesParam": ampBytes} responseTypes:@{@"dateResult": ampDate} errors:@[ampError]];
    
    GHAssertEqualStrings(command.name, @"command", nil);
    GHAssertEqualObjects(command.parameterTypes[@"intParam"], ampInteger, nil);
    GHAssertEqualObjects(command.parameterTypes[@"bytesParam"], ampBytes, nil);
    GHAssertEqualObjects(command.responseTypes[@"dateResult"], ampDate, nil);
    GHAssertTrue([command.errors containsObject:ampError], nil);
    GHAssertTrue(command.requiresAnswer, nil);
}

@end
