//
//  PhotoDetailViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoEditViewControllerDelegate.h"

@class PhotoEditViewController, Photo;

@interface PhotoDetailViewController : UIViewController<UIScrollViewDelegate,
        PhotoEditViewControllerDelegate>

@property (nonatomic, strong) Photo *photo;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (CGRect)zoomRectWithCenter:(CGPoint) center;
@end
