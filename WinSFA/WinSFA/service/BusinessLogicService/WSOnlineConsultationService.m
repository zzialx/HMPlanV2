//
//  WSOnlineConsultationService.m
//  WinSFA
//
//  Created by HZH on 2017/12/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSOnlineConsultationService.h"
#import "WSUserInfo.h"
#import "WSReportFormController.h"
#import "WSUserInfo.h"
#import "WSEMSDKManager.h"
#import "WSEnvrionment.h"

@interface WSOnlineConsultationService ()

@property (nonatomic, copy) NSString *temporaryOnlineConsultationString;
@property (nonatomic, copy) NSString *temporaryOnlineConsultationServerString;

@end

@implementation WSOnlineConsultationService

static WSOnlineConsultationService *onlineConsultationService = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onlineConsultationService = [[WSOnlineConsultationService alloc] init];
    });
    return onlineConsultationService;
}

- (void)gotoNextOnlineConsultationReportFormViewControllerWithOnlineConsultationString:(NSString *)onlineConsultationString
{
    NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
    
    if (onlineConsultationString && onlineConsultationString.length > 0) {
        online_Consultation = onlineConsultationString;
        self.temporaryOnlineConsultationServerString = onlineConsultationString;
    }
    
    if (online_Consultation && online_Consultation.length > 0) {
        
        WSAppDelegate *appDelegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        UIWindow *mianWindow = appDelegate.window;

        if ([mianWindow.rootViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navC = (UINavigationController *)mianWindow.rootViewController;
            [self rebuildOnlineConsultationUrlStringWithLastVCTitle:navC.title];
            
            if (self.temporaryOnlineConsultationString && self.temporaryOnlineConsultationString.length > 0) {
                online_Consultation = self.temporaryOnlineConsultationString;
            } else {
                online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
            }
            
            WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:
                                            [NSURL URLWithString:[online_Consultation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            rfvc.title = NSLocalizedString(@"online_consult", nil);
            [navC pushViewController:rfvc animated:YES];
        }
        else if ([mianWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *tabbarC = (UITabBarController *)mianWindow.rootViewController;
            UIViewController *tabbarSelectedVC = [[tabbarC viewControllers] objectAtIndex:[tabbarC selectedIndex]];
            
            if ([tabbarSelectedVC isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navC = (UINavigationController *)tabbarSelectedVC;
                [self rebuildOnlineConsultationUrlStringWithLastVCTitle:navC.title];
                
                if (self.temporaryOnlineConsultationString && self.temporaryOnlineConsultationString.length > 0) {
                    online_Consultation = self.temporaryOnlineConsultationString;
                } else {
                    online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
                }
                
                WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:
                                                [NSURL URLWithString:[online_Consultation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                rfvc.title = NSLocalizedString(@"online_consult", nil);
                rfvc.hidesBottomBarWhenPushed = YES;
                [navC pushViewController:rfvc animated:YES];
            }
        }
    }
}

// MSTD-6187 获取本地部分参数信息并重组URL
- (void)rebuildOnlineConsultationUrlStringWithLastVCTitle:(NSString *)lastVCTitle
{
    NSString *online_Consultation_Server = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION_SERVER];
    if (self.temporaryOnlineConsultationServerString && self.temporaryOnlineConsultationServerString.length > 0) {
        online_Consultation_Server = self.temporaryOnlineConsultationServerString;
    }
    
    //YIHAIKERRY-4217 2018-09-28
    NSString *finalString = [WSOnlineConsultationService rebuildOnlineConsultationUrlStringWithUrl:online_Consultation_Server];

    if (finalString && finalString.length > 0) {
        if (self.temporaryOnlineConsultationServerString && self.temporaryOnlineConsultationServerString.length > 0) {
            self.temporaryOnlineConsultationString = finalString;
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:finalString forKey:ONLINE_CONSULTATION];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

//YIHAIKERRY-4217 2018-09-28
+ (NSString *)rebuildOnlineConsultationUrlStringWithUrl:(NSString *)url
{
    if (!url || url.length <= 0) {
        return url;
    }
    
    if ([url rangeOfString:@"webchat.7moor.com"].location == NSNotFound) {
        return url;
    }
    
    NSString *transString = [NSString stringWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *otherParamString = transString;
    NSArray *keyArrays = @[@"$name$",@"$os$",@"$osVer$",@"$prod$",@"$ver$",@"$account$",@"$tel$",@"$org$",@"$role$",@"$lastAccount$",@"$empCode$"];
    
    NSString *FeaturesLString = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:EMPNAME]];
    NSString *osString = @"iOS";
    NSString *osVersionString = [NSString stringNotNilWithValue:[[UIDevice currentDevice] systemVersion]];
    NSString *prodNameString = [NSString stringNotNilWithValue:[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"]];
    NSString *prodVersionString = [NSString stringNotNilWithValue:[WSEnvrionment getAppSystemVersion]];
    NSString *accountString = [NSString stringNotNilWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]];
    NSString *lastAccountString = [NSString stringNotNilWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN]];
    
    WSUserInfo *userInfo = [[WSEMSDKManager sharedInstance] getUserInfo];
    NSString *telString = [NSString stringNotNilWithValue:userInfo.wsphone];
    NSString *orgString = [NSString stringNotNilWithValue:userInfo.wsdePartID];
    NSString *roleString = [NSString stringNotNilWithValue:userInfo.wsroleName];
    NSString *empCodeString = [NSString stringNotNilWithValue:userInfo.wsempCode];
    
    NSArray *valuesArrays = @[FeaturesLString, osString, osVersionString, prodNameString, prodVersionString, accountString, telString,
                              orgString, roleString, lastAccountString, empCodeString];
    for (int i = 0; i < keyArrays.count ; i++) {
        otherParamString = [otherParamString stringByReplacingOccurrencesOfString:keyArrays[i] withString:valuesArrays[i]];
    }
    
    return ((otherParamString && otherParamString.length > 0) ? [NSString stringWithFormat:@"%@", otherParamString] : url);
}

@end
