//
//  XBAMPList.h
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPType.h"

/**
 In order to encode and decode arrays of dictionaries (AmpList) the type of each entry must be known. This class stores the AMP type of each
 element in a dictionary that maps element names to AMP types.
 */
@interface XBAMPList : XBAMPType

/**
 Maps element names to XBAMPType instances, that is, it specifies the type of each element of the dictionary this class is able to encode and decode.
 */
@property (nonatomic, readonly) NSDictionary *elementTypes;

/**
 Initializes a XBAMPDictionary with the given element types.
 
 @param elementTypes A dictionary that maps names to XBAMPType instances.
 
 @return An AMP type instance capable of encoding and decoding arrays of dictionaries (AmpList) with the structure specified in elementTypes.
 */
- (id)initWithElementTypes:(NSDictionary *)elementTypes;

@end
