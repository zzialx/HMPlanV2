//
//  WSHomeProDetails.h
//  WinSFA
//
//  Created by huzepei on 16/9/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSSuggestHomePro;

@interface WSHomeProDetails : UIView

+ (instancetype)homeProductDetailView;

//菜式的模型
@property (nonatomic,strong) WSSuggestHomePro *sp;

//配方的模型
@property (nonatomic,strong) WSSuggestHomePro *formulaSp;

//自制配方的模型
@property (nonatomic,strong) WSSuggestHomePro *recipesSp;

@property (nonatomic,copy) NSString *type;

@property(nonatomic,copy) void (^callBack)();

@end
