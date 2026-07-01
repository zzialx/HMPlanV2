//
//  WSApplicationWindowsRelationManager.h
//  WinSFA
//
//  Created by HZH on 17/4/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSApplicationWindowsRelationManager : NSObject

+ (WSApplicationWindowsRelationManager *)sharedManager;

- (UIViewController *)getCurrentVC;

@end
