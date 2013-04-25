
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomCalloutProtocols.h"
#import "PLCalloutAnnotation.h"

@class PLCalloutAnnotation;

@interface PLLocationView : MKAnnotationView
<CustomAnnotationViewProtocol>
{
    PLCalloutAnnotation* calloutAnnotation;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
