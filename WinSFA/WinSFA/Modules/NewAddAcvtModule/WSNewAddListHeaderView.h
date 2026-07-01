//
//  WSNewAddListHeaderView.h
//  WinSFA
//
//  Created by zhaodanyang on 2018/5/14.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSNewAddAcvtModel,WSNewAddListHeaderView;
@protocol WSNewAddListHeaderViewDelegate <NSObject>

- (void)newAddListHeaderView:(WSNewAddListHeaderView *) newAddListHeaderView newAddAcvtModel: (WSNewAddAcvtModel *)model;

@end
@interface WSNewAddListHeaderView : UITableViewHeaderFooterView

@property (nonatomic,strong) WSNewAddAcvtModel *model;

@property (nonatomic,weak) id<WSNewAddListHeaderViewDelegate> delegate;




@end
