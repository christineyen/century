//
//  RKActivity.m
//  century
//
//  Created by Christine Yen on 12/14/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RKActivity.h"


@implementation RKActivity

@dynamic startTime;
@dynamic type;
@dynamic distanceInMeters;
@dynamic durationInSeconds;
@dynamic rkURI;
@dynamic fetchedTime;

@synthesize calendar=_calendar;

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
        [_calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return _calendar;
}

- (NSDate *)date {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:self.startTime];
    return [self.calendar dateFromComponents:components];
}

@end
