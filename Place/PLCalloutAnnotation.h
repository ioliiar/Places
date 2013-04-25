
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomCalloutProtocols.h"
#import "PLLocationView.h"
#import "PLCalloutView.h"

@class PLLocationView;

@interface PLCalloutAnnotation : NSObject
<MKAnnotation, CustomAnnotationProtocol>
{
    CLLocationCoordinate2D _coordinate;
    PLCalloutView* calloutView;
}

@property (nonatomic, retain) PLLocationView* parentAnnotationView;
@property (nonatomic, retain) MKMapView* mapView;

- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;

@end
