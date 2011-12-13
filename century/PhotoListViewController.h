//
//  PhotoListViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "Person.h"

@interface PhotoListViewController : PullRefreshTableViewController
@property (nonatomic, strong) Person *person;
@property (nonatomic, weak) UILabel *photoCountLabel;

- (BOOL)isLastCell:(NSIndexPath *)indexPath;
@end
