//
//  WSNewAddProdsWithSeriesLeftTableViewCell.h
//  WinSFA
//
//  Created by HZH on 2017/9/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kGridCellColor          [UIColor colorWithHexString:@"0xf2f2f2"]
#define kGridCellTextColor      [UIColor colorWithHexString:@"0x666666"]


typedef NS_ENUM(NSUInteger, WSNewAddProdsWithSeriesLeftTableViewCellStyle)
{
    WSNewAddProdsWithSeries1LevelLeftTableViewCell = 0,
    WSNewAddProdsWithSeries2LevelLeftTableViewCell,
};

@class WSNewAddProdsWithSeriesLeftTableViewCell;

@protocol WSNewAddProdsWithSeriesLeftTableViewCellDelegate <NSObject>

- (void)didSelectedCell:(WSNewAddProdsWithSeriesLeftTableViewCell *)cell;

@end

@interface WSNewAddProdsWithSeriesLeftTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *frontView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL isChecked;

@property (nonatomic, strong) UILabel *badgeLabel;

@property (nonatomic, assign) WSNewAddProdsWithSeriesLeftTableViewCellStyle leftTableViewCellStyle;


@property (nonatomic, weak) id <WSNewAddProdsWithSeriesLeftTableViewCellDelegate> delegate;

- (void)setBadgeLabelText:(NSString *)badgeText;

@end
