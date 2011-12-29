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

- (NSString *)resourcePath {
    if (self.path) {
        return [[NSBundle mainBundle] pathForResource:self.path ofType:@"jpg"];
    }
    return nil;
}

- (UIImage *)getUIImage {
    if (self.path) {
        return [UIImage imageWithContentsOfFile:[self resourcePath]];
    } else if (self.data) {
        return [UIImage imageWithData:self.data];
    }
    return nil;
}

- (void)didTurnIntoFault {
    [super didTurnIntoFault];
    self.data = nil;
}

@end
