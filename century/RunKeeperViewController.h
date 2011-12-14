//
//  RunKeeperViewController.h
//  century
//
//  Created by Christine Yen on 12/13/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthTableViewController.h"

@interface RunKeeperViewController : TKCalendarMonthTableViewController<
        TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource>

@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) NSMutableArray *dataArray;

- (void)setUpDataFakeMethodName:(NSDate *)start endDate:(NSDate *)end;
@end
