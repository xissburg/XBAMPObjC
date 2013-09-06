//
//  XBAMPError.h
//  XBAMPObjC
//
//  Created by xiss burg on 9/3/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBAMPError : NSObject

@property (nonatomic, readonly) int code;
@property (nonatomic, readonly) NSString *codeString;
@property (nonatomic, readonly) NSString *errorDescription;

- (id)initWithCode:(int)code codeString:(NSString *)codeString description:(NSString *)description;

@end

extern NSString *const XBAMPErrorDomain;