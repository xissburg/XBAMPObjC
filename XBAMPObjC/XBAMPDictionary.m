//
//  XBAMPDictionary.m
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPDictionary.h"

@implementation XBAMPDictionary

- (id)initWithElementTypes:(NSDictionary *)elementTypes
{
    self = [super init];
    if (self) {
        _elementTypes = elementTypes;
    }
    return self;
}

- (NSData *)encodeObject:(id)object
{
    NSDictionary *dictionary = object;
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    
    for (NSString *key in dictionary.allKeys) {
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        unsigned short keyLength = (unsigned short)keyData.length;
        [mutableData appendBytes:&keyLength length:sizeof(keyLength)];
        [mutableData appendData:keyData];
        
        XBAMPType *ampType = self.elementTypes[key];
        NSData *valueData = [ampType encodeObject:dictionary[key]];
        unsigned short valueLength = (unsigned short)valueData.length;
        [mutableData appendBytes:&valueLength length:sizeof(valueLength)];
        [mutableData appendData:valueData];
    }
    
    return [mutableData copy];
}

- (id)decodeData:(NSData *)data
{
    int i = 0;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    while (i < data.length) {
        unsigned short keyLength = 0;
        [data getBytes:&keyLength range:NSMakeRange(i, sizeof(keyLength))];
        NSData *keyData = [data subdataWithRange:NSMakeRange(i + sizeof(keyLength), keyLength)];
        NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
        i += keyLength + sizeof(keyLength);
        
        unsigned short valueLength = 0;
        [data getBytes:&valueLength range:NSMakeRange(i, sizeof(valueLength))];
        NSData *valueData = [data subdataWithRange:NSMakeRange(i + sizeof(valueLength), valueLength)];
        XBAMPType *ampType = self.elementTypes[key];
        id value = [ampType decodeData:valueData];
        
        dictionary[key] = value;
        i += valueLength + sizeof(valueLength);
    }
    
    return dictionary;
}

@end
