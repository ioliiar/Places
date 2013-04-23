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
    NSMutableArray *allPoints = [[NSMutableArray alloc] init];
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:self.data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&err];
    
    NSLog(@"%@",responseObject);
    NSArray *routes = [responseObject objectForKey:@"routes"];
    NSString *status = [responseObject objectForKey:@"status"];
    if (![status isEqualToString:@"OK"]) {
        self.response = nil;
        self.response = [[[Response alloc] init] autorelease];
        self.response.code = ResponseCodeError;
        self.response.responseInfo = [NSDictionary dictionaryWithObject:status forKey: kError];
        [self.delegate request:self didFinishedWithResponse:self.response];
        return;
    }
    
    for (int j = 0; j < [routes count]; j++) {
        NSDictionary *route = [routes objectAtIndex:j];
        if (route) {
            NSArray *legs = [route objectForKey:@"legs"];
            
            for (int i = 0; i < [legs count]; i++) {
                NSDictionary *leg = [legs objectAtIndex:i];
                NSArray *steps = [leg objectForKey:@"steps"];
                
                for (int k = 0 ; k < [steps count]; k++) {
                    NSDictionary *step = [steps objectAtIndex:k];
                    NSDictionary *polyline = [step objectForKey:@"polyline"];
                    NSString *encodedVal = [polyline objectForKey:@"points"];
                    NSArray *points = [self decodePolyline:encodedVal];
                    [allPoints addObjectsFromArray:points];
                }
            }
            
        }
    }
    NSArray *encResults = [allPoints copy];
    [allPoints release];
    self.response = nil;
    self.response = [[[Response alloc] init] autorelease];
    self.response.code = ResponseCodeOK;
    self.response.responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:[encResults autorelease],kDirection,nil];
    
    [self.delegate request:self didFinishedWithResponse:self.response];
    [connection release];
    [data release];
    
}

- (NSMutableArray *)decodePolyline:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    const char *poly = [encoded UTF8String];
    NSInteger index = 0;
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = poly[index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = poly[index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
        NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
        CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
        [array addObject:loc];
    }
    [encoded release];
    return array;
}

@end
