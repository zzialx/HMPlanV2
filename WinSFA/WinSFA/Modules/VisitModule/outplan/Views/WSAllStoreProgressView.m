//
//  WSAllStoreProgressView.m
//  WinSFA
//
//  Created by donghong on 2018/5/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAllStoreProgressView.h"


@interface WSAllStoreProgressView()

//弹窗
@property (nonatomic,strong) UIView *alertView;
//title
@property (nonatomic,strong) UILabel *titleLbl;
//左lab
@property (nonatomic,strong) UILabel *labLeft;
//右lab
@property (nonatomic,strong) UILabel *labRight;

@property (nonatomic,strong) UIView *viewList;
@property (nonatomic,strong) UIView *viewProgress;

@property (nonatomic,assign) NSInteger allNumber;






@end

@implementation WSAllStoreProgressView

- (instancetype)initWithSelect:(NSInteger )allNumber
{
    if(self == [super init])
    {
        self.frame = [UIScreen mainScreen].bounds;
        UIView *shadow = [[UIView alloc]initWithFrame:self.frame];
        shadow.alpha = 0.3;
        shadow.backgroundColor = [UIColor blackColor];
        [self addSubview:shadow];
        
        UIView * imgBackground = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-264)/2,(self.frame.size.height-148)/2,264,162)];
        imgBackground.layer.cornerRadius = 10;
        imgBackground.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
//        UIImageView *imgBackground =  [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-264)/2,(self.frame.size.height-148)/2,264,148)];
        
//        imgBackground.userInteractionEnabled = YES;
//        imgBackground.image = [UIImage imageNamed:@"bg_dialog"];
        
        [self addSubview:imgBackground];
       
         UILabel * topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imgBackground.frame.size.width, 48)];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.textColor = [UIColor colorWithHexString:@"333333"];
        topLabel.text = @"提示信息";
        topLabel.font = FONT_SIZE_PINGFANG_REGULAR(17);//设置文字类型与大小
        [imgBackground addSubview:topLabel];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,48,264,0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"dbdbdb"];
        [imgBackground addSubview:line];
        
        self.titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 76, imgBackground.frame.size.width-30, 15)];
        self.titleLbl.textColor = [UIColor colorWithHexString:@"333333"];
        self.titleLbl.text = @"正在下载，请稍后...";
        self.titleLbl.font = FONT_SIZE_PINGFANG_REGULAR(15);//设置文字类型与大小
        [imgBackground addSubview:self.titleLbl];
        
        UIView *viewList = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.titleLbl.frame)+10, self.titleLbl.frame.size.width, 3)];
        viewList.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
        [imgBackground addSubview:viewList];
        self.viewList = viewList;
        
        UIView *viewProgress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
        viewProgress.backgroundColor = [UIColor colorWithHexString:@"f94516"];
        [viewList addSubview:viewProgress];
        self.viewProgress = viewProgress;
        
        UILabel *labLeft = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(viewList.frame)+10, (imgBackground.frame.size.width-30)/2, 14)];
        
        labLeft.textColor = [UIColor colorWithHexString:@"6d6d6d"];
        labLeft.text = @"0%";
        labLeft.font = FONT_SIZE_PINGFANG_REGULAR(13);//设置文字类型与大小
        [imgBackground addSubview:labLeft];
        self.labLeft = labLeft;
        
        UILabel *labRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labLeft.frame), CGRectGetMaxY(viewList.frame)+10, (imgBackground.frame.size.width-30)/2, 14)];
        labRight.textColor = [UIColor colorWithHexString:@"f94516"];
        labRight.text = [NSString stringWithFormat:@"0/%ld",allNumber];
        labRight.textAlignment = NSTextAlignmentRight;
        labRight.font = FONT_SIZE_PINGFANG_REGULAR(13);//设置文字类型与大小
        [imgBackground addSubview:labRight];
        self.labRight = labRight;
        
        self.allNumber = allNumber;
    }
    return self;
}
- (void)setProgress:(NSInteger)progress
{
    self.labLeft.text = [NSString stringWithFormat:@"%ld%%",(progress*100)/self.allNumber];
    self.labRight.text = [NSString stringWithFormat:@"%ld/%ld",progress,self.allNumber];
    self.viewProgress.frame = CGRectMake(0, 0, self.viewList.frame.size.width*progress/self.allNumber, self.viewProgress.size.height);
}
- (void)showXLAlertView
{
    [[[[UIApplication sharedApplication] delegate] window]  addSubview:self];
    [self creatShowAnimation];
}

- (void)creatShowAnimation
{
    self.alertView.layer.position = self.center;
    self.alertView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
    }];
}
@end
