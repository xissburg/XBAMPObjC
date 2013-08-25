//
//  XBAMPArray.m
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPArray.h"

@implementation XBAMPArray

- (id)initWithElementType:(XBAMPType *)elementType
{
    self = [super init];
    if (self) {
        _elementType = elementType;
    }
    return self;
}

- (NSData *)encodeObject:(id)object
{
    NSArray *array = object;
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    
    for (id element in array) {
        NSData *elementData = [self.elementType encodeObject:element];
        unsigned short length = (unsigned short)elementData.length;
        [mutableData appendBytes:&length length:sizeof(length)];
        [mutableData appendData:elementData];
    }
    
    return [mutableData copy];
}

- (id)decodeData:(NSData *)data
{
    int i = 0;
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];
    
    while (i < data.length) {
        unsigned short length = 0;
        [data getBytes:&length range:NSMakeRange(i, sizeof(length))];
        NSData *elementData = [data subdataWithRange:NSMakeRange(i + sizeof(length), length)];
        id element = [self.elementType decodeData:elementData];
        [elementsArray addObject:element];
        i += length + sizeof(length);
    }
    
    return elementsArray;
}

@end
