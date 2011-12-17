//
//  RunKeeperLoginViewController.m
//  century
//
//  Created by Christine Yen on 12/15/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RunKeeperLoginViewController.h"
#import "RunKeeperViewController.h"
#import "FlickrFetcher.h"
#import "RKActivity.h"

#import <QuartzCore/QuartzCore.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "SVProgressHUD.h"

#define kNilOptions 0

@interface RunKeeperLoginViewController()
@property (strong, nonatomic) NSDictionary *userInfoTemporaryVariable;
@property (strong, nonatomic) NSDictionary *canonicalDataTemporaryVariable;
@end

@implementation RunKeeperLoginViewController
@synthesize mAuth=_mAuth;
@synthesize darkBackgroundView;
@synthesize welcomeImageView;
@synthesize userInfoTemporaryVariable=_userInfoTemporaryVariable;
@synthesize canonicalDataTemporaryVariable=_canonicalDataTemporaryVariable;

static NSString *const kRunKeeperKeychainItemName = @"Century: RunKeeper";
static NSString *const kRunKeeperServiceName = @"RunKeeper";
static NSString *const kRunKeeperClientId = @"d60d7a275e884b7c82a43cac15caf2db";

static NSString *const kRunKeeperAccessTokenURI = @"https://runkeeper.com/apps/token";
static NSString *const kRunKeeperAuthorizationURI = @"https://runkeeper.com/apps/authorize";
// Callback doesn't need to be an actual page; it won't be loaded
static NSString *const kRunKeeperCallbackURI = @"http://example.com/OAuthCallback";
static NSString *const kRunKeeperProfileURI = @"https://api.runkeeper.com/profile";
static NSString *const kRunKeeperActivitiesURI = @"https://api.runkeeper.com/fitnessActivities";

static NSString *const kRunKeeperAuthenticatedSegue = @"RunKeeperAuthenticated";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)awakeFromNib {
    GTMOAuth2Authentication *auth = [self authForRunKeeper];
    if (auth) {
        [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:kRunKeeperKeychainItemName
                                                    authentication:auth];
    }
    self.mAuth = auth;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.darkBackgroundView.backgroundColor = [UIColor colorWithPatternImage:
                                               [UIImage imageNamed:@"tiles.png"]];
    self.welcomeImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.welcomeImageView.layer.borderWidth = 7.0;
    
    if ([self.mAuth canAuthorize]) {
        [self readyToViewRunKeeperView];
    }
}

- (void)viewDidUnload
{
    [self setDarkBackgroundView:nil];
    [self setWelcomeImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - OAuth Listeners and Handlers
- (GTMOAuth2Authentication *)authForRunKeeper {
    NSString *clientSecret = @"15f2c8b8f1b24aed9a06481229045731";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kRunKeeperServiceName
                                                             tokenURL:[NSURL URLWithString:kRunKeeperAccessTokenURI]
                                                          redirectURI:kRunKeeperCallbackURI
                                                             clientID:kRunKeeperClientId
                                                         clientSecret:clientSecret];
    return auth;
}

- (IBAction)login:(id)sender {
    if ([self.mAuth canAuthorize]) {
        return [self readyToViewRunKeeperView];
    }
    
    NSString *authorizeStr = [NSString stringWithFormat:@"%@?response_type=code&redirect_uri=%@&client_id=%@",
                              kRunKeeperAuthorizationURI,
                              kRunKeeperCallbackURI,
                              kRunKeeperClientId];
    
    GTMOAuth2Authentication *auth = [self authForRunKeeper];

    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                 authorizationURL:[NSURL URLWithString:authorizeStr]
                                                                 keychainItemName:kRunKeeperKeychainItemName
                                                                         delegate:self
                                                                 finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [self presentModalViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error) {
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:kGTMHTTPFetcherStatusDataKey];
        if ([responseData length] > 0) {
            NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        self.mAuth = nil;
    } else {
        self.mAuth = auth;
        
        [self dismissModalViewControllerAnimated:YES];
        [self readyToViewRunKeeperView];
    }
}

#pragma mark - Data Fetching helpers

- (BOOL)runKeeperHandleProfileDataFetch:(NSData *)data withError:(NSError *)error {
    // Step 1 of the data fetching process - pull user profile information
    // Return YES to continue into the next phase of data access; NO to indicate we errored out.
    if (error) {
        NSLog(@"Error while fetching profile: %@", [error userInfo]);
        return NO;
    }
    
    NSError *parseError = nil;
    NSDictionary *userObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
    if (parseError) {
        NSLog(@"Error while parsing profile: %@", [error userInfo]);
        return NO;
    }
    
    self.userInfoTemporaryVariable = userObj;
    return YES;
}

- (BOOL)runKeeperHandleActivityFetch:(NSData *)data withError:(NSError *)error {
    // Step 2 of the data fetching process. The user's profile has been passed in,
    // and SVProgressHUD is still being shown.
    if (error) {
        NSLog(@"Error while fetching activities: %@", [error userInfo]);
        return NO;
    }
        
    NSError *parseError = nil;
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
    if (parseError) {
        NSLog(@"Error while parsing activities: %@", [error userInfo]);
        return NO;
    }
    
    NSArray *items = [jsonObj objectForKey:@"items"];
    NSMutableDictionary *activitiesByDate = [NSMutableDictionary dictionaryWithCapacity:[items count]];
    
    NSManagedObjectContext *context = [[FlickrFetcher sharedInstance] managedObjectContext];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    
    RKActivity *activity;
    NSMutableArray *storedActivities;
    
    for (NSDictionary *activityJSON in items) {
        activity = [RKActivity initWithJSON:activityJSON withDateFormatter:dateFormatter inContext:context];
        storedActivities = [activitiesByDate objectForKey:[activity date]];
        if (storedActivities == nil) {
            storedActivities = [NSMutableArray arrayWithObject:activity];
        } else {
            [storedActivities addObject:activity];
        }
        [activitiesByDate setObject:storedActivities forKey:[activity date]];
    }
    
    if (![context save:NULL]) {
        NSLog(@"Error while saving NSManagedObjectContext");
        return NO;
    }
    
    self.canonicalDataTemporaryVariable = activitiesByDate;
    NSLog(@"%d days of RunKeeper data fetched", [activitiesByDate count]);
    return YES;
}

- (void)readyToViewRunKeeperView {
    GTMHTTPFetcher *profileFetcher = [GTMHTTPFetcher fetcherWithURLString:kRunKeeperProfileURI];
    [profileFetcher setAuthorizer:self.mAuth];
    GTMHTTPFetcher *activityFetcher = [GTMHTTPFetcher fetcherWithURLString:kRunKeeperActivitiesURI];
    [activityFetcher setAuthorizer:self.mAuth];
    
    [SVProgressHUD showWithStatus:@"Fetching User Profile..."];
    
    [profileFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (![self runKeeperHandleProfileDataFetch:data withError:error]) {
            [SVProgressHUD dismissWithError:@"Trouble loading user profile."];
            return;
        }
        
        [SVProgressHUD setStatus:@"Fetching Activities..."];
        [activityFetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            if (![self runKeeperHandleActivityFetch:data withError:error]) {
                [SVProgressHUD dismissWithError:@"Trouble loading activities."];
                return;
            }
            
            // Success - now we can segue.
            [SVProgressHUD dismissWithSuccess:@"Hooray!"];
            [self performSegueWithIdentifier:kRunKeeperAuthenticatedSegue sender:self];
        }];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRunKeeperAuthenticatedSegue]) {
        RunKeeperViewController *runKeeperController = segue.destinationViewController;
        runKeeperController.canonicalDataTemporaryVariable = self.canonicalDataTemporaryVariable;
        runKeeperController.nameTemporaryVariable = [self.userInfoTemporaryVariable objectForKey:@"name"];
    }
}

@end
