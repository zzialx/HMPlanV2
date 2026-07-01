//
//  AppData.h
//  WinchannelMobile_iphone
//
//  Created by Chen Angus on 11-7-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSubempstoreBean.h"
#import "WSAddStoreTable.h"

#define EMPNAME             @"empName"
#define STORE_TYPE          @"storetype"
#define BASETIME_TICKCOUNT  @"basetickcount"
#define MOBILEHOMEPAGE      @"mobileHomePage"
#define MobileHomePageFcKey             @"fc"
#define MobileHomePageReadingTimeKey    @"readingTime"
#define MOBILEPICTURE       @"mobilePicture"
#define APPDATA_MAXCALLNUM  @"maxcallnum"
#define APPDATA_NOREPLY     @"noreply"
#define SHORTCUT_STORE_ID   @"shortCutStoreId"

@interface WSAppData : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *datas;
@property (nonatomic, assign) BOOL showHomePage;


+ (WSAppData *) sharedManager;
+ (void)putData:(id)object;
+ (void)putObject:(id) object forKey:(NSString *)key;
+ (id)getUnplannedData:(id)key;
+ (id)getObjectbyKey:(const NSString *)key;
+ (BOOL)hasObject:(const NSString *)key;
+ (BOOL)removeAll;
+ (id)getLocalObject;
+ (time_t)uptime;

//YIHAIKERRY-4249
+ (BOOL)getIsShowLoginRedirectWithFcCode:(NSString *)fcCode;
+ (void)setIsShowLoginRedirectWithFcCode:(NSString *)fcCode;
+ (void)removeIsShowLoginRedirect;
+ (NSString *)compareCurrentStrTime:(NSString*)compareStr withMonth:(int)month andDays:(int)days;

//+ (uint64_t) getTickCount;
//+ (NSDate *) getCurrentDate;

@end
