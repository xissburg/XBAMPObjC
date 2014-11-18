//
//  XBAMPList.m
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPList.h"

@implementation XBAMPList

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
    NSAssert([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]], @"-[XBAMPList encodeObject:] expected a NSDictionary or NSArray.");
    
    NSArray *array = nil;
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        array = @[object];
    }
    else {
        array = object;
    }
    
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    
    for (NSDictionary *dictionary in array) {
        for (NSString *key in dictionary.allKeys) {
            NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            unsigned short keyLength = (unsigned short)keyData.length;
            keyLength = htons(keyLength);
            [mutableData appendBytes:&keyLength length:sizeof(keyLength)];
            [mutableData appendData:keyData];
            
            XBAMPType *ampType = self.elementTypes[key];
            NSData *valueData = [ampType encodeObject:dictionary[key]];
            unsigned short valueLength = (unsigned short)valueData.length;
            valueLength = htons(valueLength);
            [mutableData appendBytes:&valueLength length:sizeof(valueLength)];
            [mutableData appendData:valueData];
        }
        
        unsigned short zero = 0;
        [mutableData appendBytes:&zero length:sizeof(unsigned short)];
    }
    
    return [mutableData copy];
}

- (id)decodeData:(NSData *)data
{
    int i = 0;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    while (i < data.length) {
        unsigned short keyLength = 0;
        [data getBytes:&keyLength range:NSMakeRange(i, sizeof(keyLength))];
        keyLength = ntohs(keyLength);
        
        if (keyLength == 0) {
            if (i + sizeof(keyLength) == data.length) {
                [array addObject:dictionary];
                break;
            }
            else {
                [array addObject:dictionary];
                dictionary = [[NSMutableDictionary alloc] init];
                i += sizeof(keyLength);
                continue;
            }
        }
        
        NSData *keyData = [data subdataWithRange:NSMakeRange(i + sizeof(keyLength), keyLength)];
        NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
        i += keyLength + sizeof(keyLength);
        
        unsigned short valueLength = 0;
        [data getBytes:&valueLength range:NSMakeRange(i, sizeof(valueLength))];
        valueLength = ntohs(valueLength);
        NSData *valueData = [data subdataWithRange:NSMakeRange(i + sizeof(valueLength), valueLength)];
        XBAMPType *ampType = self.elementTypes[key];
        id value = [ampType decodeData:valueData];
        
        dictionary[key] = value;
        i += valueLength + sizeof(valueLength);
    }
    
    return array;
}

@end
