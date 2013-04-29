//
//  DBAccess.h
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PlaceEntity;
@class RouteEntity;

@interface DBHandler : NSObject

+ (DBHandler *)sharedDBHandler;

//Places table
- (NSArray*)getPlacesByName:(NSString*)name;  // nil means all
- (NSArray*)getLastVisitedPlacesNamed:(NSString*)name; // nil means all
- (BOOL)insertPlace:(PlaceEntity*)place;
- (BOOL)updatePlace:(PlaceEntity *)place;
- (BOOL)deletePlaceWithId:(NSInteger)Ident;
- (PlaceEntity *)getPlaceById:(NSInteger)Ident;

// Route table

- (NSArray *)getAllRoutes;
- (RouteEntity *)getRouteNamed:(NSString*)name;
- (BOOL)saveRoute:(NSArray*)place named:(NSString*)name;
- (BOOL)updateRoute:(RouteEntity *)route;
- (BOOL)deleteRouteWithId:(NSString *)name;

@end
