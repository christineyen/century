//
//  FlickrFetcher.m
//  Flickr2
//
//  Created by Alan Cannistraro on 11/20/09.
//  Copyright 2009 Apple. All rights reserved.
//

#import "FlickrFetcher.h"

@interface FlickrFetcher ()

@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

@end

@implementation FlickrFetcher

+ (id)sharedInstance
{
	static id master = nil;
	
	@synchronized(self)
	{
		if (master == nil)
			master = [self new];
	}
    
    return master;
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName
                                                    withPredicate:(NSPredicate*)predicate {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [self fetchedResultsControllerForEntity:entityName
                                     withPredicate:predicate
                                         withLimit:0
                               withSortDescriptors:[NSArray arrayWithObject:sortDescriptor]
                            withSectionNameKeyPath:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName
                                                    withPredicate:(NSPredicate*)predicate
                                                        withLimit:(NSUInteger)limit
                                              withSortDescriptors:(NSArray *)sortDescriptors {
    return [self fetchedResultsControllerForEntity:entityName
                                     withPredicate:predicate
                                         withLimit:limit
                               withSortDescriptors:sortDescriptors
                            withSectionNameKeyPath:nil];
}


- (NSFetchedResultsController *)fetchedResultsControllerForEntity:(NSString*)entityName
                                                    withPredicate:(NSPredicate*)predicate
                                                        withLimit:(NSUInteger)limit
                                              withSortDescriptors:(NSArray *)sortDescriptors
                                           withSectionNameKeyPath:(NSString *)sectionNameKeyPath {
    NSFetchedResultsController *fetchedResultsController;
    /*
	 Set up the fetched results controller.
     */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // Add a predicate if we're filtering by user name
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:[self managedObjectContext]
                                                                     sectionNameKeyPath:sectionNameKeyPath
                                                                              cacheName:@"Root"];
	
	return fetchedResultsController;
}

- (NSManagedObject *)fetchFirstManagedObjectForEntity:(NSString *)entityName
                                  withSortDescriptors:(NSArray *)sortDescriptors {
    return [[self fetchManagedObjectsForEntity:entityName
                                 withPredicate:nil
                                     withLimit:1
                           withSortDescriptors:sortDescriptors] lastObject];
}

- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    return [self fetchManagedObjectsForEntity:entityName
                                withPredicate:predicate
                                    withLimit:0
                          withSortDescriptors:nil];
}

- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName
                            withPredicate:(NSPredicate*)predicate
                                withLimit:(NSUInteger)limit
                      withSortDescriptors:(NSArray *)sortDescriptors {
	NSManagedObjectContext	*context = [self managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	
	NSFetchRequest	*request = [[NSFetchRequest alloc] init];
	request.entity = entity;
	request.predicate = predicate;
    request.fetchLimit = limit;
    request.sortDescriptors = sortDescriptors;
	
	NSArray	*results = [context executeFetchRequest:request error:nil];
	
	return results;
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"People" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSString *)databasePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"temp.sqlite"];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString	*path = [self databasePath];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
    return persistentStoreCoordinator;
}

- (BOOL)databaseExists
{
	NSString	*path = [self databasePath];
	BOOL		databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	
	return databaseExists;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
