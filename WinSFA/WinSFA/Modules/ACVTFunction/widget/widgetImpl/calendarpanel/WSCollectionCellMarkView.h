//
//  WSCollectionCellMarkView.h
//  WinSFA
//
//  Created by heju on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MarkViewType) {
    MarkViewTrangleType,   //矩形
    MarkViewLeftCircleType,    //左边是圆弧部分
    MarkViewRightCircleType   //右边是圆弧部分
    
};

@interface WSCollectionCellMarkView : UIView
@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UILabel *rightLabel;

@property (nonatomic, assign) MarkViewType currentMarkType;

- (id)initWithFrame:(CGRect)frame markStyle:(MarkViewType)type;

@end
