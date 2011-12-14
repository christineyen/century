//
//  RunKeeperViewController.m
//  century
//
//  Created by Christine Yen on 12/13/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RunKeeperViewController.h"
#import "NSDate+TKCategory.h"

@implementation RunKeeperViewController
@synthesize dataDictionary=_dataDictionary;
@synthesize dataArray=_dataArray;

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

- (void)setUpDataFakeMethodName:(NSDate *)start endDate:(NSDate *)end {
    // this function sets up dataArray & dataDictionary
    // dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
    // dataDictionary: has items that are associated with date keys (for tableview)
    
    self.dataArray = [NSMutableArray array];
    self.dataDictionary = [NSMutableDictionary dictionary];
    
    NSDate *date = start;
    while ([date compare:end] != NSOrderedDescending) {
        if (arc4random() % 2 == 0) {
            [self.dataDictionary setObject:[NSArray array] forKey:date];
            [self.dataArray addObject:[NSNumber numberWithBool:YES]];
        } else {
            [self.dataArray addObject:[NSNumber numberWithBool:NO]];
        }
        
        TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
        info.day++;
        date = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
    }
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
    
    return nil;
}


#pragma mark - TKCalendarMonthTableViewController delegate methods

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
    [self setUpDataFakeMethodName:startDate endDate:lastDate];
    
    return self.dataArray;
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date {
    TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *myTimeZoneDay = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
    
    NSLog(@"Date selected: %@", myTimeZoneDay);
    [self.tableView reloadData];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated {
    [super calendarMonthView:monthView monthDidChange:month animated:animated];
    [self.tableView reloadData];
}

@end
