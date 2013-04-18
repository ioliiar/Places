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
#import "MenuPopController.h"

#import "DBHandler.h"
#import "RouteEntity.h"
#import "PlaceEntity.h"

@interface MasterViewController ()<UIActionSheetDelegate, UIPopoverControllerDelegate, UISearchBarDelegate, MenuPopControllerDelegate,PlaceViewControllerDelegate>

@property (nonatomic, copy) NSArray *routes;
@property (nonatomic, copy) NSArray *places;
@property (nonatomic, retain) DBHandler *dbHandler;
@property (nonatomic, retain) UIPopoverController *popController;
@property (nonatomic, retain) NSMutableArray *filteredPlaces;
@property (nonatomic, retain) NSMutableArray *filteredRoutes;

@end

@implementation MasterViewController

@synthesize dbHandler;
@synthesize routes;
@synthesize places;

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
    [_detailViewController release];
    [_mySearchBar release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDBList];
        UIBarButtonItem *rb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                        target:self
                                                                        action:@selector(menuAction:)];
    self.navigationItem.rightBarButtonItem = rb;
    [rb release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.detailViewController.mode = PlaceModeSurvey;
    [self.detailViewController clearMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.mySearchBar = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (void)getDBList {
    dispatch_queue_t queue = dispatch_queue_create("BaseStart", nil);
    dispatch_async(queue, ^ {
        self.places = [self.dbHandler getPlacesByName:nil];
        self.routes = [self.dbHandler getRouteNamed:nil];
        _filteredPlaces = [[self.places mutableCopy] retain];
        _filteredRoutes = [[self.routes mutableCopy] retain];
        
        dispatch_sync(dispatch_get_main_queue(), ^ {
            [self.tableView reloadData];
        });
    });

}

#pragma mark Menu Picker methods

- (void)menuAction:(UIBarButtonItem*)sender {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:LOC_CANCEL
                                                  otherButtonTitles:LOC_ADD_PLACE, LOC_ADD_ROUTE, LOC_GOTO_MAP, nil];
        [sheet showInView:self.view];
        [sheet release];
    } else {
        MenuPopController *menu = [[MenuPopController alloc] init];
        menu.delegate = self;
        self.popController = [[[UIPopoverController alloc] initWithContentViewController:menu] autorelease];
        [self.popController setPopoverContentSize:CGSizeMake(320, 88)];
        [self.popController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
        
        [menu release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    buttonIndex--;
    switch (buttonIndex) {
        case MenuRowAddPlace: {
            PlaceViewController *place = [[PlaceViewController alloc] init];
            place.mode = PlaceModeSurvey;
            place.delegate = self;
            [self.navigationController pushViewController:place animated:YES];
            [place release];
        } break;
        case MenuRowAddRoute: {
            RouteViewController *route = [[RouteViewController alloc] init];
            [self.navigationController pushViewController:route animated:YES];
            [route release];
        } break;
        case MenuRowGoToMap: {
            self.detailViewController = nil;
            self.detailViewController = [[[DetailViewController alloc] init] autorelease];
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        } break;
        case -1:
            NSLog(@"Cancelled");
            break;
        default:
            NSLog(@"Unknown menu item");
            break;
    }

}

#pragma mark custom Delegate methods

- (void)placeVC:(PlaceViewController *)placeVC didDismissedInMode:(PlaceMode)mode {
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
        [self getDBList];
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

- (void)menuPopController:(MenuPopController *)menu didChoseItem:(NSInteger)item {
    [self.popController dismissPopoverAnimated:YES];
    switch (item) {
        case MenuRowAddPlace: {
            PlaceViewController *place = [[PlaceViewController alloc] init];
            place.mode = PlaceModeSurvey;
            place.delegate = self;
            [self.navigationController pushViewController:place animated:YES];
            [place release];
        } break;
        case MenuRowAddRoute:{
            RouteViewController *route = [[RouteViewController alloc] init];
            [self.navigationController pushViewController:route animated:YES];
            self.detailViewController.mode = PlaceModeChoose;
            [route release];
        } break;
        default:
            NSLog(@"Unknown menu item");
            break;
    }
}

#pragma mark UITableview methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[[UILabel alloc] init] autorelease];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor redColor];
    switch (section) {
        case CategorySectionPlace:
            lbl.text = @"Place";
            break;
        case CategorySectionRoute:
            lbl.text = @"Route";
            break;
        default:
            NSLog(@"Unknown header");
            break;
    }
    return lbl;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CategorySectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger counter;
    switch (section) {
        case CategorySectionPlace:
            counter = [_filteredPlaces count];
            break;
        case CategorySectionRoute:
            counter = [_filteredRoutes count];
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
        int i = ((PlaceEntity *)[_filteredPlaces objectAtIndex:indexPath.row]).Id;
        if ([self.dbHandler deletePlaceWithId:i]) {
            [self getDBList];
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
    for (int i = 0; i < [_filteredRoutes count]; i++) {
        RouteEntity *route = [_filteredRoutes objectAtIndex:i];
        if ([word rangeOfString:route.name options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [self.filteredRoutes addObject:route];
        }
    }
    
        
    [_filteredPlaces removeAllObjects];
    for (int j = 0; j < [places count]; j++) {
        PlaceEntity *pl = [places objectAtIndex:j];
        if ([pl.name  rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [self.filteredPlaces addObject:pl];
        }
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
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
