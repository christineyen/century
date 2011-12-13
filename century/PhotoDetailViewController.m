//
//  PhotoDetailViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotoEditViewController.h"

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
    
    UIImage *uiImg = [self.photo getUIImage];
    if (uiImg != nil) {
        self.imageView.image = uiImg;
    } else if (self.photo.url != nil) {
        NSLog(@"need progress hud...");
        
        dispatch_queue_t bg_queue = dispatch_queue_create("Fetch Photo via URL", NULL);
        dispatch_async(bg_queue, ^{
            self.photo.data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photo.url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithData:self.photo.data];
                NSLog(@"here's where i'd hide the progress hud");
            });
        });
        dispatch_release(bg_queue);
    }
    
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.maximumZoomScale = 10.0;
    self.scrollView.contentSize = CGSizeMake(320, 460);
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.photo.name;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
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


@end
