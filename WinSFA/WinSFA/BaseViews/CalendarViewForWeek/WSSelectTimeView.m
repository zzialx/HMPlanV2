//
//  WSSelectTimeView.m
//  WinSFA
//
//  Created by zhiqing on 16/7/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSelectTimeView.h"
#import "PureLayout.h"
@interface WSSelectTimeView ()
{
    UIImageView * icon ;
    UIButton * timeButton;
    NSDate * currentDate;
    UIImageView * backgroundView;
}
@end

@implementation WSSelectTimeView
-(instancetype)init{
    if (self = [super init]) {

        backgroundView = [[UIImageView alloc]init];
        UIImage *bgImage = [[UIImage imageNamed:@"riqi_bj"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        backgroundView.tintColor = MAIN_TINT_COLOR;
        backgroundView.image = bgImage;
        [self addSubview:backgroundView];
        [backgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, 0, 6, 0)];
   
        icon = [[UIImageView alloc]init];
        UIImage *iconImage = [[UIImage imageNamed:@"icon_riqi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        icon.tintColor = MAIN_TINT_COLOR;
        icon.image = iconImage;
        icon.contentMode = UIViewContentModeScaleAspectFill;
        timeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [timeButton addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:icon];
        [self addSubview:timeButton];
        [icon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
        [icon autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:15];
        [icon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [icon autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.2];
        
        [timeButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [timeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [timeButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:icon];
        [timeButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.65];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:singleTap];
        
//        self.layer.cornerRadius = 8;
//        self.layer.borderColor = [UIColor colorWithRed:253/255.0 green:164/255.0 blue:142/255.0 alpha:1].CGColor;
//        self.layer.borderWidth = 1.5;
    }
    return self;
}

-(void)setSelectTime:(NSDate *)selectTime{
     _selectTime = selectTime;
     NSDateFormatter * formatter = [NSDateFormatter standardDateFormatter];
    if (_style == WSSelectTimeViewStyleYMD) {
        [formatter setDateFormat:@"yyyy-MM-dd"];
    }else if(_style == WSSelectTimeViewStyleYM){
        [formatter setDateFormat:@"yyyy-MM"];
    }
   
    
    [timeButton setTitle:[formatter stringFromDate:selectTime] forState:UIControlStateNormal];
}

- (void)handleTap{
    WSPickerViewType pickerViewType;
    if (_style == WSSelectTimeViewStyleYM) {
        pickerViewType = WSPickerViewTypeDateYearMonth;
    } else {
        pickerViewType = WSPickerViewTypeDate;
    }
    
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType];
    [pickerView setDate:_selectTime animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
}

- (void)setDateContent:(NSDate *)date {
    _selectTime = date;
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    if (_style == WSSelectTimeViewStyleYMD) {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
    }else if(_style == WSSelectTimeViewStyleYM){
        [dateFormat setDateFormat:@"yyyy-MM"];
    }
    
    [timeButton setTitle:[dateFormat stringFromDate:date] forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(selectTimeViewValueChanged:)]) {
        [self.delegate selectTimeViewValueChanged:date];
    }
}

@end
