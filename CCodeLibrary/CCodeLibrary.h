//  CCodeLibrary.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CCodeTypes.h"
#import "MPIntersection.h"
#import "IntersectionPoint.h"
#import "FTPDataPull.h"
#import "FTPDataPush.h"
#import "CustomAlert.h"
#import "MathTypes.h"
#import "MathUtil.h"
#import "NetworkManager.h"
#import "TileGraphics.h"
#import "UserDefaults.h"
#import "MPIntersection.h"
#import "PlacesInfo.h"
#import "GeoMasterServer.h"
#import "compress.h"
#import "VerticalSegmentedControl.h"
#import "IntersectionsDatabase.h"
#import "GetPlaceAreaFile.h"
#import "GetAssignments.h"
#import "IntersectionRecord.h"
#import "ManagePlacesDatabase.h"
#import "GSSiPopoverView.h"
#import "CRAPI.h"
#import "SharedDefaults.h"
#import "FacilitiesDatabase.h"
#import "LegendView.h"
#import "GSSiEnums.h"
#import "PriorityLocation.h"
#import "PointInAreaClass.h"
#import "GetPriorityLocations.h"
#import "GSSiAlertController.h"
#import "SpreadsheetView.h"
#import "GSSiDatePicker.h"
#import "GSSiNotesView.h"
#import "RampTypeView.h"
#import "PickedItem.h"

#define GOOGLE_API_KEY @"AIzaSyB7XIgauC5W-veOVKKdTvkYTO5zQxquw9Q"
#define GOOGLE_SERVER_KEY @"AIzaSyBQvw3ROLNlUtuSlVdnk0zLvnbonh3I3vw"
#define iPAD_HEIGHT 1024.0
#define iPAD_WIDTH 768.0
#define APP_GROUP_ID @"group.com.GSSi.SurveyApps";
#define NUMREADINGS 30
#define LEFT 1
#define MIDDLE 2
#define RIGHT 3
#define DEGREES(radians) ((radians) * (180.0 / M_PI))
#define RADIANS(degrees) ((degrees) / 180.0 * M_PI)
#define RADIANS_SLOPE(degrees) (100.0 * sin(RADIANS(degrees)))
#define METERS_PER_FOOT 0.3048
#define DEFAULT_OFFSET 150 //150 feet -> this is the default value

@interface CCodeLibrary : NSObject

@end