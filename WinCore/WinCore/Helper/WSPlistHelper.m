//
//  PlistHelper.m
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import "WSPlistHelper.h"

static WSPlistHelper *sharedPlistHelper = nil;

@interface WSPlistHelper ()

@property (nonatomic, copy) NSString *plistName;
@property (nonatomic, strong) NSMutableDictionary *plistFileDatas;

@end

@implementation WSPlistHelper
@synthesize plistName = plistName_;

+ (WSPlistHelper *)sharedInstance {
    
    @synchronized(self) {
        
        if (sharedPlistHelper == nil) {
            sharedPlistHelper = [[self alloc] init];
        }
    }
    return sharedPlistHelper;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    @synchronized(self) {
        
        if (sharedPlistHelper == nil) {
            sharedPlistHelper = [super allocWithZone:zone];
            return sharedPlistHelper;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

+ (NSDictionary *)allPropertiesWithPlistName:(NSString *)aPlistName {
    
    NSMutableDictionary *plistDic = [sharedPlistHelper.plistFileDatas objectForKey:aPlistName];
    if (plistDic == nil) {
        
        if (sharedPlistHelper.plistFileDatas == nil) {
            sharedPlistHelper.plistFileDatas = [[NSMutableDictionary alloc] init];
        }
        
        NSString *configFileString = [[NSBundle mainBundle] pathForResource:aPlistName ofType:@"plist"];
        plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:configFileString];
        if (plistDic) {
            
            [sharedPlistHelper.plistFileDatas setObject:plistDic forKey:aPlistName];
            
            if ([aPlistName isEqualToString:kControllerMappingFileName]) {
                
                NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
                NSDictionary *projectMappings = [WSPlistHelper allPropertiesWithPlistName:kControllerMapping4ProjectsFileName];
                if (projectName == nil ) {
                    assert(@"ProjectName Can't be nil!!!");
                }
                
                if ([projectMappings.allKeys containsObject:projectName]) {
                    
                    NSDictionary *dic = [projectMappings objectForKey:projectName];
                    if (dic != nil && dic.count > 0) {
                        [plistDic setValuesForKeysWithDictionary:dic];
                    }
                }
            }
        }
    }
    
    return plistDic;
}

+ (id)valueForKey:(NSString *)aKey withPlistName:(NSString *)aPlistName {
    
    if (aPlistName == nil || aKey == nil) {
        return nil;
    }
    
    aKey = [aKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDictionary *plistDic = [WSPlistHelper allPropertiesWithPlistName:aPlistName];
    return [plistDic objectForKey:aKey];
}

+ (NSString *)getApppPackageType {
    
    NSString *packageType = @"";
    NSString *svnVersion = [self valueForKey:SVNVersion withPlistName:kConfilgFileName];
    if ([svnVersion rangeOfString:@"uat"].location != NSNotFound) {
        packageType = @"uat";
    }
    else if ([svnVersion rangeOfString:@"test"].location != NSNotFound) {
        packageType = @"test";
    }
    return packageType;
}

+ (NSString *)getAppBuildType {
    
    NSString *buildType = @"";
    NSString *svnVersion = [self valueForKey:SVNVersion withPlistName:kConfilgFileName];
    NSRange range = [svnVersion rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        buildType = [svnVersion substringFromIndex:range.location + 1];
    }
    return buildType;
}

+ (NSString *)getPasswordEncrypt {
    
    NSString *saasurl =  [WSPlistHelper valueForKey:kSAAS_URL withPlistName:kConfilgFileName];
    if ([saasurl length] > 0) {
        return @"0";
    }
    
    NSString *paramInLoginData = [self valueForKey:@"GET_PARAM_IN_LOGIN_DATA" withPlistName:kConfilgFileName];
    if ([paramInLoginData isEqualToString:@"1"]) {
        return @"0";
    }
    
    NSString *passwordEncrypt = [self valueForKey:kPWD_ENCRYPT withPlistName:kConfilgFileName];
    return passwordEncrypt;
}

@end
