//
//  PhotoListDataSourceProtocol.h
//  century
//
//  Created by Christine Yen on 12/21/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Photo.h"

@protocol PersonPhotoListDataSource <NSObject>

@required
@property (strong, nonatomic) Person *person;
@property (weak, nonatomic) UILabel *photoCountLabel;

- (Photo *)photoAtIndex:(NSInteger)index;
@end
