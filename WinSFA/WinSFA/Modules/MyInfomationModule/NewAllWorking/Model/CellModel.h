//
//  CellModel.h
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellModel : NSObject

// 回复数据的数组
@property(nonatomic,strong) NSArray * RevertArray;
// 信息的标题
@property(nonatomic,copy) NSString * MsgTitle;

// 信息主题
@property(nonatomic,copy)NSString * theme;

// 信息详情
@property(nonatomic,copy)NSString * themeDetal;

// 分类标签
@property(nonatomic,copy)NSString * msgLabel;

// 时间戳
@property(nonatomic,copy)NSString * timeStr;

// 已读 未读 属性
@property(nonatomic,assign) BOOL isReaded;

// 是否有图片
@property(nonatomic,assign)BOOL isPhoto;


-(instancetype)initWithDict:(NSDictionary * )dict;

+(instancetype)cellWithDict:(NSDictionary * )dict;

@end
