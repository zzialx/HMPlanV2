//
//  LTDebugTableViewCell.h
//  WinSFA
//
//  Created by Alicia on 2017/3/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LTDDLogModel;

@interface LTDebugTableViewCell : UITableViewCell

@property (nonatomic, strong) LTDDLogModel *logModel;

+ (CGFloat)getCellHeightByLogModel:(LTDDLogModel *)logModel;

@end
