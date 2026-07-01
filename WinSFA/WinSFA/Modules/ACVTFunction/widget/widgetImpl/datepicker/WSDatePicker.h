//
//  WCDatePicker.h
//  NewSolution
//
//  Created by winchannel on 1/10/15.
//  Copyright (c) 2015 com.winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSDatePickerDelegate <NSObject>

-(void)cancelSelected;

-(void)confirmSelectedDate:(NSDate *)date;


@end

@interface WSDatePicker : UIView{
    
    UIButton *confrimbtn;
    
    UIButton *closebtn;
    
    
    UIDatePicker  *datepicker;
    
    __unsafe_unretained id<WSDatePickerDelegate> delegate;
    
    
}
@property (nonatomic,assign) id<WSDatePickerDelegate>  delegate;

- (id)initWithFrame:(CGRect)frame withDateMode:(UIDatePickerMode)datePickerMode;
-(void)setBeginSelected:(NSDate *)date;
-(void)setMinimumDate:(NSDate *)date;

-(void)setMaximumDate:(NSDate *)date;
@end
