//
//  WSMapSubTrailView.m
//  WinSFA
//
//  Created by wanghaipeng on 2019/4/8.
//  Copyright © 2019年 WinChannel. All rights reserved.
//

#import "WSMapSubTrailView.h"

#define K_EmpButtonButtonWidth 50
#define K_EmpButtonButtonHeight 28
#define K_TimeLabelWidth 77
#define K_EmpButtonTitleColor RGBCOLOR(51, 51, 51)
#define K_EmpButtonTitleFont  [UIFont systemFontOfSize: ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?13:15)]

@interface WSMapSubTrailView ()

@property (nonatomic , strong) UILabel * timeLabel;

@end

@implementation WSMapSubTrailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = RGBCOLOR(153, 153, 153).CGColor;
        
        UILabel * timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, K_TimeLabelWidth, K_EmpButtonButtonHeight)];
        self.timeLabel = timeLabel;
        timeLabel.userInteractionEnabled = YES;
        timeLabel.text = [WSCurrentTime getDateString];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = K_EmpButtonTitleFont;
        timeLabel.textColor = K_EmpButtonTitleColor;
        timeLabel.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer  *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadDateView)];
        [timeLabel addGestureRecognizer:gesture];
        [self addSubview:timeLabel];
        
        UILabel * lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeLabel.right + 1, (K_EmpButtonButtonHeight -MAIN_BIG_PADDING) * 0.5, 1, K_EmpButtonButtonHeight -MAIN_BIG_PADDING)];
        lineLabel.backgroundColor = RGBCOLOR(240, 240, 240);
        [self addSubview:lineLabel];
        
        UIButton * dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dateButton addTarget:self action:@selector(loadDateView) forControlEvents:UIControlEventTouchUpInside];
        dateButton.frame = CGRectMake(K_TimeLabelWidth + 5 + 2, 0, K_EmpButtonButtonHeight, K_EmpButtonButtonHeight);
        [dateButton setImage:[UIImage scaledImageForName:@"date_select_icon_gray" ofType:@"png"] forState:UIControlStateNormal];
        [dateButton setTitleColor:K_EmpButtonTitleColor forState:UIControlStateNormal];
        dateButton.titleLabel.font = K_EmpButtonTitleFont;
        dateButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:dateButton];
    }
    
    return self;
    
}

-(void)loadDateView{
    
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:WSPickerViewTypeDate];
    [pickerView setMaximumDate:[NSDate date]];
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:self.timeLabel.text];
    [pickerView setDate:destDate animated:YES];
    __weak typeof(self)weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        weakSelf.timeLabel.text = [dateFormat stringFromDate:date];
        [weakSelf selectDate];
        
    }];
}

- (void)selectDate{
    
    if ([self.delegate respondsToSelector:@selector(didSelectDate:)]) {
        [self.delegate didSelectDate:self.timeLabel.text];
    }
}

@end
