//
//  RequestDispatcher.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RequestDispatcher.h"
#import "PlaceEntity.h"

@implementation Response

@synthesize code;
@synthesize responseInfo;

- (void)dealloc {
    [responseInfo release];
    [super dealloc];
}

@end

@interface RequestDispatcher ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>


@property (nonatomic, retain) NSMutableData *data;

@end


static RequestDispatcher *sharedInstance = nil;

@implementation RequestDispatcher

@synthesize response;
@synthesize type;
@synthesize delegate;
@synthesize data;


+ (RequestDispatcher *)sharedRequestDispatcher {
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    @synchronized([RequestDispatcher class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[RequestDispatcher alloc] init];
        }
        return sharedInstance;
    }
}

- (oneway void)release {
}

- (id)retain {
    return sharedInstance;
}

- (NSUInteger)retainCount {
    return INT_MAX;
}


- (id)autorelease {
    return sharedInstance;
}

- (void)dealloc {
    [response release];
    [data release];
    [super dealloc];
}

- (void)requestWeatherForPlace:(CLLocationCoordinate2D)location {
    
}

- (void)requestRoute:(NSArray *)routePoints options:(NSDictionary *)options {
    self.type = RequestTypeRoute;
//    NSInteger rpCount = [routePoints count];
//    NSAssert(rpCount < 2, @"routePoints.count < 2 ");
//    NSMutableString *str = [[NSMutableString alloc] initWithString:@"http://maps.googleapis.com/maps/api/directions/json?origin="];
//
//    NSString *start = [NSString stringWithFormat:@"%@&destination=%@", [routePoints objectAtIndex:0], [routePoints objectAtIndex:rpCount - 1]];
//    [str appendString:start];
//    if (rpCount > 2) {
//        [str appendString:@"&waypoints="];
//        for (int j = 1; j < rpCount - 3; j++) {
//            NSString *wp = [NSString stringWithFormat:@"%@|",[routePoints objectAtIndex:j]];
//            [str appendString:wp];
//        }
//        [str appendString:[routePoints objectAtIndex:rpCount - 2]];
//    }
//    NSString *end = @"&sensor=false";
//    [str appendString:end];
    
    // there are some hardcode in this method just to check how it works
    
    /*NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                     start.latitude, start.longitude, destination.latitude, destination.longitude];*/
    NSString *str = @"http://maps.googleapis.com/maps/api/directions/json?origin=Chicago,IL&destination=Los+Angeles,CA&waypoints=Joplin,MO|Oklahoma+City,OK&sensor=false";
    
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
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressString:name completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil){
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            self.response = [[Response alloc] init];
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
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:self.data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&err];
    
    NSLog(@"%@",responseObject);
/*
    // TODO parse in cycle
    NSMutableArray *routes = [responseObject valueForKeyPath:@"routes"];
    NSMutableArray *legs = [[routes objectAtIndex:0] valueForKeyPath:@"legs"];
    NSMutableArray *steps = [[legs objectAtIndex:0] valueForKeyPath:@"steps"];
    
    CLLocationCoordinate2D startLocation;
    startLocation.latitude = [(NSString *)[steps valueForKeyPath: @"start_location.lat"] doubleValue];
    startLocation.longitude = [(NSString *)[steps valueForKeyPath: @"start_location.lng"] doubleValue];
    
    CLLocationCoordinate2D endLocation;
    endLocation.latitude = [(NSString *)[steps valueForKeyPath: @"end_location.lat"] doubleValue];
    endLocation.longitude = [(NSString *)[steps valueForKeyPath: @"end_location.lng"] doubleValue];
    
    [connection release];
    [data release];
 */   
//    NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSMutableDictionary *data1 = [responseData objectFromJSONData];
//    NSMutableArray *ad = [data1 objectForKey:@"routes"];
//    NSMutableArray *data2 = [[ad objectAtIndex:0] objectForKey:@"legs"];
//    NSMutableArray *data3 = [[data2 objectAtIndex:0] objectForKey:@"steps"];
//    //    NSLog(@"Data3 %@", data3);
//    for(int i = 0; i<data3.count;i++){
//        NSLog(@"Start %@", [[data3 objectAtIndex:i] objectForKey:@"start_location"]);
//        NSLog(@"End %@", [[data3 objectAtIndex:i] objectForKey:@"end_location"]);
//        
//    }

    
    
}

@end
