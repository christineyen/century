//
//  PhotoListViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface PhotoListViewController : UITableViewController
@property (nonatomic, strong) Person *person;

@end
