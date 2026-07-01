//
//  MainViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMainCellView.h"
#import "WCBaseViewController.h"
#import "WSBaseMainViewController.h"
#import "WSInfoService.h"

//默认进入工作重点fv
#define DEFAULT_HOMEPAGE_FV @"TAB_V1001"

@class WSGPSUpload;

@interface MainViewController : WSBaseMainViewController <WSMainCellViewDelegate,UIActionSheetDelegate, UIScrollViewDelegate,WSInfoServiceDelegate> {
    NSInteger _cellCount;
    NSInteger  _cellRows;
    NSInteger _cellColumns;
}

@property (nonatomic, strong)WSGPSUpload *iGPSUpload;
@property (nonatomic, assign)BOOL remindHasShown;
@property (nonatomic, assign)BOOL geoHasUpdated;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WSMainCellView *currentCellView;
@property (nonatomic, strong) NSArray *filterAcvts;

- (void)beginRefreshDataFromNewMessage;
- (NSInteger)markBadgeForMessage;
- (void)refreshMainCellViewImageWithFuncsBean:(WSFuncsBean *)fb;

@end
