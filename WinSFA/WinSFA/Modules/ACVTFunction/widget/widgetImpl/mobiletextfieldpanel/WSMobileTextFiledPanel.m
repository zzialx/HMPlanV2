//
//  WSMobileTextFiledPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMobileTextFiledPanel.h"
#import "I_M_View.h"
#import "I_W_BuildInfo.h"


@interface WSMobileTextFiledPanel ()

@property (nonatomic, strong) UIButton *callButton;

@end

//手机号面板
@implementation WSMobileTextFiledPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
      
        return self;
    }
    return nil;
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    BOOL orientition = NO;
    
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    CGFloat height = orientition ? self.height : MAIN_CELL_BUTTON_WH;
    
    self.callButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - MAIN_CELL_BUTTON_WH, (self.frame.size.height - MAIN_CELL_BUTTON_WH) / 2, MAIN_CELL_BUTTON_WH, height)];
    UIImage *image = [UIImage scaledImageForName:@"tel" ofType:@"png"];
    [self.callButton setImage:image forState:UIControlStateNormal];
    [self.callButton addTarget:self action:@selector(callPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.callButton];
    
    if (orientition) {
        CGRect newFrame = self.textField.frame;
        newFrame.size.width -= MAIN_CELL_BUTTON_WH;
        self.textField.frame = newFrame;
    }
    CGFloat seperatOffsetY = (self.size.height - MAIN_CELL_SEPERATOR_LENGTH) / 2;
    UIView *sperateLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.callButton.frame), seperatOffsetY, 1, MAIN_CELL_SEPERATOR_LENGTH)];
    sperateLineView.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [self addSubview:sperateLineView];
    
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    
    [self addGestureRecognizer:longPressGesture];


}
//SFA-13268  SFA葵花药业--手机端问题显示被遮挡
- (void)layoutSubviews{
    [super layoutSubviews];
    
    BOOL orientition = NO;
    
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    if (orientition) {
        CGRect newFrame = self.textField.frame;
        newFrame.size.width -= MAIN_CELL_BUTTON_WH;
        self.textField.frame = newFrame;
        
    }
    
}


-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];

}

- (void)callPhoneNumber
{
   NSString * phone = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]];
    if ([[UIApplication sharedApplication] canOpenURL:telUrl]) {
        [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:nil];
    }
}

#pragma mark -
#pragma mark I_M_ViewDelegate mehtod

-(void)MessageView:(NSObject<I_M_View> *)messageView clickAtButtonIndex:(NSInteger)index{

    
}

- (void)MessageViewClickAtCancel:(NSObject<I_M_View> *)messageView {
    
}

- (void)longPress:(UILongPressGestureRecognizer *)longGesture{

    if (longGesture.state == UIGestureRecognizerStateBegan) {
        
        [self callPhoneNumber];
        
    }
}
@end
