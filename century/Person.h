//
//  Person.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSOrderedSet *photos;
@end

@interface Person (CoreDataGeneratedAccessors)
+ (NSString *)flickrRecentsName;
+ (Person *)flickrRecentsPerson;

- (BOOL)isFlickrUser;
- (BOOL)fetchMorePhotosWithError:(NSError **)error;
@end
