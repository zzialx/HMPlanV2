//
//  WSGridHorizontalFuncBeansListScrollView.h
//  WinSFA
//
//  Created by HZH on 2017/12/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSGridHorizontalFuncBeansListScrollViewDelegate <NSObject>

- (void)doActionAfterCellClickedWithFuncsBean:(WSFuncsBean *)fb;

@end

@interface WSGridHorizontalFuncBeansListScrollView : UIScrollView

@property (nonatomic, weak) id <WSGridHorizontalFuncBeansListScrollViewDelegate> fDelegate;

- (id)initWithFrame:(CGRect)frame andParentFuncsBean:(WSFuncsBean *)pFuncsBean;

@end
