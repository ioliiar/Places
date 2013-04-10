//
//  PlaceViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/29/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "PlaceViewController.h"
#import "TextFieldCell.h"

@interface PlaceViewController ()

@end

@implementation PlaceViewController

@synthesize delegate;
@synthesize mode;
@synthesize place;
@synthesize detailTableView;
@synthesize photoImageView;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 300.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
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
    static NSString *CellIdentifier = @"TextFieldCell";
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (TextFieldCell *)[nib objectAtIndex:0];
    }
    
    switch (indexPath.row) {
        case DescriptionRowName:
            cell.whatLabel.text = LOC_NAME;
            cell.valueTextField.text = self.place.name;
            break;
        case DescriptionRowComment:
            cell.whatLabel.text = LOC_COMMENT;
            break;
        case DescriptionRowCategory:
            cell.whatLabel.text = LOC_CATEGORY;
            break;
        case DescriptionRowDateVisited:
            if (self.place.dateVisited == nil) {
                self.place.dateVisited =  [NSDate date];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: \t %@", LOC_DATE_VISITED,
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
