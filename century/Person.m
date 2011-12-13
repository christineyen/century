//
//  Person.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "Person.h"
#import "Photo.h"
#import "FlickrFetcher.h"

#define kFlickrInterestingUrl @"http://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"

@implementation Person

@dynamic name;
@dynamic photos;

+ (NSString *)flickrRecentsName {
    return @"Flickr Users";
}

+ (Person *)flickrRecentsPerson {
    FlickrFetcher *fetcher = [FlickrFetcher sharedInstance];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", [self flickrRecentsName]];
    NSArray *flickrResults = [fetcher fetchManagedObjectsForEntity:@"Person" withPredicate:pred];
    
    // Set up root Person
    Person *person;
    if ([flickrResults count] > 0) {
        person = [flickrResults objectAtIndex:0];
    } else {
        NSManagedObjectContext *context = [fetcher managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person"
                                                  inManagedObjectContext:context];
        person = [[Person alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        person.name = [self flickrRecentsName];
    }
    return person;
}

- (BOOL)isFlickrUser {
    return [self.name isEqualToString:Person.flickrRecentsName];
}

- (int)fetchMorePhotos {
    FlickrFetcher *fetcher = [FlickrFetcher sharedInstance];
    
    NSUInteger oldCount = [self.photos count];
    
    // Fetch items from Flickr, within reason
    NSManagedObjectContext *context = [fetcher managedObjectContext];
    
    // TODO: actually handle errors more gracefully, somewhere
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kFlickrInterestingUrl]];
    NSError *error = nil;
    NSArray *items = [[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error]
                      objectForKey:@"items"];
    
    
    
    // check me!.
    
    
    
    Photo *photo;
    NSString *flickrUrl;
    
    for (NSDictionary *photoAttrs in items) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.name = [photoAttrs objectForKey:@"title"];
        photo.person = self;
        
        flickrUrl = [[photoAttrs objectForKey:@"media"] objectForKey:@"m"];
        photo.url = [flickrUrl stringByReplacingOccurrencesOfString:@"_m.jpg" withString:@"_z.jpg"];
    }
    
    [context save:nil];
    
    NSUInteger diff = [self.photos count] - oldCount;
    if (diff == 0) {
        NSLog(@"ERROR SUSPECTED: %@, %@", error, [error userInfo]);
        return 0;
    } 
    
    NSLog(@"%d photos pulled from Flickr", diff);
    return diff;
}


- (NSArray *)photosAsArray {
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [[self.photos allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
}


@end
