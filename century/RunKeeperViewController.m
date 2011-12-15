//
//  RunKeeperViewController.m
//  century
//
//  Created by Christine Yen on 12/13/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RunKeeperViewController.h"
#import "FlickrFetcher.h"
#import "RKActivity.h"
#import "SVProgressHUD.h"

#import "NSDate+TKCategory.h"

@implementation RunKeeperViewController
@synthesize dataDictionary=_dataDictionary;
@synthesize dataArray=_dataArray;
@synthesize rkCell=_rkCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSDictionary *)fetchRunKeeperData {
    // "Fetch" JSON data from RunKeeper API
    
    NSData *jsonData = [kFakeRunKeeperActivityJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"JSON Parse Error! %@", [error userInfo]);
    }
    
    NSArray *items = [jsonObj objectForKey:@"items"];
    NSMutableDictionary *activitiesByDate = [NSMutableDictionary dictionaryWithCapacity:[items count]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    
    NSManagedObjectContext *context = [[FlickrFetcher sharedInstance] managedObjectContext];
    RKActivity *activity;
    NSMutableArray *storedActivities;
    for (NSDictionary *activityJSON in items) {
        activity = [NSEntityDescription insertNewObjectForEntityForName:@"RKActivity" inManagedObjectContext:context];
        activity.type = [activityJSON objectForKey:@"type"];
        
        activity.startTime = [dateFormatter dateFromString:[activityJSON objectForKey:@"start_time"]];
        activity.distanceInMeters = [activityJSON objectForKey:@"total_distance"];
        activity.durationInSeconds = [activityJSON objectForKey:@"duration"];
        activity.rkURI = [activityJSON objectForKey:@"uri"];
        activity.fetchedTime = [NSDate date];
        
        storedActivities = [activitiesByDate objectForKey:[activity date]];
        if (storedActivities == nil) {
            storedActivities = [NSMutableArray arrayWithObject:activity];
        } else {
            [storedActivities addObject:activity];
        }
        [activitiesByDate setObject:storedActivities forKey:[activity date]];
    }
    if ([context save:NULL]) { // context save == success
        return activitiesByDate;
    }
    
    return nil;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.monthView selectDate:[NSDate month]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewController Data Source / Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *ar = [self.dataDictionary objectForKey:[self.monthView dateSelected]];
    
    if (ar == nil) {
        return 0;
    }
    
    return [ar count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RunKeeperTableViewCell"];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RunKeeperTableViewCell" owner:self options:nil];
        cell = self.rkCell;
        self.rkCell = nil;
    }
    
    return cell;
}


#pragma mark - TKCalendarMonthTableViewController delegate methods

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
    // this function sets up dataArray & dataDictionary
    // dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
    // dataDictionary: has items that are associated with date keys (for tableview)
    
    self.dataArray = [NSMutableArray array];
    self.dataDictionary = [NSMutableDictionary dictionary];
    
    [SVProgressHUD showWithStatus:@"Fetching from RunKeeper..."];
    NSDictionary *activitiesByDate = [self fetchRunKeeperData];
    if (activitiesByDate) {
        NSLog(@"SUCCESS! Got %d RunKeeper days", [activitiesByDate count]);
        [SVProgressHUD dismissWithSuccess:@"SUCCESS!"];
    } else {
        NSLog(@"WAHH FAILED");
        [SVProgressHUD dismissWithError:@"WAHHH FAILED"];
    }
    
    // Set up the data in a format that the TKCalendarMonthView can handle
    NSDate *date = startDate;
    NSArray *activities;
    while ([date compare:lastDate] != NSOrderedDescending) {
        activities = [activitiesByDate objectForKey:date];
        if (activities) {
            [self.dataDictionary setObject:activities forKey:date];
            [self.dataArray addObject:[NSNumber numberWithBool:YES]];
        } else {
            [self.dataArray addObject:[NSNumber numberWithBool:NO]];
        }
        
        TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        info.day++;
        date = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    return self.dataArray;
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date {
    TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone  timeZoneForSecondsFromGMT:0]];
    NSDate *myTimeZoneDay = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSLog(@"Date selected: %@", myTimeZoneDay);
    [self.tableView reloadData];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated {
    [super calendarMonthView:monthView monthDidChange:month animated:animated];
    [self.tableView reloadData];
}

@end
