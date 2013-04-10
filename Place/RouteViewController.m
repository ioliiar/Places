//
//  RouteViewController.m
//  Place
//
//  Created by Iurii Oliiar on 4/1/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "RouteViewController.h"
#import "PlaceViewController.h"

#import "RouteEntity.h"

@interface RouteViewController ()<PlaceViewControllerDelegate>

@end

@implementation RouteViewController

@synthesize route;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 320.0);
        self.title = LOC_ROUTE;
        self.route = [[[RouteEntity alloc] init] autorelease];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addPlace:)];
    self.navigationItem.rightBarButtonItem = bar;
    [bar release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [route release];
    [_tableView release];
    [super dealloc];
}

#pragma mark BarButton Actions

- (void)addPlace:(UIBarButtonItem *)sender {
    // TODO add map chooser variant
    if ([self.route.places count] < 8) {
        PlaceViewController *place = [[PlaceViewController alloc] init];
        place.mode = PlaceModeChoose;
        place.delegate = self;
        [self.navigationController pushViewController:place animated:YES];
        [place release];
    }
}

- (void)placeVC:(PlaceViewController *)placeVC didDismissedInMode:(PlaceMode)mode {
    // TODO update Map In Ipad Mode
    [self.route.places addObject:placeVC.place];
    [self.tableView reloadData];
}

#pragma actions implementations

- (IBAction)saveAction:(UIButton *)sender {
    NSLog(@"save");
}

- (IBAction)doneAction:(UIButton *)sender {
    NSLog(@"done");
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
    }
    cell.textLabel.text = ((PlaceEntity *)[self.route.places objectAtIndex:indexPath.row]).name;
    cell.detailTextLabel.text = ((PlaceEntity *)[self.route.places objectAtIndex:indexPath.row]).comment;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected %i",indexPath.row);
    PlaceViewController *place = [[PlaceViewController alloc] init];
    place.mode = PlaceModeChoose;
    place.delegate = self;
    place.place = [self.route.places objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:place animated:YES];
    [place release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.route.places removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

@end
