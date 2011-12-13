//
//  PhotoListViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"
#import "Photo.h"

#define kPhotoCellIdentifier @"PhotoCell"
#define kPhotoCountCellIdentifier @"PhotoCountCell"
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \
    green:((c>>16)&0xFF)/255.0 \
    blue:((c>>8)&0xFF)/255.0 \
    alpha:((c)&0xFF)/255.0]

@implementation PhotoListViewController
@synthesize person=_person;
@synthesize photoCountLabel=_photoCountLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (BOOL)isLastCell:(NSIndexPath *)indexPath {
    return indexPath.row == [self.person.photos count];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xD5D6D0FF);
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.person != nil) {
        self.title = self.person.name;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.photoCountLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [self.navigationItem setHidesBackButton:editing animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.person.photos count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([self isLastCell:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCountCellIdentifier];
        
        if (!self.photoCountLabel) {
            self.photoCountLabel = (UILabel *)[cell viewWithTag:200];
        }
        self.photoCountLabel.text = [NSString stringWithFormat:@"%d", [self.person.photos count]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCellIdentifier];
        
        Photo *photo = [self.person.photosAsArray objectAtIndex:indexPath.row];
        
        UILabel *textLabel = (UILabel *)[cell viewWithTag:100];
        textLabel.text = photo.name;
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
        imageView.image = [UIImage imageNamed:photo.path];
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![self isLastCell:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Photo *photo = [self.person.photosAsArray objectAtIndex:indexPath.row];
        
        NSManagedObjectContext *context = [[FlickrFetcher sharedInstance] managedObjectContext];
        [context deleteObject:photo];
        [context save:nil];
        
        // Update UI
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        self.photoCountLabel.text = [NSString stringWithFormat:@"%d", [self.person.photos count]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickPhoto"]) {
        PhotoDetailViewController *photoViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        photoViewController.photo = [self.person.photosAsArray objectAtIndex:indexPath.row];
        photoViewController.wantsFullScreenLayout = YES;
    }
}

#pragma mark - PullToRefresh Overrides

- (void)refresh {
    [self stopLoading];
}

@end
