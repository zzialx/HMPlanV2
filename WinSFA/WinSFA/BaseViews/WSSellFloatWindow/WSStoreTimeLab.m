//
//  WSStoreTimeLab.m
//  WinSFA
//
//  Created by admin on 2022/10/24.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSStoreTimeLab.h"

#define KDEAISellFloatWindowWidth 60.0f
#define KDEAISellFloatWindowHeight 60.0f

@interface WSStoreTimeLab ()

@property (weak, nonatomic) IBOutlet UIImageView *timeImg1;

@property (weak, nonatomic) IBOutlet UIImageView *timeImg2;

@property (weak, nonatomic) IBOutlet UIImageView *timeImg3;


@end

@implementation WSStoreTimeLab
- (void)awakeFromNib{
    [super awakeFromNib];
    self.hourTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (KDEAISellFloatWindowWidth * 2 - 20)/3, KDEAISellFloatWindowHeight)];
    [self.timeImg1 addSubview:self.hourTimeLab];
    self.hourTimeLab.font = [UIFont systemFontOfSize:12.0];
    self.hourTimeLab.textAlignment = NSTextAlignmentCenter;
    self.hourTimeLab.textColor = UIColor.blackColor;

    self.minuteTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (KDEAISellFloatWindowWidth * 2 - 20)/3, KDEAISellFloatWindowHeight)];
    [self.timeImg2 addSubview:self.minuteTimeLab];
    self.minuteTimeLab.font = [UIFont systemFontOfSize:12.0];
    self.minuteTimeLab.textAlignment = NSTextAlignmentCenter;
    self.minuteTimeLab.backgroundColor = UIColor.clearColor;
    
    self.secondTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (KDEAISellFloatWindowWidth * 2 - 20)/3, KDEAISellFloatWindowHeight)];
    [self.timeImg3 addSubview:self.secondTimeLab];
    self.secondTimeLab.font = [UIFont systemFontOfSize:12.0];
    self.secondTimeLab.textAlignment = NSTextAlignmentCenter;
    self.secondTimeLab.backgroundColor = UIColor.clearColor;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
