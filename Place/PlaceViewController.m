//
//  PlaceViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/29/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "PlaceViewController.h"

@interface PlaceViewController ()

@end

@implementation PlaceViewController

@synthesize delegate;
@synthesize mode;
@synthesize place;
@synthesize detailTableView;
@synthesize photoImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 300.0);
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [self.photoImageView addGestureRecognizer:recognizer];
    [recognizer release];
    if (place == nil) {
        self.place = [[[PlaceEntity alloc] init] autorelease];
    }
    
    if (!self.place.photo) {
        self.photoImageView.image = [ResourceLoader unknownPlaceImage];
    } else {
        self.photoImageView.image = self.place.photo;
    }
    
    if (mode == PlaceModeSurvey) {
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:LOC_DONE
                                                                style:UIBarButtonItemStyleDone
                                                               target:self
                                                               action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = bar;
        [bar release];
    } else {
        UIBarButtonItem *br = [[UIBarButtonItem alloc] initWithTitle:LOC_DONE
                                                                style:UIBarButtonItemStyleDone
                                                               target:self
                                                               action:@selector(choose:)];
        self.navigationItem.rightBarButtonItem = br;
        [br release];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [place release];
    [detailTableView release];
    [photoImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    self.detailTableView = nil;
    self.photoImageView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (void)photoTapped:(UITapGestureRecognizer*)sender {
    NSLog(@"Photo tapped");
}

#pragma mark UIBarbuttonItem methods

- (BOOL)validatePlace:(PlaceEntity *)pl {
    return !(pl.name == nil || [pl.name isEqualToString:@""]);
   
}

- (void)choose:(UIBarButtonItem *)sender {
    if ([self validatePlace:self.place]) {
        sender.enabled = NO;
        [self.delegate placeVC:self didDismissedInMode:mode];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)done:(UIBarButtonItem *)sender {
    if ([self validatePlace:self.place]) {
        sender.enabled = NO;
        if ([self.delegate respondsToSelector:@selector(placeVC:didDismissedInMode:)]) {
            [self.delegate placeVC:self didDismissedInMode:mode];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DescriptionRowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    switch (indexPath.row) {
        case DescriptionRowName:
            cell.textLabel.text = LOC_NAME;
            break;
        case DescriptionRowComment:
            cell.textLabel.text = LOC_COMMENT;
            break;
        case DescriptionRowCategory:
            cell.textLabel.text = LOC_CATEGORY;
            break;
        case DescriptionRowDateVisited:
            if (self.place.dateVisited == nil) {
                self.place.dateVisited =  [NSDate date];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@: \t %@", LOC_DATE_VISITED,
                                   [NSDateFormatter localizedStringFromDate:self.place.dateVisited
                                                                  dateStyle:NSDateFormatterMediumStyle
                                                                  timeStyle:NSDateFormatterShortStyle]];
            break;
        default:
            NSLog(@"Unknown description cell");
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case DescriptionRowName:
            break;
        case DescriptionRowComment:
            break;
        case DescriptionRowCategory:
            break;
        case DescriptionRowDateVisited:
            
            break;
        default:
            NSLog(@"Unknown description cell");
            break;
    }
}

@end
