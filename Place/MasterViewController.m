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

@interface MasterViewController ()<UIActionSheetDelegate, UIPopoverControllerDelegate, MenuPopControllerDelegate>

@property (nonatomic, copy) NSArray *routes;
@property (nonatomic, copy) NSArray *places;
@property (nonatomic, retain) DBHandler *dbHandler;
@property (nonatomic, retain) UIPopoverController *popController;

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
        self.places = [self.dbHandler getPlacesByName:nil];
        self.routes = [self.dbHandler getRouteNamed:nil];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(300.0, 600.0);
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
    UIBarButtonItem *rb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                        target:self
                                                                        action:@selector(menuAction:)];
    self.navigationItem.rightBarButtonItem = rb;
    [rb release];
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
        self.popController = [[UIPopoverController alloc] initWithContentViewController:menu];
        [self.popController setPopoverContentSize:CGSizeMake(300, 88)];
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
            [self.navigationController pushViewController:place animated:YES];
            [place release];
        } break;
        case MenuRowAddRoute: {
            RouteViewController *route = [[RouteViewController alloc] init];
            [self.navigationController pushViewController:route animated:YES];
            [route release];
        } break;
        case MenuRowGoToMap: {
            self.detailViewController = [[DetailViewController alloc] init];
            [self.navigationController pushViewController:self.detailViewController animated:YES];
            [self.detailViewController release];
        } break;
        case -1:
            NSLog(@"Cancelled");
            break;
        default:
            NSLog(@"Unknown menu item");
            break;
    }

}

- (void)menuPopController:(MenuPopController *)menu didChoseItem:(NSInteger)item {
    [self.popController dismissPopoverAnimated:YES];
    switch (item) {
        case MenuRowAddPlace: {
            PlaceViewController *place = [[PlaceViewController alloc] init];
            place.mode = PlaceModeSurvey;
            [self.navigationController pushViewController:place animated:YES];
            [place release];
        } break;
        case MenuRowAddRoute:{
            RouteViewController *route = [[RouteViewController alloc] init];
            [self.navigationController pushViewController:route animated:YES];
            [route release];
        } break;
        default:
            NSLog(@"Unknown menu item");
            break;
    }
}

#pragma mark UITableview methods

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[[UIView alloc] init] autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lbl = [[[UILabel alloc] init] autorelease];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor redColor];
    switch (section) {
        case CategorySectionPlace:
            lbl.text = @"Route";
            break;
        case CategorySectionRoute:
            lbl.text = @"Place";
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
            counter = [places count];
            break;
        case CategorySectionRoute:
            counter = [routes count];
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
            cell.textLabel.text = [places objectAtIndex:indexPath.row];
            break;
        case CategorySectionRoute:
            cell.textLabel.text = [routes objectAtIndex:indexPath.row];
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
            pl.place = [self.places objectAtIndex:indexPath.row];
            [pl release];
        }
            break;
        case CategorySectionRoute: {
            RouteViewController *rt = [[RouteViewController alloc] init];
            rt.route = [self.routes objectAtIndex:indexPath.row];
            [rt release];
        }
            break;
        default:
            NSLog(@"Unknown Place - Route cell taped");
            break;
    }
    
}


#pragma mark UISearchBar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {}


@end
