//
//  Photo.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Person *person;

- (UIImage *)getUIImage;

@end
