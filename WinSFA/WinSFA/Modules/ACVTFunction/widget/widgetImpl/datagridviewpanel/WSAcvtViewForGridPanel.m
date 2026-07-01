//
//  WSAcvtViewForGridPanel.m
//  WinSFA
//
//  Created by HZH on 2017/10/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSAcvtViewForGridPanel.h"
#import "WSAcvtScrollView.h"
#import "WSAcvtView.h"
#import "WSAcvtBean.h"
#import "WSTableItem.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import <WinCore.h>
#import "WSScrollLabelView.h"

#define hTopOrBottomWithoutKeyboardPadding SCREEN_HEIGHT * 0.14
#define kScrollLabelFont          ([UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] : FONT_SIZE_PINGFANG_MEDIUM(UI_Font))

@interface WSAcvtViewForGridPanel () <UIScrollViewDelegate, CAAnimationDelegate>

@property (nonatomic, assign) CGFloat statusbarAndNavigationbarRealHeight;
@property (nonatomic, strong) WSAcvtScrollView *scrollView;
@property (nonatomic, strong) WSAcvtView  *acvtview;
@property (nonatomic, assign) BOOL firstLoad;  //是否第一次载入
@property (nonatomic, strong) WSAcvtModel * currentAcvtModel;
@property (nonatomic, strong) WSAcvtBean *currentAcvtBean;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, assign) BOOL cancelBounce;
@property (nonatomic, strong) UIView *centreView;
@property (nonatomic, assign) CGRect scrollViewOriginFrame;
@property (nonatomic, assign) CGRect centreViewOriginFrame;
@property (nonatomic, strong) WSStoreBean *currentStore;
@property (nonatomic, strong) WSSubempstoreBean *currentSubEmpStore;
@property (nonatomic , assign) BOOL readonly;
@property (nonatomic, strong) WSBaseModel *lastAcvtModel;


@end

@implementation WSAcvtViewForGridPanel

- (id)initWithAcvtBean:(WSTableItem *)tableItem withItemId:(NSString *)itemId withItemName:(NSString *)itemName withDisplayValue:(NSDictionary *)dict withLuaScript:(NSString *)luaScript andCurrentStore:(WSStoreBean *)currentStore andCurrentSubEmpStore:(WSSubempstoreBean *)currentSubEmpStore andIsReadOnly:(BOOL)readonly

{
    
    if(tableItem == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentAcvtBean = [[WSAcvtBean alloc] initAcvtBeanWithTableItem:tableItem withItemId:itemId withItemName:itemName withLuaScript:luaScript];
        self.itemId = itemId;
        self.itemName = itemName;
        self.currentStore = currentStore;
        self.currentSubEmpStore = currentSubEmpStore;
        self.readonly = readonly;

        self.lastAcvtModel = [WSDataSourceManager sharedInstance].currentActiveModel;
        [self createAcvtModel:dict];
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _statusbarAndNavigationbarRealHeight = 0.0;
        _firstLoad = YES;
        
        return self;
    }
    return nil;
    
}

- (void)addKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)createAcvtModel:(NSDictionary * )dict{
    
    self.currentAcvtModel = [[WSAcvtModel alloc]init];
    self.currentAcvtModel.currentAcvtBean = self.currentAcvtBean;
    self.currentAcvtModel.hasLocalData = YES;
    self.currentAcvtModel.qstDBValueDictionary = [dict mutableCopy];
    self.currentAcvtModel.currentStore = self.currentStore;
    self.currentAcvtModel.currentSubEmpStore = self.currentSubEmpStore;
    
    [WSDataSourceManager sharedInstance].currentActiveModel = self.currentAcvtModel;
}

- (void)setupSubviews
{
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    // MSTD-7260 UI 规范
    CGFloat width = SCREEN_WIDTH * POP_VIEW_WIDTH_RATIO;
    CGFloat paddingX = (SCREEN_WIDTH - width) / 2;
    _centreView = [[UIView alloc] initWithFrame:CGRectMake(paddingX, hTopOrBottomWithoutKeyboardPadding - _statusbarAndNavigationbarRealHeight, width, SCREEN_HEIGHT - hTopOrBottomWithoutKeyboardPadding * 2)];
    _centreView.backgroundColor = [UIColor whiteColor];

    CGFloat titleHeight = 50.0;
    WSScrollLabelView *titleLabel = [[WSScrollLabelView alloc] initWithFrame:CGRectMake(MAIN_BIG_PADDING, 0, _centreView.frame.size.width - 2 * MAIN_BIG_PADDING, titleHeight)];
    titleLabel.text = self.itemName;
    titleLabel.font = kScrollLabelFont;
    titleLabel.textColor = [UIColor colorForKey:@"GridHeaderTitleColor"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_centreView addSubview:titleLabel];
    
    // MSTD-7181 titleLabel 宽度是自适应的，需要用 _centreView 宽度
    UIView *titleBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.size.height - 2, _centreView.width, 2)];
    titleBottomView.backgroundColor = MAIN_TINT_COLOR;
    [_centreView addSubview:titleBottomView];
    
    CGFloat height = titleHeight;
    CGFloat buttonHeight = 50;
    
    _scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(0, height, _centreView.frame.size.width, _centreView.frame.size.height - buttonHeight - titleHeight) andAcvtBean:_currentAcvtBean];
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.acvtview = _scrollView.acvtView;
    
    [self.acvtview buildDisplayContent];
    
    if (self.acvtview.frame.size.height < _scrollView.frame.size.height) {
        CGRect scrollViewFrame = _scrollView.frame;
        scrollViewFrame.size.height = self.acvtview.frame.size.height;
        _scrollView.frame = scrollViewFrame;
        
        
        CGRect centreViewFrame = _centreView.frame;
        centreViewFrame.size.height =  buttonHeight + titleHeight + scrollViewFrame.size.height;
        centreViewFrame.origin.y = (SCREEN_HEIGHT - centreViewFrame.size.height)/2 - _statusbarAndNavigationbarRealHeight;
        _centreView.frame = centreViewFrame;
        
    }
    
    _scrollViewOriginFrame = _scrollView.frame;
    _centreViewOriginFrame = _centreView.frame;
    
    [_centreView addSubview:_scrollView];
    
    height = height + _scrollView.frame.size.height;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, height, _centreView.frame.size.width/2, 50.0)];
    [cancelBtn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:(kAlertViewButtonTextColor ? kAlertViewButtonTextColor : [UIColor darkGrayColor]) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = kAlertViewButtonFont;
    
    cancelBtn.backgroundColor = kAlertViewButtonBackgroundColor;
    
    [_centreView addSubview:cancelBtn];
    
    //YIHAIKERRY-4047 （与安卓统一逻辑，只读模式下不需要确定按钮）
    if (self.readonly != YES) {
        
        CALayer *RightBorder = [CALayer layer];
        RightBorder.frame = CGRectMake(cancelBtn.frame.size.width, 0, 1, cancelBtn.frame.size.height);
        RightBorder.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
        [cancelBtn.layer addSublayer:RightBorder];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setFrame:CGRectMake(_centreView.frame.size.width/2 + 1, height, _centreView.frame.size.width/2 - 1, 50.0)];
        [confirmBtn setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setTitleColor:(kAlertViewButtonTextColor ? kAlertViewButtonTextColor : [UIColor darkGrayColor]) forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = kAlertViewButtonFont;
        
        confirmBtn.backgroundColor = kAlertViewButtonBackgroundColor;
        
        [_centreView addSubview:confirmBtn];
        
    }else{
        [cancelBtn setFrame:CGRectMake(0, height, _centreView.frame.size.width, 50.0)];
    }
    
    
    // MSTD-7260 备注去掉分割线
    //    CALayer *TopBorder = [CALayer layer];
    //    TopBorder.frame = CGRectMake(0, 0, cancelBtn.frame.size.width, 1);
    //    TopBorder.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    //    [cancelBtn.layer addSublayer:TopBorder];
    
    //    CALayer *TopBorder01 = [CALayer layer];
    //    TopBorder01.frame = CGRectMake(0, 0, confirmBtn.frame.size.width, 1);
    //    TopBorder01.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    //    [confirmBtn.layer addSublayer:TopBorder01];
    
    [self addSubview:_centreView];
    
    _firstLoad = NO;
}

- (void)cancelBtnClicked:(id)sender
{
    
    [self dismiss];
}

- (void)confirmBtnClicked:(id)sender
{
    if ([self.acvtview executeValidate]) {
        if ([self.acvtview checkLuaScriptWhenUpload]) {
            NSMutableDictionary * dict = (NSMutableDictionary *)[self.acvtview getAllDataAboutQstIdAndValue];
            [dict removeObjectForKey:@"prodId"];
            if (self.reloadGridView) {
                self.reloadGridView(dict, self.itemId);
            }
            [self dismiss];
        }
    }

}

- (void)show
{
    [self addKeyboardNotificationObserver];
    
    if (self.viewController.navigationController) {
        UINavigationController *navc = self.viewController.navigationController;
        _statusbarAndNavigationbarRealHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + navc.navigationBar.frame.size.height;
    }
    
    if (_firstLoad) {
        [self setupSubviews];
    }
    
    self.hidden = NO;
    
    // MSTD-7309 添加动效
    self.alpha = 0;
    [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss
{
    [self removeKeyboardNotificationObserver];
    
    [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
         self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    // YIHAIKERRY-4226  YIHAIKERRY-4227
    [WSDataSourceManager sharedInstance].currentActiveModel = self.lastAcvtModel;
    
}

- (UIView *)getCenterView {
    return self.centreView;
}

#pragma mark - keyboard show and hiden
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSString *infoName = [aNotification name];
//    NSDictionary* info = [aNotification userInfo];
    //kbSize即为键盘尺寸 (有width, height)
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    if ([infoName isEqualToString:UIKeyboardWillShowNotification]) {
        
        CGRect centreViewFrame = _centreView.frame;
        centreViewFrame.origin.y = 10.0;
        _centreView.frame = centreViewFrame;

    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSString *name = [aNotification name];
    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
        _centreView.frame = _centreViewOriginFrame;
    }
}


@end
