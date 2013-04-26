//
//  RouteViewController.m
//  Place
//
//  Created by Iurii Oliiar on 4/1/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "RouteViewController.h"
#import "PlaceViewController.h"
#import "DetailViewController.h"

#import "TaggedAnnotation.h"
#import "TableAlertView.h"

#import "DBHandler.h"
#import "RouteEntity.h"
#import <CoreLocation/CLLocation.h>
#import "RequestDispatcher.h"

@interface RouteViewController ()<TableAlertViewDelegate, UIAlertViewDelegate, RequestDispatcherDelegate>

@property (nonatomic, retain) NSArray *dbList;

@end

@implementation RouteViewController {
    BOOL saved;
}

@synthesize route;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 320.0);
        self.title = LOC_ROUTE;
        self.route = [[[RouteEntity alloc] init] autorelease];
        self.route.places = [NSMutableArray arrayWithCapacity:8];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.editing = YES;
    saved = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedAnnotaion:)
                                                 name:kPlaceChosen
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMapClear:)
                                                 name:kClearMap
                                               object:nil];
    
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addPlace:)];
    
    self.navigationItem.rightBarButtonItem = bar;
    [bar release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRouteFromMap
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self.route.places forKey:kRouteFromMap]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.tableView = nil;
    [self setSaveBtn:nil];
    [self setDoneBtn:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [route release];
    [_dbList release];
    [_tableView release];
    [_saveBtn release];
    [_doneBtn release];
    [super dealloc];
}

#pragma mark TableAlertView delegate method and show list methods

- (void)showDBList {
    dispatch_queue_t queue = dispatch_queue_create("Start", nil);
    dispatch_async(queue, ^ {
        DBHandler *dbHandler = [DBHandler sharedDBHandler];
        self.dbList = [dbHandler getAllPlaces];
        
        dispatch_sync(dispatch_get_main_queue(), ^ {
            TableAlertView  *alert = [[TableAlertView alloc] initWithCaller:self
                                                                        data:self.dbList
                                                                       title:@"Choose Place"
                                                                  andContext:nil] ;
            [alert show];
            [alert release];

        });
    });
    
}

- (void)showListOnMap {
    DetailViewController *mapVC = [[DetailViewController alloc] init];
    mapVC.mode = PlaceModeChoose;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (PlaceEntity *pl in self.route.places) {
        TaggedAnnotation *ann = [[TaggedAnnotation alloc] init];
        ann.title = pl.name;
        CLLocationCoordinate2D loc;
        loc.longitude = pl.longtitude;
        loc.latitude = pl.latitude;
        [ann setCoordinate:loc];
        [arr addObject:ann];
        [ann release];
    }
    mapVC.annotations = arr;
    [arr release];
    [self.navigationController pushViewController:mapVC animated:YES];
    [mapVC release];

}

-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context{
    if(row >= 0){
        PlaceEntity *pl = [self.dbList objectAtIndex:row];
        pl.tag  = [self.route.places count];
        if (pl.latitude != 0.0 && pl.longtitude != 0.0) {
        [self.route.places addObject:pl];
        saved = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddDBAnnot
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:pl forKey:kAddDBAnnot]];
        [self.tableView reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"There are no location for this point"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    // else "Selection cancelled";
}

#pragma mark BarButton Actions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    if (alertView.tag  == AlertTagsName) {
        if (![[alertView textFieldAtIndex:0].text isEqualToString:self.route.name]) {
            self.route.name = [alertView textFieldAtIndex:0].text;
            saved = NO;
        }
        if (saved || [self.route.places count] < 2) {
            return;
        }
        if (![[DBHandler sharedDBHandler] saveRoute:self.route.places named:self.route.name]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_ERROR
                                                            message:LOC_TRY_LTR
                                                           delegate:nil
                                                  cancelButtonTitle:LOC_OK
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            saved = NO;
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
            saved = YES;
        }
        
    } else {
        switch (buttonIndex) {
            case 0:
                // cancelled
                break;
            case 1:
                [self showListOnMap];
                break;
            case 2:
                [self showDBList];
                break;
            default:
                NSLog(@"Unknown button index");
                break;
        }
    }
}

#pragma mark Map  methods

- (void)addPlace:(UIBarButtonItem *)sender {
    if ([self.route.places count] == 8)
        return;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_PLACES
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:LOC_CANCEL
                                              otherButtonTitles:@"From Map",@"Local place",nil];
        alert.tag = AlertTagsNone;
        [alert show];
        [alert release];
        
    } else {
        [self showDBList];
        
    }
}

- (void)onMapClear:(NSNotification *)notification {
    [self.route.places removeAllObjects];
    [self.tableView reloadData];
}

- (void)receivedAnnotaion:(NSNotification *)notification {
    saved = NO;
    TaggedAnnotation *ann = [notification.userInfo objectForKey:kAnnotation];
    PlaceEntity *pl = [[PlaceEntity alloc] init];
    pl.name = LOC_WAYPOINT;
    pl.comment = @"From Map";
    pl.longtitude = ann.coordinate.longitude;
    pl.latitude = ann.coordinate.latitude;
    pl.tag = ann.tag;
    [self.route.places addObject:pl];
    [pl release];
    [self.tableView reloadData];
}

#pragma actions implementations

- (IBAction)saveAction:(UIBarButtonItem *)sender {
    if (saved || [self.route.places count] < 2) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_PLACES
                                                    message:@"Route Name"
                                                   delegate:self
                                          cancelButtonTitle:LOC_CANCEL
                                          otherButtonTitles:LOC_OK ,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = AlertTagsName;
    [alert show];
    [alert release];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
    NSLog(@"done");
    if ([self.route.places count] > 1) {
        RequestDispatcher *dispatcher = [[RequestDispatcher alloc] init];
        dispatcher.delegate = self;
        [dispatcher requestRoute:self.route.places options:nil];
        [dispatcher release];
    }
}

- (void)request:(RequestDispatcher *)request didFinishedWithResponse:(Response *)response {
    if (request.type  == RequestTypeRoute && response.code == ResponseCodeError) {
        NSString *status =[response.responseInfo objectForKey:kError];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No results"
                                                        message:status
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    if(response.code == ResponseCodeError) {
        NSError *error = [response.responseInfo objectForKey:kError];
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    NSArray *encPoints = [response.responseInfo objectForKey:kDirection];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        DetailViewController *mapVC = [[DetailViewController alloc] init];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[self.route.places count]];
        for (PlaceEntity *pl in self.route.places) {
            TaggedAnnotation *ann = [[TaggedAnnotation alloc] init];
            ann.title = pl.name;
            CLLocationCoordinate2D loc;
            loc.longitude = pl.longtitude;
            loc.latitude = pl.latitude;
            [ann setCoordinate:loc];
            [arr addObject:ann];
            [ann release];
        }
        mapVC.annotations = arr;
        mapVC.mode = PlaceModeChoose;
        mapVC.detailItems = encPoints;
        [self.navigationController pushViewController:mapVC animated:YES];
        [mapVC release];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRoutePoints
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:encPoints,kDirection,nil]];
    }
}

#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.route.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.showsReorderControl = YES;
    }
    cell.textLabel.text = ((PlaceEntity *)[self.route.places objectAtIndex:indexPath.row]).name;
    cell.detailTextLabel.text = ((PlaceEntity *)[self.route.places objectAtIndex:indexPath.row]).comment;
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    PlaceEntity *source = [(PlaceEntity *)[self.route.places objectAtIndex:sourceIndexPath.row] retain];
    [self.route.places removeObject:source];
    [self.route.places insertObject:source atIndex:destinationIndexPath.row];
    [source release];
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        saved = NO;
        int i = ((PlaceEntity *)[self.route.places objectAtIndex:indexPath.row]).tag;
        [self.route.places removeObjectAtIndex:indexPath.row];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMap
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:kAnnotation]];
            
            
        }
        
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
