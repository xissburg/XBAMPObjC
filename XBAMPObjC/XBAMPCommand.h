//
//  XBAMPCommand.h
//  XBAMPObjC
//
//  Created by xissburg on 8/23/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBAMPInteger.h"
#import "XBAMPBytes.h"
#import "XBAMPString.h"
#import "XBAMPBoolean.h"
#import "XBAMPFloat.h"
#import "XBAMPDate.h"
#import "XBAMPArray.h"
#import "XBAMPDictionary.h"
#import "XBAMPError.h"

/**
 XBAMPCommand specifies an AMP command, including its name, the parameters and its types, the reponse types, possible errors and whether it
 returns an answer or not.
 */
@interface XBAMPCommand : NSObject

/**
 The name of the command.
 */
@property (nonatomic, readonly) NSString *name;

/**
 A dictionary that maps parameter names to XBAMPType instances. It specifies the names of the parameters this command receives and its 
 types.
 */
@property (nonatomic, readonly) NSDictionary *parameterTypes;

/**
 A dictionary that maps names to XBAMPType instances. It specifies the names of the items this command returns and its types.
 */
@property (nonatomic, readonly) NSDictionary *responseTypes;

/**
 An array of XBAMPError instances that specify the possible errors this command returns.
 */
@property (nonatomic, readonly) NSArray *errors;

/**
 Determines whether this command returns a response. The response might be nil though. It is considered a 'fire and forget' kind of command
 if it this property is NO.
 
 The default value is YES.
 */
@property (nonatomic, readonly) BOOL requiresAnswer;

- (id)initWithName:(NSString *)name parameterTypes:(NSDictionary *)parameterTypes responseTypes:(NSDictionary *)responseTypes errors:(NSArray *)errors;
- (id)initWithName:(NSString *)name parameterTypes:(NSDictionary *)parameterTypes responseTypes:(NSDictionary *)responseTypes errors:(NSArray *)errors requiresAnswer:(BOOL)requiresAnswer;

@end
