//
//  XBAMPType.h
//  XBAMPObjC
//
//  Created by xissburg on 8/23/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBAMPType : NSObject

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
