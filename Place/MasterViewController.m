//
//  MasterViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "PlaceViewController.h"
#import "RouteViewController.h"
#import "SimpleMapViewController.h"

#import "DBHandler.h"
#import "RouteEntity.h"
#import "PlaceEntity.h"

#import "CustomHeader.h"
#import "CustomFooter.h"
#import "CustomCellBackground.h"

@interface MasterViewController ()<UIActionSheetDelegate, UISearchBarDelegate,PlaceViewControllerDelegate, DetailViewControllerDelegate>

@property (nonatomic, copy) NSArray *routes;
@property (nonatomic, copy) NSArray *places;
@property (nonatomic, retain) DBHandler *dbHandler;
@property (nonatomic, retain) NSMutableArray *filteredPlaces;
@property (nonatomic, retain) NSMutableArray *filteredRoutes;
@property (nonatomic, retain) CustomCellBackground * backgroundTableView;

@end

@implementation MasterViewController {
    BOOL expandedPlace;
    BOOL expandedRoute;
    BOOL presentingVC;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LOC_MY_PLACES;
        self.dbHandler = [[[DBHandler alloc] init] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = YES;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void)dealloc {
    [_filteredPlaces release];
    [_filteredRoutes release];
    [_places release];
    [_routes release];
    [_backgroundTableView release];
    [_detailViewController release];
    [_mySearchBar release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    UIBarButtonItem *rb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                        target:self
                                                                        action:@selector(addAction:)];
    self.navigationItem.rightBarButtonItem = rb;
    [rb release];
    }
    
    self.detailViewController.delegate = self;
    self.backgroundTableView = [[[CustomCellBackground alloc] init] autorelease];
    self.tableView.backgroundView = self.backgroundTableView;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    expandedPlace = NO;
    expandedRoute = NO;
    presentingVC = NO;
    [self.tableView reloadData];
    self.detailViewController.mode = PlaceModeSurvey;
    [self.detailViewController clearMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.backgroundTableView = nil;
    self.backgroundTableView = nil;
    self.mySearchBar = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

#pragma mark helper methods

- (BOOL)validCoordinate:(PlaceEntity *)place {
    return (place.latitude != 0.0 && place.longtitude != 0.0);
}

- (void)getDBPlaceList {
    dispatch_queue_t queue = dispatch_queue_create("Place", nil);
    dispatch_async(queue, ^ {
        self.places = [self.dbHandler getAllPlaces];
        _filteredPlaces = [[self.places mutableCopy] retain];
        dispatch_sync(dispatch_get_main_queue(), ^ {
            expandedPlace = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

- (void)getDBRouteList {
    dispatch_queue_t queue = dispatch_queue_create("Place", nil);
    dispatch_async(queue, ^ {
        self.routes = [self.dbHandler getRouteNamed:nil];
        _filteredRoutes = [[self.routes mutableCopy] retain];
        dispatch_sync(dispatch_get_main_queue(), ^ {
            expandedRoute = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
    
}

#pragma mark Menu Picker methods

- (void)addAction:(UIBarButtonItem*)sender {
    dispatch_queue_t queue = dispatch_queue_create("REMOVE", nil);
    dispatch_async(queue, ^(void) {
        self.places = nil;
        self.routes = nil;
        [self.filteredPlaces removeAllObjects];
        [self.filteredRoutes removeAllObjects];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    self.detailViewController = nil;
    self.detailViewController = [[[DetailViewController alloc] init] autorelease];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}


#pragma mark custom Delegate methods

- (void)placeVC:(PlaceViewController *)placeVC didDismissedInMode:(PlaceMode)mode {
    presentingVC = NO;
    if (mode != PlaceModeSurvey) {
        return;
    }
    BOOL success;
        if (placeVC.place.Id) {
            success = [self.dbHandler updatePlace:placeVC.place];
            
        } else {
            success = [self.dbHandler insertPlace:placeVC.place];
        }
    if (success) {
        [self getDBPlaceList];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_ERROR
                                                        message:LOC_TRY_LTR
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
}

#pragma mark GhostPicker processing methods

- (void)processPlaceComponent:(NSInteger)component tapCoordinate:(CLLocationCoordinate2D)coordinate {
    if (presentingVC) {
        return;
    }
    presentingVC = YES;
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
    if (presentingVC) {
        return;
    }
    switch (component) {
        case 0: {
             [self.detailViewController clearMap];
            RouteViewController *route = [[RouteViewController alloc] init];
            [self.navigationController pushViewController:route animated:YES];
            self.detailViewController.mode = PlaceModeChoose;
            [route release];
        }
            break;
        case 1: {
             [self.detailViewController clearMap];
            RouteViewController *route = [[RouteViewController alloc] init];
            PlaceEntity *pl = [[PlaceEntity alloc] init];
            pl.name = LOC_WAYPOINT;
            pl.latitude = coordinate.latitude;
            pl.longtitude = coordinate.longitude;
            [route.route.places addObject:pl];
            [pl release];
            [self.navigationController pushViewController:route animated:YES];
            self.detailViewController.mode = PlaceModeChoose;
            [route release];
        }
            break;
        default:
            NSLog(@"Unknown component %i", component);
            break;
    }
    
}

#pragma mark Expand methods

- (void)expandPlaces {
    if (expandedPlace) {
        expandedPlace = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([_filteredPlaces count] == 0) {
        [self getDBPlaceList];
    }
    expandedPlace = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)expandRoutes {
    if (expandedRoute) {
        expandedRoute = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if ([_filteredRoutes count] == 0) {
        [self getDBRouteList];
    }
    expandedRoute = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark customized uitableView methods

- (UIButton *)makeAccessoryButton {
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
    
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"eye_color"] forState:UIControlStateNormal];
    return [button autorelease];

}

- (UIButton *) makeDetailDisclosureButtonForIndex:(NSIndexPath *)path {
    switch (path.section) {
        case 0:
            if ([self validCoordinate:[self.filteredPlaces objectAtIndex:path.row]]) {
                return [self makeAccessoryButton];
            } 
            return nil;
        case 1:
            return [self makeAccessoryButton];
        default:
            NSLog(@"unknown cell section %i", path.section);
            break;
    }
    return nil;
}

- (void) accessoryButtonTapped:(UIControl *)button
                     withEvent:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    switch (indexPath.section) {
        case 0: {
            PlaceEntity *pl = [self.filteredPlaces objectAtIndex:indexPath.row];
            pl.tag = indexPath.row;
            [self.detailViewController addAnnotation:pl];
        }
            break;
        case 1://route
            break;
        default:
            NSLog(@"Unknown section");
            break;
    }
    } else {
        switch (indexPath.section) {
            case 0: {
                PlaceEntity *pl = [self.filteredPlaces objectAtIndex:indexPath.row];
                pl.tag = indexPath.row;
                SimpleMapViewController *smvc = [[[SimpleMapViewController alloc] init] autorelease];
                [smvc addAnnotation:pl];
                [self.navigationController pushViewController:smvc
                                                     animated:YES];
            }
                break;
            case 1://route
                break;
            default:
                NSLog(@"Unknown section");
                break;
        }

        
    }
}


#pragma mark UITableview methods

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[[CustomFooter alloc] init] autorelease];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomHeader * head = [[[CustomHeader alloc] init] autorelease];
    UITapGestureRecognizer *recognizer = nil;
        head.lightColor = [UIColor colorWithRed:98.0/255.0
                                          green:211.0/255.0
                                           blue:247.0/255.0
                                          alpha:1.0];
        
        head.darkColor = [UIColor colorWithRed:0.0/255.0
                                         green:189.0/255.0
                                          blue:243.0/255.0
                                         alpha:1.0];
    
    switch (section) {
        case CategorySectionPlace: {
            head.titleLabel.text = LOC_PLACES;
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(expandPlaces)];
        }
            break;
        case CategorySectionRoute: {
            head.titleLabel.text = LOC_ROUTES;
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(expandRoutes)];
        }

            break;
        default:
            NSLog(@"Unknown header");
            break;
    }
    [head addGestureRecognizer:recognizer];
    [recognizer release];
    return head;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CategorySectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger counter;
    switch (section) {
        case CategorySectionPlace:
            if (expandedPlace) {
                counter = [_filteredPlaces count];
            } else {
                counter = 0;
            }
            break;
        case CategorySectionRoute:
            if (expandedRoute) {
                counter = [_filteredRoutes count];
            } else {
                counter = 0;
            }
            break;
        default:
            counter = 0;
            NSLog(@"Unknown Place - Route section");
            break;
    }
    return counter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
        CustomCellBackground * backgroundCell = [[[CustomCellBackground alloc] init] autorelease];
        cell.backgroundView = backgroundCell;
    }
    
    cell.accessoryView  = [self makeDetailDisclosureButtonForIndex:indexPath];
    switch (indexPath.section) {
        case CategorySectionPlace:
            cell.textLabel.text = ((PlaceEntity *)[_filteredPlaces objectAtIndex:indexPath.row]).name;
            break;
        case CategorySectionRoute:
            cell.textLabel.text = ((RouteEntity *)[_filteredRoutes objectAtIndex:indexPath.row]).name;
            break;
        default:
            NSLog(@"Unknown Place - Route");
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CategorySectionPlace: {
            PlaceViewController *pl = [[PlaceViewController alloc] init];
            pl.place = [self.filteredPlaces objectAtIndex:indexPath.row];
            pl.delegate = self;
            [self.navigationController pushViewController:pl animated:YES];
            [pl release];
        }
            break;
        case CategorySectionRoute: {
            RouteViewController *rt = [[RouteViewController alloc] init];
            rt.route = [self.filteredRoutes objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:rt animated:YES];
            [rt release];
        }
            break;
        default:
            NSLog(@"Unknown Place - Route cell taped");
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case 0: {
                int i = ((PlaceEntity *)[_filteredPlaces objectAtIndex:indexPath.row]).Id;
                if ([self.dbHandler deletePlaceWithId:i]) {
                    [self getDBPlaceList];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_ERROR
                                                                    message:LOC_TRY_LTR
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert release];
                    
                }
            }
                break;
            case 1: {
                NSString *nm = ((RouteEntity *)[_filteredRoutes objectAtIndex:indexPath.row]).name;
                if ([self.dbHandler deleteRouteWithName:nm]) {
                    [self getDBRouteList];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LOC_ERROR
                                                                    message:LOC_TRY_LTR
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert release];
                    
                }
            }
                break;
            default:
                NSLog(@"Unknown section %i",indexPath.section);
                break;
        }
    }
}

#pragma mark UISearchBar delegate methods

- (void)filterUsingText:(NSString *)word {
    if ([word isEqualToString:@""]) {
        _filteredPlaces = [[self.places mutableCopy] retain];
        _filteredRoutes = [[self.routes mutableCopy] retain];
        [self.tableView reloadData];
        return;
    }
    
    [_filteredRoutes removeAllObjects];
    for (int i = 0; i < [_routes count]; i++) {
        RouteEntity *route = [_routes objectAtIndex:i];
        if ([route.name rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [self.filteredRoutes addObject:route];
        }
    }
    
        
    [_filteredPlaces removeAllObjects];
    for (int j = 0; j < [_places count]; j++) {
        PlaceEntity *pl = [_places objectAtIndex:j];
        if ([pl.name  rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [self.filteredPlaces addObject:pl];
        }
    }
    expandedPlace = YES;
    expandedRoute = YES;
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([_routes count] == 0 && [_places count] == 0) {
        [self getDBPlaceList];
        [self getDBRouteList];
    }
    searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchBar.showsCancelButton = YES;
    [self filterUsingText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self filterUsingText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    _filteredPlaces = [[self.places mutableCopy] retain];
    _filteredRoutes = [[self.routes mutableCopy] retain];
    [self.tableView reloadData];

}

@end
