//
//  XBAMPInteger.m
//  XBAMPObjC
//
//  Created by xissburg on 8/23/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPInteger.h"

@implementation XBAMPInteger

+ (NSData *)encodeObject:(id)object
{
    NSNumber *number = object;
    NSString *string = [NSString stringWithFormat:@"%d", number.integerValue];
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)decodeData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [NSNumber numberWithInteger:string.integerValue];
}

@end
