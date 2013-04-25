

#import "PLCalloutAnnotation.h"
#import "PLCalloutView.h"

@implementation PLCalloutAnnotation
@synthesize parentAnnotationView, mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;
{
    _coordinate = CLLocationCoordinate2DMake(latitute, longitude);
    return self;
}

- (MKAnnotationView*)annotationViewInMap:(MKMapView *)aMapView;
{
    if(!calloutView) {
        calloutView = [(PLCalloutView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"PLCalloutView"] retain];
        if(!calloutView)
            calloutView = [[PLCalloutView alloc] initWithAnnotation:self];
    } else {
        calloutView.annotation = self;
    }
    calloutView.parentAnnotationView = self.parentAnnotationView;
    
    return calloutView;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
    if(calloutView) {
        [calloutView setAnnotation:self];
    }
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (void)dealloc
{
    [calloutView release];
    [super dealloc];
}

@end
