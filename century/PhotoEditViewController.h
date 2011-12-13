//
//  PhotoEditViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@protocol PhotoEditViewControllerDelegate;

@interface PhotoEditViewController : UIViewController
@property (strong, nonatomic) Photo *photo;
@property (weak, nonatomic) id <PhotoEditViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (UITextField *)nameTextField;
@end

@protocol PhotoEditViewControllerDelegate
- (void)photoEditViewDidSave:(PhotoEditViewController *)editController;
- (void)photoEditviewDidCancel;
@end