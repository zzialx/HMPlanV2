//
//  PlistHelper.h
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import <Foundation/Foundation.h>

#define kConfilgFileName                    @"configFile"
#define kControllerMappingFileName          @"controllerMapping"
#define kControllerMapping4ProjectsFileName @"controllerMapping4Projects"
#define kSkinStyleFileName                  @"skinStyle"
#define kDataBaseMappingFileName            @"dataBaseMapping"
#define kInsertTablesFileName               @"insertTables"

#define kServerIP                           @"ServerIP"
#define SVNVersion                          @"SVNVersion"
#define kEaseMobAppKey                      @"EaseMobAppKey"
#define kSSO_LOGIN                          @"SSO_LOGIN"
#define kSSO_SESSION                        @"SSO_SESSION"
#define kGET_PASSWORD_URL                   @"GET_PASSWORD_URL"
#define kMODIFY_PASSWORD_URL                @"MODIFY_PASSWORD_URL"
#define kGaode_key                          @"gaode_key"
#define kBaiduMap_key                       @"BaiduMapKey"
#define kYOUMENG_key                        @"youmeng_key"
#define kAliyunAccessKey                    @"AliyunAccessKeyId"
#define kAliyunSecretKey                    @"AliyunAccessKeySecret"
#define kAliyunEndPoint                     @"AliyunEndPoint"
#define kAliyunBucket                       @"AliyunBucket"
#define kSAAS_URL                           @"SAAS_URL"
#define kPWD_ENCRYPT                        @"PasswordEncrypt"
#define kSSO_JSESSIONID                     @"JSESSIONID"

#define kCLEAR_COLOR_value                  [UIColor colorWithHexString:@""]
#define kCOLOR_TEXT_value                   [UIColor colorWithHexString:@"#6c6c6c"]
#define kBLACK_COLOR_value                  [UIColor colorWithHexString:@"#3D3D3D"]

@interface WSPlistHelper : NSObject

+ (NSDictionary *)allPropertiesWithPlistName:(NSString *)aPlistName;
+ (id)valueForKey:(NSString *)aKey withPlistName:(NSString *)aPlistName;
+ (NSString *)getApppPackageType;
+ (NSString *)getAppBuildType;
+ (NSString *)getPasswordEncrypt;

@end
