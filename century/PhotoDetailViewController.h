//
//  PhotoDetailViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoEditViewController.h"
#import "Photo.h"

@interface PhotoDetailViewController : UIViewController<UIScrollViewDelegate,
        PhotoEditViewControllerDelegate>

@property (nonatomic, strong) Photo *photo;
@end
