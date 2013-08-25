//
//  XBAMPType.m
//  XBAMPObjC
//
//  Created by xissburg on 8/23/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPType.h"

@implementation XBAMPType

- (NSData *)encodeObject:(id)object
{
    NSAssert(NO, @"+[XBAMPType encodeObject:] is abstract and should be implemented by a subclass");
    return nil;
}

- (id)decodeData:(NSData *)data
{
    NSAssert(NO, @"+[XBAMPType decodeData:] is abstract and should be implemented by a subclass");
    return nil;
}

@end
