//
//  PhotoListDataSource.h
//  century
//
//  Created by Christine Yen on 12/21/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoListDataSourceProtocol.h"

@interface PhotoListDataSource : NSObject <UITableViewDataSource,PersonPhotoListDataSource>
@end
