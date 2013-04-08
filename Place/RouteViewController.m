//
//  RouteViewController.m
//  Place
//
//  Created by Iurii Oliiar on 4/1/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "RouteViewController.h"

#import "RouteEntity.h"

@interface RouteViewController ()

@property (nonatomic, retain) NSMutableArray *placePrivate;

@end

@implementation RouteViewController

@synthesize placePrivate;
@synthesize places;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)setPlaces:(NSArray *)value {
    if (value != places) {
        [places release];
        places = [value copy];
        placePrivate = [places mutableCopy];
    }
}

- (void)viewDidLoad
{
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

- (void)dealloc {
    [placePrivate release];
    [places release];
    [super dealloc];
}

#pragma mark BarButton Actions

- (void)addPlace:(UIBarButtonItem *)sender {
    NSLog(@"add Place");
}

#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [placePrivate count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = ((RouteEntity*)[placePrivate objectAtIndex:indexPath.row]).name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected %i",indexPath.row);
}

@end
