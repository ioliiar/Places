//
//  PlaceViewController.m
//  Place
//
//  Created by Iurii Oliiar on 3/29/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "PlaceViewController.h"
#import "DatePickerController.h"
#import "DatePickerController.h"

#import "TextFieldCell.h"
#import "TwoLabelCell.h"

@interface PlaceViewController ()<DatePickerDelegate, UITextFieldDelegate>

@property (nonatomic, retain) DatePickerController *datePicker;

@end

@implementation PlaceViewController {
    BOOL datePickerVisible;
}

@synthesize delegate;
@synthesize mode;
@synthesize place;
@synthesize detailTableView;
@synthesize photoImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker = [[[DatePickerController alloc] init] autorelease];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [place release];
    [_datePicker release];
    [detailTableView release];
    [photoImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    self.datePicker = nil;
    self.detailTableView = nil;
    self.photoImageView = nil;
    [super viewDidUnload];
}

- (void)orientationChanged:(NSNotification *)notification {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad  && datePickerVisible) {
        self.datePicker.view.frame = [self frameForDatePickerSwapAxis:YES];
    }
}

- (CGRect)frameForDatePickerSwapAxis:(BOOL)swap {
    CGRect rect;
    rect.origin = self.view.frame.origin;
    rect.size = CGSizeMake(320, 260);
    rect.origin.y = self.view.frame.size.height - 260;
    if (swap) {
        switch ([[UIDevice currentDevice] orientation]) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                rect.origin.y = self.view.frame.size.height - 260;
                break;
            case UIDeviceOrientationPortrait:
                rect.origin.y = self.view.frame.size.width + 320;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                rect.origin.y = self.view.frame.size.width + 320;
                break;
            default:
                NSLog(@"unknown orientation");
                break;
        }
    }
    return rect;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (void)photoTapped:(UITapGestureRecognizer*)sender {
    NSLog(@"Photo tapped");
}

#pragma mark Keyboard method

- (void)handleKeyboard:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
	NSValue *keyboardframeValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [keyboardframeValue CGRectValue];
    
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.view.frame;
    
    CGFloat height = 0.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        height = keyboardRect.size.height; //we support only portrait orientation for iPhone
    } else if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {// there is no need to adjust view in portrait mode
        height = keyboardRect.size.width;
    }
    
    
    if (notification.name == UIKeyboardDidShowNotification) {
        frame.origin.y -= height;
    } else {
        frame.origin.y += height;
    }
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    
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

- (TextFieldCell *)getTextFieldCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"TextFieldCell";
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (TextFieldCell *)[nib objectAtIndex:0];
    }
    cell.valueTextField.delegate = self;
    return cell;
}

- (TwoLabelCell *)getTwoLabelCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"TwoLabelCell";
    TwoLabelCell *cell = (TwoLabelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (TwoLabelCell *)[nib objectAtIndex:0];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case DescriptionRowName: {
            TextFieldCell *cell = [self getTextFieldCell:tableView];
            cell.whatLabel.text = LOC_NAME;
            cell.valueTextField.text = self.place.name;
            cell.valueTextField.tag = DescriptionRowName;
            return cell;
        }
        case DescriptionRowComment: {
            TextFieldCell *cell = [self getTextFieldCell:tableView];
            cell.whatLabel.text = LOC_COMMENT;
            cell.valueTextField.text = self.place.comment;
            cell.valueTextField.tag = DescriptionRowComment;
            return cell;
        }
        case DescriptionRowCategory: {
            TextFieldCell *cell = [self getTextFieldCell:tableView];
            cell.whatLabel.text = LOC_CATEGORY;
            cell.valueTextField.tag = DescriptionRowCategory;
            return cell;
        }
        case DescriptionRowDateVisited: {
            TwoLabelCell *cell = [self getTwoLabelCell:tableView];
            if (self.place.dateVisited == nil) {
                self.place.dateVisited =  [NSDate date];
            }
            cell.whatLabel.text = LOC_DATE_VISITED;
            cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.place.dateVisited
                                                                 dateStyle:NSDateFormatterMediumStyle
                                                                 timeStyle:NSDateFormatterShortStyle];
            return cell;
        }
        default:
            NSLog(@"Unknown description cell");
            return nil;
    }
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
        case DescriptionRowDateVisited: {
            self.datePicker.view.frame = [self frameForDatePickerSwapAxis:NO];
            self.datePicker.delegate = self;
            datePickerVisible = YES;
            [self.view addSubview:_datePicker.view];
            
        }
            break;
        default:
            NSLog(@"Unknown description cell");
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[[UIView alloc] init] autorelease];
}

#pragma mark DatePickerController delegate

- (void)datePickerCancelled {
    datePickerVisible = NO;
}

- (void)datePickerDidChooseDate:(NSDate *)date {
    datePickerVisible = NO;
    self.place.dateVisited = date;
    [self.detailTableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case DescriptionRowName:
            self.place.name = textField.text;
            break;
        case DescriptionRowComment:
            self.place.comment = textField.text;
            break;
        case DescriptionRowCategory:
            break;
        default:
            break;
    }
}

@end
