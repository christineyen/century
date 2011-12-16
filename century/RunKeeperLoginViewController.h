//
//  RunKeeperLoginViewController.h
//  century
//
//  Created by Christine Yen on 12/15/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"

@interface RunKeeperLoginViewController : UIViewController
@property (strong, nonatomic) GTMOAuth2Authentication *mAuth;
@property (weak, nonatomic) IBOutlet UIView *darkBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *welcomeImageView;

@end
