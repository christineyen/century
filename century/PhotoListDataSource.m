//
//  PhotoListDataSource.m
//  century
//
//  Created by Christine Yen on 12/21/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import "PhotoListDataSource.h"
#import "FlickrFetcher.h"

@implementation PhotoListDataSource
@synthesize person=_person;
@synthesize photoCountLabel=_photoCountLabel;

static NSString *const kPhotoCellIdentifier = @"PhotoCell";
static NSString *const kPhotoCountCellIdentifier = @"PhotoCountCell";

- (BOOL)isLastCell:(NSIndexPath *)indexPath {
    return indexPath.row == [self.person.photos count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.person.photos count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([self isLastCell:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCountCellIdentifier];
        
        if (!self.photoCountLabel) {
            self.photoCountLabel = (UILabel *)[cell viewWithTag:200];
        }
        self.photoCountLabel.text = [NSString stringWithFormat:@"%d", [self.person.photos count]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCellIdentifier];
        
        Photo *photo = [self.person.photosAsArray objectAtIndex:indexPath.row];
        
        UILabel *textLabel = (UILabel *)[cell viewWithTag:100];
        textLabel.text = photo.name;
        
        if (photo.path) {
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageWithContentsOfFile:[photo resourcePath]];
        }
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![self isLastCell:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Photo *photo = [self.person.photosAsArray objectAtIndex:indexPath.row];
        
        NSManagedObjectContext *context = [[FlickrFetcher sharedInstance] managedObjectContext];
        [context deleteObject:photo];
        [context save:nil];
        
        // Update UI
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        self.photoCountLabel.text = [NSString stringWithFormat:@"%d", [self.person.photos count]];
    }
}


- (Photo *)photoAtIndex:(NSInteger)index {
    return [self.person.photosAsArray objectAtIndex:index];
}

- (NSInteger)dataItemCount {
    return [self.person.photos count];
}

- (void)dealloc {
    self.photoCountLabel = nil;
}

@end
