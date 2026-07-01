//
//  WSContactsBookDetailsScrollView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDetailsScrollView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
#import "WSContactsBookDetailsHeaderView.h"
#import "WSContactsBookDetailsOneTitleView.h"
#import "WSContactsBookDetailsPhoneView.h"
#import "WSContactsBookDetailsTwoTitleView.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情滚动视图 延展(内部)
@interface WSContactsBookDetailsScrollView ()

@property (nonatomic, strong) WSContactsBookDetailsHeaderView *headView;                //头视图
@property (nonatomic, strong) WSContactsBookDetailsOneTitleView *contactTitleView;      //联系标题视图
@property (nonatomic, strong) WSContactsBookDetailsPhoneView *phoneView;                //电话视图
@property (nonatomic, strong) WSContactsBookDetailsOneTitleView *infoTitleView;         //信息标题视图
@property (nonatomic, strong) WSContactsBookDetailsTwoTitleView *codeTitleView;         //信息标题视图
@property (nonatomic, strong) WSContactsBookDetailsTwoTitleView *departmentTitleView;   //部门标题视图
@property (nonatomic, strong) WSContactsBookDetailsTwoTitleView *timeTitleView;         //事件标题视图
@property (nonatomic, strong) UIButton *messageButton;                                  //信息按键

#pragma mark - 消息按键点击响应方法 sender:按键对象
- (void)touchUpMessageButtonEnevt:(id)sender;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情滚动视图 延展(工具)
@interface WSContactsBookDetailsScrollView (Tools)

#pragma mark - 更新滚动视图方法
- (void)updateScrollView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情滚动视图
@implementation WSContactsBookDetailsScrollView

#pragma mark - 获取headView方法
- (WSContactsBookDetailsHeaderView *)headView
{
    if(_headView == nil)
    {
        _headView = [[WSContactsBookDetailsHeaderView alloc] initWithFrame:CGRectZero];
        _headView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _headView;
}

#pragma mark - 获取contactTitleView方法
- (WSContactsBookDetailsOneTitleView *)contactTitleView
{
    if(_contactTitleView == nil)
    {
        _contactTitleView = [[WSContactsBookDetailsOneTitleView alloc] initWithFrame:CGRectZero];
        _contactTitleView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _contactTitleView;
}

#pragma mark - 获取phoneView方法
- (WSContactsBookDetailsPhoneView *)phoneView
{
    if(_phoneView == nil)
    {
        _phoneView = [[WSContactsBookDetailsPhoneView alloc] initWithFrame:CGRectZero];
        _phoneView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _phoneView;
}

#pragma mark - 获取infoTitleView方法
- (WSContactsBookDetailsOneTitleView *)infoTitleView
{
    if(_infoTitleView == nil)
    {
        _infoTitleView = [[WSContactsBookDetailsOneTitleView alloc] initWithFrame:CGRectZero];
        _infoTitleView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _infoTitleView;
}

#pragma mark - 获取codeTitleView方法
- (WSContactsBookDetailsTwoTitleView *)codeTitleView
{
    if(_codeTitleView == nil)
    {
        _codeTitleView = [[WSContactsBookDetailsTwoTitleView alloc] initWithFrame:CGRectZero];
        _codeTitleView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _codeTitleView;
}

#pragma mark - 获取departmentTitleView方法
- (WSContactsBookDetailsTwoTitleView *)departmentTitleView
{
    if(_departmentTitleView == nil)
    {
        _departmentTitleView = [[WSContactsBookDetailsTwoTitleView alloc] initWithFrame:CGRectZero];
        _departmentTitleView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _departmentTitleView;
}

#pragma mark - 获取timeTitleView方法
- (WSContactsBookDetailsTwoTitleView *)timeTitleView
{
    if(_timeTitleView == nil)
    {
        _timeTitleView = [[WSContactsBookDetailsTwoTitleView alloc] initWithFrame:CGRectZero];
        _timeTitleView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _timeTitleView;
}

#pragma mark - 获取messageButton方法
- (UIButton *)messageButton
{
    if (_messageButton == nil)
    {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageButton.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookThemeColor];
        [_messageButton setTitleColor:[[WSContactsBookTools sharedManager] getContactsBookTitleWhiteColor] forState:UIControlStateNormal];
        _messageButton.titleLabel.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_standard];
        _messageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_messageButton addTarget:self action:@selector(touchUpMessageButtonEnevt:) forControlEvents:UIControlEventTouchUpInside];
        _messageButton.layer.masksToBounds = YES;
        _messageButton.clipsToBounds = YES;
        _messageButton.layer.cornerRadius = 5.0f;
    }
    
    return _messageButton;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:self.headView];
        [self addSubview:self.contactTitleView];
        [self addSubview:self.phoneView];
        [self addSubview:self.infoTitleView];
        [self addSubview:self.codeTitleView];
        [self addSubview:self.departmentTitleView];
        [self addSubview:self.timeTitleView];
        [self addSubview:self.self.messageButton];
        
        __weak typeof(self) weakSelf = self;
        [self.phoneView setMessageClickBlock:^(NSString *phone){
            if (weakSelf.interactiveDelegate && [weakSelf.interactiveDelegate respondsToSelector:@selector(messageButtonSelected:)])
                [weakSelf.interactiveDelegate messageButtonSelected:phone];
        }];
        [self.phoneView setPhoneClickBlock:^(NSString *phone){
            if (weakSelf.interactiveDelegate && [weakSelf.interactiveDelegate respondsToSelector:@selector(phoneButtonSelected:)])
                [weakSelf.interactiveDelegate phoneButtonSelected:phone];
        }];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateScrollView];
}

#pragma mark - 重写setInfoData:方法
- (void)setInfoData:(WSContactsDetailInfo *)infoData
{
    _infoData = infoData;
    
    UIImage *headViewBgImag = [UIImage scaledImageForName:@"contactsBookDetailsHeaderBg" ofType:@"png"];
    NSString *name = (self.infoData.name.length > 0) ? self.infoData.name : @"";
    NSString *jobTitle = (self.infoData.jobTitle.length > 0) ? self.infoData.jobTitle : @"";
    NSString *iconUrl = (self.infoData.headPhoto.length > 0) ? self.infoData.headPhoto : @"";
    [self.headView updateViewWithBgImage:headViewBgImag name:name jobTitle:jobTitle iconUrl:iconUrl];
    
    [self.contactTitleView updateViewWithTitle:NSLocalizedString(@"contact_information", nil) isBottomSpace:NO];
    
    NSString *phone = (self.infoData.phone.length > 0) ? self.infoData.phone : @"";
    UIImage *messageImag = [UIImage scaledImageForName:@"contactsBookDetailsMessage" ofType:@"png"];
    UIImage *phoneImag = [UIImage scaledImageForName:@"contactsBookDetailsPhone" ofType:@"png"];
    [self.phoneView updateViewWithTitle:NSLocalizedString(@"phone", nil) content:phone messageIcon:messageImag phoneIcon:phoneImag isShowLine:YES];
    
    if(self.isHidePerInfo == YES)
    {
        [self setNeedsLayout];
        return;
    }
    
    [self.infoTitleView updateViewWithTitle:NSLocalizedString(@"personal_information", nil) isBottomSpace:NO];
    
    NSString *code = (self.infoData.code.length > 0) ? self.infoData.code : @"";
    [self.codeTitleView updateViewWithTitle:NSLocalizedString(@"job_number", nil) content:code isShowLine:YES];
    
    NSString *department = (self.infoData.orgName.length > 0) ? self.infoData.orgName : @"";
    [self.departmentTitleView updateViewWithTitle:NSLocalizedString(@"department", nil) content:department isShowLine:YES];
    
    NSString *time = (self.infoData.entryTime.length > 0) ? self.infoData.entryTime : @"";
    [self.timeTitleView updateViewWithTitle:NSLocalizedString(@"entry_time", nil) content:time isShowLine:NO];
    
    [self.messageButton setTitle:NSLocalizedString(@"send_message", nil) forState:UIControlStateNormal];

    [self setNeedsLayout];
}

#pragma mark - 消息按键点击响应方法 sender:按键对象
- (void)touchUpMessageButtonEnevt:(id)sender
{
    if (self.interactiveDelegate && [self.interactiveDelegate respondsToSelector:@selector(chatButtonSelected:name:iconUrl:)])
        [self.interactiveDelegate chatButtonSelected:self.infoData.hxCode name:self.infoData.name iconUrl:self.infoData.headPhoto];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情滚动视图 延展(工具)
@implementation WSContactsBookDetailsScrollView (Tools)

#pragma mark - 更新滚动视图方法
- (void)updateScrollView
{
    UIImage *headViewBgImag = [UIImage scaledImageForName:@"contactsBookDetailsHeaderBg" ofType:@"png"];
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = [self.headView getHeightWithBgImage:headViewBgImag maxWidth:CGRectGetWidth(self.frame)];
    self.headView.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = CGRectGetMaxY(self.headView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.contactTitleView getHeightWithTitle:NSLocalizedString(@"contact_information", nil) isBottomSpace:NO maxWidth:CGRectGetWidth(self.frame)];
    self.contactTitleView.frame = CGRectMake(x, y, w, h);
    
    NSString *phone = (self.infoData.phone.length > 0) ? self.infoData.phone : @"";
    UIImage *messageImag = [UIImage scaledImageForName:@"contactsBookDetailsMessage" ofType:@"png"];
    UIImage *phoneImag = [UIImage scaledImageForName:@"contactsBookDetailsPhone" ofType:@"png"];
    x = 0.0f;
    y = CGRectGetMaxY(self.contactTitleView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.phoneView getHeightWithTitle:NSLocalizedString(@"phone", nil) content:phone messageIcon:messageImag phoneIcon:phoneImag
                                isShowLine:YES maxWidth:CGRectGetWidth(self.frame)];
    self.phoneView.frame = CGRectMake(x, y, w, h);
    
    if(self.isHidePerInfo == YES)
    {
        self.infoTitleView.frame = CGRectZero;
        self.codeTitleView.frame = CGRectZero;
        self.departmentTitleView.frame = CGRectZero;
        self.timeTitleView.frame = CGRectZero;
        self.messageButton.frame = CGRectZero;
        
        self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), (CGRectGetMaxY(self.phoneView.frame) + kContactsBookDetailsIconBottomSpace));
        return;
    }
    
    x = 0.0f;
    y = CGRectGetMaxY(self.phoneView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.infoTitleView getHeightWithTitle:NSLocalizedString(@"personal_information", nil) isBottomSpace:NO maxWidth:CGRectGetWidth(self.frame)];
    self.infoTitleView.frame = CGRectMake(x, y, w, h);
    
    NSString *code = (self.infoData.code.length > 0) ? self.infoData.code : @"";
    x = 0.0f;
    y = CGRectGetMaxY(self.infoTitleView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.codeTitleView getHeightWithTitle:NSLocalizedString(@"job_number", nil) content:code isShowLine:YES maxWidth:CGRectGetWidth(self.frame)];
    self.codeTitleView.frame = CGRectMake(x, y, w, h);
    
    NSString *department = (self.infoData.orgName.length > 0) ? self.infoData.orgName : @"";
    x = 0.0f;
    y = CGRectGetMaxY(self.codeTitleView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.departmentTitleView getHeightWithTitle:NSLocalizedString(@"department", nil) content:department isShowLine:YES maxWidth:CGRectGetWidth(self.frame)];
    self.departmentTitleView.frame = CGRectMake(x, y, w, h);
    
    NSString *time = (self.infoData.entryTime.length > 0) ? self.infoData.entryTime : @"";
    x = 0.0f;
    y = CGRectGetMaxY(self.departmentTitleView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.timeTitleView getHeightWithTitle:NSLocalizedString(@"entry_time", nil) content:time isShowLine:NO maxWidth:CGRectGetWidth(self.frame)];
    self.timeTitleView.frame = CGRectMake(x, y, w, h);
    
    x = kContactsBookSpace_big;
    y = CGRectGetHeight(self.frame) - kContactsBookDetailsMessageButtonHeight - kContactsBookDetailsIconBottomSpace;
    if(y <= CGRectGetMaxY(self.timeTitleView.frame))
        y = CGRectGetMaxY(self.timeTitleView.frame) + kContactsBookDetailsIconBottomSpace;
    w = CGRectGetWidth(self.frame) - (kContactsBookSpace_big * 2);
    h = kContactsBookDetailsMessageButtonHeight;
    self.messageButton.frame = CGRectMake(x, y, w, h);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), (CGRectGetMaxY(self.messageButton.frame) + kContactsBookDetailsIconBottomSpace));
}

@end
//===================================================================================================================================================================
