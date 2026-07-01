//
//  WSSellFloatWindow.m
//  WMDragView
//
//  Created by admin on 2022/10/21.
//  Copyright © 2022 zzialx. All rights reserved.
//

#import "WSSellFloatWindow.h"
#import "WSRequestTools.h"
#import "WSStoreTimeLab.h"
#import "Masonry.h"

#define KREQUEST_INSTORETIME     @"visitStoreTimeByEmp"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define  LXMSTATUS_BAR_HEIGHT  84
UIButton *button[4];//button数组

@interface WSSellFloatWindow ()

@property (nonatomic, strong) UIImageView * iconImageView;

///时间轴
@property (nonatomic, strong) WSStoreTimeLab * timeLab;

/// 关闭时长显示动画
@property (nonatomic, strong) UIButton * closeBtn;

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

/// 记录关闭和打开的状态
@property (nonatomic, assign) BOOL isOpen;

/// 记录单个约束
@property (nonatomic, strong) MASConstraint * iconImageViewConstraint;

@property (nonatomic, strong) MASConstraint * timeLabConstraint;

@property (nonatomic, strong) MASConstraint * closeBtnConstraint;
/// 当前所处边界
@property (nonatomic, assign) BoundaryType currentBoundaryType;

@end

@implementation WSSellFloatWindow


-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        [self makeKeyAndVisible];
        self.currentBoundaryType = BoundaryTypeRight;
        [self iconImageView];
        [self timeLab];
        [self closeBtn];
        self.isShowMenu=false;
        [self setRootViewController:[UIViewController new]];
        self.currentOrientation = UIInterfaceOrientationPortrait;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;
}
#define KDEAISellDegreesToRadians(degrees) (degrees * M_PI / 180)
- (void)statusBarOrientationChange:(NSNotification*)notification{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self setTransform:[self transformForOrientation:orientation]];
    self.currentOrientation = orientation;
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        self.frame = CGRectMake(KDEAISellFloatWindowHeight+KDEAISellFloatWindowBottomSpace, screenWidth - KDEAISellFloatWindowWidth , KDEAISellFloatWindowWidth, KDEAISellFloatWindowHeight);
    }else{
        self.frame = CGRectMake(screenWidth - KDEAISellFloatWindowWidth, screenHeight - KDEAISellFloatWindowHeight - KDEAISellFloatWindowBottomSpace , KDEAISellFloatWindowWidth, KDEAISellFloatWindowHeight);
    }
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
    
    switch (orientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-KDEAISellDegreesToRadians(90));
            
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(KDEAISellDegreesToRadians(90));
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(KDEAISellDegreesToRadians(180));
            
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(KDEAISellDegreesToRadians(0));
    }
}

//改变位置
//横屏之后的坐标系变为左下角坐标系，其中x轴向上，y轴向右，在这样的坐标系中计算即可
-(void)locationChange:(UIPanGestureRecognizer*)pan
{
    if (self.floatType == WSSellFloatWindowTypeNormal) {//如果是普通的则不可滑动
        return;
    }
    
    if  (self.currentOrientation == UIInterfaceOrientationLandscapeRight || self.currentOrientation == UIInterfaceOrientationLandscapeLeft) {//如果是横屏
        
        if (self.floatType & WSSellFloatWindowTypeSupportLandscapeSpringToBounds) {//横屏弹到边框效果
            [self springToBoundsOnLandscape:pan];

        } else if (self.floatType & WSSellFloatWindowTypeSupportLandscapePan){//横屏的拖动
            [self landscapePan:pan];
        }

    } else{ //如果是竖屏
        if (self.floatType & WSSellFloatWindowTypeSupportPortraitPan) {//竖屏拖动
            
            [self portraitPan:pan];
        }else if (self.floatType & WSSellFloatWindowTypeSupportPortraitSpringToBounds) {//竖屏弹到边框
            [self springToBoundsOnPortrait:pan];
        }
    }

    
    //    touchpoint=self.frame.origin;
}
- (void)portraitPan:(UIPanGestureRecognizer*)panGesture{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [[UIApplication sharedApplication] keyWindow];
    CGPoint panPoint = [panGesture locationInView:[[UIApplication sharedApplication] windows][0]];
    if(panGesture.state == UIGestureRecognizerStateBegan)
       {
           [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeColor) object:nil];
           _iconImageView.alpha = 0.8;
       } else if (panGesture.state == UIGestureRecognizerStateChanged)
       {
           if (self.floatType & WSSellFloatWindowTypeSupportPortraitPan) {
               if (panPoint.x < WIDTH/2) {
                   panPoint.x = WIDTH/2;
               } else if (panPoint.x > screenWidth - WIDTH/2) {
                   panPoint.x = screenWidth - WIDTH/2;
               }
               if (panPoint.y < LXMSTATUS_BAR_HEIGHT + HEIGHT/2) {
                   panPoint.y = LXMSTATUS_BAR_HEIGHT + HEIGHT/2;
               } else if (panPoint.y > screenHeight - HEIGHT/2) {
                   panPoint.y = screenHeight - HEIGHT/2;
               }
           }
           self.center = CGPointMake(panPoint.x,  panPoint.y);
       } else if(panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
       {
           _iconImageView.alpha = 1.0;
       }
}

- (void)landscapePan:(UIPanGestureRecognizer*)panGesture{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [[UIApplication sharedApplication] keyWindow];
    CGPoint panPoint = [panGesture locationInView:[[UIApplication sharedApplication] windows][0]];
    panPoint = CGPointMake(screenHeight - panPoint.y, panPoint.x);
    
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeColor) object:nil];
        _iconImageView.alpha = 0.8;
    } else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        if (self.floatType & WSSellFloatWindowTypeSupportPortraitPan) {
            if (panPoint.x < HEIGHT/2) {
                panPoint.x = HEIGHT/2;
            } else if (panPoint.x > screenHeight - HEIGHT/2) {
                panPoint.x = screenHeight - HEIGHT/2;
            }
            if (panPoint.y < LXMSTATUS_BAR_HEIGHT + WIDTH/2) {
                panPoint.y = LXMSTATUS_BAR_HEIGHT + WIDTH/2 + LXMSTATUS_BAR_HEIGHT;
            } else if (panPoint.y > screenWidth - WIDTH/2) {
                panPoint.y = screenWidth - WIDTH/2;
            }
        }
        self.center = CGPointMake(panPoint.x,  panPoint.y);
    } else if(panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
    {
        _iconImageView.alpha = 1.0;
    }
}

- (void)springToBoundsOnPortrait:(UIPanGestureRecognizer*)panGesture{
    if(self.isOpen){
        return;
    }
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [[UIApplication sharedApplication] keyWindow];
    CGPoint panPoint = [panGesture locationInView:[[UIApplication sharedApplication] windows][0]];
    if(panGesture.state == UIGestureRecognizerStateBegan)
       {
//           [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeColor) object:nil];
           _iconImageView.alpha = 0.8;
       } else if (panGesture.state == UIGestureRecognizerStateChanged)
       {
           self.center = CGPointMake(panPoint.x,  panPoint.y);
       } else if(panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
       {
           _iconImageView.alpha = 1.0;
           
           NSLog(@"ssssss");
           if(panPoint.x <= screenWidth/2)
           {
               if(panPoint.y >= screenHeight-HEIGHT/2-40 )//左下边界判断
               {
                   [UIView animateWithDuration:0.2 animations:^{
                       self.center = CGPointMake(WIDTH/2, screenHeight-HEIGHT/2);
                   }];
                   
               } else if (panPoint.y < (HEIGHT/2 + LXMSTATUS_BAR_HEIGHT)) {
                   [UIView animateWithDuration:0.2 animations:^{
                       self.center = CGPointMake(WIDTH/2, HEIGHT/2 + LXMSTATUS_BAR_HEIGHT);
                       
                   }];
               } else{
                   //CGFloat pointy = panPoint.y < (HEIGHT/2 + LXMSTATUS_BAR_HEIGHT)? (HEIGHT/2 + LXMSTATUS_BAR_HEIGHT) :panPoint.y;//左上边界与正常拖动
                   [UIView animateWithDuration:0.2 animations:^{
                       self.center = CGPointMake(WIDTH/2, panPoint.y);
                   }];
               }
               self.currentBoundaryType = BoundaryTypeLeft;
               [self p_updateSubViewConstrains];
           }
           else if(panPoint.x > screenWidth/2)
           {
               if(panPoint.y <= (HEIGHT/2 + LXMSTATUS_BAR_HEIGHT))//向右越过上边界
               {
                   [UIView animateWithDuration:0.2 animations:^{
                       self.center = CGPointMake(screenWidth-WIDTH/2, HEIGHT/2 + LXMSTATUS_BAR_HEIGHT);
                   }];
                   
               }
               else if (panPoint.y > screenHeight-HEIGHT/2) {//右下边界
                   [UIView animateWithDuration:0.2 animations:^{
                       self.center = CGPointMake(screenWidth-WIDTH/2, screenHeight-HEIGHT/2);
                   }];
                   
               }else{//正常拖动
                   [UIView animateWithDuration:0.2 animations:^{
                       self.center = CGPointMake(screenWidth-WIDTH/2, panPoint.y);
                   }];
                   
               }
               self.currentBoundaryType = BoundaryTypeRight;
               [self p_updateSubViewConstrains];
           }
       }
    
}

- (void)springToBoundsOnLandscape:(UIPanGestureRecognizer*)panGesture{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [[UIApplication sharedApplication] keyWindow];
    CGPoint panPoint = [panGesture locationInView:[[UIApplication sharedApplication] windows][0]];
    
    panPoint = CGPointMake(screenHeight - panPoint.y, panPoint.x);
    
    
    NSLog(@"screenWidth:%f, panPoint:%@", screenWidth, NSStringFromCGPoint(panPoint));
    
    if(panGesture.state == UIGestureRecognizerStateBegan)
    {
        _iconImageView.alpha = 0.8;
    } else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x,  panPoint.y);
        
    } else if(panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled)
    {
        _iconImageView.alpha = 1.0;
        if(panPoint.y <= screenWidth/2)
        {
            if (panPoint.x <= HEIGHT/2 + LXMSTATUS_BAR_HEIGHT) {
                [UIView animateWithDuration:0.2 animations:^{//左下角
                    self.center = CGPointMake(WIDTH/2, HEIGHT/2 + LXMSTATUS_BAR_HEIGHT);
                }];
            }else if (panPoint.x >= screenHeight - HEIGHT/2){//左上角
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(screenHeight - HEIGHT/2, HEIGHT/2 + LXMSTATUS_BAR_HEIGHT);
                }];
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2 + LXMSTATUS_BAR_HEIGHT);
                }];
                
            }
        }
        else if(panPoint.y > screenWidth/2)
        {
            if (panPoint.x <= HEIGHT/2) {//右下角
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(HEIGHT/2,  screenWidth - WIDTH/2);
                }];
            }else if (panPoint.x >= screenHeight - HEIGHT/2){//右上角
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(screenHeight - HEIGHT/2, screenWidth - WIDTH/2);
                }];
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(panPoint.x , screenWidth - WIDTH/2);
                }];
            }
            
        }
    }
    
}
#pragma mark - # Private Method ClickBtn Action
-(void)singleTapAction:(UITapGestureRecognizer*)t{
    self.iconImageView.alpha = 0.8;
    self.userInteractionEnabled = NO;
    self.isOpen = !self.isOpen;
    if(self.isOpen){
        self.backgroundColor = UIColor.whiteColor;
        self.timeLab.hidden = !self.isOpen;
        self.closeBtn.hidden = !self.isOpen;
        NSString *text = NSLocalizedString(@"pull_to_refresh_refreshing_label", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:self action:nil];
        @weakify_self;
        [WSRequestTools requestInStoreTimelengthWithNotice:@"" block:^(NSString * hhStr,NSString * mmStr,NSString * ssStr, NSString *errorMsg) {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            @strongify_self;
            if(errorMsg.length > 0){
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:errorMsg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                
            }else{
                self.timeLab.hourTimeLab.text = [NSString stringWithFormat:@"%@时",hhStr];
                self.timeLab.minuteTimeLab.text = [NSString stringWithFormat:@"%@分",mmStr];
                self.timeLab.secondTimeLab.text = [NSString stringWithFormat:@"%@秒",ssStr];
                if(self.frame.origin.x < WIDTH/2){
                    self.frame = CGRectMake(-2.75 * KDEAISellFloatWindowWidth,self.frame.origin.y, KDEAISellFloatWindowWidth *3.75, self.frame.size.height);
                }
                [UIView animateWithDuration:1.0 animations:^{
                    if(self.frame.origin.x > WIDTH/2){
                        self.frame = CGRectMake(self.frame.origin.x - KDEAISellFloatWindowWidth * 2.75,self.frame.origin.y, KDEAISellFloatWindowWidth * 3.75, self.frame.size.height);
                    }else{
                        self.frame = CGRectMake(0,self.frame.origin.y, KDEAISellFloatWindowWidth *3.75, self.frame.size.height);
                    }
                } completion:^(BOOL finished) {
                   
                }];
            }
        }];
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            if(self.frame.origin.x > WIDTH/2){
                self.frame = CGRectMake(self.frame.origin.x + KDEAISellFloatWindowWidth * 2.75,self.frame.origin.y, KDEAISellFloatWindowWidth, self.frame.size.height);;
            }else{
                self.frame = CGRectMake(- 2.75 * KDEAISellFloatWindowWidth ,self.frame.origin.y, KDEAISellFloatWindowWidth * 3.75, self.frame.size.height);
            }
        } completion:^(BOOL finished) {
            if(self.frame.origin.x < WIDTH/2){
                self.frame = CGRectMake(0 ,self.frame.origin.y, KDEAISellFloatWindowWidth, self.frame.size.height);
            }
            self.timeLab.hidden = !self.isOpen;
            self.closeBtn.hidden = !self.isOpen;
            self.backgroundColor = UIColor.clearColor;
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.iconImageView.alpha = 1.0;
        self.userInteractionEnabled = YES;
    });
}

-(void)changeColor
{
    [UIView animateWithDuration:2.0 animations:^{
        self.iconImageView.alpha = 0.3;
    }];
}
#pragma mark - # Update Constrains
- (void)p_updateSubViewConstrains{
    [self.iconImageViewConstraint uninstall];
    [self.timeLabConstraint uninstall];
    [self.closeBtnConstraint uninstall];
    if(self.currentBoundaryType == BoundaryTypeRight){
    
        [_iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.iconImageViewConstraint = make.left.equalTo(self).offset(0);
        }];
        [_timeLab mas_updateConstraints:^(MASConstraintMaker *make) {
            self.timeLabConstraint = make.left.equalTo(self.iconImageView.mas_right).offset(0);
        }];
        [_closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            self.closeBtnConstraint =  make.left.equalTo(self.timeLab.mas_right).offset(0);
        }];
        [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"rightClose"] forState:UIControlStateNormal];

    }else{
        [_iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.iconImageViewConstraint = make.right.equalTo(self).offset(0);
        }];
        [_timeLab mas_updateConstraints:^(MASConstraintMaker *make) {
            self.timeLabConstraint = make.right.equalTo(self.iconImageView.mas_left).offset(0);
        }];
        
        [_closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            self.closeBtnConstraint = make.right.equalTo(self.timeLab.mas_left).offset(0);
        }];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"closeTime_left"] forState:UIControlStateNormal];
    }
    
}
#pragma mark - # Load Lazy UI
- (UIImageView*)iconImageView{
    if(!_iconImageView){
        _iconImageView  = [[UIImageView alloc]initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"time_store"];
        [self addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.iconImageViewConstraint = make.left.equalTo(self).offset(0);
            make.width.mas_equalTo(KDEAISellFloatWindowWidth);
            make.height.mas_equalTo(KDEAISellFloatWindowHeight);
            make.centerY.equalTo(self);
        }];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
        [self addGestureRecognizer:tap];
    }
    return _iconImageView;
}
- (WSStoreTimeLab*)timeLab{
    if(!_timeLab){
        _timeLab =(WSStoreTimeLab*)[[[NSBundle mainBundle]loadNibNamed:@"WSStoreTimeLab" owner:self options:nil] lastObject];
        [self addSubview:_timeLab];
        [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            self.timeLabConstraint = make.left.equalTo(self.iconImageView.mas_right).offset(0);
            make.width.mas_equalTo(KDEAISellFloatWindowWidth * 2);
            make.height.mas_equalTo(KDEAISellFloatWindowHeight);
            make.centerY.equalTo(self);
        }];
        _timeLab.backgroundColor = UIColor.whiteColor;
        _timeLab.hidden = YES;
    }
    return _timeLab;
}
- (UIButton*)closeBtn{
    if(!_closeBtn){
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_closeBtn];
        [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            self.closeBtnConstraint = make.left.equalTo(self.timeLab.mas_right).offset(0);
            make.width.mas_equalTo(KDEAISellFloatWindowWidth*0.75);
            make.height.mas_equalTo(KDEAISellFloatWindowHeight);
            make.centerY.equalTo(self);
        }];
        _closeBtn.hidden = YES;
        [_closeBtn setBackgroundColor:UIColor.clearColor];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"rightClose"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

@end
