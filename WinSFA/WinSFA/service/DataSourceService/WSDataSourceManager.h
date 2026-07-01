//
//  WSDataSourceManager.h
//  WinSFA
//
//  Created by yang on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSBaseModel;

@interface WSDataSourceManager : NSObject

+ (WSDataSourceManager*)sharedInstance;

@property (nonatomic, strong) WSBaseModel *currentActiveModel;

@end
