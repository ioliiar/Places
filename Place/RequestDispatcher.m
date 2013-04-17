//
//  RequestDispatcher.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <CoreLocation/CLLocation.h>
#import "RequestDispatcher.h"
#import "PlaceEntity.h"
#import "GoogleStep.h"

@implementation Response

@synthesize code;
@synthesize responseInfo;

- (void)dealloc {
    [responseInfo release];
    [super dealloc];
}

@end

@interface RequestDispatcher ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, copy) NSArray *directionPoints;
@property (nonatomic, retain) NSMutableData *data;

@end


@implementation RequestDispatcher

@synthesize directionPoints;
@synthesize response;
@synthesize type;
@synthesize delegate;
@synthesize data;

- (void)dealloc {
    [directionPoints release];
    [response release]; 
    [super dealloc];
}

- (void)requestWeatherForPlace:(CLLocationCoordinate2D)location {    
}

- (NSString *)makeQueryString:(PlaceEntity *)place {
    return [NSString stringWithFormat:@"%1.6f,%1.6f",place.latitude,place.longtitude];
}

- (void)requestRoute:(NSArray *)routePoints options:(NSDictionary *)options {
    self.directionPoints = routePoints;
    self.type = RequestTypeRoute;
    NSInteger rpCount = [routePoints count];

    NSMutableString *str = [[NSMutableString alloc] initWithString:@"http://maps.googleapis.com/maps/api/directions/json?origin="];

    NSString *start = [NSString stringWithFormat:@"%@&destination=%@", [self makeQueryString:[routePoints objectAtIndex:0]], [self makeQueryString:[routePoints objectAtIndex:rpCount - 1]]];
    [str appendString:start];
    if (rpCount > 2) {
        [str appendString:@"&waypoints="];
        for (int j = 1; j < rpCount - 2; j++) {
            NSString *wp = [NSString stringWithFormat:@"%@|",[self makeQueryString:[routePoints objectAtIndex:j]]];
            [str appendString:wp];
        }
        [str appendString:[self makeQueryString:[routePoints objectAtIndex:rpCount - 2]]];
    }
    NSString *end = @"&sensor=false";
    [str appendString:end];
    

    //examples of using Google Directions
//    
//    NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
//                                     start.latitude, start.longitude, destination.latitude, destination.longitude];
//    NSString *str = @"http://maps.googleapis.com/maps/api/directions/json?origin=Chicago,IL&destination=Los+Angeles,CA&waypoints=Joplin,MO|Oklahoma+City,OK&sensor=false";
    
    NSLog(@"%@",str);
    NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [str release];
    if (connection) {
        data = [[NSMutableData alloc] init];
    } else {
        NSLog(@"Failed to create conncetion");
    }
}

- (void)requestPlacemarkNamed:(NSString*)name {
    self.type = RequestTypePlacemarkSearch;
    self.response = nil;
    self.response = [[[Response alloc] init] autorelease];
    
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressString:name completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil){
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            self.response.code = ResponseCodeOK;
            self.response.responseInfo = [NSDictionary dictionaryWithObject:firstPlacemark.location forKey: kLocation];
            [self.delegate request:self didFinishedWithResponse:self.response];
        }
        else if ([placemarks count] == 0 &&
                 error == nil) {
            NSLog(@"Found no placemarks.");
            self.response.code = ResponseCodeError;
            self.response.responseInfo = [NSDictionary dictionaryWithObject:nil forKey: kLocation];
            [self.delegate request:self didFinishedWithResponse:self.response];
        }
        else if (error != nil){
            self.response.code = ResponseCodeError;
            self.response.responseInfo = [NSDictionary dictionaryWithObject:error forKey: kError];
            [self.delegate request:self didFinishedWithResponse:self.response];
            NSLog(@"An error occurred = %@", error);
        }
    }];
}

#pragma mark NSURLConnection  methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.response = nil;
    self.response = [[[Response alloc] init] autorelease];
    self.response.code = ResponseCodeError;
    self.response.responseInfo = [NSDictionary dictionaryWithObject:error forKey: kError];
    [self.delegate request:self didFinishedWithResponse:self.response];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)_response;
    NSLog(@"Response %i returned",[httpResponse statusCode]);
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data {
    [self.data appendData:_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *err = nil;
    NSArray *results = nil;
    NSMutableArray *resultSteps = [[NSMutableArray alloc] init];
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:self.data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&err];
    
    NSLog(@"%@",responseObject);
    NSArray *routes = [responseObject objectForKey:@"routes"];
    NSDictionary *route = [routes lastObject];
    
    if (route) {
        NSArray *legs = [route objectForKey:@"legs"];
        for (int i = 0; i < [legs count]; i++) {
            //waypoint are not reordered (we doesn't implement this option)
            NSDictionary *leg = [legs objectAtIndex:i];
            NSArray *steps = [leg objectForKey:@"steps"];
            for (int k = 0 ; k < [steps count]; k++) {
                NSDictionary *step = [steps objectAtIndex:k];
                NSDictionary *stLoc = [step objectForKey:@"start_location"];
                NSDictionary *endLoc = [step objectForKey:@"end_location"];
                
                GoogleStep *gStep  = [[GoogleStep alloc] init];
                CLLocationCoordinate2D start;
                start.latitude = [[stLoc objectForKey:@"lat"] doubleValue];
                start.longitude = [[stLoc objectForKey:@"lng"] doubleValue];
                
                CLLocationCoordinate2D end;
                end.latitude = [[endLoc objectForKey:@"lat"] doubleValue];
                end.longitude = [[endLoc objectForKey:@"lng"] doubleValue];
                
                gStep.start = start;
                gStep.end = end;
                
                [resultSteps addObject:gStep];
    
                [gStep release];
            }
        }
       
    }
    results = [resultSteps copy];
    [resultSteps release];
    
    self.response = nil;
    self.response = [[[Response alloc] init] autorelease];
    self.response.code = ResponseCodeOK;
    self.response.responseInfo = [NSDictionary dictionaryWithObject:[results autorelease] forKey:kDirection];
    [self.delegate request:self didFinishedWithResponse:self.response];
    [connection release];
    [data release];
    
}

@end
