//
//  PlaceChooserViewController.m
//  Place
//
//  Created by Iurii Oliiar on 4/22/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "PlaceChooserViewController.h"
#import "PlaceEntity.h"
#import "DBHandler.h"
@interface PlaceChooserViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *places;
@property (nonatomic, retain) DBHandler *db;

@end

@implementation PlaceChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.db = [[[DBHandler alloc] init] autorelease];
        [self getDBList];
    }
    return self;
}

- (void)getDBList {
    dispatch_queue_t queue = dispatch_queue_create("BaseStart", nil);
    dispatch_async(queue, ^ {
        self.places = [self.db getPlacesByName:nil];
        dispatch_sync(dispatch_get_main_queue(), ^ {
            [self.placeTableView reloadData];
        });
    });
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_places release];
    [_placeTableView release];
    [_db release];
    [super dealloc];
}

- (void)viewDidUnload {
    self.placeTableView = nil;
    [super viewDidUnload];
}

#pragma mark UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_places count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = ((PlaceEntity *)[self.places objectAtIndex:indexPath.row]).name;
    cell.detailTextLabel.text = ((PlaceEntity *)[self.places objectAtIndex:indexPath.row]).comment;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaceEntity *pl = [_places objectAtIndex:indexPath.row];
    [self.delegate placeChooserPickedPlace:pl];
}

@end
