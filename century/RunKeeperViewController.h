//
//  RunKeeperViewController.h
//  century
//
//  Created by Christine Yen on 12/13/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthTableViewController.h"
#import "GTMOAuth2Authentication.h"
#import "FlickrFetcher.h"

#define kFakeRunKeeperActivityJSON @"{ \
    \"size\": 40, \
    \"items\": \
    [ { \"type\": \"Running\", \
    \"start_time\": \"Thu, 1 Dec 2011 07:00:00\", \
    \"total_distance\": 3492.27648, \
    \"duration\": 1437, \
    \"uri\": \"/activities/40\" }, \
    { \"type\": \"Running\", \
    \"start_time\": \"Sat, 3 Dec 2011 07:00:00\", \
    \"total_distance\": 5310.8352, \
    \"duration\": 2278, \
    \"uri\": \"/activities/39\" }, \
    { \"type\": \"Running\", \
    \"start_time\": \"Fri, 9 Dec 2011 11:00:00\", \
    \"total_distance\": 12939.1258, \
    \"duration\": 5043, \
    \"uri\": \"/activities/38\" }, \
    { \"type\": \"Walking\", \
    \"start_time\": \"Fri, 9 Dec 2011 14:00:00\", \
    \"total_distance\": 2939.1258, \
    \"duration\": 3043, \
    \"uri\": \"/activities/37\" }, \
    { \"type\": \"Cycling\", \
    \"start_time\": \"Fri, 9 Dec 2011 07:00:00\", \
    \"total_distance\": 6839.712, \
    \"duration\": 2570, \
    \"uri\": \"/activities/36\" }], \
    \"previous\": \"https://api.runkeeper.com/user/1234567890/activities?page=2&pageSize=4\" \
    }"

@interface RunKeeperViewController : TKCalendarMonthTableViewController<
        TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *monthDataDict;
@property (strong, nonatomic) NSMutableArray *monthDataArray;

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSDictionary *databaseFetchTemporaryVariable;

@property (weak, nonatomic) IBOutlet UITableViewCell *rkCell;
@end
