//
//  PLPlaceManager.m
//  Place
//
//  Created by Serhii on 4/9/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "PLPlaceManager.h"
#import "PlaceEntity.h"
#define kGOOGLE_API_KEY @"AIzaSyCdGd2IONvkd1--Bo8NXqyg9mgRkhDgOZ0"

@implementation PLPlaceManager

+ (PLPlaceManager *)sharedPlaceManager {
    
    static PLPlaceManager *sharedPlaceManager;
    
    @synchronized(self)
    {
        if (!sharedPlaceManager)
            sharedPlaceManager = [[PLPlaceManager alloc] init];
        return sharedPlaceManager;
    }
}

- (void) sendRequestWithType:(NSString *)placeType
                      coordinates:(CLLocationCoordinate2D) coordinates
                           radius:(NSInteger) radius {
    
     NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", coordinates.latitude,coordinates.longitude, [NSString stringWithFormat:@"%i", radius], placeType, kGOOGLE_API_KEY];
 
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    //[urlRequest setTimeoutInterval:30.0f];
    //[urlRequest setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate plaseManagerDidFinishWihError:error];
        } else {
        
           
            [self.delegate plaseManagerDidFinishWithPlaces:[self fetchedData:data]];
        }
    
    }];
}

-(NSArray *)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"JSON = %@", json);
    
    
    NSArray* places = [json objectForKey:@"results"];
    NSArray *result  = [self plotPlaces:places];
    
    return result;
    
    
}

-(NSArray*)plotPlaces:(NSArray *)data {
    
    NSMutableArray *places = [[NSMutableArray alloc] init];
    NSString *pathPlist = [[NSBundle mainBundle] pathForResource:
                           @"Places" ofType:@"plist"];
    NSMutableArray *arrayPlaces = [[NSMutableArray alloc] initWithContentsOfFile:pathPlist];

    for (int i=0; i<[data count]; i++) {
        
        PlaceEntity *placeEntity = [[PlaceEntity alloc] init];
        
        NSDictionary* place = [data objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *loc = [geo objectForKey:@"location"];
        NSString *name=[place objectForKey:@"name"];
        
        NSArray *photosLinks = [place objectForKey:@"photos"];
        
        NSURL *urlToPhoto = nil;
        if (photosLinks.count > 0 && photosLinks) {
            NSDictionary *photoParametses = [photosLinks objectAtIndex:0];
            NSString *photoRef = [photoParametses objectForKey:@"photo_reference"];
            NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=%@&sensor=false&key=%@",photoRef,kGOOGLE_API_KEY];
            urlToPhoto = [NSURL URLWithString:urlString];
        }
        
        NSArray* types = [place objectForKey:@"types"];
        NSString *type = [types objectAtIndex:0];
                NSInteger intType = 0;
        
        if ([arrayPlaces containsObject:type]) {
            intType = [arrayPlaces indexOfObject:type];
        }
        
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        placeEntity.latitude = placeCoord.latitude;
        placeEntity.longtitude = placeCoord.longitude;
        placeEntity.name = name;
        placeEntity.category = intType;
        
            
        UIImage *loadedImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:urlToPhoto]];
        placeEntity.photo = loadedImage;

        
        [places addObject:placeEntity];
        [placeEntity release];
    }
    
    [arrayPlaces release];
    NSArray *res = [places copy];
    [places release];
    
    return [res autorelease];
}

@end
