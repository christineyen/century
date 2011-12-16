//
//  RunKeeperLoginViewController.m
//  century
//
//  Created by Christine Yen on 12/15/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RunKeeperLoginViewController.h"

@implementation RunKeeperLoginViewController
@synthesize darkBackgroundView;
@synthesize welcomeImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.darkBackgroundView.backgroundColor = [UIColor colorWithPatternImage:
                                               [UIImage imageNamed:@"tiles.png"]];
    self.welcomeImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.welcomeImageView.layer.borderWidth = 7.0;
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
- (IBAction)login:(id)sender {
    
}

@end
