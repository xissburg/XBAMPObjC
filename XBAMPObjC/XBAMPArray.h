//
//  XBAMPArray.h
//  XBAMPObjC
//
//  Created by xissburg on 8/25/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPType.h"

@interface XBAMPArray : XBAMPType

@property (nonatomic, readonly) XBAMPType *elementType;

- (id)initWithElementType:(XBAMPType *)elementType;

@end
