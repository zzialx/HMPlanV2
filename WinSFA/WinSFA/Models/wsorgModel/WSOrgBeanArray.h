//
//  WSOrgBeanArray.h
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSOrgBeanArray : NSObject

@property (nonatomic ,strong) NSMutableArray *orgBeans;

@property (nonatomic,assign) NSInteger  difLevelNum;

- (id)initWithObject:(id)object;

@end
