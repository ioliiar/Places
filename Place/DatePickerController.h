//
//  DatePickerController.h
//  Place
//
//  Created by Iurii Oliiar on 4/11/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DatePickerController;

@protocol DatePickerDelegate <NSObject>

- (void)datePickerDidChooseDate:(NSDate *)date;
- (void)datePickerCancelled;

@end


@interface DatePickerController : UIViewController

@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (assign, nonatomic) id <DatePickerDelegate> delegate;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)done:(UIBarButtonItem *)sender;

@end
