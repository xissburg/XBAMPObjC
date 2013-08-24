//
//  XBAMPString.m
//  XBAMPObjC
//
//  Created by xissburg on 8/24/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPString.h"

@implementation XBAMPString

+ (NSData *)encodeObject:(id)object
{
    NSString *string = object;
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)decodeData:(NSData *)data
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
