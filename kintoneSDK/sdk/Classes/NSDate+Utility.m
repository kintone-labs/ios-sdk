//
//  NSDate+Utility.m
//
//  Copyright 2013 Cybozu
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "NSDate+Utility.h"

@implementation NSDate (Utility)

static NSDateFormatter *sRFC3339DateFormatter()
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [NSDateFormatter new];
        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    return formatter;
}

static NSDateFormatter *sDateFormatter()
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [NSDateFormatter new];
        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    return formatter;
}

static NSDateFormatter *sTimeFormatter()
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [NSDateFormatter new];
        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        [formatter setDateFormat:@"HH':'mm"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    return formatter;
}

+ (NSDate *)dateFromRFC3339:(NSString *)rfc3339DateTimeString
{
    // See https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html

    /*
    // If the date formatter hasn't already set up, create and cache it for reuse.
    static NSDateFormatter *sRFC3339DateFormatter = nil;
    if (sRFC3339DateFormatter == nil) {
        sRFC3339DateFormatter = [NSDateFormatter new];
        
        [sRFC3339DateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [sRFC3339DateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
     */
    
    // Convert the RFC 3339 date time string to an NSDate.
    return [sRFC3339DateFormatter() dateFromString:rfc3339DateTimeString];
}

+ (NSString *)rfc3339StringFromDate:(NSDate *)date
{
    return [sRFC3339DateFormatter() stringFromDate:date];
}

+ (NSString *)dateStringFromDate:(NSDate *)date
{
    return [sDateFormatter() stringFromDate:date];
}

+ (NSString *)timeStringFromDate:(NSDate *)date
{
    return [sTimeFormatter() stringFromDate:date];
}

@end
