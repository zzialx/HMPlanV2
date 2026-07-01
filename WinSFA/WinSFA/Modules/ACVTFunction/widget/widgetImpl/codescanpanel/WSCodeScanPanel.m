//
//  WSCodeScanPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCodeScanPanel.h"
#import "I_W_BuildInfo.h"
#import "WidgetConstant.h"
#import "WSQRModule.h"

@implementation WSCodeScanPanel

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
    
    CGFloat i_button_Width = orientition ? (self.bounds.size.width - kLabelLeftSpace*2)/2 : (self.bounds.size.width - kLabelLeftSpace);
    
    CGFloat i_button_x = orientition ? (self.bounds.size.width/2) : 0;
    
    CGFloat i_button_y = orientition ? 5 : (self.titleLabel.origin.y + self.titleLabel.height + 5);
    
    UIButton* i_button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    i_button.frame = CGRectMake(i_button_x, i_button_y, i_button_Width, 40);
    [i_button addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
    [i_button setImage:[[UIImage imageNamed:@"scan_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [i_button setTintColor:MAIN_TINT_COLOR];
    if (orientition) {
        i_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    } else {
        i_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    i_button.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    NSString *i_buttonTitle = NSLocalizedString(@"scan",nil);
    if ([xbuildInfo  getQuestName]) {
        i_buttonTitle = [xbuildInfo  getQuestName];
    }
    
    CGSize size = [i_buttonTitle ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
    
    
    
    CGFloat imageEdge_left = orientition ? 0 : (size.width - 40)/2;
    
    [i_button setImageEdgeInsets:UIEdgeInsetsMake(0, imageEdge_left, 0, 0)];
    i_button.tag = [[xbuildInfo getAcvtQstId] integerValue] + kScanButtonBaseTag;
    [self addSubview:i_button];
    
    [self setTitleLabelFrame: CGRectMake(titleLabel.frame.origin.x, 7.0, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    
    if (orientition) {
        [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, self.frame.size.width,5.0f + textField.frame.size.height+10.0)];
        
        CGRect labelRect = self.titleLabel.frame;
        
        self.titleLabel.frame = CGRectMake(labelRect.origin.x, (self.size.height - labelRect.size.height)/2,  labelRect.size.width, labelRect.size.height);
        
    } else {
        
        [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.y, self.frame.size.width, i_button.frame.size.height+1.0+textField.frame.size.height+10.0)];
    }
    textField.hidden = YES;
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
   
 
}


-(void)startScan:(id)sender
{
    __weak UITextField *textFieldx = textField;
    
    __weak WSCodeScanPanel *scanpanel = self;

    WSQRModule *wsScanModule = [WSQRModule getInstance];
    
    [wsScanModule showQRViewControllerToViewController:scanpanel.superview.viewController WithScanTxtBlock:^(NSString *textStr) {

        [textFieldx setText:textStr];
      
    } withScanImgBlock:nil];
}


@end
