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

@interface DBHandler ()

@property (nonatomic, copy) NSString *writableDBPath;

@end


@implementation DBHandler {
    sqlite3 *database;
}

static DBHandler *sharedInstance = nil;


+ (DBHandler *)sharedDBHandler {
    @synchronized(self){
        if (sharedInstance == nil) {
            sharedInstance  = [[super allocWithZone:NULL] initialize];
        }
        return sharedInstance;
    }
}

+ (id) allocWithZone:(NSZone *)zone {
    return [[self sharedDBHandler] retain];
}

- (id) copyWithZone:(NSZone*)zone {
    return self;
}

- (id) retain {
    return self;
}

- (NSUInteger) retainCount {
    return NSUIntegerMax;
    
}

- (oneway void) release {
}

- (id) autorelease {
    return self;
}

- (id)initialize {
    self = [super init];
    if (self) {
        [self createEditableDBIfNeeded];
        [self openDB];
    }
    return self;
}

- (void)dealloc {
    [_writableDBPath release];
    [self closeDB];
    [super dealloc];
}

#pragma mark Private DB methods

- (void)openDB {
    if (sqlite3_open([_writableDBPath UTF8String], &database) == SQLITE_OK) {
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
    self.writableDBPath = [documentsDir stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.%@",kDBName,@"sqlite"]];
    success = [fileManager fileExistsAtPath:_writableDBPath];
    if (success) {
        NSLog(@"DB is already created");
        return;
    }
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",kDBName,@"sqlite"]];
    success = [fileManager copyItemAtPath:defaultPath
                                   toPath:_writableDBPath error:&error];
    if (!success) {
        NSLog(@"Failed to create writable database file: %@.", [error localizedDescription]);
    }
}

#pragma mark DB Queries

- (PlaceEntity *)getPlaceById:(NSInteger)Ident {
    char *sql = "SELECT * FROM Place WHERE Place.PlaceId =?";
    sqlite3_stmt *statement;
    int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    
    if (sqlResult != SQLITE_OK) {
        printf("%s",sqlite3_errmsg(database));
        NSLog(@"Problem with preparing query %d",sqlResult);
        return nil;
    }
    
    sqlResult = sqlite3_bind_int(statement, 0, Ident);

    // Retrieving result
    if (sqlResult != SQLITE_OK) {
        printf("%s",sqlite3_errmsg(database));
        NSLog(@"Problem with database %d",sqlResult);
        return nil;
    }

    if (sqlite3_step(statement) != SQLITE_ROW) {
        printf("%s",sqlite3_errmsg(database));
        NSLog(@"Problem with retrieving %d",sqlResult);
        sqlite3_finalize(statement);
        return nil;
    }
    
    PlaceEntity *place = [[PlaceEntity alloc] init];
    place.Id = sqlite3_column_int(statement, 0);
    
    char *cName = (char *)sqlite3_column_text(statement, 1);
    place.name = (cName) ? [NSString stringWithUTF8String:cName] : @"";
    
    char *cComment = (char *)sqlite3_column_text(statement, 2);
    place.comment = (cComment) ? [NSString stringWithUTF8String:cComment] : @"";
    
    NSData *getImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 3) length:sqlite3_column_bytes(statement, 3)];
    place.photo=[UIImage imageWithData:getImageData];
    
    place.dateVisited = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 4)];
    
    place.latitude =(double)sqlite3_column_double(statement, 5);
    place.longtitude =(double)sqlite3_column_double(statement, 6);
    place.category = sqlite3_column_int(statement, 7);
   
    char *cRoute = (char *)sqlite3_column_text(statement, 8);
    place.route = (cRoute) ? [NSString stringWithUTF8String:cRoute] : @"";
    
    [getImageData release];
    sqlite3_finalize(statement);
    
    return [place autorelease];
}

- (NSArray *)getPlacesByName:(NSString*)name {
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
            
            place.category = sqlite3_column_int(statement, 7);
            if (place.category == 0) {
                [place release];
                continue;
            }
            place.Id = sqlite3_column_int(statement, 0);
            
            char *cName = (char *)sqlite3_column_text(statement, 1);
            place.name = (cName) ? [NSString stringWithUTF8String:cName] : @"";
            
            
            char *cComment = (char *)sqlite3_column_text(statement, 2);
            place.comment = (cComment) ? [NSString stringWithUTF8String:cComment] : @"";
            
            NSData *getImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 3) length:sqlite3_column_bytes(statement, 3)];
            place.photo=[UIImage imageWithData:getImageData];
            
            place.dateVisited = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 4)];
                        
            place.latitude =(double)sqlite3_column_double(statement, 5);
         
            place.longtitude =(double)sqlite3_column_double(statement, 6);

            char *cRoute = (char *)sqlite3_column_text(statement, 8);
            place.route = (cRoute) ? [NSString stringWithUTF8String:cRoute] : @"";
            

            [placesArray addObject:place];
            [place release];
            [getImageData release];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Problem with database %d",sqlResult);
    }
    
    NSArray *result = [placesArray copy];
    [placesArray release];
    
    return [result autorelease];
}

- (NSArray*)getLastVisitedPlacesNamed:(NSString*)name {
   
    char *sql;
    NSMutableArray *placesArray = [[NSMutableArray alloc] init];
    if (name) {
        sql = "SELECT * FROM Place WHERE Place.Visited =?";
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
    
            char *cName = (char *)sqlite3_column_text(statement, 1);
            place.name = (cName) ? [NSString stringWithUTF8String:cName] : @"";
            
            
            char *cComment = (char *)sqlite3_column_text(statement, 2);
            place.comment = (cComment) ? [NSString stringWithUTF8String:cComment] : @"";
            
            NSData *getImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 3) length:sqlite3_column_bytes(statement, 3)];
            place.photo=[UIImage imageWithData:getImageData];
            
            place.dateVisited = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement, 4)];
            
            place.latitude =(double)sqlite3_column_double(statement, 5);
            
            place.longtitude =(double)sqlite3_column_double(statement, 6);
            place.category = sqlite3_column_int(statement, 7);

            char *cRoute = (char *)sqlite3_column_text(statement, 8);
            place.route = (cRoute) ? [NSString stringWithUTF8String:cRoute] : @"";
            
            [placesArray addObject:place];
            [place release];
            [getImageData release];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Problem with database %d",sqlResult);
    }
    
    NSArray *result = [placesArray copy];
    [placesArray release];
    
    return [result autorelease];
    
    return nil;
}

- (BOOL)insertPlace:(PlaceEntity*)place {
    const char* sql = "INSERT INTO Place (Name,Comment,Image,Visited,Latitude,Longitude,Category,Route) Values (?,?,?,?,?,?,?,?)";
    
    sqlite3_stmt *statement;
 
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL)==SQLITE_OK) {
        
        sqlite3_bind_text(statement,1,[place.name UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,2,[place.comment UTF8String],-1,SQLITE_TRANSIENT);
        
        NSData *imageData=UIImagePNGRepresentation(place.photo);
        sqlite3_bind_blob(statement, 3, [imageData bytes], [imageData length], NULL);
        
        sqlite3_bind_double(statement, 4, [place.dateVisited timeIntervalSince1970]);
        sqlite3_bind_double(statement,5,place.latitude);
        sqlite3_bind_double(statement,6,place.longtitude);
        sqlite3_bind_int(statement, 7, place.category);
        sqlite3_bind_text(statement, 8, [place.route UTF8String], -1, SQLITE_TRANSIENT);
    
    } 
 
    if (sqlite3_step(statement) != SQLITE_DONE) {
        int rowID = sqlite3_last_insert_rowid(database);
        NSLog(@"last inserted rowId = %d",rowID);
        printf("%s",sqlite3_errmsg(database));
        return NO;
    }
    
    sqlite3_finalize(statement);
    return YES;
}

- (BOOL)updatePlace:(PlaceEntity *)place{
    
    const char *sql = "UPDATE Place Set Name = ?, Comment = ?, Image = ?, Visited = ?, Latitude = ?, Longitude = ?, Category = ?,Route = ?    Where PlaceId = ?";
    sqlite3_stmt *statement;
   
    if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK){
        sqlite3_bind_text(statement,1,[place.name UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement,2,[place.comment UTF8String],-1,SQLITE_TRANSIENT);
        NSData *imageData=UIImagePNGRepresentation(place.photo);
        sqlite3_bind_blob(statement, 3, [imageData bytes], [imageData length], NULL);
        sqlite3_bind_double(statement, 4, [place.dateVisited timeIntervalSince1970]);
        sqlite3_bind_double(statement,5,place.latitude);
        sqlite3_bind_double(statement,6,place.longtitude);
        sqlite3_bind_int(statement, 7, place.category);
        sqlite3_bind_text(statement,8,[place.route UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 9, place.Id);
    }
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Update has not been successuly completed ");
         printf("%s",sqlite3_errmsg(database));
        return NO;
    }
    sqlite3_finalize(statement);
    return YES;
}

- (BOOL)deletePlaceWithId:(NSInteger)Ident {
    const char *sql = "DELETE FROM Place WHERE PlaceId = ?";
    sqlite3_stmt *deleteStmt;
    if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) !=SQLITE_OK)      {
        printf("%s",sqlite3_errmsg(database));
        return NO;
    }
    sqlite3_bind_int(deleteStmt, 1, Ident);
    if (sqlite3_step(deleteStmt) != SQLITE_DONE){
        printf("%s",sqlite3_errmsg(database));
        return NO;
        
    }
    sqlite3_reset(deleteStmt);
    return YES;
}


// Route table

- (NSArray*)getRouteNamed:(NSString*)name {
    char *sql;
    NSString *tmp=[[NSString alloc]init];
    NSMutableArray *routesArray = [[NSMutableArray alloc] init];
    
    if (name) {
        sql = "SELECT * FROM Place WHERE Place.Route =?";
    } else {
        sql = " SELECT * FROM Place";
    }
    
    sqlite3_stmt *statement;
    int sqlResult = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
    
    if (name) {
        sqlResult = sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    if (sqlResult == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
   
            RouteEntity *route = [[RouteEntity alloc] init];
            route.Id = sqlite3_column_int(statement, 0);
            char *cName = (char *)sqlite3_column_text(statement, 8);
            route.name = (cName) ? [NSString stringWithUTF8String:cName] : @"";
            
            if (![route.name isEqual:tmp]) {
                [routesArray addObject:route];
                tmp=[route.name copy];
                [route release];
             }
        
        }
    sqlite3_finalize(statement);
    }
    else{
        
        NSLog(@"Problem with Databse? :%i",sqlResult);
    }
    NSArray *result = [routesArray copy];
    [routesArray release];
    [tmp release];

    return [result autorelease];

}

- (BOOL)saveRoute:(NSArray*)place named:(NSString*)name {

    sqlite3_stmt *statement;
   
    const char* sql2 = "INSERT INTO Place (Name,Comment,Image,Visited,Latitude,Longitude,Category,Route) Values (?,?,?,?,?,?,?,?)";
    
    for (int i=0; i<place.count; i++) {
        
        if (sqlite3_prepare_v2(database, sql2, -1, &statement, NULL)==SQLITE_OK) {
          
            PlaceEntity *lPlace=[place objectAtIndex:i];
         
            sqlite3_bind_text(statement,1,[lPlace.name UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement,2,[lPlace.comment UTF8String],-1,SQLITE_TRANSIENT);
            
            NSData *imageData=UIImagePNGRepresentation(lPlace.photo);
            sqlite3_bind_blob(statement, 3, [imageData bytes], [imageData length], NULL);
            
            sqlite3_bind_double(statement, 4, [lPlace.dateVisited timeIntervalSince1970]);
            sqlite3_bind_double(statement,5,lPlace.latitude);
            sqlite3_bind_double(statement,6,lPlace.longtitude);
            sqlite3_bind_int(statement, 7, lPlace.category);
            sqlite3_bind_text(statement, 8, [name UTF8String], -1, SQLITE_TRANSIENT);
            
        }
        if (sqlite3_step(statement) != SQLITE_DONE) {
            int rowID = sqlite3_last_insert_rowid(database);
            NSLog(@"last inserted rowId = %d",rowID);
            printf("%s",sqlite3_errmsg(database));
            return NO;
        }
    }
    
    sqlite3_finalize(statement);
    
    return YES;
}

- (BOOL)updateRoute:(RouteEntity *)route {
    
    const char *sql = "UPDATE Place Set Route = ? Where PlaceId = ?";
    
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK){

        
    }
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"Update has not been successuly completed ");
        printf("%s",sqlite3_errmsg(database));
        return NO;
    }
    sqlite3_finalize(statement);
    return YES;
}

- (BOOL)deleteRouteWithId:(NSString *)name {
 
    NSString *sSql = [NSString stringWithFormat: @"DELETE FROM Place where Route ='%@'",name];
    const char *sql = [sSql UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) !=SQLITE_OK)      {
        printf("%s",sqlite3_errmsg(database));
        return NO;
    }

    sqlite3_bind_text(statement, 1, sql, -1, SQLITE_STATIC);
    if (sqlite3_step(statement) != SQLITE_DONE){
        printf("%s",sqlite3_errmsg(database));
        return NO;
    }
    sqlite3_reset(statement);
    return YES;
}

-(void)reindexDatabase{
    if(sqlite3_exec(database, "VACUUM;REINDEX", 0, 0, NULL)==SQLITE_OK) {
        NSLog(@"Vacuumed DataBase");
    } else {
        NSLog(@"Can't Vacuume DataBase");
    }
}

@end
