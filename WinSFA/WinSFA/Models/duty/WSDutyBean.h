//
//  WSDutyBean.h
//  WinSFA
//
//  Created by heju on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSDutyBean : NSObject
@property (nonatomic,strong)NSString *col4;
@property (nonatomic,strong)NSString *col3;
@property (nonatomic,strong)NSString *bizDate;
@property (nonatomic,assign)NSInteger empId;
@property (nonatomic,strong)NSString *afternoon;
@property (nonatomic,strong)NSString *morning;
@property (nonatomic,strong)NSString *year;
@property (nonatomic,strong)NSString *month;
@property (nonatomic,strong)NSString *day;
@property (nonatomic,strong)NSString *rate;
@property (nonatomic,strong)NSString *rateColor;


- (id)initWithObjec:(id)object;

@end
