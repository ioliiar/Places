

#import "PLLocationView.h"

@implementation PLLocationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"PLLocationView"]))
        return nil;
    
    self.canShowCallout = NO;
    self.image = [UIImage imageNamed:@"map_marker.png"];
    self.centerOffset = CGPointMake(10, -16);
    self.draggable = YES;
    
    return self;
}

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{
    
    calloutAnnotation = [[PLCalloutAnnotation alloc] initWithLat:self.annotation.coordinate.latitude lon:self.annotation.coordinate.longitude];
    
    calloutAnnotation.parentAnnotationView = self;
    [mapView addAnnotation:calloutAnnotation];
    
    [calloutAnnotation release];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    [mapView removeAnnotation:calloutAnnotation];
    calloutAnnotation = nil;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    if(calloutAnnotation) {
        [calloutAnnotation setCoordinate:annotation.coordinate];
    }
    
    [super setAnnotation:annotation];
}

@end
