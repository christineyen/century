//
//  PhotoEditViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoEditViewController.h"
#import "Person.h"

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \
    green:((c>>16)&0xFF)/255.0 \
    blue:((c>>8)&0xFF)/255.0 \
    alpha:((c)&0xFF)/255.0]

@implementation PhotoEditViewController
@synthesize photo=_photo;
@synthesize delegate=_delegate;
@synthesize nameTextField=_nameTextField;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    navBar.tintColor = HEXCOLOR(0x94BA65FF);
    
    scrollView.contentSize = CGSizeMake(320, 400);
    keyboardVisible = NO;
    
    imageView.image = [self.photo getUIImage];
    
    self.nameTextField.text = self.photo.name;
    pathLabel.text = self.photo.path;
    personLabel.text = self.photo.person.name;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    activeField = nil;
    self.nameTextField = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
}

#pragma mark - Listeners / Handlers
- (IBAction)cancel:(id)sender {
    [self.delegate photoEditviewDidCancel];
}

- (IBAction)save:(id)sender {
    [self.delegate photoEditViewDidSave:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSLog(@"keyboard was shown?");
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If the active text field is hidden by keyboard, scroll it so it's visible
    CGRect wholeFrame = scrollView.frame;
    wholeFrame.size.height -= kbSize.height;
    
    if (!CGRectContainsRect(wholeFrame, activeField.frame)) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y + kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}


@end
