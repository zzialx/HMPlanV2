//
//  WSSelectTimeView.h
//  WinSFA
//
//  Created by zhiqing on 16/7/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WSSelectTimeViewStyleYM,   // yyyy-mm
    WSSelectTimeViewStyleYMD,  // yyyy-mm-dd
} WSSelectTimeViewStyle;

@protocol WSSelectTimeViewDelegate <NSObject>

-(void)selectTimeViewValueChanged:(NSDate *)date;

@end

@interface WSSelectTimeView : UIView
@property(nonatomic,strong)NSDate * selectTime;
@property(nonatomic,assign) WSSelectTimeViewStyle style;
@property(nonatomic,weak) id <WSSelectTimeViewDelegate> delegate;
@end
