//
//  RunKeeperLoginViewController.m
//  century
//
//  Created by Christine Yen on 12/15/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "RunKeeperLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "RunKeeperViewController.h"

@implementation RunKeeperLoginViewController
@synthesize mAuth;
@synthesize darkBackgroundView;
@synthesize welcomeImageView;

static NSString *const kRunKeeperKeychainItemName = @"Century: RunKeeper";
static NSString *const kRunKeeperServiceName = @"RunKeeper";
static NSString *const kRunKeeperClientId = @"d60d7a275e884b7c82a43cac15caf2db";

static NSString *const kRunKeeperAccessTokenURL = @"https://runkeeper.com/apps/token";
static NSString *const kRunKeeperAuthorizationURL = @"https://runkeeper.com/apps/authorize";
// Callback doesn't need to be an actual page; it won't be loaded
static NSString *const kRunKeeperCallbackURL = @"http://example.com/OAuthCallback";

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
        [self performSegueWithIdentifier:kRunKeeperAuthenticatedSegue sender:self];
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

#pragma mark - Listeners and Handlers
- (GTMOAuth2Authentication *)authForRunKeeper {
    NSString *clientSecret = @"15f2c8b8f1b24aed9a06481229045731";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kRunKeeperServiceName
                                                             tokenURL:[NSURL URLWithString:kRunKeeperAccessTokenURL]
                                                          redirectURI:kRunKeeperCallbackURL
                                                             clientID:kRunKeeperClientId
                                                         clientSecret:clientSecret];
    return auth;
}

- (IBAction)login:(id)sender {
    if ([self.mAuth canAuthorize]) {
        [self performSegueWithIdentifier:kRunKeeperAuthenticatedSegue sender:self];
        return;
    }
    
    NSString *authorizeStr = [NSString stringWithFormat:@"%@?response_type=code&redirect_uri=%@&client_id=%@",
                              kRunKeeperAuthorizationURL,
                              kRunKeeperCallbackURL,
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
        [self performSegueWithIdentifier:kRunKeeperAuthenticatedSegue sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRunKeeperAuthenticatedSegue]) {
        RunKeeperViewController *runKeeperController = segue.destinationViewController;
        runKeeperController.auth = self.mAuth;
    }
}

@end
