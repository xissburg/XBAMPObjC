//
//  XBAMPDictionary.h
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPType.h"

@interface XBAMPDictionary : XBAMPType

@property (nonatomic, readonly) NSDictionary *elementTypes;

- (id)initWithElementTypes:(NSDictionary *)elementTypes;

@end
