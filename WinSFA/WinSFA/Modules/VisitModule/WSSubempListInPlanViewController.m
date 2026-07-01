//
//  WSSubempListInplanViewController.m
//  WinSFA
//
//  Created by yang on 14-5-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSubempListInPlanViewController.h"

@interface WSSubempListInPlanViewController ()

@end

@implementation WSSubempListInPlanViewController

-(void)initDataArray{
    
    WSSubempstoreBeanArray *subBeanArr;
    
    subBeanArr = [WSAppData getObjectbyKey:self.currentFuncs.filter];
    
    if (subBeanArr && [subBeanArr isKindOfClass:[WSSubempstoreBeanArray class]]) {
        [self.dataArray addObjectsFromArray:subBeanArr.subempstoreArray];
    }
      
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    
}


@end
