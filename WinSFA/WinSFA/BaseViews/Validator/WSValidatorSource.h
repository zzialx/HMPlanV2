//
//  WSValidatorSource.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-6.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtViewController.h"
#import "WSAcvtBean_qst.h"

@interface WSValidatorSource : NSObject


@property (nonatomic, strong) WSAcvtBean_qst *currentQst;
@property (nonatomic, strong) NSMutableArray *ddsArray;
@property (nonatomic, strong) NSMutableArray *dds2Array;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float value2;

@end
