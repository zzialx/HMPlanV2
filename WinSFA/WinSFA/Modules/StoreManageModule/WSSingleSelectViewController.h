//
//  SingleSelectViewController.h
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"

@class WSSingleSelectViewController;

@protocol ItemSelectedDelegate <NSObject>

-(void)singleSelectView:(WSSingleSelectViewController *)singleSelectView itemSelected:(NSString *)aItem;

@end

@interface WSSingleSelectViewController : WCBaseViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSArray *itemArray;
@property (nonatomic, strong)NSArray *itemIds;
@property (nonatomic, weak)id<ItemSelectedDelegate> selectDelegate;

@end
