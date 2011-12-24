//
//  CenturyAppDelegate.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "CenturyAppDelegate.h"
#import "FlickrFetcher.h"

#import "CenturyTabBarController.h"
#import "PersonListViewController.h"
#import "FlickrListViewController.h"
#import "RandomMapViewController.h"

#import "Photo.h"
#import "Person.h"


@interface CenturyAppDelegate() {
    FlickrFetcher *fetcher;
}
@end

@implementation CenturyAppDelegate

@synthesize window = _window;

- (int)loadDatabaseWithDefaults {
    fetcher = [FlickrFetcher sharedInstance];
    if (![fetcher databaseExists]) {
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Photos" ofType:@"plist"];
        NSArray *db = [[NSArray alloc] initWithContentsOfFile:thePath];
        
        NSMutableDictionary *namePersonDict = [[NSMutableDictionary alloc] init];
        Person *person;
        NSString *personName;
        
        NSManagedObjectContext *context = [fetcher managedObjectContext];
        Photo *photoObj;
        
        for (NSDictionary *photo in db) {
            photoObj = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photoObj.name = [photo objectForKey:@"name"];
            photoObj.path = [[photo objectForKey:@"path"] stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
            personName = [photo objectForKey:@"user"];
            
            person = [namePersonDict objectForKey:personName];
            if (person == nil) {
                person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
                person.name = personName;
                
                [namePersonDict setObject:person forKey:personName];
            }
            photoObj.person = person;
        }
        
        if (![context save:NULL]) {
            NSLog(@"FAILED TO SAVE!!");
        }
        
        return [db count];
    }
    return 0;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int loaded = [self loadDatabaseWithDefaults];
    NSLog(@"Read and loaded %d rows from the .plist", loaded);
    
    UITabBarController *tabBarController = (CenturyTabBarController *)self.window.rootViewController;
    
    UINavigationController *peopleNavController = (UINavigationController *)[[tabBarController viewControllers]
                                                                             objectAtIndex:0];
    peopleNavController.navigationBar.tintColor = HEXCOLOR(0x94BA65FF);
    UINavigationController *recentsNavController = (UINavigationController *)[[tabBarController viewControllers]
                                                                              objectAtIndex:1];
    recentsNavController.navigationBar.tintColor = HEXCOLOR(0x94BA65FF);
    UINavigationController *runKeeperNavController = (UINavigationController *)[[tabBarController viewControllers]
                                                                                lastObject];
    runKeeperNavController.navigationBar.tintColor = HEXCOLOR(0x94BA65FF);
    
    // Set up Contacts tab
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name != %@", [Person flickrRecentsName]];
	PersonListViewController *personListController = [[peopleNavController viewControllers] objectAtIndex:0];
    personListController.fetchedResultsController = [fetcher fetchedResultsControllerForEntity:@"Person"
                                                                                 withPredicate:pred];
    personListController.fetcher = fetcher;
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
