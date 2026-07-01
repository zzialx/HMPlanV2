//
//  MonthModel.h
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthModel : NSObject

@property (assign, nonatomic) long dayValue;
@property (assign, nonatomic) long monValue;
@property (assign, nonatomic) long yearValue;
@property (strong, nonatomic) NSDate *dateValue;
@property (assign, nonatomic) BOOL isSelectedDay;
@property (assign, nonatomic) BOOL isCurMonth;
@property (strong, nonatomic) NSString * num10ImageUrl;
@property (strong, nonatomic) NSString * num12ImageUrl;
@property (strong, nonatomic) NSString * num13ImageUrl;
@property (strong ,nonatomic) NSString * yymmdd;

@end
