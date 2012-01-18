//
//  RunKeeperTableViewCell.m
//  century
//
//  Created by Christine Yen on 12/19/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RunKeeperTableViewCell.h"
#import "RKActivity.h"

@implementation RunKeeperTableViewCell
@synthesize rkImageView;
@synthesize mileLabel;
@synthesize durationLabel;
@synthesize timestampLabel;
@synthesize paceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForActivity:(RKActivity *)activity {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY (EEE) @ hh:mma"];
    
    self.rkImageView.image = [UIImage imageNamed:[activity imageName]];
    
    double miles = [activity distanceInMiles];
    if (miles == 0) {
        self.mileLabel.text = activity.type;
    } else {
        self.mileLabel.text = [NSString stringWithFormat:@"%.2f miles", miles];
    }
    self.durationLabel.text = [NSString stringWithFormat:@"for %@", [activity durationInHHmmss]];
    self.timestampLabel.text = [dateFormatter stringFromDate:activity.startTime];
    self.paceLabel.text = [NSString stringWithFormat:@"(%@)", [activity pace]];
}

@end
