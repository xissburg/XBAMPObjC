//
//  XBAMPBytes.m
//  XBAMPObjC
//
//  Created by xissburg on 8/24/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPBytes.h"

@implementation XBAMPBytes

- (NSData *)encodeObject:(id)object
{
    NSData *data = object;
    return [data copy];
}

- (id)decodeData:(NSData *)data
{
    return [data copy];
}

@end
