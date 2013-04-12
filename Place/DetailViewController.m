//
//  DetailViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "DetailViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController {
    BOOL receivedTouch;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_annotations release];
    [_detailItems release];
    [_masterPopoverController release];
    [_mapView release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSArray*)newDetailItem{
    if (_detailItems != newDetailItem) {
        [_detailItems release];
        _detailItems = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    for (MKPointAnnotation *ann in _annotations) {
        [self.mapView addAnnotation:ann];
    }

    if (self.detailItems) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

- (void)updateMap:(NSNotification *)notification {
    self.annotations = [notification.userInfo objectForKey:kAnnotation];
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    [self.mapView removeAnnotations:pins];
    [pins release];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LOC_MAP;
        self.mode = PlaceModeSurvey;
    }
    return self;
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
    if (!receivedTouch) {
        receivedTouch = YES;
        sender.enabled = NO;
        if (_mode == PlaceModeChoose) {
            int i = [self.mapView.annotations count];
            if (i > 8) {
                return;
            }
            CGPoint p = [sender locationInView:self.view];
            CLLocationCoordinate2D cor = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            ann.coordinate = cor;
            ann.title = @"waypoint";
      
            [self.mapView addAnnotation:ann];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlaceChosen
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObject:ann forKey:kAnnotation]];
            [ann release];
        } else {
            // TODO add ability to add place from map
        }
        
    } else {
        receivedTouch = NO;
        sender.enabled = YES;
    }
}

@end
