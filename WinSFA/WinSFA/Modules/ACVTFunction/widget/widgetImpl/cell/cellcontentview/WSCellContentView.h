//
//  WSCellContentView.h
//  WinSFA
//
//  Created by winchannel on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSWidget.h"

@protocol I_W_PosDisplayInfo;

@protocol I_W_Cell;

@interface WSCellContentView : WSWidget

@property (nonatomic,strong)  UIView   *leftView;  //左侧标题

@property (nonatomic,strong)  UIView   *rightView; //右侧标题

@property (nonatomic,strong)  UIView   *mainView;  //主标题

@property (nonatomic,strong)  UIView   *assisantView; //副标题

@property (nonatomic,strong)  NSMutableArray  *contentArray; //内容array

@property (nonatomic,strong)  NSString *assignedViewId;


-(void)clearContent;  //清除内容

-(void)onChangeEvent; //发生内容改变事件时，要触发一些事件

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)content; //载入内容

-(NSObject<I_W_BuildInfo> *)getBuildInfoByType:(NSInteger)buildInfoInd;




@end
