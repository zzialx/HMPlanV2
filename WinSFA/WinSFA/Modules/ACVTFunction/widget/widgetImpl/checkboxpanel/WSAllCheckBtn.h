//
//  WSAllCheckBtn.h
//  WinSFA
//
//  Created by mwj on 2021/3/16.
//  Copyright © 2021 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^selectAllBtnAction)(BOOL isAllSelect);


@interface WSAllCheckBtn : UIView

@property (nonatomic, strong)UIButton * checkBtn;///<选择框

@property (nonatomic, copy)selectAllBtnAction selectAllBtnAction;

- (instancetype)initWithFrame:(CGRect)frame btnName:(NSString*)btnName;

@end

NS_ASSUME_NONNULL_END
