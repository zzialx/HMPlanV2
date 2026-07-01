//
//  WSPersonnelListTreeCell.h
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define kPersonnelCellTagBase    100

typedef NS_OPTIONS(NSInteger, WSPersonnelListStyle) {
    WSPersonnelListStyleDefault = 1,                     // 默认样式，叶子结点有选项按钮，选项按钮显示在右侧，没有搜索框
    WSPersonnelListStyleOption = 1 << 1,                // 显示选项框
    WSPersonnelListStyleParentOption =  1 << 2,          // 父节点有选项按钮
    WSPersonnelListStyleLeftOption = 1 << 3,            // 选项按钮显示在左侧，展开节点和标题中间
    WSPersonnelListStyleSearchable = 1 << 4            // 显示搜索框
};

@class WSPersonnelListTreeCell;

@protocol WSPersonnelListTreeCellDelegate <NSObject>

- (void)listTreeCell:(WSPersonnelListTreeCell *)listTreeCell reloadDataItem:(NSObject<I_W_Cell> *)dataItem;
- (void)listTreeCell:(WSPersonnelListTreeCell *)listTreeCell didClickItem:(NSObject<I_W_Cell> *)dataItem;

@end

@interface WSPersonnelListTreeCell : UITableViewCell

@property (nonatomic, strong) NSObject<I_W_Cell> *dataItem;


@property (nonatomic, weak) id<WSPersonnelListTreeCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier listStyle:(WSPersonnelListStyle )listStyle;
- (void)assignedWithWSSubempStoreBean:(NSObject<I_W_Cell> *)bean withIsReadOnly:(BOOL)isReadOnly;


@end
