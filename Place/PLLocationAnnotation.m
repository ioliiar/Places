
#import "PLLocationAnnotation.h"

@implementation PLLocationAnnotation
@synthesize coordinate, mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;
{
    _coordinate = CLLocationCoordinate2DMake(latitute, longitude);
    return self;
}

- (MKAnnotationView*)annotationViewInMap:(MKMapView*) aMapView;
{
    if(!locationView) {
        locationView = [(PLLocationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"PLLocationView"] retain];
        if(!locationView)
            locationView = [[PLLocationView alloc] initWithAnnotation:self];
    } else {
        locationView.annotation = self;
    }
    
    return locationView;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    NSLog(@"\nOld: %f %f New: %f %f", _coordinate.latitude, _coordinate.longitude, newCoordinate.latitude, newCoordinate.longitude);
    _coordinate = newCoordinate;
    [self.mapView addAnnotation:self];
    if(locationView) {
        [locationView setAnnotation:self];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}



- (void)dealloc {
    [_title release];
    [_subtitle release];
    [super dealloc];
    [locationView release];
    [super dealloc];
}


@end
