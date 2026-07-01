//
//  WSProductDetails.h
//  WinSFA
//
//  Created by huzepei on 16/7/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSSuggestPro;
@interface WSProductDetails : UIView

+ (instancetype)productDetailView;

@property (nonatomic,strong) WSSuggestPro *sp;

@property(nonatomic,copy) void (^callBack)();

@end
