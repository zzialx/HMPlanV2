//
//  WSRadioQstView.h
//  WinSFA
//
//  Created by zhangke on 15/2/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSQstView.h"

@protocol WSRadioQstViewDelegate

-(void)didSelectIndex:(NSInteger)selectIndex qst:(WSAcvtBean_qst*)qst sourceArray:(NSArray*)sourceArray;

@end


@interface WSRadioQstView : WSQstView{
    
    NSString          *redisplayContentStr;
    NSArray           *sourceArray;
}

@property (nonatomic, strong) NSString          *redisplayContentStr;   //回显内容/Id
@property (nonatomic, strong) NSArray           *sourceArray;           //下拉列表数据源 WSStoreBean or WSDictBean

@property (nonatomic, weak) id<WSRadioQstViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame acvtQstObject:(WSAcvtBean_qst*)qst souceArray:(NSArray*)dataArray redisplayContent:(NSString*)redisplayStr;

- (void)initializationOptionView;

-(instancetype)initWithFrame:(CGRect)frame acvtQstObject:(WSAcvtBean_qst*)qst;

@end
