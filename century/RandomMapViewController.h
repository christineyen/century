//
//  RandomMapViewController.h
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RandomMapViewController : UIViewController<CLLocationManagerDelegate> {
    IBOutlet MKMapView *mapView;
}

- (NSArray *)fetchAnnotationsForLat:(double)lat andLongitude:(double)lng;
- (void)setIsLoading:(BOOL)loading;

@end
