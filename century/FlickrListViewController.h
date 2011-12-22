//
//  FlickrListViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoListDataSource.h"

@interface FlickrListViewController : UIViewController<UITableViewDelegate>

@property (nonatomic, strong) IBOutlet PhotoListDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)refresh:(id)sender;
@end
