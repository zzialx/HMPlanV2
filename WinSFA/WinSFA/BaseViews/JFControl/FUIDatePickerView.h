//
//  FUITimePickerView.h
//  WinSFA
//  标题+时间显示选择器
//
//  Created by dujinfeng481 on 14-7-28.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FRefreshDateBlock)(NSString *acvtQstId, NSString *dateStr);

@interface FUIDatePickerView : UIView

@property (nonatomic, strong) UIDatePicker  *customDatePicker;

- (id)initWithFrame:(CGRect)frame
     withPickerMode:(UIDatePickerMode)mode
       withTitleStr:(NSString*)title
  withDateNormalStr:(NSString*)dateStr
      withAcvtQstId:(NSString*)idStr
          withBlock:(FRefreshDateBlock)block;

- (void) changeInteractionEnabled:(BOOL) isEnabled;

@end
