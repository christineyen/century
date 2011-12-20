//
//  RKActivity.m
//  century
//
//  Created by Christine Yen on 12/14/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RKActivity.h"
#import "FlickrFetcher.h"

#define kMetersPerMile 1609.344
#define kHour 3600.0
#define kMinute 60.0

@implementation RKActivity

@dynamic startTime;
@dynamic type;
@dynamic distanceInMeters;
@dynamic durationInSeconds;
@dynamic rkURI;
@dynamic fetchedTime;

static NSString *const kRKTypeRunningIcon = @"icon-running.png";
static NSString *const kRKTypeWalkingIcon = @"icon-walking.png";
static NSString *const kRKTypeCyclingIcon = @"icon-cycling.png";
static NSString *const kRKTypeEllipticalIcon = @"icon-elliptical.png";
static NSString *const kRKTypeOtherIcon = @"icon-other.png";

@synthesize calendar=_calendar;

+ (RKActivity *)initWithJSON:(NSDictionary *)activityJSON
           withDateFormatter:(NSDateFormatter *)dateFormatter
                   inContext:(NSManagedObjectContext *)context {
    RKActivity *activity = [NSEntityDescription insertNewObjectForEntityForName:@"RKActivity" inManagedObjectContext:context];
    activity.type = [activityJSON objectForKey:@"type"];
    
    activity.startTime = [dateFormatter dateFromString:[activityJSON objectForKey:@"start_time"]];
    activity.distanceInMeters = [activityJSON objectForKey:@"total_distance"];
    activity.durationInSeconds = [activityJSON objectForKey:@"duration"];
    activity.rkURI = [activityJSON objectForKey:@"uri"];
    activity.fetchedTime = [NSDate date];
    return activity;
}

+ (NSDictionary *)allActivitiesByDate {
    NSMutableDictionary *activitiesByDate = [NSMutableDictionary dictionary];
    NSMutableArray *storedActivities;
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    NSArray *activities = [[FlickrFetcher sharedInstance] fetchManagedObjectsForEntity:@"RKActivity"
                                                                         withPredicate:nil
                                                                             withLimit:0
                                                                   withSortDescriptors:[NSArray arrayWithObject:descriptor]];
    for (RKActivity *activity in activities) {
        storedActivities = [activitiesByDate objectForKey:[activity date]];
        if (storedActivities) {
            [storedActivities addObject:activity];
        } else {
            storedActivities = [NSMutableArray arrayWithObject:activity];
        }
        [activitiesByDate setObject:storedActivities forKey:[activity date]];
    }
    
    NSLog(@"%d days of RunKeeper data fetched", [activitiesByDate count]);
    return activitiesByDate;
}

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

- (NSString *)imageName {
    if ([self.type isEqualToString:@"Running"]) {
        return kRKTypeRunningIcon;
    } else if ([self.type isEqualToString:@"Cycling"]) {
        return kRKTypeCyclingIcon;
    } else if ([self.type isEqualToString:@"Walking"]) {
        return kRKTypeWalkingIcon;
    } else if ([self.type isEqualToString:@"Elliptical"]) {
        return kRKTypeEllipticalIcon;
    }
    return kRKTypeOtherIcon;
}
- (double)distanceInMiles {
    return [self.distanceInMeters doubleValue] / kMetersPerMile;
}

- (NSString *)durationInHHmmss {
    int seconds = [self.durationInSeconds intValue];
    
    int hours = seconds / kHour;
    seconds -= hours * kHour;
    
    int minutes = seconds / kMinute;
    seconds -= minutes * kMinute;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (NSString *)pace {
    double minutes = [self.durationInSeconds intValue] / kMinute;
    double miles = [self distanceInMiles];
    if (miles == 0) {
        return @" N/A ";
    }
    int pace = (minutes / miles);
    int remainderSeconds = ((minutes / miles) - pace) * kMinute;
    
    return [NSString stringWithFormat:@"%d:%02d min/mi", pace, remainderSeconds];
}

- (NSString *)monthName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM yyyy"];
    return [dateFormatter stringFromDate:self.startTime];
}

@end
