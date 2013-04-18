//
//  DetailViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "DetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TaggedAnnotation.h"
#import "GoogleStep.h"
#import "RequestDispatcher.h"

@interface DetailViewController ()<UISearchBarDelegate, RequestDispatcherDelegate, MKMapViewDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (retain, nonatomic) UISearchBar *searchBar;
- (void)configureView;
@end

@implementation DetailViewController



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
    [self configureView];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:longPress];
    [longPress release];
    
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
    self.mapView.delegate = self;
    if ([_detailItems count] >= 2) {
        [self drawAllPoints:_detailItems];
    }
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

- (void)configureView {
    for (TaggedAnnotation *ann in _annotations) {
        [self.mapView addAnnotation:ann];
    }
    if (self.detailItems) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

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
        if (((TaggedAnnotation *)[self.mapView.annotations objectAtIndex:i]).tag == k) {
            [self.mapView removeAnnotation:[self.mapView.annotations objectAtIndex:i]];
        }
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

- (void)viewDidUnload {
    self.searchBar = nil;
    self.mapView = nil;
    [super viewDidUnload];
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
            TaggedAnnotation *ann = [[TaggedAnnotation alloc] init];
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
            // TODO add ability to add place from map
        }
        
    }
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
