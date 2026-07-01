//
//  ViewControllerMappingManager.h
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import <Foundation/Foundation.h>

@interface WCOptionalSource : NSObject

+ (WCOptionalSource *)sharedInstance;

- (UIViewController *)viewControllerFromKey:(NSString *)aKey;
- (NSString *)getViewControllerNamebyKey:(NSString *)aKey;
- (void)setViewControllerParam:(UIViewController *)vc byKey:(NSString *)aKey;
- (id)getValuebyKey:(NSString *)aKey;

@end
