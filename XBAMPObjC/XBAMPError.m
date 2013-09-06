//
//  XBAMPError.m
//  XBAMPObjC
//
//  Created by xiss burg on 9/3/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPError.h"

@implementation XBAMPError

- (id)initWithCode:(int)code codeString:(NSString *)codeString description:(NSString *)description
{
    self = [super init];
    if (self) {
        _code = code;
        _codeString = [codeString copy];
        _errorDescription = [description copy];
    }
    return self;
}

@end

NSString *const XBAMPErrorDomain = @"XBAMPErrorDomain";
