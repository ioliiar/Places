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
#import "TableAlertView.h"

#import "CustomFooter.h"
#import "CustomHeader.h"
#import "CustomCellBackground.h"

@interface PlaceViewController ()<DatePickerDelegate, TableAlertViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) DatePickerController *datePicker;
@property (nonatomic, copy) NSArray *categories;

@end

@implementation PlaceViewController {
    BOOL datePickerVisible;
    BOOL photoPicked;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = LOC_PLACES;
        self.place = [[[PlaceEntity alloc] init] autorelease];
        self.place.category = 1;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Places" ofType:@"plist"];
        self.categories = [NSArray arrayWithContentsOfFile:filePath];
         
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker = [[[DatePickerController alloc] init] autorelease];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [self.photoImageView addGestureRecognizer:recognizer];
    [recognizer release];
    
    if (!self.place.photo) {
        self.photoImageView.image = [ResourceLoader unknownPlaceImage];
    } else {
        self.photoImageView.image = self.place.photo;
    }
    
    if (_mode == PlaceModeSurvey) {
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
    
    [_place release];
    [_datePicker release];
    [_detailTableView release];
    [_photoImageView release];
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

#pragma mark UIimagePicker methods

- (void)photoTapped:(UITapGestureRecognizer*)sender {
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.contentSizeForViewInPopover = CGSizeMake(300, 400);
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (hasCamera) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = YES;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
        
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentViewController:picker
                           animated:YES
                         completion:nil];
        
    } else {
        self.popover = nil;
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
        
        [self.popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    photoPicked = YES;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    self.photoImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
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
        if (photoPicked) {
             self.place.photo = self.photoImageView.image;
        }
       
        [self.delegate placeVC:self didDismissedInMode:_mode];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)done:(UIBarButtonItem *)sender {
    if ([self validatePlace:self.place]) {
        sender.enabled = NO;
        if (photoPicked) {
            self.place.photo = self.photoImageView.image;
        }
        if ([self.delegate respondsToSelector:@selector(placeVC:didDismissedInMode:)]) {
            [self.delegate placeVC:self didDismissedInMode:_mode];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UITableView methods

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}


- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[[CustomFooter alloc] init] autorelease];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[[UIView alloc] init] autorelease];
}

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
            [cell.valueTextField addTarget:self
                                    action:@selector(textFieldDidEndEditing:)
                          forControlEvents:UIControlEventEditingChanged];
            if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
                CustomCellBackground * backgroundCell = [[[CustomCellBackground alloc] init] autorelease];
                cell.backgroundView = backgroundCell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        case DescriptionRowComment: {
            TextFieldCell *cell = [self getTextFieldCell:tableView];
            cell.whatLabel.text = LOC_COMMENT;
            cell.valueTextField.text = self.place.comment;
            cell.valueTextField.tag = DescriptionRowComment;
            [cell.valueTextField addTarget:self
                                    action:@selector(textFieldDidEndEditing:)
                          forControlEvents:UIControlEventEditingChanged];
            if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
                CustomCellBackground * backgroundCell = [[[CustomCellBackground alloc] init] autorelease];
                cell.backgroundView = backgroundCell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        case DescriptionRowCategory: {
            TwoLabelCell *cell = [self getTwoLabelCell:tableView];
            cell.whatLabel.text = LOC_CATEGORY;
            cell.dateLabel.text = [self.categories objectAtIndex:_place.category - 1];
            if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
                CustomCellBackground * backgroundCell = [[[CustomCellBackground alloc] init] autorelease];
                cell.backgroundView = backgroundCell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
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
            if (![cell.backgroundView isKindOfClass:[CustomCellBackground class]]) {
                CustomCellBackground * backgroundCell = [[[CustomCellBackground alloc] init] autorelease];
                cell.backgroundView = backgroundCell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
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
        case DescriptionRowCategory: {
            TableAlertView  *alert = [[TableAlertView alloc] initWithCaller:self
                                                                       data:self.categories
                                                                      title:@"Choose Place"
                                                                 andContext:nil] ;
            [alert show];
            [alert release];
        }
            break;
        case DescriptionRowDateVisited: {
            self.datePicker.view.frame = [self frameForDatePickerSwapAxis:NO];
            self.datePicker.datePicker.date = self.place.dateVisited;
            self.datePicker.delegate = self;
            datePickerVisible = YES;
            [tableView endEditing:YES];
            [self.view addSubview:_datePicker.view];
            
        }
            break;
        default:
            NSLog(@"Unknown description cell");
            break;
    }
}

-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context {
    self.place.category = row + 1;
    [self.detailTableView reloadData];
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

#pragma mark textField delegate methods

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
        default:
            break;
    }
}

@end
