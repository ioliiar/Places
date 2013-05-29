//
//  OptionMapViewController.m
//  Place
//
//  Created by Iurii Oliiar on 5/29/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "OptionMapViewController.h"

@interface OptionMapViewController ()

@end

@implementation OptionMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.segmentedControl.selectedSegmentIndex = _mapType;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    [self.delegate optionMapVC:self didSelectmapType:sender.selectedSegmentIndex];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [_segmentedControl release];
    [super dealloc];
}
- (void)viewDidUnload {
    self.segmentedControl = nil;
    [super viewDidUnload];
}
@end
