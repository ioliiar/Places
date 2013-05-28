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
    CGRect rc = self.view.frame;
    rc.origin = CGPointMake(rc.origin.x,rc.origin.y + rc.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame = rc;
    [UIView commitAnimations];
    [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.5];
}

- (void)done:(UIBarButtonItem *)sender {
    CGRect rc = self.view.frame;
    rc.origin = CGPointMake(rc.origin.x,rc.origin.y + rc.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame = rc;
    [UIView commitAnimations];
    [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.5];
    [self.delegate datePickerDidChooseDate:self.datePicker.date];
}

- (IBAction)today:(UIBarButtonItem *)sender {
    self.datePicker.date  = [NSDate date];
}

@end
