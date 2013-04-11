//
//  RequestDispatcher.h
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class RequestDispatcher;
@class Response;

@protocol RequestDispatcherDelegate <NSObject>
@required
-(void)request:(RequestDispatcher*)request didFinishedWithResponse:(Response*)response;

@end


@interface Response : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, retain) NSDictionary *responseInfo;

@end


@interface RequestDispatcher : NSObject 

@property (nonatomic, assign) RequestType type;
@property (nonatomic, assign) id<RequestDispatcherDelegate> delegate;

- (void)requestWeatherForPlace:(CLLocationCoordinate2D)location;
- (void)requestRoute:(NSArray*)routePoints options:(NSDictionary *)options;
- (void)requestPlacemarkNamed:(NSString*)name;

@end
