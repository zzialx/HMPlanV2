//
//  WSQRPanel.m
//  WinSFA
//
//  Created by winchannel on 16/7/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSQRPanel.h"
#import "WSInterAction.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"
#import "WSQRCodeViewController.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_Lua_Target_Operator.h"

#define DefaultHeight 50

#define QRCODE_VIEWCONTROLLER           @"WSQRCodeViewController"

@interface WSQRPanel ()

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) NSString *urlString;

@end

@implementation WSQRPanel

- (void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    CGRect newFrame = self.frame;
    newFrame.size.height = DefaultHeight;
    self.frame = newFrame;
    
    self.titleLabel.frame = CGRectMake(self.titleLabel.left, (self.height - self.titleLabel.height)/2, self.titleLabel.width, self.titleLabel.height);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_qrcode"]];
    
    imageView.frame = CGRectMake(self.width - imageView.size.width - MAIN_CELL_PADDING, (self.height - imageView.size.width)/2, imageView.size.width, imageView.size.height);
    imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:imageView];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.right + 10, self.titleLabel.top, imageView.left - (self.titleLabel.right + 20), self.titleLabel.height)];
    infoLabel.textColor = [UIColor grayColor];
    infoLabel.font = [UIFont systemFontOfSize:UI_Font];
    infoLabel.textAlignment = NSTextAlignmentRight;
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    self.infoLabel = infoLabel;
    [self addSubview:infoLabel];
    
    _originalValue = [xdisplayValue getDisplayValueFor:xbuildInfo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:tap];

}

- (void)tapped{
    
    
    if ([[xbuildInfo getLuaScript] length] > 0) {
        self.urlString = nil;
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }else {
        self.urlString = (NSString *)_originalValue;
    }
    
    if (!self.urlString || [self.urlString length] == 0) {
        return ;
    }
    
    WSInterAction *interaction  = [[WSInterAction alloc]init];
    [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    
    [interaction setDirect_type:DIRECT_TYPE_POPOVER];
    
    WSQRCodeViewController *qrCon = [[WSQRCodeViewController alloc] init];
    qrCon.title = [xbuildInfo getQuestName];
    qrCon.updateUrl = self.urlString;
    qrCon.isFromQst = YES;
    qrCon.isNotSendMessage = YES;
    qrCon.qrCodeWidth = INTERFACE_IS_PHONE ? 180 : 300;
    
    [interaction setExecute_controller:qrCon];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:INTERFACE_IS_PHONE ? @250 : @450 forKey:@"width"];
    [dic setObject:INTERFACE_IS_PHONE ? @300 : @500 forKey:@"height"];
    
    [interaction setExecute_class_param:dic];
    
    [delegate executeInterAction:interaction];
    
}
- (NSObject *)getResultDirectly{
    
    return _originalValue;
}

- (void)setValueForCurrentObject:(NSObject *)objvalue {
    
    self.urlString = (NSString *)objvalue;
    
}

@end
