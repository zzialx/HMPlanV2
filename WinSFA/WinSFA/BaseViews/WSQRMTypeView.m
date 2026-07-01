//
//  WSQRMTypeView.m
//  WinSFA
//
//  Created by HZH on 17/4/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSQRMTypeView.h"
#import "WSScanListPanel.h"

#import "WSScanListViewController.h"
#import "WSApplicationWindowsRelationManager.h"

#define DATAGRID_TITLE_FONTSIZE  (INTERFACE_IS_PHONE ? 15.0 : 17.0)
#define TilteTextFont [UIFont fontWithName:@"Helvetica-Light" size:DATAGRID_TITLE_FONTSIZE]

#define TilteColor [UIColor colorWithHexString:@"#282828"]

#define PANEL_HORIZONTAL_PADDING (INTERFACE_IS_PHONE ? 30.0 : 300.0)
#define PANEL_VERTICAL_PADDING (INTERFACE_IS_PHONE ? 150.0 : 200.0)

#define kAlertViewBackgroundColor    [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:0.3]

@interface WSQRMTypeView ()
{
    UIView *_qrPanelBgView;
    UIView *_backgroundView;
    WSScanListPanel *_qrPanel;
    WSFuncsBean_Param *_aParam;
}
@property (nonatomic, assign)BOOL isRequired;

@end

@implementation WSQRMTypeView

-(instancetype)init{
    if (self = [super init]) {
        [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setTitleColor:TilteColor forState:UIControlStateNormal];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = TilteTextFont;
        [self setupQRPanelWithParam:nil];
    }
    
    return self;
}

- (instancetype)initWithParam:(WSFuncsBean_Param *)aParam
{
    if (self = [super init]) {
        [self addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setTitleColor:TilteColor forState:UIControlStateNormal];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = TilteTextFont;
        _aParam = aParam;
        [self setupQRPanelWithParam:aParam];
    }
    
    return self;
}

- (void)setupQRPanelWithParam:(WSFuncsBean_Param *)aParam
{
    _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroundView.backgroundColor = kAlertViewBackgroundColor;
    _qrPanelBgView = [[UIView alloc] initWithFrame:CGRectMake(PANEL_HORIZONTAL_PADDING, SCREEN_HEIGHT, SCREEN_WIDTH - PANEL_HORIZONTAL_PADDING*2, SCREEN_HEIGHT - PANEL_VERTICAL_PADDING*2)];
    _qrPanelBgView.backgroundColor = [UIColor whiteColor];
    _qrPanel = [[WSScanListPanel alloc] initWithFrame:CGRectMake(0, 0, _qrPanelBgView.frame.size.width, _qrPanelBgView.frame.size.height - 40) andParam:aParam];


    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, _qrPanelBgView.frame.size.height - 40, _qrPanelBgView.frame.size.width/2, 40)];
    [cancelBtn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:27.0/255.0 green:157.0/255.0 blue:252.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(_qrPanelBgView.frame.size.width/2, _qrPanelBgView.frame.size.height - 40, _qrPanelBgView.frame.size.width/2, 40)];
    [confirmBtn setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor colorWithRed:27.0/255.0 green:157.0/255.0 blue:252.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_qrPanelBgView addSubview:cancelBtn];
    [_qrPanelBgView addSubview:confirmBtn];
    [_qrPanelBgView addSubview:_qrPanel];
    [_backgroundView addSubview:_qrPanelBgView];
}

- (void)confirmBtnClicked:(id)sender
{
    [self hideQRPanel];
    
    WSScanListView *listView = _qrPanel.scanListView;
    NSArray *aQRlist = [listView resultArray];
    
    if (aQRlist.count > 0) {
        
        [self setImage:nil forState:UIControlStateNormal];
        
        NSString *qrCodeString = @"";
        int cnt = 0;
        
        for (NSString *code in aQRlist) {
            cnt ++;
            if (cnt >= aQRlist.count) {
                qrCodeString = [qrCodeString stringByAppendingString:[NSString stringWithFormat:@"%@", code]];
            }else
                qrCodeString = [qrCodeString stringByAppendingString:[NSString stringWithFormat:@"%@,", code]];
        }
        
        [self setTitle:qrCodeString forState:UIControlStateNormal];
        
    }else{
        [self setTitle:@"" forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"qr_code"] forState:UIControlStateNormal];
        
    }
}


- (void)cancelBtnClicked:(id)sender
{
    [self hideQRPanel];

}

- (void)showQRPanel
{
    
    [[[[WSApplicationWindowsRelationManager sharedManager] getCurrentVC] view] addSubview:_backgroundView];
    
    [UIView animateWithDuration:0.2 animations:^{
        [_qrPanelBgView setFrame:CGRectMake(PANEL_HORIZONTAL_PADDING, PANEL_VERTICAL_PADDING, SCREEN_WIDTH - PANEL_HORIZONTAL_PADDING*2, SCREEN_HEIGHT - PANEL_VERTICAL_PADDING*2)];
    }];
}

- (void)hideQRPanel
{
    [UIView animateWithDuration:0.2 animations:^{
        [_qrPanelBgView setFrame:CGRectMake(PANEL_HORIZONTAL_PADDING, SCREEN_HEIGHT, SCREEN_WIDTH - PANEL_HORIZONTAL_PADDING*2, SCREEN_HEIGHT - PANEL_VERTICAL_PADDING*2)];
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
    }];
}

-(void)buttonClick:(UIButton *)sender{
    
    
    [self showQRPanel];
    
}

- (void)setDisplayString:(NSString *)displayString
{
    _qrPanel.displayString = displayString;
    _qrPanel.isNotChangePanelHeight = YES;
    _qrPanel.titleString = _aParam.name;
    
    [_qrPanel buildDisplayContent];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
