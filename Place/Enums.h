//
//  Enums.h
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#ifndef Place_Enums_h
#define Place_Enums_h

// keys for response
#define kTempDegrees @"Degrees"
#define kLocation    @"Location"
#define kRoutePoints @"Route"
#define kError       @"Error"
#define kDBName      @"Places"
#define kAnnotation  @"Annotation"
#define kPlaceChosen @"PlaceChosen"
#define kClearMap    @"ClearMap"
#define kAnnToRemove @"AnnotationToRemove"
#define kUpdateMap   @"UpdateMap"
#define kDirection   @"Direction"

//Enums

typedef enum {
    CategorySectionPlace,
    CategorySectionRoute,
    CategorySectionCount
} CategorySection;

typedef enum {
  CategoryOther,
  CategoryEntertainment,
  CategoryVisited,
  CategoryCount
} MyCategory;

typedef enum {
    MenuRowAddPlace,
    MenuRowAddRoute,
    MenuRowGoToMap,
    MenuRowCount
} MenuRow;

typedef enum {
    DescriptionRowName,
    DescriptionRowComment,
    DescriptionRowCategory,
    DescriptionRowDateVisited,
    DescriptionRowCount
} DescriptionRow;

typedef enum {
    RequestTypeWeather,
    RequestTypePlacemarkSearch,
    RequestTypeRoute,
    RequestTypeCount
} RequestType;

typedef enum {
    ResponseCodeOK,
    ResponseCodeError,
    ResponseCodeCount
} ResponseCode;

typedef enum {
    PlaceModeSurvey,
    PlaceModeChoose,
    PlaceModeCount
} PlaceMode;

#endif
