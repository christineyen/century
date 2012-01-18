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
@synthesize emptyView=_emptyView;
@synthesize refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;

static NSString *const kPullToRefreshPull = @"Pull down to PULL FROM FLICKR...";
static NSString *const kPullToRefreshRelease = @"Release to GET FROM FLICKR...";
static NSString *const kPullToRefreshLoading = @"Loading FROM FLICKR...";

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
    [self addPullToRefreshHeader];
    self.view.backgroundColor = HEXCOLOR(0xD5D6D0FF);
    self.tableView.accessibilityLabel = ACC_PhotoList;
    self.title = @"Flickr Users";
    
    if (self.dataSource.person == nil) {
        self.dataSource.person = [Person flickrRecentsPerson];
    }
    
    if ([self.dataSource.person.photos count] == 0) {
        [self refresh];
        [self reloadTableOrEmptyView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTableOrEmptyView];
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

- (void)refresh {
    [SVProgressHUD show];
    
    dispatch_queue_t person_queue = dispatch_queue_create("Fetch Flickr Person", NULL);
    dispatch_async(person_queue, ^{
        NSError *error;
        if ([self.dataSource.person fetchMorePhotosWithError:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableOrEmptyView];
                [SVProgressHUD dismiss];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:[[error userInfo] objectForKey:@"NSDebugDescription"]];
            });
        }
    });
    dispatch_release(person_queue);
    [self stopLoading];
}

- (void)reloadTableOrEmptyView {
    [self.tableView reloadData];
    BOOL hasData = [self.dataSource dataItemCount] > 0;
    
    self.emptyView.hidden = hasData;
    self.tableView.hidden = !hasData;
}

- (IBAction)refreshClicked:(id)sender {
    [self refresh];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickPhoto"]) {
        PhotoDetailViewController *photoViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        photoViewController.photo = [self.dataSource photoAtIndex:indexPath.row];
        photoViewController.wantsFullScreenLayout = YES;
    }
}

#pragma mark - PullToRefresh logic, (c) 2010 Leah Culver

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = kPullToRefreshRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel.text = kPullToRefreshPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = kPullToRefreshLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = kPullToRefreshPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

@end
