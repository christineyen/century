//
//  FlickrListViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "FlickrListViewController.h"
#import "PhotoDetailViewController.h"
#import "PhotoListDataSource.h"
#import "SVProgressHUD.h"

@implementation FlickrListViewController
@synthesize dataSource = _dataSource;
@synthesize tableView=_tableView;

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

- (id<UITableViewDataSource,PersonPhotoListDataSource>)dataSource {
    if (!_dataSource) {
        self.dataSource = [[PhotoListDataSource alloc] init];
    }
    return _dataSource;
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xD5D6D0FF);
    
    if (self.dataSource.person == nil) {
        self.dataSource.person = [Person flickrRecentsPerson];
    }
    
    if ([self.dataSource.person.photos count] == 0) {
        [self refresh:nil];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidUnload
{
    [self setDataSource:nil];
    [super viewDidUnload];
    self.dataSource = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)refresh:(id)sender {
    [SVProgressHUD show];
    
    dispatch_queue_t person_queue = dispatch_queue_create("Fetch Flickr Person", NULL);
    dispatch_async(person_queue, ^{
        NSError *error;
        if ([self.dataSource.person fetchMorePhotosWithError:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:[[error userInfo] objectForKey:@"NSDebugDescription"]];
            });
        }
    });
    dispatch_release(person_queue);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickPhoto"]) {
        PhotoDetailViewController *photoViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        photoViewController.photo = [self.dataSource photoAtIndex:indexPath.row];
        photoViewController.wantsFullScreenLayout = YES;
    }
}

@end
