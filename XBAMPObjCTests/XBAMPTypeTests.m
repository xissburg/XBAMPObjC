//
//  XBAMPObjC - XBAMPTypeTests.m
//  Copyright 2013 xissburg. All rights reserved.
//
//  Created by: xissburg
//

    // Class under test
#import "XBAMPInteger.h"
#import "XBAMPBytes.h"
#import "XBAMPString.h"
#import "XBAMPBoolean.h"
#import "XBAMPFloat.h"
#import "XBAMPDate.h"

    // Collaborators

    // Test support
#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>


@interface XBAMPTypeTests : SenTestCase
@end

@implementation XBAMPTypeTests
{
    // test fixture ivars go here
}

- (void)testIntegerEncoding
{
    NSNumber *number = @(-6);
    
    NSData *data = [XBAMPInteger encodeObject:number];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    assertThat(string, is(equalTo(@"-6")));
}

- (void)testIntegerDecoding
{
    NSData *data = [@"2703" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSNumber *number = [XBAMPInteger decodeData:data];
    
    assertThat(number, is(equalTo(@2703)));
}

- (void)testBytesEncoding
{
    unsigned char bytes[] = {0x5a, 0xd5, 0xff, 0xfd, 0xcc};
    NSUInteger length = sizeof(bytes)/sizeof(bytes[0]);
    NSData *data = [NSData dataWithBytes:bytes length:length];
    
    NSData *encodedData = [XBAMPBytes encodeObject:data];
    unsigned char *encodedBytes = (unsigned char *)encodedData.bytes;
    
    assert(length == encodedData.length);
    
    for (int i = 0; i < encodedData.length; ++i) {
        assert(encodedBytes[i] == bytes[i]);
    }
}

- (void)testBytesDecoding
{
    NSData *data = [@"xissburg" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *decodedData = [XBAMPBytes decodeData:data];
    
    assertThat(data, is(equalTo(decodedData)));
}

- (void)testStringEncoding
{
    NSString *string = @"xissburg";
    NSData *data = [XBAMPString encodeObject:string];
    
    assertThat(data, is(equalTo([string dataUsingEncoding:NSUTF8StringEncoding])));
}

- (void)testStringDecoding
{
    NSString *string = @"xissburg";
    NSString *decodedString = [XBAMPString decodeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    assertThat(string, is(equalTo(decodedString)));
}

- (void)testBooleanEncoding
{
    NSData *data = [XBAMPBoolean encodeObject:@YES];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    assertThat(string, is(equalTo(@"True")));
    
    data = [XBAMPBoolean encodeObject:@NO];
    
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    assertThat(string, is(equalTo(@"False")));
}

- (void)testBooleanDecoding
{
    NSData *data = [@"False" dataUsingEncoding:NSUTF8StringEncoding];
    NSNumber *number = [XBAMPBoolean decodeData:data];
    assert(number.boolValue == NO);
    
    data = [@"True" dataUsingEncoding:NSUTF8StringEncoding];
    number = [XBAMPBoolean decodeData:data];
    assert(number.boolValue == YES);
}

- (void)testFloatEncoding
{
    NSArray *numbers = @[@(-3.141592653589793238462643383279502), @(NAN), @(INFINITY), @(-INFINITY)];
    
    for (NSNumber *number in numbers) {
        NSData *data = [XBAMPFloat encodeObject:number];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        assertThat([number description], is(equalTo(string)));
    }
}

- (void)testFloatDecoding
{
    NSArray *strings = @[@"-3.141592653589793238462643383279502", @"nan", @"inf", @"-inf"];
    
    for (NSString *string in strings) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSNumber *number = [XBAMPFloat decodeData:data];
        assert(number.doubleValue == string.doubleValue);
    }
}

- (void)testDateEncoding
{
    NSDate *date = [NSDate date];
    NSData *data = [XBAMPDate encodeObject:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ";
    NSString *dateString = [formatter stringFromDate:date];
    
    assertThat(data, is(equalTo([dateString dataUsingEncoding:NSUTF8StringEncoding])));
}

- (void)testDateDecoding
{
    NSString *string = @"2012-01-23T12:34:56.054321-01:23";
    
    NSDate *date = [XBAMPDate decodeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSZ";
    NSDate *dateFromString = [formatter dateFromString:string];
    
    assertThat(date, is(equalTo(dateFromString)));
}

@end
