//
//  WSPopStoreDetailMessageView.h
//  WinSFA
//
//  Created by zhiqing on 16/8/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSelectListNewTableviewCell.h"

@interface WSPopStoreDetailMessageView : UIView
@property(nonatomic,strong) NSDictionary *store;
@property(nonatomic,copy) NSString *dateString;
@property(nonatomic,weak) id <WSSelectListNewTableviewCellDelegate>delegate;
@end
