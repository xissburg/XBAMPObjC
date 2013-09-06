//
//  XBAMPCommand.m
//  XBAMPObjC
//
//  Created by xissburg on 8/23/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPCommand.h"

@implementation XBAMPCommand

- (id)initWithName:(NSString *)name parameterTypes:(NSDictionary *)parameterTypes responseTypes:(NSDictionary *)responseTypes errors:(NSArray *)errors
{
    return [self initWithName:name parameterTypes:parameterTypes responseTypes:responseTypes errors:errors requiresAnswer:YES];
}

- (id)initWithName:(NSString *)name parameterTypes:(NSDictionary *)parameterTypes responseTypes:(NSDictionary *)responseTypes errors:(NSArray *)errors requiresAnswer:(BOOL)requiresAnswer
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _parameterTypes = [parameterTypes copy];
        _responseTypes = [responseTypes copy];
        _errors = [errors copy];
        _requiresAnswer = requiresAnswer;
    }
    return self;
}

@end
