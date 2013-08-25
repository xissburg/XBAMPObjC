//
//  XBAMPBoolean.m
//  XBAMPObjC
//
//  Created by xissburg on 8/24/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPBoolean.h"

@implementation XBAMPBoolean

- (NSData *)encodeObject:(id)object
{
    NSNumber *number = object;
    NSString *string = number.boolValue? @"True": @"False";
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)decodeData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([string isEqualToString:@"True"]) {
        return @YES;
    }
    if ([string isEqualToString:@"False"]) {
        return @NO;
    }
    return nil;
}

@end
