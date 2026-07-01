//
//  WSContactsBookStoreDetailsScrollView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookStoreDetailsScrollView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
#import "WSContactsBookDetailsHeaderView.h"
#import "WSContactsBookDetailsOneTitleView.h"
#import "WSContactsBookDetailsPhoneView.h"
#import "WSContactsBookDetailsTwoTitleView.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情(店)滚动视图 延展(内部)
@interface WSContactsBookStoreDetailsScrollView ()

@property (nonatomic, strong) WSContactsBookDetailsHeaderView *headView;                //头视图
@property (nonatomic, strong) WSContactsBookDetailsOneTitleView *contactTitleView;      //联系标题视图
@property (nonatomic, strong) WSContactsBookDetailsPhoneView *phoneView;                //电话视图
@property (nonatomic, strong) WSContactsBookDetailsOneTitleView *infoTitleView;         //信息标题视图
@property (nonatomic, strong) WSContactsBookDetailsTwoTitleView *addrView;              //地址视图

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情(店)滚动视图 延展(工具)
@interface WSContactsBookStoreDetailsScrollView (Tools)

#pragma mark - 更新滚动视图方法
- (void)updateScrollView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情(店)滚动视图
@implementation WSContactsBookStoreDetailsScrollView

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

#pragma mark - 获取addrView方法
- (WSContactsBookDetailsTwoTitleView *)addrView
{
    if(_addrView == nil)
    {
        _addrView = [[WSContactsBookDetailsTwoTitleView alloc] initWithFrame:CGRectZero];
        _addrView.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
    }
    return _addrView;
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
        [self addSubview:self.addrView];

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
    
    [self.infoTitleView updateViewWithTitle:NSLocalizedString(@"customer_information", nil) isBottomSpace:NO];
    
    NSString *code = (self.infoData.address.length > 0) ? self.infoData.address : @"";
    [self.addrView updateViewWithTitle:NSLocalizedString(@"customer_address", nil) content:code isShowLine:YES];
    
    [self setNeedsLayout];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情(店)滚动视图 延展(工具)
@implementation WSContactsBookStoreDetailsScrollView (Tools)

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
    
    x = 0.0f;
    y = CGRectGetMaxY(self.phoneView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.infoTitleView getHeightWithTitle:NSLocalizedString(@"customer_information", nil) isBottomSpace:NO maxWidth:CGRectGetWidth(self.frame)];
    self.infoTitleView.frame = CGRectMake(x, y, w, h);
    
    NSString *code = (self.infoData.address.length > 0) ? self.infoData.address : @"";
    x = 0.0f;
    y = CGRectGetMaxY(self.infoTitleView.frame);
    w = CGRectGetWidth(self.frame);
    h = [self.addrView getHeightWithTitle:NSLocalizedString(@"customer_address", nil) content:code isShowLine:YES maxWidth:CGRectGetWidth(self.frame)];
    self.addrView.frame = CGRectMake(x, y, w, h);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), (CGRectGetMaxY(self.addrView.frame) + kContactsBookDetailsIconBottomSpace));
}

@end
//===================================================================================================================================================================
