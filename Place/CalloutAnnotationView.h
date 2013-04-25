

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomCalloutProtocols.h"

@interface CalloutAnnotationView : MKAnnotationView 
<CustomAnnotationViewProtocol>
{
	MKAnnotationView *_parentAnnotationView;
	MKMapView *_mapView;
	CGRect _endFrame;
	UIView *_contentView;
	CGFloat _yShadowOffset;
	CGPoint _offsetFromParent;
	CGFloat _contentHeight;
}

@property (nonatomic, retain) MKAnnotationView *parentAnnotationView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *contentView;

- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;
- (void)setAnnotationAndAdjustMap:(id <MKAnnotation>)annotation;
- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
