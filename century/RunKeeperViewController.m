//
//  RunKeeperViewController.m
//  century
//
//  Created by Christine Yen on 12/13/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RunKeeperViewController.h"
#import "RKActivity.h"
#import "SVProgressHUD.h"

#import "GTMHTTPFetcher.h"
#import "NSDate+TKCategory.h"

@implementation RunKeeperViewController
@synthesize dataDictionary=_dataDictionary;
@synthesize dataArray=_dataArray;
@synthesize userInfo=_userInfo;
@synthesize databaseFetchTemporaryVariable=_databaseFetchTemporaryVariable;

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
    
    NSMutableDictionary *activitiesByDate = [NSMutableDictionary dictionary];
    NSMutableArray *storedActivities;
    
    NSArray *activities = [[FlickrFetcher sharedInstance] fetchManagedObjectsForEntity:@"RKActivity" withPredicate:nil];
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
    self.databaseFetchTemporaryVariable = activitiesByDate;
    
    [self.monthView selectDate:[NSDate month]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.databaseFetchTemporaryVariable = nil;
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
    NSArray *arr = [self.dataDictionary objectForKey:[self.monthView dateSelected]];
    RKActivity *activity = [arr objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RunKeeperTableViewCell"];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RunKeeperTableViewCell" owner:self options:nil];
        cell = self.rkCell;
        self.rkCell = nil;
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:500];
    UILabel *mileLabel = (UILabel *)[cell viewWithTag:501];
    UILabel *durationLabel = (UILabel *)[cell viewWithTag:502];
    UILabel *timestampLabel = (UILabel *)[cell viewWithTag:503];
    UILabel *paceLabel = (UILabel *)[cell viewWithTag:504];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY (EEE) @ hh:mma"];
    
    imageView.image = [UIImage imageNamed:[activity imageName]];
    mileLabel.text = [NSString stringWithFormat:@"%.2f miles", [activity distanceInMiles]];
    durationLabel.text = [NSString stringWithFormat:@"for %@", [activity durationInHHmmss]];
    timestampLabel.text = [dateFormatter stringFromDate:activity.startTime];
    paceLabel.text = [NSString stringWithFormat:@"(%@)", [activity pace]];
    
    return cell;
}


#pragma mark - TKCalendarMonthTableViewController delegate methods

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
    // this function sets up dataArray & dataDictionary
    // dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
    // dataDictionary: has items that are associated with date keys (for tableview)
    self.dataArray = [NSMutableArray array];
    self.dataDictionary = [NSMutableDictionary dictionary];
    
    // Set up the data in a format that the TKCalendarMonthView can handle
    NSDate *date = startDate;
    NSArray *activities;
    while ([date compare:lastDate] != NSOrderedDescending) {
        activities = [self.databaseFetchTemporaryVariable objectForKey:date];
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
