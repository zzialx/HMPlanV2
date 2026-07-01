//
//  WSMyJPJCollectionModel.h
//  WinSFA
//
//  Created by zhiqing on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSMyJPJCollectionModel : NSObject
@property(nonatomic,copy) NSString *week;
@property(nonatomic,copy) NSDate *day;
@property(nonatomic,strong) NSMutableArray * visitPlanStoreArray;
@end
