//
//  XBAMPArray.h
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPType.h"

/**
 An AMP array, also known as 'ListOf'.
 */
@interface XBAMPArray : XBAMPType

/**
 The AMP type of the elements of the array this class is capable of encoding and decoding.
 */
@property (nonatomic, readonly) XBAMPType *elementType;

/**
 AMP arrays have a fixed element type, which must be specified in this designated initializer.
 
 @param elementType The AMP type of the elements.
 
 @return An AMP type instance capable of encoding and decoding AMP arrays (listOf) containing elements of the specified AMP type.
 */
- (id)initWithElementType:(XBAMPType *)elementType;

@end
