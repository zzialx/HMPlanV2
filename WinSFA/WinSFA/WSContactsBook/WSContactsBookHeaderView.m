//
//  WSContactsBookHeaderView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookHeaderView.h"
#import "WSContactsBookHeaderButton.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录头视图 延展(内部)
@interface WSContactsBookHeaderView ()

@property (nonatomic, assign) BOOL isShowOrganize;                          //是否显示组织标示
@property (nonatomic, assign) BOOL isShowStoreButton;                       //是否显示门店按键标示
@property (nonatomic, strong) UISearchBar *searchBar;                       //搜索框
@property (nonatomic, strong) UILabel *label;                               //标签
@property (nonatomic, strong) WSContactsBookHeaderButton *standardButton;   //标准按键
@property (nonatomic, strong) WSContactsBookHeaderButton *storeButton;      //门店按键

#pragma mark - 标准按键点击响应方法 sender:按键对象
- (void)touchUpStandardButtonEnevt:(id)sender;

#pragma mark - 门店按键点击响应方法 sender:按键对象
- (void)touchUpStoreButtonEnevt:(id)sender;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头视图 延展(内部)
@interface WSContactsBookHeaderView (Tools)

#pragma mark - 布局头视图方法
- (void)layoutHeaderView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头视图 延展(实现UISearchBarDelegate代理协议)
@interface WSContactsBookHeaderView (searchBarDelegate) <UISearchBarDelegate>

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头视图
@implementation WSContactsBookHeaderView

#pragma mark - 获取searchBar方法
- (UISearchBar *)searchBar
{
    if(_searchBar == nil)
    {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.backgroundImage = [UIImage new];
        _searchBar.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookBgColor];
        _searchBar.placeholder = NSLocalizedString(@"search", nil);
    }
    return _searchBar;
}

#pragma mark - 获取label方法
- (UILabel *)label
{
    if(_label == nil)
    {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont boldSystemFontOfSize:kContactsBookMainTitleSize_standard];
        _label.textColor = [[WSContactsBookTools sharedManager] getContactsBookGroupingTitleColor];
        _label.text = NSLocalizedString(@"organizational_structure", nil);
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _label;
}

#pragma mark - 获取standardButton方法
- (WSContactsBookHeaderButton *)standardButton
{
    if(_standardButton == nil)
    {
        _standardButton = [[WSContactsBookHeaderButton alloc] initWithFrame:CGRectZero];
        _standardButton.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
        [_standardButton updateWithMark:NSLocalizedString(@"ministry", nil) content:NSLocalizedString(@"department", nil)];
        [_standardButton addTarget:self action:@selector(touchUpStandardButtonEnevt:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _standardButton;
}

#pragma mark - 获取storeButton方法
- (WSContactsBookHeaderButton *)storeButton
{
    if(_storeButton == nil)
    {
        _storeButton = [[WSContactsBookHeaderButton alloc] initWithFrame:CGRectZero];
        _storeButton.backgroundColor = [[WSContactsBookTools sharedManager] getContactsBookElementBgColor];
        [_storeButton updateWithMark:NSLocalizedString(@"customer", nil) content:NSLocalizedString(@"customer_address_book", nil)];
        [_storeButton addTarget:self action:@selector(touchUpStoreButtonEnevt:) forControlEvents:UIControlEventTouchUpInside];
        _storeButton.hidden = YES;
    }
    return _storeButton;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.searchBar];
        [self addSubview:self.label];
        [self addSubview:self.standardButton];
        [self addSubview:self.storeButton];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutHeaderView];
}

#pragma mark - 更新视图方法 isShowOrganize:是否显示组织标示 isShowStoreButton:是否显示门店按键
- (void)updateWithIsShowOrganize:(BOOL)isShowOrganize isShowStoreButton:(BOOL)isShowStoreButton
{
    self.isShowOrganize = isShowOrganize;
    self.isShowStoreButton = isShowStoreButton;
    [self setNeedsLayout];
}

#pragma mark - 获取高度方法 isShowOrganize:是否显示组织标示 isShowStoreButton:是否显示门店按键 maxWidth:最大宽度
- (CGFloat)getHeightWithisShowOrganize:(BOOL)isShowOrganize isShowStoreButton:(BOOL)isShowStoreButton maxWidth:(CGFloat)maxWidth
{
    if(isShowOrganize)
    {
        CGFloat maxWidth = CGRectGetWidth(self.frame);
        CGSize textSize = [self.label.text ws_sizeWithFont:self.label.font constrainedToWidth:2000.0f];
        CGFloat buttonHeight = [self.standardButton getHeightWithMark:NSLocalizedString(@"ministry", nil) content:NSLocalizedString(@"department", nil)
                                                             maxWidth:maxWidth];
        
        CGFloat height = (kContactsBookSearchHeight_standard + textSize.height + kContactsBookSpace_small + buttonHeight);
        if(isShowStoreButton)
        {
            buttonHeight = [self.storeButton getHeightWithMark:NSLocalizedString(@"customer", nil) content:NSLocalizedString(@"customer_address_book", nil)
                                                      maxWidth:maxWidth];
            height += buttonHeight;
        }
        return height;
    }
    
    return kContactsBookSearchHeight_standard;
}

#pragma mark - 关闭搜索框方法
- (void)cloaseSearchBar
{
    if([self.searchBar isFirstResponder])
    {
        [self.searchBar resignFirstResponder];
        
        UIButton *cancelBtn = [self.searchBar valueForKey:@"cancelButton"];
        cancelBtn.enabled = YES;
    }
}

#pragma mark - 标准按键点击响应方法 sender:按键对象
- (void)touchUpStandardButtonEnevt:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(standardButtonSelected)])
        [self.delegate standardButtonSelected];
}

#pragma mark - 门店按键点击响应方法 sender:按键对象
- (void)touchUpStoreButtonEnevt:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(storeButtonSelected)])
        [self.delegate storeButtonSelected];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头视图 延展(内部)
@implementation WSContactsBookHeaderView (Tools)

#pragma mark - 布局头视图方法
- (void)layoutHeaderView
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = kContactsBookSearchHeight_standard;
    self.searchBar.frame = CGRectMake(x, y, w, h);
    
    if(self.isShowOrganize)
    {
        CGSize textSize = [self.label.text ws_sizeWithFont:self.label.font constrainedToWidth:2000.0f];
        x = kContactsBookSpace_big;
        y = CGRectGetMaxY(self.searchBar.frame);
        w = CGRectGetWidth(self.frame) - (kContactsBookSpace_big * 2);
        h = textSize.height;
        self.label.frame = CGRectMake(x, y, w, h);
        self.label.hidden = NO;
        
        x = 0.0f;
        y = CGRectGetMaxY(self.label.frame) + kContactsBookSpace_small;
        w = CGRectGetWidth(self.frame);
        h = [self.standardButton getHeightWithMark:NSLocalizedString(@"ministry", nil) content:NSLocalizedString(@"department", nil) maxWidth:CGRectGetWidth(self.frame)];
        self.standardButton.frame = CGRectMake(x, y, w, h);
        self.standardButton.hidden = NO;
        
        if(self.isShowStoreButton)
        {
            x = 0.0f;
            y = CGRectGetMaxY(self.standardButton.frame);
            w = CGRectGetWidth(self.frame);
            h = [self.storeButton getHeightWithMark:NSLocalizedString(@"customer", nil) content:NSLocalizedString(@"customer_address_book", nil)
                                           maxWidth:CGRectGetWidth(self.frame)];
            self.storeButton.frame = CGRectMake(x, y, w, h);
            self.storeButton.hidden = NO;
        }
        else
        {
            self.storeButton.frame = CGRectZero;
            self.storeButton.hidden = YES;
        }
    }
    else
    {
        self.label.frame = CGRectZero;
        self.label.hidden = YES;
        
        self.standardButton.frame = CGRectZero;
        self.standardButton.hidden = YES;
        
        self.storeButton.frame = CGRectZero;
        self.storeButton.hidden = YES;
    }
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录头视图 延展(实现UISearchBarDelegate代理协议)
@implementation WSContactsBookHeaderView (searchBarDelegate)

#pragma mark - 实现searchBarTextDidBeginEditing:协议
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginSearch)])
        [self.delegate beginSearch];
}

#pragma mark - 实现searchBarCancelButtonClicked:协议
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    self.searchBar.showsCancelButton = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(endSearch)])
        [self.delegate endSearch];
}

#pragma mark - 实现searchBar:textDidChange:协议
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResult:)])
        [self.delegate searchResult:searchText];
}

#pragma mark - 实现searchBarSearchButtonClicked:协议
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self cloaseSearchBar];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResult:)])
        [self.delegate searchResult:searchBar.text];
}

@end
//===================================================================================================================================================================
