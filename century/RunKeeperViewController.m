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
@synthesize monthDataDict=_monthDataDict;
@synthesize monthDataArray=_monthDataArray;
@synthesize databaseFetchTemporaryVariable=_databaseFetchTemporaryVariable;
@synthesize rkCell=_rkCell;

static NSString *const kRunKeeperCellIdentifier = @"RunKeeperTableViewCell";

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
    self.databaseFetchTemporaryVariable = [RKActivity allActivitiesByDate];
    
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kRKActivityUserInfoKey];
    self.title = [NSString stringWithFormat:@"%@'s Activities", [userInfo objectForKey:@"name"]];
    
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
    NSArray *ar = [self.monthDataDict objectForKey:[self.monthView dateSelected]];
    
    if (ar == nil) {
        return 0;
    }
    
    return [ar count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = [self.monthDataDict objectForKey:[self.monthView dateSelected]];
    RKActivity *activity = [arr objectAtIndex:indexPath.row];
    
    RunKeeperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRunKeeperCellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:kRunKeeperCellIdentifier owner:self options:nil];
        cell = self.rkCell;
        self.rkCell = nil;
    }
    
    [cell configureForActivity:activity];
    return cell;
}


#pragma mark - TKCalendarMonthTableViewController delegate methods

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
    // this function sets up dataArray & dataDictionary
    // dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
    // dataDictionary: has items that are associated with date keys (for tableview)
    self.monthDataArray = [NSMutableArray array];
    self.monthDataDict = [NSMutableDictionary dictionary];
    
    // Set up the data in a format that the TKCalendarMonthView can handle
    NSDate *date = startDate;
    NSArray *activities;
    while ([date compare:lastDate] != NSOrderedDescending) {
        activities = [self.databaseFetchTemporaryVariable objectForKey:date];
        if (activities) {
            [self.monthDataDict setObject:activities forKey:date];
            [self.monthDataArray addObject:[NSNumber numberWithBool:YES]];
        } else {
            [self.monthDataArray addObject:[NSNumber numberWithBool:NO]];
        }
        
        TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        info.day++;
        date = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    return self.monthDataArray;
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
