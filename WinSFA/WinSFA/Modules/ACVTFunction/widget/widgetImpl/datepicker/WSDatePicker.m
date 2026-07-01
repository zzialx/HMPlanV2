//
//  WCDatePicker.m
//  NewSolution
//
//  Created by winchannel on 1/10/15.
//  Copyright (c) 2015 com.winchannel. All rights reserved.
//

#import "WSDatePicker.h"
#import <QuartzCore/QuartzCore.h>

@implementation WSDatePicker
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withDateMode:(UIDatePickerMode)datePickerMode{
    self  =[super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIView *viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40.0)];
        viewBG.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
        [self addSubview:viewBG];
        
        closebtn =[UIButton buttonWithType:UIButtonTypeCustom];
        
        closebtn.frame = CGRectMake(5.0, 5.0, 40.0, 30.0);
        
        [closebtn setTitle:@"关闭" forState:UIControlStateNormal];
        
        [closebtn setTitle:@"关闭" forState:UIControlStateHighlighted];
        [closebtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
        [closebtn setTitleColor:[UIColor colorWithHexString:@"3291cd"] forState:UIControlStateNormal];
        
        [self addSubview:closebtn];
        
        
        
        confrimbtn =[UIButton buttonWithType:UIButtonTypeCustom];
        
        confrimbtn.frame = CGRectMake(self.frame.size.width-45.0, 5.0, 40, 30.0);
        
        [confrimbtn setTitle:@"confirm" forState:UIControlStateNormal];
        
        [confrimbtn setTitle:@"confirm" forState:UIControlStateHighlighted];
        
        [confrimbtn setTitleColor:[UIColor colorWithHexString:@"3291cd"] forState:UIControlStateNormal];
        
        [confrimbtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confrimbtn];
                
        datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, closebtn.frame.origin.y+closebtn.frame.size.height+5.0,300, 200)];
        if (@available(iOS 13.4, *)) {
            datepicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        [datepicker setDatePickerMode:datePickerMode];
        [self addSubview:datepicker];

        return self;
    }
    return nil;
}
-(void)close{
    
    if ([delegate respondsToSelector:@selector(cancelSelected)]) {
        
        [delegate cancelSelected];
        
    }
    
}

-(void)confirm{
    
    NSDate  *date = datepicker.date;
    
    if ([delegate respondsToSelector:@selector(confirmSelectedDate:)]) {
        
        [delegate confirmSelectedDate:date];
        
    }
    
}

-(void)setBeginSelected:(NSDate *)date{
    
    datepicker.date = date;
}

-(void)setMinimumDate:(NSDate *)date{
    datepicker.minimumDate = date;
}

-(void)setMaximumDate:(NSDate *)date{
 
    datepicker.maximumDate = date;
}
@end
