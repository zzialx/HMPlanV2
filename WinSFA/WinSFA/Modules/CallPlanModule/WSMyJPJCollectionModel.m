//
//  WSMyJPJCollectionModel.m
//  WinSFA
//
//  Created by zhiqing on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyJPJCollectionModel.h"

@implementation WSMyJPJCollectionModel
-(NSMutableArray *)visitPlanStoreArray{
    if (_visitPlanStoreArray == nil) {
        _visitPlanStoreArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _visitPlanStoreArray;
}
@end
