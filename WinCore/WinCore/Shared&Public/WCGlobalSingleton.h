//
//  WCGlobalSingleton.h
//  WinSFA
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//


//*/ location
#define kGlobalLatitude         @ "global_latitude"
#define kGlobalLongitude        @ "global_longitude"
#define kGlobalProvinceName     @ "global_provinceName"
#define kGlobalCityName         @ "global_cityName"
#define kGlobalAddress          @ "global_address"
#define kGlobalDistrict         @ "global_district"
//*/

//*/ network
#define kCommonToken @""
#define kCommonPlatform @"sfai_winchannel"
#define kCommonVer @"1.0.0"
#define kCommonSw @"CRM_LOREAL_A"
#define kCommonLang @"936"
#define kCommonSrc @"winchannel"
//*/

//*/ settings from UED
#define NAV_BUTTON_SIZE  12
#define NAV_TITLE_SIZE   22
#define LIST_TITLE_SIZE       20
#define PRODUCT_SORT_TITLE_SIZE   22
#define TEXT_SIZE        18
#define BUTTON_TITLE_SIZE  18
#define ICON_TEXT_SIZE   20

#define PINK_COLOR  [UIColor colorWithRed:212.0f/255 green:0 blue:125.0f/255 alpha:1]
#define BLACK_COLOR  [UIColor colorWithRed:52.0f/255 green:52.0f/255 blue:52.0f/255 alpha:1]
#define GRAY_COLOR  [UIColor colorWithRed:113.0f/255 green:113.0f/255 blue:111.0f/255 alpha:1]
#define WHITE_COLOR  [UIColor colorWithRed:255.0f/255 green:255.0f/255 blue:255.0f/255 alpha:1]
#define YELLOW_COLOR  [UIColor colorWithRed:238.0f/255 green:222.0f/255 blue:187.0f/255 alpha:1]
#define GOLD_COLOR  [UIColor colorWithRed:192.0f/255 green:159.0f/255 blue:94.0f/255 alpha:1]
#define BG_TRANSPARENT_BLACK_COLOR  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]
#define BLACK_TEXT_COLOR  [UIColor colorWithRed:83.0f/255.0f green:83.0f/255.0f blue:83.0f/255.0f alpha:1]

// landing page
#define GOLD_COLOR_NORMAL [UIColor colorWithRed:192.0f/255 green:159.0f/255 blue:94.0f/255 alpha:1]
#define GOLD_COLOR_HIGHLIGHT [UIColor colorWithRed:159.0f/255 green:115.0f/255 blue:53.0f/255 alpha:1]
#define BLACK_COLOR_LANDING_BG [UIColor colorWithRed:25.0f/255 green:25.0f/255 blue:25.0f/255 alpha:1]
#define IQKEYBOARD_COLOR_BG [UIColor colorWithRed:210.0f/255 green:210.0f/255 blue:210.0f/255 alpha:0.3]

#define LUCKYDRAW_ACVTCODE @"LOREAL_LOTTERY_1"

#define SIDE_MARGIN   20

#define HEIGHT_BIG_SIZE  190
#define HEIGHT_MEDIUM_SIZE  145
#define HEIGHT_SMALL_SIZE   85

#define DEFAULT_POINT  100
//*/

//*/ Sign In Up
#define gplistHAS_SIGN_IN       @"plist has sign in"
#define gplistHAS_LUCKY_DRAW    @"plist has lucky draw"
#define gplistUSER_NAME         @"plist user name"
#define gplistSOFTWARE_VERSION  @"plist software version"
#define gSWVersion              @"SWVersion"
//*/

#import <Foundation/Foundation.h>
#import "WCNaviFile.h"

#pragma mark - WCGlobalSingleton interface

@interface WCGlobalSingleton : NSObject
+ (WCGlobalSingleton *)sharedInstance;

//@property (nonatomic, strong) WCUserInfo *currentUser;

// network
@property (nonatomic, copy) NSString *gToken;
@property (nonatomic, copy) NSString *gIMEI;
@property (nonatomic, copy) NSString *gPlatform;
@property (nonatomic, copy) NSString *gVer;
@property (nonatomic, copy) NSString *gSw;
@property (nonatomic, copy) NSString *gLang;
@property (nonatomic, copy) NSString *gSrc;

// navi item
@property (nonatomic, strong) WCNaviFile *gNaviFileItem;


@end
