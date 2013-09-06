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

@interface XBAMPCommand : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSDictionary *parameterTypes;
@property (nonatomic, readonly) NSDictionary *responseTypes;
@property (nonatomic, readonly) NSArray *errors;
@property (nonatomic, readonly) BOOL requiresAnswer;

- (id)initWithName:(NSString *)name parameterTypes:(NSDictionary *)parameterTypes responseTypes:(NSDictionary *)responseTypes errors:(NSArray *)errors;
- (id)initWithName:(NSString *)name parameterTypes:(NSDictionary *)parameterTypes responseTypes:(NSDictionary *)responseTypes errors:(NSArray *)errors requiresAnswer:(BOOL)requiresAnswer;

@end
