//
//  XBAMPType.h
//  XBAMPObjC
//
//  Created by xissburg on 8/23/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The XBAMPType class allows you to encode and decode objects to be used with AMP. You can encode an object and obtain a NSData instance to 
 be sent over the wire and you can also decode a NSData instance and obtain the object back.
 */
@interface XBAMPType : NSObject

+ (instancetype)type;

/**
 Encodes an object of the expected type into an NSData instance whose bytes can be inserted in an AMP packet.
 
 @param object The object to be encoded.
 
 @return The data that represents the encoded object
 */
- (NSData *)encodeObject:(id)object;

/**
 Decodes the data of a value from an AMP packet into an object of the expected type.
 
 @param data The data to be decoded.
 
 @return The decoded object.
 */
- (id)decodeData:(NSData *)data;

@end
