
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol CustomAnnotationProtocol <NSObject>

- (MKAnnotationView*)annotationViewInMap:(MKMapView*) mapView;

@end

@protocol CustomAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;

@end
