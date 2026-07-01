//
//  WSRecipeController.h
//  WinSFA
//
//  Created by huzepei on 16/8/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichItemModel.h"
#import "WSRMShowBaseController.h"

@class WSRecipeController;

@protocol WSRecipeControllerDelegate <NSObject>

- (void)itemClickCallH5:(WSRecipeController *)Recipe itemModel:(WSRichItemModel *)item;

@end

@interface WSRecipeController : WSRMShowBaseController

@property (nonatomic,copy) NSString *vcName;

//当点击选项的时候调用\(^o^)/~

@property (nonatomic, copy) void (^itemClickCallH5)(WSRichItemModel *itemModel);

@property (nonatomic, weak) id <WSRecipeControllerDelegate> delegate;

@property (nonatomic,assign) BOOL isNotEdit;

//已添加完的数组.
@property (nonatomic,strong) NSMutableArray * addedArr;

@property (nonatomic,copy) NSString *visitData;
@property (nonatomic, copy) NSString *storeId;

@end
