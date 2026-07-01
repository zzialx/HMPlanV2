//
//  WSGenerateSuggestForHomeViewController.h
//  WinSFA
//
//  Created by HZH on 16/9/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"

@class WSSuggestHome;

@interface WSGenerateSuggestForHomeViewController : UIViewController

@property(nonatomic,copy) void (^sug)(WSSuggestHome *);

// 模板类型 [01:菜式应用  02:配方应用]
@property (nonatomic, copy) NSString *sStyle;
// 建议单名称
@property (nonatomic, copy) NSString *sTableName;

//门店ID
@property (nonatomic, copy) NSString *storeID;

//准备日期
@property (nonatomic, copy) NSString *prepareDate;
/**
 *  外面传进来的可点击的suhome
 */
@property (nonatomic,strong) WSSuggestHome *suhome;


@end
