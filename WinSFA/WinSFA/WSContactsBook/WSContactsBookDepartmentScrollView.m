//
//  WSContactsBookDepartmentScrollView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDepartmentScrollView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图元素
@interface WSContactsBookDepartmentElement : UIView

@property (nonatomic, strong) UILabel *label;           //标签
@property (nonatomic, strong) UIImageView *arrowImage;  //箭头图片
@property (nonatomic, assign) CGFloat space;            //间距

#pragma mark - 更新视图方法 title:标题 font:字体 arrowImage:箭头图片 space:间距
- (void)updateViewWithTitle:(NSString *)title font:(UIFont *)font arrowImage:(UIImage *)arrowImage space:(CGFloat)space;

#pragma mark - 获取视图宽度方法 title:标题 font:字体 arrowImage:箭头图片 space:间距
- (CGFloat)getViewWidthWithTitle:(NSString *)title font:(UIFont *)font arrowImage:(UIImage *)arrowImage space:(CGFloat)space;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图元素
@implementation WSContactsBookDepartmentElement

#pragma mark - 获取label方法
- (UILabel *)label
{
    if(_label == nil)
    {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [[WSContactsBookTools sharedManager] getContactsBookThemeColor];
    }
    return _label;
}

#pragma mark - 获取arrowImage方法
- (UIImageView *)arrowImage
{
    if(_arrowImage == nil)
    {
        _arrowImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImage.backgroundColor = [UIColor clearColor];
        _arrowImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _arrowImage;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.label];
        [self addSubview:self.arrowImage];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize titleSize = [self.label.text ws_sizeWithFont:self.label.font constrainedToWidth:2000.0f];
    UIImage *image = self.arrowImage.image;
    
    CGFloat x = self.space;
    CGFloat y = (CGRectGetHeight(self.frame) - titleSize.height) / 2;
    CGFloat w = titleSize.width;
    CGFloat h = titleSize.height;
    self.label.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.label.frame) + self.space;
    y = (CGRectGetHeight(self.frame) - image.size.height) / 2;
    w = image.size.width;
    h = image.size.height;
    self.arrowImage.frame = CGRectMake(x, y, w, h);
}

#pragma mark - 更新视图方法 title:标题 font:字体 arrowImage:箭头图片 space:间距
- (void)updateViewWithTitle:(NSString *)title font:(UIFont *)font arrowImage:(UIImage *)arrowImage space:(CGFloat)space
{
    self.label.text = title;
    self.label.font = font;
    self.arrowImage.image = arrowImage;
    self.space = space;
    
    [self setNeedsLayout];
}

#pragma mark - 获取视图宽度方法 title:标题 font:字体 arrowImage:箭头图片 space:间距
- (CGFloat)getViewWidthWithTitle:(NSString *)title font:(UIFont *)font arrowImage:(UIImage *)arrowImage space:(CGFloat)space
{
    CGSize titleSize = [title ws_sizeWithFont:font constrainedToWidth:2000.0f];
    CGFloat width = space + titleSize.width + space + arrowImage.size.width;
    return width;
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图 延展(内部)
@interface WSContactsBookDepartmentScrollView ()

@property (nonatomic, strong) UIScrollView *scrollView;     //滚动视图
@property (nonatomic, strong) NSMutableArray *tagSubviews;  //标签子视图数组
@property (nonatomic, strong) UILabel *departmentLabel;     //部门标签

#pragma mark - 手势响应方法
- (void)gestureAction:(id)sender;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图 延展(工具)
@interface WSContactsBookDepartmentScrollView (Tools)

#pragma mark - 常规初始化方法
- (void)commonInit;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图
@implementation WSContactsBookDepartmentScrollView

#pragma mark - 获取scrollView滚动视图方法
- (UIScrollView *)scrollView
{
    if(_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

#pragma mark - 获取departmentLabel方法
- (UILabel *)departmentLabel
{
    if(_departmentLabel == nil)
    {
        _departmentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _departmentLabel.backgroundColor = [UIColor clearColor];
        _departmentLabel.textAlignment = NSTextAlignmentCenter;
        _departmentLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleGrayColor];
    }
    return _departmentLabel;
}

#pragma mark - 获取tagSubviews方法
- (NSMutableArray *)tagSubviews
{
    if(_tagSubviews == nil)
        _tagSubviews = [[NSMutableArray alloc] init];
    return _tagSubviews;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self commonInit];
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    self.scrollView.frame = CGRectMake(x, y, w, h);
    
    CGFloat offX = 0.0f;
    for (int i = 0; i < self.tagSubviews.count; ++i)
    {
        NSString *tag = (i < self.tags.count) ? [self.tags objectAtIndex:i] : @"";
        UIImage *image = [UIImage scaledImageForName:@"contactsBookDetailsArrow" ofType:@"png"];
        
        WSContactsBookDepartmentElement *element = [self.tagSubviews objectAtIndex:i];
        CGFloat width = [element getViewWidthWithTitle:tag font:self.font arrowImage:image space:kContactsBookSpace_standard];
        element.frame = CGRectMake(offX, 0.0f, width, CGRectGetHeight(self.frame));
        
        offX = CGRectGetMaxX(element.frame);
    }
    
    if(self.tagSubviews.count > 0)
    {
        CGSize titleSize = [self.departmentLabel.text ws_sizeWithFont:self.departmentLabel.font constrainedToWidth:2000.0f];
        CGFloat width = kContactsBookSpace_standard + titleSize.width + kContactsBookSpace_standard;
        self.departmentLabel.frame = CGRectMake(offX, 0.0f, width, CGRectGetHeight(self.frame));
        
        offX = CGRectGetMaxX(self.departmentLabel.frame);
    }
    
    self.scrollView.contentSize = CGSizeMake(offX, CGRectGetHeight(self.frame));
    CGSize contentSize = self.scrollView.contentSize;
    CGRect frame = self.scrollView.frame;
    if (contentSize.width > frame.size.width)
    {
        CGFloat offx = contentSize.width - frame.size.width;
        [self.scrollView setContentOffset:CGPointMake(offx, 0.0f) animated:YES];
    }
    else
        [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}

#pragma mark - 重载标签子视图方法
- (void)reloadTagSubviews
{
    for (UIView *view in self.tagSubviews)
        [view removeFromSuperview];
    [self.tagSubviews removeAllObjects];
    
    for (int i = 0; i < self.tags.count; ++i)
    {
        NSString *tag = [self.tags objectAtIndex:i];
        UIImage *image = [UIImage scaledImageForName:@"contactsBookDetailsArrow" ofType:@"png"];
        
        WSContactsBookDepartmentElement *element = [[WSContactsBookDepartmentElement alloc] initWithFrame:CGRectZero];
        element.backgroundColor = [UIColor clearColor];
        element.tag = i;
        [element updateViewWithTitle:tag font:self.font arrowImage:image space:kContactsBookSpace_standard];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [element setUserInteractionEnabled:YES];
        [element addGestureRecognizer:tapRecognizer];
        
        [self.tagSubviews addObject:element];
        [self.scrollView addSubview:element];
    }
    
    if(self.tagSubviews.count > 0)
    {
        self.departmentLabel.text = self.tagPlaceholder;
        self.departmentLabel.font = self.font;
        [self.scrollView addSubview:self.departmentLabel];
    }
    
    [self setNeedsLayout];
}

#pragma mark - 添加标签方法
- (void)addTag:(NSString *)tag
{
    [self.tags addObject:tag];
    [self reloadTagSubviews];
}

#pragma mark - 手势响应方法
- (void)gestureAction:(id)sender
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;
    if ([self.delegate respondsToSelector:@selector(departmentScrollView:tappedAtIndex:)])
        [self.delegate departmentScrollView:self tappedAtIndex:tapRecognizer.view.tag];
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录部门滚动视图 延展(工具)
@implementation WSContactsBookDepartmentScrollView (Tools)

#pragma mark - 常规初始化方法
- (void)commonInit
{
    self.tags = [[NSMutableArray alloc] init];
    self.tagPlaceholder = NSLocalizedString(@"department", nil);
    self.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_standard];
    
    [self addSubview:self.scrollView];
}

@end
//===================================================================================================================================================================
