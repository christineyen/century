//
//  RunKeeperListViewController.h
//  century
//
//  Created by Christine Yen on 12/19/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class RunKeeperTableViewCell;

@interface RunKeeperListViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet RunKeeperTableViewCell *rkCell;
@end
