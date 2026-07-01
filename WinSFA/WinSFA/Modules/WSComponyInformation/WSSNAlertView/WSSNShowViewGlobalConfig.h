//
//  EasyEmptyGlobalConfig.h
//  EasyShowViewDemo
//  Created by zzialx on 2023/2/14.
//  Copyright © 2023年 zzialx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSSNShowViewGlobalConfig : NSObject

@property (nonatomic,strong)UIColor *bgColor UI_APPEARANCE_SELECTOR ;   //背景颜色

@property (nonatomic,strong)UIFont  *tittleFont UI_APPEARANCE_SELECTOR ; //标题字体大小
@property (nonatomic,strong)UIColor *titleColor UI_APPEARANCE_SELECTOR ;//标题字体颜色

@property (nonatomic,strong)UIFont  *subtitleFont UI_APPEARANCE_SELECTOR ;  //副标题字体大小
@property (nonatomic,strong)UIColor *subTitleColor UI_APPEARANCE_SELECTOR ;//副标题字体颜色

@property (nonatomic,strong)UIFont  *buttonFont UI_APPEARANCE_SELECTOR ;    //按钮字体大小
@property (nonatomic,strong)UIColor *buttonColor UI_APPEARANCE_SELECTOR ;  //按钮字体亚瑟
@property (nonatomic,strong)UIColor *buttonBgColor UI_APPEARANCE_SELECTOR ;//按钮背景颜色

@property (nonatomic,assign)UIEdgeInsets buttonEdgeInsets UI_APPEARANCE_SELECTOR ; //按钮往内缩的边距（按钮四边边缘距离文字的距离）

@property (nonatomic,assign)BOOL scrollVerticalEnable ;//是否可以上下滚动

+ (WSSNShowViewGlobalConfig *)shared;


@end

NS_ASSUME_NONNULL_END

