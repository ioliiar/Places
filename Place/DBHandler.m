//
//  DBAccess.m
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "DBHandler.h"
#import <sqlite3.h>

#import "RouteEntity.h"
#import "PlaceEntity.h"
//Place.PlaceId,Place.Name,Place.Comment,Place.Photo,Place.Visited,Place.Latitude,Place.Longtitude,Place.Category

#define SQLITE_ENABLE_MEMORY_MANAGEMENT

@implementation DBHandler {
    sqlite3 *database;
}

- (id)init {
    self = [super init];
    if (self) {
        [self openDB];
        [self createEditableDBIfNeeded];
    }
    return self;
}

- (void)dealloc {
    [self closeDB];
    [super dealloc];
}

#pragma mark Private DB methods

- (void)openDB {
    NSString *path = [[NSBundle mainBundle] pathForResource:kDBName ofType:@"sqlite"];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        NSLog(@"Opening Database");
    } else {
        sqlite3_close(database);
        printf("\n Cannot open DB %s",sqlite3_errmsg(database));
    }
}

- (void)closeDB {
    if (sqlite3_close(database) == SQLITE_OK) {
        NSLog(@"Closing Database");
    } else {
        printf("\n Cannot close DB %s",sqlite3_errmsg(database));
    }
}

- (void)createEditableDBIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *writableDB = [documentsDir stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.%@",kDBName,@"db"]];
    success = [fileManager fileExistsAtPath:writableDB];
    if (success) {
        return;
    }
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",kDBName,@"sqlite"]];
    success = [fileManager copyItemAtPath:defaultPath
                                   toPath:writableDB error:&error];
    if (!success) {
        NSLog(@"Failed to create writable database file: %@.", [error localizedDescription]);
    }
}

#pragma mark DB Queries

- (NSArray*)getPlacesByName:(NSString*)name {
    char *sql;
    NSMutableArray *placesArray = [[NSMutableArray alloc] init];
    
    if (name) {
        sql = "SELECT * FROM Place WHERE Place.Name =?";
    } else {
        sql = " SELECT * FROM Place";
    }
    
    sqlite3_stmt *statement;
    int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    
    if (name) {
      sqlResult = sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    // Retrieving result
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            PlaceEntity *place = [[PlaceEntity alloc] init];
            place.Id = sqlite3_column_int(statement, 0);
            
            char *nm = (char *)sqlite3_column_text(statement, 1);
            place.name = (nm) ? [NSString stringWithUTF8String:nm] : @"";
            
            char *cm = (char *)sqlite3_column_text(statement, 2);
            place.comment = (cm) ? [NSString stringWithUTF8String:cm] : @"";
            
            const void *ptr = sqlite3_column_blob(statement, 3);
            int imSize = sqlite3_column_bytes(statement, 3);
            NSData *imData = [[NSData alloc] initWithBytes:ptr length:imSize];
            place.photo = [UIImage imageWithData:imData];
            [imData release];
            double since1970 = sqlite3_column_double(statement, 4);
            place.dateVisited = [NSDate dateWithTimeIntervalSince1970:since1970];
            place.latitude = sqlite3_column_double(statement, 5);
            place.longtitude = sqlite3_column_double(statement, 6);
            place.category = sqlite3_column_int(statement, 7);
            [placesArray addObject:place];
            [place release];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Problem with database %d",sqlResult);
    }
    
    NSArray *result = [placesArray copy];
    [placesArray release];
    return [result autorelease];
}

- (BOOL)insertPlace:(PlaceEntity*)place {
    const char* sql = "INSERT INTO Place (Name,Comment,Photo,Visited,Latitude,Longtitude,Category) Values (?,?,?,?,?,?,?)";//read about this
    sqlite3_stmt *statement;
    int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    NSLog(@"sqlResult %i", sqlResult);
    
    if (sqlite3_step(statement) != SQLITE_DONE) {
        int rowID = sqlite3_last_insert_rowid(database);
        NSLog(@"last inserted rowId = %d",rowID);
    }
    
    sqlite3_finalize(statement);
    return YES;
}

- (BOOL)updatePlaceWithId:(NSInteger)Ident {
    return YES;
}

- (BOOL)deletePlaceWithId:(NSInteger)Ident {
    return YES;
}

// Route table
- (NSArray*)getRouteNamed:(NSString*)name {
    return nil;
}

- (BOOL)saveRoute:(NSArray*)route named:(NSString*)name {
    return YES;
}

- (BOOL)updateRouteWithId:(NSInteger)Ident {
    return YES;
}

- (BOOL)deleteRouteWithId:(NSInteger)Ident {
    return YES;
}

@end
