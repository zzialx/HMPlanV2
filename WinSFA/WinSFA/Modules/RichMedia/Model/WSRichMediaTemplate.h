//
//  WSRichMediaTemplate.h
//  WinSFA
//
//  Created by huzepei on 16/8/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRichItemModel.h"

@interface WSRichMediaTemplate : NSObject

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) NSArray *listArray;

@end

@interface WSRichMediaDemoList : NSObject

@property (nonatomic,copy) NSString *ID;

@property (nonatomic,copy) NSString *pid;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) NSData *item;

@property (nonatomic,copy) NSString *storeID;

@property (nonatomic,copy) NSString *storeName;

@property (nonatomic,copy) NSString *visitName;

@property (nonatomic,copy) NSString *sid;

@property (nonatomic,strong) WSRichItemModel *itemModel;

@end
