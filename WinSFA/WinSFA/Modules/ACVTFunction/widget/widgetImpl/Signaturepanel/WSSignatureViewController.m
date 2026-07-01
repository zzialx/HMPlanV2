//
//  WSSignatureViewController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSignatureViewController.h"
#import "WSSignatureView.h"
#import "PureLayout.h"

#define kButtonFont             [UIFont systemFontOfSize:18]
#define kTagSignView            (111)
#define kAnnimateTime           (0.5)


@interface WSSignatureViewController ()
{
    UIImageView *_signImageView;
    
    UIView      *_signBoardView;
    
    UIView      *_maskView;
    
    CATransform3D _transfrom;
    UIButton * _deleteBtn;
    WSSignatureView *signatureView;
}
@end

@implementation WSSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _signBoardView = [[UIView alloc]initWithFrame:self.view.bounds];
    _signBoardView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _signBoardView.backgroundColor = [UIColor whiteColor];
//    _transfrom = CATransform3DConcat(CATransform3DMakeScale(self.view.bounds.size.width/self.view.bounds.size.width,self.view.bounds.size.height/self.view.bounds.size.height, 1), CATransform3DMakeTranslation(+_signImageView.left-_signBoardView.left-_signImageView.width,-_signImageView.centerY+_signBoardView.centerY, 0));
//    _signBoardView.layer.transform = _transfrom;
    _signBoardView.layer.borderColor = [UIColor grayColor].CGColor;
    _signBoardView.layer.borderWidth = 0.6;
    _signBoardView.userInteractionEnabled = YES;
    [self.view addSubview:_signBoardView];
    
    CGFloat bgHeight = 64;
    UIView *bgView = [UIView newAutoLayoutView];
    
    UIColor *navBarBackgroudColor;
    if (INTERFACE_IS_PHONE) {
        navBarBackgroudColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
    } else {
        navBarBackgroudColor = [UIColor colorForKey:@"MainTintColor"];
    }
    if (!navBarBackgroudColor) {
        navBarBackgroudColor = [UIColor colorWithHexString:@"#d2ecf7"];
    }
    bgView.backgroundColor = navBarBackgroudColor;
    [_signBoardView addSubview:bgView];
    [bgView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [bgView autoSetDimension:ALDimensionHeight toSize:bgHeight];
    
    CGFloat topPadding = 20.0;
    CGFloat buttonHeight = bgHeight - topPadding;
    UILabel *titleLabel = [UILabel newAutoLayoutView];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.font = kButtonFont;
    [titleLabel setText:NSLocalizedString(@"writte_name", nil)];
    [bgView addSubview:titleLabel];
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:topPadding];
    [titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:buttonHeight];
  
    CGSize buttonSize = CGSizeMake(60, buttonHeight);
    /**
     *  @brief 增加删除按钮
     */
    _deleteBtn = [UIButton newAutoLayoutView];
    [_deleteBtn setTitle:NSLocalizedString(@"cancel_label",nil) forState:UIControlStateNormal];
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _deleteBtn.titleLabel.font = kButtonFont;
    [bgView addSubview:_deleteBtn];
    [_deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:topPadding];
    [_deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_deleteBtn autoSetDimensionsToSize:buttonSize];
    
    /**
     *  @brief 增加保存按钮
     */
    UIButton *saveBtn = [UIButton newAutoLayoutView];
    [saveBtn setTitle:NSLocalizedString(@"save_label",nil) forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = kButtonFont;
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:saveBtn];
    [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:topPadding];
    [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [saveBtn autoSetDimensionsToSize:buttonSize];
    
//    UIButton *exit = [UIButton newAutoLayoutView];
//    [exit setTitle:@"退出" forState:UIControlStateNormal];
//    [exit setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
//    exit.titleLabel.font = kButtonFont;
//    [exit addTarget:self action:@selector(Dismiss) forControlEvents:UIControlEventTouchUpInside];
//    [_signBoardView addSubview:exit];
//    [exit autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
//    [exit autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:75];
    
    signatureView = [[WSSignatureView alloc]initForAutoLayout];
    signatureView.tag = kTagSignView;
    [_deleteBtn addTarget:self action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
    signatureView.signatureImage = _signImageView.image;
    [_signBoardView addSubview:signatureView];
    [signatureView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_signBoardView bringSubviewToFront:bgView];
    [_signBoardView bringSubviewToFront:_deleteBtn];
    [_signBoardView bringSubviewToFront:saveBtn];
//    [_signBoardView bringSubviewToFront:exit];

    if (self.signImage) {
        signatureView.userInteractionEnabled = NO;
        _signImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, bgHeight, self.view.width, self.view.height - bgHeight)];
        _signImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _signImageView.image = self.signImage;
        [self.view addSubview:_signImageView];
        [_deleteBtn setTitle:NSLocalizedString(@"re_hand_written", nil) forState:UIControlStateNormal];
        
    }
    [UIView animateWithDuration:kAnnimateTime animations:^
     {
         _maskView.alpha = 0.5;
//         _signBoardView.layer.transform = CATransform3DIdentity;
         _deleteBtn.hidden = NO;
         saveBtn.hidden = NO;
     } completion:^(BOOL finished) {
         
     }];

}

-(void)erase{

    if ([_deleteBtn.titleLabel.text isEqualToString:NSLocalizedString(@"re_hand_written", nil)]) {
        [_deleteBtn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
    }else{
        [self Dismiss];
        
    }
    
    if (_signImageView.image) {
        self.signImage = nil;
        signatureView.userInteractionEnabled = YES;
        [_signImageView removeFromSuperview];
    }else{
        [signatureView erase];
    }
}

-(void)save
{
  
    if (signatureView.signatureImage) {
        UIView * bgView = [[UIView alloc]initWithFrame:signatureView.bounds];
        UIImageView * imgView = [[UIImageView alloc]initWithImage:signatureView.signatureImage];
        [bgView addSubview:imgView];
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"winSFA"]];
        self.signImage = [self imageFromView:bgView atFrame:bgView.bounds];
//        self.signImage = signatureView.signatureImage;
    }
    
    if ([self.delegate respondsToSelector:@selector(saveImage:)]) {
        [self.delegate saveImage:self.signImage];
    }
    //self.signatureImageBlock(self.signImage);
    _signBoardView.hidden = NO;
    _maskView.hidden = NO;
    
    [UIView animateWithDuration:kAnnimateTime animations:^
     {
         _maskView.alpha = 0;
         //         _signBoardView.layer.transform = _transfrom;
     } completion:^(BOOL finished)
     {
         _signBoardView.hidden = YES;
         _maskView.hidden = YES;
         _signImageView.hidden = NO;
     }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self Dismiss];
}


-(void)Dismiss
{
    if ([self.delegate respondsToSelector:@selector(cacellSignature)]) {
        [self.delegate cacellSignature];
    }
    _signBoardView.hidden = NO;
    _maskView.hidden = NO;
    
    [UIView animateWithDuration:kAnnimateTime animations:^
     {
         _maskView.alpha = 0;
//         _signBoardView.layer.transform = _transfrom;
     } completion:^(BOOL finished)
     {
         _signBoardView.hidden = YES;
         _maskView.hidden = YES;
         _signImageView.hidden = NO;
     }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)dealloc
{
    [_maskView removeFromSuperview];
    _maskView = nil;
    
    [_signBoardView removeFromSuperview];
    _signBoardView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - About rotate

// iOS6以前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

// iOS6及以后
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (INTERFACE_IS_PHONE) {
        return UIInterfaceOrientationLandscapeRight;
    } else {
        return [self preferredInterfaceOrientationForPresentation];
        /*
         self.interfaceOrientation ios8.0以后已经废除 create by 孙洪福
        return self.interfaceOrientation;
         */
    }
}

//获得某个范围内的屏幕图像
- (UIImage *)imageFromView: (UIView *) theView   atFrame:(CGRect)r
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}
@end
