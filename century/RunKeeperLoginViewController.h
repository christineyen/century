//
//  RunKeeperLoginViewController.h
//  century
//
//  Created by Christine Yen on 12/15/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FlickrFetcher, GTMOAuth2Authentication;

@interface RunKeeperLoginViewController : UIViewController
@property (strong, nonatomic) GTMOAuth2Authentication *mAuth;
@property (strong, nonatomic) FlickrFetcher *fetcher;

@property (weak, nonatomic) IBOutlet UIView *darkBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *welcomeImageView;

- (GTMOAuth2Authentication *)authForRunKeeper;
- (void)fetchProfileAndInitializeRunKeeperData;
- (void)fetchAllRunKeeperActivitiesAtURL:(NSString *)fetchURL;
- (void)fetchLatestActivities;

// OAuth callbacks
- (BOOL)runKeeperHandleProfileDataFetch:(NSData *)data withError:(NSError *)error;
- (BOOL)runKeeperHandleActivityFetch:(NSData *)data withError:(NSError *)error;

@end
