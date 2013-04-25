
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomCalloutProtocols.h"
#import "PLLocationView.h"

@interface PLLocationAnnotation : NSObject
<MKAnnotation, CustomAnnotationProtocol>
{
    CLLocationCoordinate2D _coordinate;
    PLLocationView* locationView;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) MKMapView* mapView;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (id) initWithLat:(CGFloat)latitute lon:(CGFloat)longitude;

@end
