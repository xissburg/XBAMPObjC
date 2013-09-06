//
//  XBAMPObjC - XBAMPTypeTests.m
//  Copyright 2013 xissburg. All rights reserved.
//
//  Created by: xissburg
//

#import "XBAMPInteger.h"
#import "XBAMPBytes.h"
#import "XBAMPString.h"
#import "XBAMPBoolean.h"
#import "XBAMPFloat.h"
#import "XBAMPDate.h"
#import "XBAMPArray.h"
#import "XBAMPDictionary.h"

#import <GHUnitIOS/GHUnit.h>


@interface XBAMPTypeTests : GHTestCase
@end

@implementation XBAMPTypeTests
{
    // test fixture ivars go here
}

- (void)testIntegerEncoding
{
    NSNumber *number = @(-6);
    XBAMPInteger *ampInteger = [[XBAMPInteger alloc] init];
    
    NSData *data = [ampInteger encodeObject:number];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(string, @"-6", nil);
}

- (void)testIntegerDecoding
{
    NSData *data = [@"2703" dataUsingEncoding:NSUTF8StringEncoding];
    XBAMPInteger *ampInteger = [[XBAMPInteger alloc] init];

    NSNumber *number = [ampInteger decodeData:data];
    
    GHAssertEqualObjects(number, @2703, nil);
}

- (void)testBytesEncoding
{
    unsigned char bytes[] = {0x5a, 0xd5, 0xff, 0xfd, 0xcc};
    NSUInteger length = sizeof(bytes)/sizeof(bytes[0]);
    NSData *data = [NSData dataWithBytes:bytes length:length];
    XBAMPBytes *ampBytes = [[XBAMPBytes alloc] init];
    
    NSData *encodedData = [ampBytes encodeObject:data];
    unsigned char *encodedBytes = (unsigned char *)encodedData.bytes;
    
    GHAssertEquals(length, encodedData.length, nil);
    
    for (int i = 0; i < encodedData.length; ++i) {
        assert(encodedBytes[i] == bytes[i]);
        GHAssertEquals(encodedBytes[i], bytes[i], nil);
    }
}

- (void)testBytesDecoding
{
    NSData *data = [@"xissburg" dataUsingEncoding:NSUTF8StringEncoding];
    XBAMPBytes *ampBytes = [[XBAMPBytes alloc] init];

    NSData *decodedData = [ampBytes decodeData:data];
    
    GHAssertEqualObjects(data, decodedData, nil);
}

- (void)testStringEncoding
{
    NSString *string = @"xissburg";
    XBAMPString *ampString = [[XBAMPString alloc] init];
    NSData *data = [ampString encodeObject:string];
    
    GHAssertEqualObjects(data, [string dataUsingEncoding:NSUTF8StringEncoding], nil);
}

- (void)testStringDecoding
{
    NSString *string = @"xissburg";
    XBAMPString *ampString = [[XBAMPString alloc] init];
    NSString *decodedString = [ampString decodeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    GHAssertEqualStrings(string, decodedString, nil);
}

- (void)testBooleanEncoding
{
    XBAMPBoolean *ampBoolean = [[XBAMPBoolean alloc] init];
    NSData *data = [ampBoolean encodeObject:@YES];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(string, @"True", nil);
    
    data = [ampBoolean encodeObject:@NO];
    
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    GHAssertEqualStrings(string, @"False", nil);
}

- (void)testBooleanDecoding
{
    NSData *data = [@"False" dataUsingEncoding:NSUTF8StringEncoding];
    XBAMPBoolean *ampBoolean = [[XBAMPBoolean alloc] init];
    NSNumber *number = [ampBoolean decodeData:data];
    GHAssertFalse(number.boolValue, nil);
    
    data = [@"True" dataUsingEncoding:NSUTF8StringEncoding];
    number = [ampBoolean decodeData:data];
    GHAssertTrue(number.boolValue, nil);
}

- (void)testFloatEncoding
{
    NSArray *numbers = @[@(-3.141592653589793238462643383279502), @(NAN), @(INFINITY), @(-INFINITY)];
    XBAMPFloat *ampFloat = [[XBAMPFloat alloc] init];
    
    for (NSNumber *number in numbers) {
        NSData *data = [ampFloat encodeObject:number];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        GHAssertEqualStrings(number.description, string, nil);
    }
}

- (void)testFloatDecoding
{
    NSArray *strings = @[@"-3.141592653589793238462643383279502", @"nan", @"inf", @"-inf"];
    XBAMPFloat *ampFloat = [[XBAMPFloat alloc] init];

    for (NSString *string in strings) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSNumber *number = [ampFloat decodeData:data];
        GHAssertEquals(number.doubleValue, string.doubleValue, nil);
    }
}

- (void)testDateEncoding
{
    NSDate *date = [NSDate date];
    XBAMPDate *ampDate = [[XBAMPDate alloc] init];
    NSData *data = [ampDate encodeObject:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ";
    NSString *dateString = [formatter stringFromDate:date];
    
    GHAssertEqualObjects(data, [dateString dataUsingEncoding:NSUTF8StringEncoding], nil);
}

- (void)testDateDecoding
{
    NSString *string = @"2012-01-23T12:34:56.054321-01:23";
    XBAMPDate *ampDate = [[XBAMPDate alloc] init];
    NSDate *date = [ampDate decodeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSZ";
    NSDate *dateFromString = [formatter dateFromString:string];
    
    GHAssertEqualObjects(date, dateFromString, nil);
}

- (void)testArrayEncoding
{
    XBAMPInteger *ampInteger = [[XBAMPInteger alloc] init];
    XBAMPArray *ampArray = [[XBAMPArray alloc] initWithElementType:ampInteger];
    NSArray *array = @[@23, @26, @(-458)];
    
    NSData *data = [ampArray encodeObject:array];
    
    int i = 0;
    for (NSNumber *number in array) {
        NSData *numberData = [ampInteger encodeObject:number];
        unsigned short length = 0;
        [data getBytes:&length range:NSMakeRange(i, sizeof(unsigned short))];
        assert(numberData.length == length);
        NSData *arrayNumberData = [data subdataWithRange:NSMakeRange(i + sizeof(unsigned short), length)];
        GHAssertEqualObjects(numberData, arrayNumberData, nil);
        i += length + sizeof(unsigned short);
    }
}

- (void)testArrayDecoding
{
    unsigned char bytes[] = {0x02, 0x00, 0x32, 0x33, 0x02, 0x00, 0x32, 0x36, 0x04, 0x00, 0x2d, 0x34, 0x35, 0x38};
    NSData *data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)/sizeof(unsigned char)];
    
    XBAMPInteger *ampInteger = [[XBAMPInteger alloc] init];
    XBAMPArray *ampArray = [[XBAMPArray alloc] initWithElementType:ampInteger];
    NSArray *array = [ampArray decodeData:data];
    NSArray *anotherArray = @[@23, @26, @(-458)];
    
    GHAssertEqualObjects(array, anotherArray, nil);
}

- (void)testDictionaryEncoding
{
    NSDictionary *dictionary = @{@"name": @"Nilson Souto", @"nick": @"xissburg", @"age": @26, @"antichrist": @YES};
    XBAMPDictionary *ampDictionary = [[XBAMPDictionary alloc] initWithElementTypes:@{@"name": [[XBAMPString alloc] init], @"nick": [[XBAMPString alloc] init], @"age": [[XBAMPInteger alloc] init], @"antichrist": [[XBAMPBoolean alloc] init]}];
    NSData *data = [ampDictionary encodeObject:dictionary];
    
    int i = 0;
    while (i < data.length) {
        unsigned short length = 0;
        [data getBytes:&length range:NSMakeRange(i, sizeof(length))];
        NSData *keyData = [data subdataWithRange:NSMakeRange(i + sizeof(length), length)];
        NSString *key = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
        GHAssertNotNil(dictionary[key], nil);
        i += length + sizeof(length);
        
        [data getBytes:&length range:NSMakeRange(i, sizeof(length))];
        NSData *valueData = [data subdataWithRange:NSMakeRange(i + sizeof(length), length)];
        XBAMPType *ampType = ampDictionary.elementTypes[key];
        id value = [ampType decodeData:valueData];
        GHAssertEqualObjects(value, dictionary[key], nil);
        i += length + sizeof(length);
    }
}

- (void)testDictionaryDecoding
{
    unsigned char bytes[] = {0x04, 0x00, 0x6e, 0x61, 0x6d, 0x65, 0x0c, 0x00, 0x4e, 0x69, 0x6c, 0x73, 0x6f, 0x6e, 0x20, 0x53, 0x6f, 0x75, 0x74, 0x6f, 0x03, 0x00, 0x61, 0x67, 0x65, 0x02, 0x00, 0x32, 0x36, 0x0a, 0x00, 0x61, 0x6e, 0x74, 0x69, 0x63, 0x68, 0x72, 0x69, 0x73, 0x74, 0x04, 0x00, 0x54, 0x72, 0x75, 0x65, 0x04, 0x00, 0x6e, 0x69, 0x63, 0x6b, 0x08, 0x00, 0x78, 0x69, 0x73, 0x73, 0x62, 0x75, 0x72, 0x67};
    NSData *data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)/sizeof(unsigned char)];
    
    XBAMPDictionary *ampDictionary = [[XBAMPDictionary alloc] initWithElementTypes:@{@"name": [[XBAMPString alloc] init], @"nick": [[XBAMPString alloc] init], @"age": [[XBAMPInteger alloc] init], @"antichrist": [[XBAMPBoolean alloc] init]}];
    NSDictionary *dictionary = [ampDictionary decodeData:data];
    NSDictionary *anotherDictionary = @{@"name": @"Nilson Souto", @"nick": @"xissburg", @"age": @26, @"antichrist": @YES};
    
    GHAssertEqualObjects(dictionary, anotherDictionary, nil);
}

@end
