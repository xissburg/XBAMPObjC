//
//  XBAMPFloat.m
//  XBAMPObjC
//
//  Created by xissburg on 8/24/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPFloat.h"

@implementation XBAMPFloat

- (NSData *)encodeObject:(id)object
{
    NSNumber *number = object;
    NSString *string = [number description];
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)decodeData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [NSNumber numberWithDouble:string.doubleValue];
}

@end
