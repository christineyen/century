//
//  Photo.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "Photo.h"
#import "Person.h"


@implementation Photo

@dynamic data;
@dynamic path;
@dynamic url;
@dynamic name;
@dynamic person;

- (UIImage *)getUIImage {
    if (self.path != nil) {
        return [UIImage imageNamed:self.path];
    } else if (self.data != nil) {
        return [UIImage imageWithData:self.data];
    }
    return nil;
}

@end
