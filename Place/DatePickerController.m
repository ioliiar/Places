//
//  DatePickerController.m
//  Place
//
//  Created by Iurii Oliiar on 4/11/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "DatePickerController.h"
#import <QuartzCore/QuartzCore.h>

@interface DatePickerController ()

@end

@implementation DatePickerController

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
    [_datePicker release];
    [_toolbar release];
    [super dealloc];
}
- (void)viewDidUnload {
    self.datePicker = nil;
    self.toolbar = nil;
    [super viewDidUnload];
}

- (void)cancel:(UIBarButtonItem *)sender {
    [self.delegate datePickerCancelled];
    [self.view removeFromSuperview];
}

- (void)done:(UIBarButtonItem *)sender {
    [self.view removeFromSuperview];
    [self.delegate datePickerDidChooseDate:self.datePicker.date];
}

- (IBAction)today:(UIBarButtonItem *)sender {
    self.datePicker.date  = [NSDate date];
}

@end
