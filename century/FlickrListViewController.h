//
//  FlickrListViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoListDataSource.h"

@interface FlickrListViewController : UIViewController<UITableViewDelegate> {
    // from PullToRefresh
    BOOL isDragging;
    BOOL isLoading;
}

@property (nonatomic, strong) IBOutlet PhotoListDataSource *dataSource;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)refreshClicked:(id)sender;

// PullToRefresh members
#define REFRESH_HEADER_HEIGHT 52.0f

@property (strong, nonatomic) UIView *refreshHeaderView;
@property (strong, nonatomic) UILabel *refreshLabel;
@property (strong, nonatomic) UIImageView *refreshArrow;
@property (strong, nonatomic) UIActivityIndicatorView *refreshSpinner;

- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)refresh;
@end
