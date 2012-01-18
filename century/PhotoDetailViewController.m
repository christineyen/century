//
//  PhotoDetailViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotoEditViewController.h"
#import "SVProgressHUD.h"
#import "Photo.h"

@implementation PhotoDetailViewController
@synthesize photo=_photo;
@synthesize imageView=_imageView;
@synthesize scrollView=_scrollView;

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

- (void)toggleNavigationBar:(BOOL)hidden {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    [UIView commitAnimations];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *uiImg = [self.photo getUIImage];
    if (uiImg != nil) {
        self.imageView.image = uiImg;
    } else if (self.photo.url != nil) {
        [SVProgressHUD showWithStatus:@"Snatching..." networkIndicator:YES];
        
        dispatch_queue_t bg_queue = dispatch_queue_create("Fetch Photo via URL", NULL);
        dispatch_async(bg_queue, ^{
            self.photo.data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photo.url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:self.photo.data];
                [SVProgressHUD dismiss];
            });
        });
        dispatch_release(bg_queue);
    }
    
    // Set up ScrollView
    self.scrollView.delegate = self;
    
    // Handle gestures
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    // Single taps are only recognized if a double tap definitely doesn't occur
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    
    self.imageView.accessibilityLabel = ACC_PhotoDetailImageView;
    self.navigationItem.rightBarButtonItem.accessibilityLabel = ACC_PhotoDetailEditButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.photo.name;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    for (UIGestureRecognizer *recognizer in [self.imageView gestureRecognizers]) {
        [self.imageView removeGestureRecognizer:recognizer];
    }
    self.photo.data = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPhoto"]) {
        PhotoEditViewController *editController = segue.destinationViewController;
        editController.photo = self.photo;
        editController.delegate = self;
    }
}

#pragma mark - UIScrollViewDelegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - PhotoEditViewControllerDelegate methods
- (void)photoEditViewDidSave:(PhotoEditViewController *)editController {
    UITextField *nameField = [editController nameTextField];
    self.photo.name = nameField.text;
    [[self.photo managedObjectContext] save:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditviewDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITapGesture Handlers
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    BOOL hidden = !self.navigationController.navigationBarHidden;
    [self toggleNavigationBar:hidden];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    float zoomScale = [self.scrollView zoomScale];
    if (zoomScale != 1.0) {
        [self.scrollView zoomToRect:[self.scrollView frame] animated:YES];
    } else {
        CGRect zoomRect = [self zoomRectWithCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

#pragma mark - Utility methods
- (CGRect)zoomRectWithCenter:(CGPoint) center {
    CGRect zoomRect;
    
    // the zoom rect is within the content view's coordinates.
    //   as the zoom scale increases beyond the default 1.0, less content is visible /
    //   / the size of the zoom rect shrinks.
    zoomRect.size.height = [self.scrollView frame].size.height / 2.0;
    zoomRect.size.width = [self.scrollView frame].size.width / 2.0;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
