//
//  DetailViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "PlaceViewController.h"
#import "RouteViewController.h"

#import "TaggedAnnotation.h"
#import "IOGhostPickerView.h"

#import "RouteEntity.h"
#import "RequestDispatcher.h"
#import "DBHandler.h"

#import <CoreLocation/CLLocationManagerDelegate.h>
#import "CustomCalloutProtocols.h"
#import "PLCalloutView.h"
#import "PLLocationAnnotation.h"

@interface DetailViewController ()<UISearchBarDelegate, RequestDispatcherDelegate, MKMapViewDelegate, IOGhostPickerDataSource, IOGhostPickerDelegate, PlaceViewControllerDelegate>
@property (retain, nonatomic) UIPopoverController *masterPopoverController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) IOGhostPickerView *pickerView;
@property (retain, nonatomic) UILongPressGestureRecognizer *longPress;
@property (retain, nonatomic) PLLocationAnnotation* locationAnnotation;
@end

@implementation DetailViewController {
    CLLocationCoordinate2D tapCoord;
}

@synthesize locationAnnotation;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LOC_MAP;
        self.mode = PlaceModeSurvey;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_longPress release];
    [_pickerView release];
    [_searchBar release];
    [_annotations release];
    [_detailItems release];
    [_masterPopoverController release];
    [_mapView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar = [[[UISearchBar alloc] init] autorelease];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, 0, 550, 44);
    _searchBar.placeholder = @"External Search";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _searchBar.placeholder = @"External";
    }
    
    self.navigationItem.titleView = self.searchBar;
    
    self.longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(handleLongPress:)] autorelease];
    self.longPress.minimumPressDuration = 0.5;
    self.longPress.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.longPress];
    
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:LOC_CLEAR
                                                              style:UIBarButtonItemStylePlain                                                                           target:self
                                                             action:@selector(clearMap)];
    self.navigationItem.rightBarButtonItem = clear;
    [clear release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMap:)
                                                 name:kUpdateMap
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawRoute:)
                                                 name:kRoutePoints
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeFromMap:)
                                                 name:kRouteFromMap
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newAnnotation:)
                                                 name:kAddDBAnnot
                                               object:nil];
    
    
   // [self configureView];
    self.mapView.delegate = self;
    if ([_detailItems count] >= 2) {
        for (id<MKOverlay> overlayToRemove in self.mapView.overlays) {
            [self.mapView removeOverlay:overlayToRemove];
        }
        [self drawAllPoints:_detailItems];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_mode == PlaceModeSurvey) {
        [self clearMap];
    } else
    [self configureView];
}

- (void)viewDidUnload {
    self.masterPopoverController = nil;
    self.mapView = nil;
    self.searchBar = nil;
    self.pickerView = nil;
    [super viewDidUnload];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSArray*)newDetailItem{
    if (_detailItems != newDetailItem) {
        [_detailItems release];
        _detailItems = [newDetailItem retain];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)drawRoute:(NSNotification *)notification {
    NSArray *encPoiints = [notification.userInfo objectForKey:kDirection];
    for (id<MKOverlay> overlayToRemove in self.mapView.overlays) {
        [self.mapView removeOverlay:overlayToRemove];
    }

    [self drawAllPoints:encPoiints];
}

- (void)drawAllPoints:(NSArray *)points {
    int k = [points count];
    CLLocationCoordinate2D *locs = malloc(k * sizeof(CLLocationCoordinate2D));
    
    for (int j = 0; j < k; j++) {
        CLLocation *lc = [points objectAtIndex:j];
        locs[j].latitude = lc.coordinate.latitude;
        locs[j].longitude = lc.coordinate.longitude;
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:locs count:k];
    [self.mapView addOverlay:polyline];
    self.mapView.visibleMapRect = polyline.boundingMapRect;
    free(locs);
    
}

- (void)routeFromMap:(NSNotification *)notification {
    NSArray *places = [notification.userInfo objectForKey:kRouteFromMap];
    int k = [places count];
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:k];
    for (int j = 0; j < k; j++) {
        PlaceEntity *pl = [places objectAtIndex:j];
        CLLocationCoordinate2D cor;
        cor.latitude = pl.latitude;
        cor.longitude = pl.longtitude;
        
        PLLocationAnnotation *ann = [[PLLocationAnnotation alloc] initWithLat:cor.latitude lon:cor.longitude];
        ann.title = pl.name;
        ann.tag = j;
        [arr addObject:ann];
        [ann release];
    }
    NSArray *array = [arr copy];
    self.annotations = [NSArray arrayWithArray:array];
    [array release];
    [self configureView];
}

- (void)newAnnotation:(NSNotification *)notification {
    PlaceEntity *pl = [notification.userInfo objectForKey:kAddDBAnnot];
    
    PLLocationAnnotation *ann = [[PLLocationAnnotation alloc] initWithLat:pl.latitude lon:pl.longtitude];
    ann.title = pl.name;
    ann.tag = pl.tag;
    ann.mapView = self.mapView;
    [self.mapView addAnnotation:ann];
    [ann release];
    
}

- (void)configureView {
    for (PLLocationAnnotation *ann in _annotations) {
        [self.mapView addAnnotation:ann];
    }
//    if (self.detailItems) {
//        //self.detailDescriptionLabel.text = [self.detailItem description];
//    }
}

#pragma mark mapView delegate methods

/*- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if(annotationView)
        return annotationView;
    else
    {
        MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                         reuseIdentifier:AnnotationIdentifier] autorelease];
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"DrawingPin1"];
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
       // [rightButton addTarget:self action:@selector(doSomething:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = rightButton;
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}*/

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 3.0;
    
    return [polylineView autorelease];
}

- (void)updateMap:(NSNotification *)notification {
    int k = [[notification.userInfo objectForKey:kAnnotation] integerValue];
    for (int i = 0; i < [self.mapView.annotations count]; i++) {
        id userLocation = [self.mapView userLocation];
        if (![[self.mapView.annotations objectAtIndex:i] isEqual:userLocation]) {
        if (((PLLocationAnnotation *)[self.mapView.annotations objectAtIndex:i]).tag == k) {
            [self.mapView removeAnnotation:[self.mapView.annotations objectAtIndex:i]];
        }
    }
    }
}

- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view {
    if([view conformsToProtocol:@protocol(CustomAnnotationViewProtocol)]) {
        [((NSObject<CustomAnnotationViewProtocol>*)view) didSelectAnnotationViewInMap:self.mapView];
    }
}

- (void)mapView:(MKMapView *)aMapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if([view conformsToProtocol:@protocol(CustomAnnotationViewProtocol)]) {
        [((NSObject<CustomAnnotationViewProtocol>*)view) didDeselectAnnotationViewInMap:self.mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation conformsToProtocol:@protocol(CustomAnnotationProtocol)]) {
        
        
        return [((NSObject<CustomAnnotationProtocol>*)annotation) annotationViewInMap:self.mapView];
        
        
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV;
    
    for (aV in views) {
        
        if (![aV isKindOfClass:[PLCalloutView class]]) {
            CGRect endFrame = aV.frame;
            
            aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y-230.0, aV.frame.size.width, aV.frame.size.height);
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.45];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [aV setFrame:endFrame];
            [UIView commitAnimations];
        }
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = LOC_MENU;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (void)clearMap {
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    [self.mapView removeAnnotations:pins];
    [pins release];
    
    for (id<MKOverlay> overlayToRemove in self.mapView.overlays) {
        [self.mapView removeOverlay:overlayToRemove];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearMap
                                                        object:nil
                                                      userInfo:nil];
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        static int counter = 0;
        if (_mode == PlaceModeChoose) {
            int i = [self.mapView.annotations count];
            if (i > 8) {
                return;
            }
            CGPoint p = [sender locationInView:self.view];
            CLLocationCoordinate2D cor = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
            PLLocationAnnotation *ann = [[PLLocationAnnotation alloc] initWithLat:cor.latitude lon:cor.longitude];
            ann.coordinate = cor;
            ann.title = @"waypoint";
            ann.tag = counter;
            counter++;
            [self.mapView addAnnotation:ann];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlaceChosen
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObject:ann forKey:kAnnotation]];
            [ann release];
        } else {
            CGPoint point = [sender locationInView:self.view];
            tapCoord = [self.mapView convertPoint:point toCoordinateFromView:self.view];
            CGFloat circleHalfSize = kGhostPickerRadius+ kGhostPickerLineWidth + kGhostPickerImageSize + allowableOversight/2;
            CGRect frameRect = CGRectMake(point.x-circleHalfSize, point.y-circleHalfSize, 2 * circleHalfSize, 2 * circleHalfSize);
            self.pickerView = nil;
            self.pickerView = [[[IOGhostPickerView alloc] initWithFrame:frameRect] autorelease];
            [sender removeTarget:self action:@selector(longPressRecognized:)];
            [sender addTarget:_pickerView action:@selector(methodForPressRecognizer:)];
            _pickerView.dataSource = self;
            _pickerView.delegate = self;
            [self.view addSubview:_pickerView];
            [_pickerView displayMenuAnimated:YES];
        }
        
    }
}


- (void)placeVC:(PlaceViewController *)placeVC didDismissedInMode:(PlaceMode)mode {
    if (mode != PlaceModeSurvey) {
        return;
    }
    DBHandler *dbHandler = [[DBHandler alloc] init];
    BOOL success;
    if (placeVC.place.Id) {
        success = [dbHandler updatePlace:placeVC.place];
        
    } else {
        success = [dbHandler insertPlace:placeVC.place];
    }
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_ERROR
                                                        message:LOC_TRY_LTR
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
    [dbHandler release];
}

#pragma mark place processing methods

- (void)processPlaceComponent:(NSInteger)component tapCoordinate:(CLLocationCoordinate2D)coordinate {
    switch (component) {
        case 0:{
            PlaceViewController *place = [[PlaceViewController alloc] init];
            place.mode = PlaceModeSurvey;
            place.delegate = self;
            [self.navigationController pushViewController:place animated:YES];
            [place release];
        } break;
            
        case 1:{
            PlaceViewController *place = [[PlaceViewController alloc] init];
            place.mode = PlaceModeSurvey;
            place.delegate = self;
            place.place.latitude = coordinate.latitude;
            place.place.longtitude = coordinate.longitude;
            [self.navigationController pushViewController:place animated:YES];
            [place release];
        } break;
            
        default:
            NSLog(@"Unknown component %i", component);
            break;
    }
}

- (void)processRouteComponent:(NSInteger)component startPoint:(CLLocationCoordinate2D)coordinate {
    switch (component) {
        case 0: {
            RouteViewController *route = [[RouteViewController alloc] init];
            [self.navigationController pushViewController:route animated:YES];
            [route release];
        }
            break;
        case 1: {
            RouteViewController *route = [[RouteViewController alloc] init];
            PlaceEntity *pl = [[PlaceEntity alloc] init];
            pl.name = LOC_WAYPOINT;
            pl.latitude = coordinate.latitude;
            pl.longtitude = coordinate.longitude;
            [route.route.places addObject:pl];
            [pl release];
            [self.navigationController pushViewController:route animated:YES];
            [route release];
        }
            break;
        default:
            NSLog(@"Unknown component %i", component);
            break;
    }
    
}

#pragma mark imageMaking methods

- (UIImage *)imageForPlaceComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [UIImage imageNamed:@"schedule"];
        case 1:
            return [UIImage imageNamed:@"earth"];
        default:
            NSLog(@"Unknown component %i", component);
            break;
    }
    return nil;
}

- (UIImage *)imageForRouteComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [UIImage imageNamed:@"schedule.png"];
        case 1:
            return [UIImage imageNamed:@"earth.png"];
        default:
            NSLog(@"Unknown component %i", component);
            break;
    }
    return nil;
}


#pragma mark IOGhostPickerDelegate method

- (void)IOGhostPicker:(IOGhostPickerView*)ghostPicker
   didChooseComponent:(NSInteger)component
          inDirection:(NSInteger)direction {
    
    switch (direction) {
        case 0:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                [self.delegate processPlaceComponent:component tapCoordinate:tapCoord];
            } else {
                [self processPlaceComponent:component tapCoordinate:tapCoord];
            }
            break;
        case 1:
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                [self.delegate processRouteComponent:component startPoint:tapCoord];
            } else {
                [self processRouteComponent:component startPoint:tapCoord];
            }
            break;
        default:
            NSLog(@"Unknown direction");
            break;
    }
    [self.longPress removeTarget:_pickerView action:@selector(methodForPressRecognizer:)];
    [self.longPress addTarget:self action:@selector(handleLongPress:)];
    self.longPress.minimumPressDuration = 0.5f;
    [ghostPicker removeFromSuperview];
}

- (void)IOGhostPicker:(IOGhostPickerView *)ghostPicker cancelledChoosingInDirection:(NSInteger)direction {
    [self.longPress removeTarget:_pickerView action:@selector(methodForPressRecognizer:)];
    [self.longPress addTarget:self action:@selector(handleLongPress:)];
    self.longPress.minimumPressDuration = 0.5f;
    [ghostPicker removeFromSuperview];
}

- (void)IOGhostPicker:(IOGhostPickerView *)ghostPicker
 highlightedComponent:(NSInteger)component
          inDirection:(NSInteger)direction
                 view:(UIView*)view {
    
}


#pragma mark IOGhostPickerDataSource methods

- (NSUInteger)numberOfDirectionInGhostPicker {
    return 2;
}

- (NSUInteger)numberOfComponentsInDirection:(NSInteger)direction {
    switch (direction) {
        case 0:
            return 2;
        case 1:
            return 2;
        default:
            NSLog(@"unknown component");
            break;
    }
    return 0;
}

- (UIView*)viewForGhostPickerDirection:(NSInteger)direction {
    UIImageView *iv = [[UIImageView alloc] init];
    
    switch (direction) {
        case 0://add place
            iv.image = [UIImage imageNamed:@"DrawingPin"];
            break;
        case 1:// add route
            iv.image = [UIImage imageNamed:@"direction"];
            break;
        default:
            NSLog(@"Unknown direction");
            break;
    }
    
    return [iv autorelease];
}

- (UIView*)viewForComponent:(NSInteger)component inDirection:(NSInteger)direction {
    UIImageView *iv = [[UIImageView alloc] init];
    switch (direction) {
        case 0:
            iv.image  = [self imageForPlaceComponent:component];
            break;
        case 1:
            iv.image  = [self imageForRouteComponent:component];
            break;
        default:
            NSLog(@"Unknown component in direction %i",direction);
            break;
    }
    return [iv autorelease];
}

#pragma mark searchBar delegate methods

- (void)filterRegion:(NSString *)word {
    if ([word isEqualToString:@""]) {
        return;
    }
    RequestDispatcher *dispatcher = [[RequestDispatcher alloc] init];
    dispatcher.delegate = self;
    [dispatcher requestPlacemarkNamed:word];
    [dispatcher release];
}

- (void)request:(RequestDispatcher *)request didFinishedWithResponse:(Response *)response {
    if(response.code == ResponseCodeError) {
        NSError *error = [response.responseInfo objectForKey:kError];
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    CLLocation *loc =[response.responseInfo objectForKey:kLocation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 50000.0, 50000.0);
    [self.mapView setRegion:region animated:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self filterRegion:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}


@end
