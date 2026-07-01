//
//  WSAcvtGridTableViewCell.h
//  WinSFA
//
//  Created by Stephanie on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSAcvtBean_qst,WSAcvtGridTableViewCell;

extern CGFloat const AcvtGridTableViewCellHeight;

extern CGFloat const AcvtGridTableViewCellLeftTitleTotalWidth;

extern CGFloat const AcvtGridTableViewCellLabelMinWidth;

@protocol WSAcvtGridTableViewCellDelegate <NSObject>

- (void)acvtGridTableViewCell:(WSAcvtGridTableViewCell *)cell leftTitleButtonSelected:(BOOL)isSelected;

@end

@interface WSAcvtGridTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *md5;

@property (nonatomic, strong) WSAcvtBean_qst *leftTitleQst;

@property (nonatomic, weak) id<WSAcvtGridTableViewCellDelegate> delegate;

- (void)setDataArray:(NSArray *)dataArray leftTitleQst:(WSAcvtBean_qst *)leftTitleQst leftTitleValue:(NSString *)value indexPath:(NSIndexPath *)indexPath totalCount:(NSInteger)totalCount;

+ (CGFloat)getCellRealWidthWithDataCount:(NSInteger)count displayWidth:(CGFloat)width hasLeftTitle:(BOOL)hasLeftTitle;

@end
