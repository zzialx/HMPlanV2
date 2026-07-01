//
//  WSSellFloatWindowManager.m
//
//
//  Created by zzialx on 2022/10/22.
//  Copyright © 2022 zzialx. All rights reserved.
//

#import "WSSellFloatWindowManager.h"
#import <AVFoundation/AVFoundation.h>
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"

static WSSellFloatWindowManager *instance = nil;

@interface WSSellFloatWindowManager ()

/// 在店时长悬浮框
@property(nonatomic,strong)WSSellFloatWindow * sellFloatWindow;

@end

@implementation WSSellFloatWindowManager

+ (WSSellFloatWindowManager *)sharedInstance
{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSSellFloatWindowManager alloc] init];
        });
    }
    return instance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [self creatSellStoreWindowUI];
    }
    return self;
}

#pragma mark - # Public Method
+ (void)showSellFloatWindow{
    [[WSSellFloatWindowManager sharedInstance] showSellFloatWindow];
}
+ (void)hideSellFloatWindow{
    [[WSSellFloatWindowManager sharedInstance] hideSellFloatWindow];
}
+ (BOOL)isShowSellFloatWindowWithRole{
    WSBaseAcvtdisDBService * service = [[WSBaseAcvtdisDBService alloc]init];
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];

    WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithQstCod:@"wt_selectrole"];
    
    WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstCod:@"wt_selectrole"];
    
    NSString * role =  [service queryQstServerValueWithStoreId:@"" acvtId:acvtBean.acvtId acvtQstId:qstBean.acvtQstId genId:nil];
    LogInfo(@"登录用户角色：%@",role);

    if([role isEqualToString:@"SR"] || [role isEqualToString:@"销售代表"]){
        return YES;
    }
    return NO;
}

- (void)showSellFloatWindow{
    @weakify_self;
    self.sellFloatWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.3/1.5 animations:^{
        @strongify_self;
        self.sellFloatWindow.hidden = NO;
        self.sellFloatWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.sellFloatWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.sellFloatWindow.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    
}
- (void)hideSellFloatWindow{
    self.sellFloatWindow.hidden = YES;
}

#pragma mark - # Load Lazy

- (void)creatSellStoreWindowUI{
    if(_sellFloatWindow==nil){
        _sellFloatWindow = [[WSSellFloatWindow alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - KDEAISellFloatWindowWidth, SCREEN_HEIGHT - KDEAISellFloatWindowHeight - KDEAISellFloatWindowBottomSpace * 2 , KDEAISellFloatWindowWidth, KDEAISellFloatWindowHeight)];
        _sellFloatWindow.hidden = YES;
        _sellFloatWindow.floatType = WSSellFloatWindowTypeSupportPortraitSpringToBounds;
        _sellFloatWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    //    _floatWindow.backgroundColor = HColorFromHex(0xFFFFFF);
        _sellFloatWindow.backgroundColor = UIColor.clearColor;
        _sellFloatWindow.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        _sellFloatWindow.layer.shadowOffset = CGSizeMake(0,0);
        _sellFloatWindow.layer.shadowRadius = 8;
        _sellFloatWindow.layer.shadowOpacity = 1;
        [UIView animateWithDuration:0.3/1.5 animations:^{
            _sellFloatWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _sellFloatWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3/2 animations:^{
                    _sellFloatWindow.transform = CGAffineTransformIdentity;
                }];
            }];
        }];
    }
    return;

//    self.sellFloatWindow = _floatWindow;
//    UIBezierPath*maskPath =[UIBezierPath bezierPathWithRoundedRect:_floatWindow.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:_floatWindow.frame.size];
//    CAShapeLayer*maskLayer =[[CAShapeLayer alloc]init];
//    maskLayer.frame =_floatWindow.bounds;
//    maskLayer.path =maskPath.CGPath;
//    _floatWindow.layer.mask=maskLayer;
}

@end
