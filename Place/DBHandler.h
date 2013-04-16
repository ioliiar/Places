//
//  DBAccess.h
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PlaceEntity;

@interface DBHandler : NSObject

//Places table
- (NSArray*)getPlacesByName:(NSString*)name;  // nil means all
- (NSArray*)getLastVisitedPlacesNamed:(NSString*)name; // nil means all
- (BOOL)insertPlace:(PlaceEntity*)place;
- (BOOL)updatePlaceWithId:(NSInteger)Ident;
- (BOOL)deletePlaceWithId:(NSInteger)Ident;

// Route table
- (NSArray*)getRouteNamed:(NSString*)name;
- (BOOL)saveRoute:(NSArray*)route named:(NSString*)name;
- (BOOL)updateRouteWithId:(NSInteger)Ident;
- (BOOL)deleteRouteWithId:(NSInteger)Ident;

@end
