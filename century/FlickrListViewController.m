//
//  FlickrListViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "FlickrListViewController.h"

@implementation FlickrListViewController

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
    if (self.person == nil) {
        self.person = [Person flickrRecentsPerson];
    }
    
    if ([self.person.photos count] == 0) {
        [self refresh];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PullToRefresh Overrides

- (void)refresh {
    dispatch_queue_t person_queue = dispatch_queue_create("Fetch Flickr Person", NULL);
    dispatch_async(person_queue, ^{
        if ([self.person fetchMorePhotos] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } // else, no need to refresh
    });
    dispatch_release(person_queue);
    [self stopLoading];
}

- (void)setupStrings {
    textPull = [[NSString alloc] initWithString:@"Pull down to PULL FROM FLICKR..."];
    textRelease = [[NSString alloc] initWithString:@"Release to GET FROM FLICKR..."];
    textLoading = [[NSString alloc] initWithString:@"Loading FROM FLICKR..."];
}

@end
