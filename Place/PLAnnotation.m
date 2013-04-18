//
//  SLAnnotation.m
//  Slavske
//
//  Created by Serhii Nakonechnyi on 3/10/13.
//  Copyright (c) 2013 Serhii. All rights reserved.
//

#import "PLAnnotation.h"

@implementation PLAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize tag = _tag;

- (void)dealloc
{
    self.title = nil;
    self.subtitle = nil;
    [super dealloc];
}

@end
