//
//  WinRPMapViewController.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "BaseViewController.h"
@class WinRPMapPOI;
//=================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void (^WinRPMapConfirmBlock)(WinRPMapPOI *mapPOI); //定义确认闭包

#pragma mark - RP地图管理器
@interface WinRPMapViewController : BaseViewController

@property (nonatomic, copy) NSString *searchPlaceholder;        //收索框占位符
@property (nonatomic, copy) NSString *searchPOI;                //搜索poi关键字
@property (nonatomic, copy) NSString *searchRange;              //搜索范围
@property (nonatomic, copy) NSString *searchCount;              //搜索条数
@property (nonatomic, copy) WinRPMapConfirmBlock confirmBlock;  //确认闭包

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================
