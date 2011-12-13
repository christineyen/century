//
//  PersonListViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FlickrFetcher.h"

@interface PersonListViewController : UITableViewController<UITableViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, strong) FlickrFetcher *fetcher;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
