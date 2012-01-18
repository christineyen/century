//
//  PhotoEditViewControllerDelegate.h
//  century
//
//  Created by Christine Yen on 1/18/12.
//  Copyright (c) 2012 MIT. All rights reserved.
//

@class PhotoEditViewController;

@protocol PhotoEditViewControllerDelegate
- (void)photoEditViewDidSave:(PhotoEditViewController *)editController;
- (void)photoEditviewDidCancel;
@end
