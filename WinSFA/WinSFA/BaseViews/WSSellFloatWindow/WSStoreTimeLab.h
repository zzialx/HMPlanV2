//
//  WSStoreTimeLab.h
//  WinSFA
//
//  Created by admin on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSStoreTimeLab : UIView
///小时
@property(nonatomic,strong)UILabel * hourTimeLab;

///分
@property(nonatomic,strong)UILabel * minuteTimeLab;

///秒
@property(nonatomic,strong)UILabel * secondTimeLab;

@end

NS_ASSUME_NONNULL_END
