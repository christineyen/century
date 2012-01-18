//
//  RunKeeperViewController.h
//  century
//
//  Created by Christine Yen on 12/13/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TKCalendarMonthTableViewController.h"

@class RunKeeperTableViewCell;

@interface RunKeeperViewController : TKCalendarMonthTableViewController<
        TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *monthDataDict;
@property (strong, nonatomic) NSMutableArray *monthDataArray;

@property (strong, nonatomic) NSDictionary *databaseFetchTemporaryVariable;

@property (weak, nonatomic) IBOutlet RunKeeperTableViewCell *rkCell;
@end
