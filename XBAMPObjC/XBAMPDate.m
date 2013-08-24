//
//  XBAMPDate.m
//  XBAMPObjC
//
//  Created by xissburg on 8/24/13.
//  Copyright (c) 2013 xissburg. All rights reserved.
//

#import "XBAMPDate.h"

@implementation XBAMPDate

+ (NSData *)encodeObject:(id)object
{
    NSDate *date = object;
    NSString *string = [[self dateFormatter] stringFromDate:date];
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)decodeData:(NSData *)data
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[self dateFormatter] dateFromString:dataString];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ";
    });
    return formatter;
}

@end
