//
//  RunKeeperTableViewCell.h
//  century
//
//  Created by Christine Yen on 12/19/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKActivity;

@interface RunKeeperTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *rkImageView;
@property (weak, nonatomic) IBOutlet UILabel *mileLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;

- (void)configureForActivity:(RKActivity *)activity;
@end
