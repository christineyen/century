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

- (BOOL)fetchMorePhotosWithError:(NSError **)error {
    FlickrFetcher *fetcher = [FlickrFetcher sharedInstance];
    
    NSUInteger oldCount = [self.photos count];
    
    // Fetch items from Flickr, within reason
    NSManagedObjectContext *context = [fetcher managedObjectContext];
    
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kFlickrInterestingUrl]];
    NSError *flickrError = nil;
    NSArray *items = [[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&flickrError]
                      objectForKey:@"items"];
    Photo *photo;
    
    for (NSDictionary *photoAttrs in items) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.name = [photoAttrs objectForKey:@"title"];
        photo.person = self;
        
        photo.url = [[[photoAttrs objectForKey:@"media"] objectForKey:@"m"]
                     stringByReplacingOccurrencesOfString:@"_m.jpg" withString:@"_z.jpg"];
    }
    
    [context save:nil];
    
    if (flickrError != nil) {
        *error = flickrError;
        return NO;
    }
    
    NSUInteger diff = [self.photos count] - oldCount;
    NSLog(@"%d photos pulled from Flickr", diff);
    return YES;
}

@end
