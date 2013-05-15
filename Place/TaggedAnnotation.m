//
//  TaggedAnnotation.m
//  Place
//
//  Created by Iurii Oliiar on 4/16/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
// some change

#import "TaggedAnnotation.h"

@implementation TaggedAnnotation

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (void)dealloc {
    [_title release];
    [_subtitle release];
    [super dealloc];
}

@end
