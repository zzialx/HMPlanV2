//
//  WSSearchBar.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-15.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSSearchBar.h"
//==============================================================================================================

@interface WSSearchBar ()

@property (nonatomic, copy) NSString *placeholderText;  //占位符号文本
@property (nonatomic, strong) UIColor *placeholderColor;//占位符号颜色

@end
//==============================================================================================================

@implementation WSSearchBar

- (instancetype)initWithFrame:(CGRect)frame {

    return [self initWithFrame:frame isResetTextField:NO isResetBackgroundColor:YES isTop:NO];
}

- (instancetype)initWithFrame:(CGRect)frame isResetTextField:(BOOL)isResetTextField isResetBackgroundColor:(BOOL)isResetBackgroundColor {
    
    return [self initWithFrame:frame isResetTextField:isResetTextField isResetBackgroundColor:isResetBackgroundColor isTop:NO];
}

- (instancetype)initWithFrame:(CGRect)frame isResetTextField:(BOOL)isResetTextField isResetBackgroundColor:(BOOL)isResetBackgroundColor isTop:(BOOL)isTop {

    return [self initWithFrame:frame isResetTextField:isResetTextField isResetBackgroundColor:isResetBackgroundColor isTop:isTop isNotAutoresizingFlexible:NO];
}

- (instancetype)initWithFrame:(CGRect)frame isResetTextField:(BOOL)isResetTextField isResetBackgroundColor:(BOOL)isResetBackgroundColor isTop:(BOOL)isTop
    isNotAutoresizingFlexible:(BOOL)isNotAutoresizingFlexible {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat leftPaadding = 7;
        CGFloat topPadding = 15;
        CGFloat searchBarDefaulHeight = 30;
        self.contentInset = UIEdgeInsetsMake(leftPaadding+2, topPadding, leftPaadding, topPadding);
        self.isResetTextField = isResetTextField;
        self.isResetBackgroundColor = isResetBackgroundColor;
        self.isTopBar = isTop;
        self.isNotAutoresizingFlexible = isNotAutoresizingFlexible;
        
        self.searchBar = [[UISearchBar alloc] init];
        if (isTop) {
            
            self.backViewColor = [UIColor clearColor];
            self.searchBarCornerRadius = 15;
            _searchBar.frame = CGRectMake(0, (self.frame.size.height-searchBarDefaulHeight)/2,
                                          self.frame.size.width, searchBarDefaulHeight);
            _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _searchBar.clipsToBounds = YES;
            _searchBar.backgroundColor = [self getSearchBarBgColor];
        } else {
            
            self.backViewColor = [UIColor whiteColor];
            _searchBar.frame = CGRectMake(leftPaadding, 0, self.frame.size.width - leftPaadding * 2, self.frame.size.height);
            if (!_isNotAutoresizingFlexible) {
                _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }
        }
        
        [self addSubview:_searchBar];
        [self resetViews];
    }
    return self;
}

- (UIColor *)getSearchBarBgColor {
    
    UIColor *bgColor = [UIColor colorForKey:@"SearchBarBackgroundColor"];
    if (!bgColor) {
        
        bgColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
        if (!bgColor) {
            bgColor = MAIN_TINT_COLOR;
        }
        
        CGFloat red = 0;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0;
        BOOL isOK = [bgColor getRed:&red green:&green blue:&blue alpha:&alpha];
        if (isOK) {
            CGFloat offsetColor = 0.0784;
            red -= offsetColor;
            green -= offsetColor;
            blue -= offsetColor;
            if (red >= 0 && green >= 0 && blue >= 0) {
                bgColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.7];
            }
        }
    }
    
    return bgColor;
}


#pragma mark - 重置视图方法
- (void)resetViews {
    
    if (INTERFACE_IS_PAD) {
        
        CGRect rect = self.frame;
        self.frame = rect;
        self.centerX = self.bounds.size.width / 2;
    }
    
    NSMutableDictionary *dicAttr = [NSMutableDictionary dictionary];
    [dicAttr setObject:DETAIL_TEXT_COLOR forKey:NSForegroundColorAttributeName];
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    [barButtonItem setTitleTextAttributes:dicAttr forState:UIControlStateNormal];
    
    if (self.isResetBackgroundColor) {
        [self setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    self.tintColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = self.backViewColor;
    self.searchBar.barTintColor = [UIColor whiteColor];
    
    UIView *view = [self.searchBar.subviews firstObject];
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            if (@available(iOS 13.0, *)) {
                                       subview.hidden = YES;
                                   } else {
                                       [subview removeFromSuperview];
                                   }
            break;
        }
    }
    
    UITextField *searchTextField = [self getSearchBarTextField];
    if (searchTextField) {
        
        if (self.isResetTextField && INTERFACE_IS_PAD) {
            
            [searchTextField setBackground:nil];
            UIColor *color = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
            searchTextField.layer.borderColor = [color CGColor];
            searchTextField.layer.borderWidth = 1;
            searchTextField.layer.cornerRadius = 15;
        } else {
            
            if (self.isTopBar) {
                
                self.searchBar.layer.cornerRadius = self.searchBarCornerRadius;
                
                [searchTextField setBackground:nil];
                searchTextField.backgroundColor = [UIColor clearColor];
                searchTextField.textColor = [UIColor blackColor];
                searchTextField.enablesReturnKeyAutomatically = NO;
                searchTextField.tintColor = [UIColor grayColor];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.image = [UIImage scaledImageForName:@"icon_search_grey" ofType:@"png"];
                searchTextField.leftView = imageView;
            } else {
                
                searchTextField.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
                searchTextField.enablesReturnKeyAutomatically = NO;
                searchTextField.tintColor = [UIColor grayColor];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
                imageView.backgroundColor = [UIColor clearColor];
                imageView.image = [UIImage scaledImageForName:@"icon_search_grey" ofType:@"png"];
                searchTextField.leftView = imageView;
            }
        }
        searchTextField.centerY = self.searchBar.centerY;
    }
}

#pragma mark - 获取搜索栏输入框方法
- (UITextField *)getSearchBarTextField {
    
    UITextField *searchField = nil;
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        searchField = self.searchBar.searchTextField;
    } else
#endif
    {
        searchField = [self.searchBar valueForKey:@"searchField"];
    }
    return searchField;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIView *view = [self.searchBar.subviews firstObject];
    CGFloat x = 0.0f;
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            x = subview.frame.origin.x;
        }
    }
    
    UITextField *searchTextField = [self getSearchBarTextField];
    if (searchTextField) {
        
        if (self.searchBar.showsCancelButton) {
            
            CGFloat w = x - self.contentInset.left - MAIN_HORIZONTAL_GROUP_SPACE;
            CGFloat h = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
            searchTextField.frame = CGRectMake(self.contentInset.left, self.contentInset.top, w, h);
        } else {
            
            CGFloat w = self.bounds.size.width - self.contentInset.left * 2;
            CGFloat h = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
            searchTextField.frame = CGRectMake(self.contentInset.left, self.contentInset.top, w, h);
        }
        
        if (self.placeholderText && self.placeholderColor) {
            
            NSDictionary *dic = @{NSForegroundColorAttributeName : self.placeholderColor};
            searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholderText attributes:dic];
        }
    }
}

#pragma mark - 设置占位符文本/颜色方法
- (void)setSearchBarPlaceholderWithText:(NSString *)text color:(UIColor *)color {
    
    self.placeholderText = (text ? text : NSLocalizedString(@"query_hint_label", nil));
    self.placeholderColor = (color ? color : [UIColor whiteColor]);
    [self setNeedsLayout];
}

@end
//==============================================================================================================

