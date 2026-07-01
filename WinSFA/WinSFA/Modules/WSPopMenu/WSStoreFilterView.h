//
//  WSStoreFilterView.h
//  WinSFA
//
//  Created by sunhongfu on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSAcvtBean_qst.h"
#import "WSPopMenuView.h"

typedef enum : NSUInteger {
    WSStoreFilterViewMengNiuStyle,//蒙牛
    WSStoreFilterViewHuiRuiStyle,//辉瑞医院
} WSStoreFilterViewStyle;

@protocol WSStoreFilterViewDelegate <NSObject>
- (void)storeFilterButonDidClick:(UIButton *)filterBtn;

@end

@interface WSStoreFilterView : UIView <UIScrollViewDelegate>
{

}

@property (nonatomic, assign) WSStoreFilterViewStyle filterStyle;
@property (nonatomic,weak)id <WSStoreFilterViewDelegate> delegate;
/**
 初始化
 */
- (id)initWithFrame:(CGRect)frame withDataArray:(NSMutableArray *)dataArray withFilterStyle:(WSStoreFilterViewStyle)filterStyle;

@end
