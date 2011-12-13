//
//  RandomMapViewController.m
//  century
//
//  Created by Christine Yen on 12/12/11.
//  Copyright (c) 2011 MIT. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RandomMapViewController.h"

#define k4sqAuthToken @"44AIQ2GRI2FXJWKJBJI1S3S0V1MYKBEFYQLB2NCBDGU5D4II&v=20111204"
#define k4sqAPIFormat @"https://api.foursquare.com/v2/venues/search?ll=%f,%f&oauth_token=%@"

// THIS IS A HACK to get around CoreLocation issues and iOS Simulator
// http://stackoverflow.com/questions/802156/testing-corelocation-on-iphone-simulator/3304378
#if TARGET_IPHONE_SIMULATOR
@interface CLLocationManager (Simulator)
@end

@implementation CLLocationManager (Simulator)

-(void)startMonitoringSignificantLocationChanges {
    [self startUpdatingLocation];
}
-(void)startUpdatingLocation {
    CLLocation *homeHome = [[CLLocation alloc] initWithLatitude:37.256443
                                                      longitude:-122.017323];
    [self.delegate locationManager:self
               didUpdateToLocation:homeHome
                      fromLocation:homeHome];
}

@end
#endif // TARGET_IPHONE_SIMULATOR

@interface RandomMapViewController() {
    CLLocationManager *locationManager;
}
@end

@implementation RandomMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setIsLoading:YES];
    // Just delays this heavy work to the next run loop, so the UI appears
    [self performSelector:@selector(initializeLocationManager) withObject:nil afterDelay:0.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    locationManager = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Callbacks and helpers

- (void)initializeLocationManager {
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"fetching annotations for lat: %f, lng: %f",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
    NSArray *annos = [self fetchAnnotationsForLat:newLocation.coordinate.latitude
                                     andLongitude:newLocation.coordinate.longitude];
    
    // Hide spinner & manipulate map
    [self setIsLoading:NO];
    [mapView addAnnotations:annos];
    
    float minLat = 150, minLng = 150, maxLat = -150, maxLng = -150;
    
    for (MKPointAnnotation *anno in annos) {
        if (anno.coordinate.latitude < minLat)
            minLat = anno.coordinate.latitude;
        if (anno.coordinate.latitude > maxLat)
            maxLat = anno.coordinate.latitude;
        if (anno.coordinate.longitude < minLng)
            minLng = anno.coordinate.longitude;
        if (anno.coordinate.longitude > maxLng)
            maxLng = anno.coordinate.longitude;    
    }
    
    MKCoordinateRegion region = mapView.region;
    region.span.latitudeDelta = maxLat - minLat;
    region.span.longitudeDelta = maxLng - minLng;
    CLLocationCoordinate2D center = {
        ((minLat + maxLat) / 2), ((minLng + maxLng) / 2)
    };
    region.center = center;
    
    [mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager errored out!");
}

- (NSArray *)fetchAnnotationsForLat:(double)lat andLongitude:(double)lng {
    NSString *foursquareURL = [NSString stringWithFormat:k4sqAPIFormat, lat, lng, k4sqAuthToken];

    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:foursquareURL]];
    NSArray *items = [[[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil]
                       objectForKey:@"response"] objectForKey:@"venues"];
    NSMutableArray *annos = [[NSMutableArray alloc] init];
    
    // Populate map and zoom as necessary
    for (NSDictionary *venueAttrs in items) {
        NSDictionary *loc = [venueAttrs objectForKey:@"location"];
        CLLocationCoordinate2D venue = {
            [[loc objectForKey:@"lat"] floatValue], [[loc objectForKey:@"lng"] floatValue]
        };
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = venue;
        annotation.title = [venueAttrs objectForKey:@"name"];
        annotation.subtitle = [loc objectForKey:@"address"];
        
        [annos addObject:annotation];
    }
    
    return annos;
}




- (void)setIsLoading:(BOOL)loading {
    
}

@end
