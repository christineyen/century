//
//  RKActivity.h
//  century
//
//  Created by Christine Yen on 12/14/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kRKActivityUserInfoKey @"RKActivity User Info Key"

@interface RKActivity : NSManagedObject

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDecimalNumber *distanceInMeters;
@property (nonatomic, retain) NSNumber *durationInSeconds;
@property (nonatomic, retain) NSString *rkURI;
@property (nonatomic, retain) NSDate *fetchedTime;

@property (nonatomic, retain) NSCalendar *calendar;

+ (RKActivity *)initWithJSON:(NSDictionary *)activityJSON
           withDateFormatter:(NSDateFormatter *)dateFormatter
                   inContext:(NSManagedObjectContext *)context;

+ (NSDictionary *)allActivitiesByDate;

- (NSDate *)date;
- (NSString *)imageName;
- (double)distanceInMiles;
- (NSString *)durationInHHmmss;
- (NSString *)pace;

- (NSString *)monthName;
@end
