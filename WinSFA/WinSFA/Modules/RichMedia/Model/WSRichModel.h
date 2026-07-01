//
//  WSRichModel.h
//  WinSFA
//
//  Created by huzepei on 16/8/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSFilterItem;
@interface WSRichModel : NSObject

@property (nonatomic,copy) NSString *_id;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *pid;

@property (nonatomic,strong) NSMutableArray *filterItems;

@end

@interface WSFilterItem : NSObject

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *_id;

@property (nonatomic,copy) NSString *pid;

@property (nonatomic,assign) BOOL isSelected;

@end
