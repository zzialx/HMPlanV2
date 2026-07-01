//
//  HZHSearchBar.h
//  HZHTestProject
//
//  Created by HZH on 2017/9/8.
//  Copyright © 2017年 HZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HZHSearchBarDelegate;

typedef NS_ENUM(NSUInteger, HZHSearchBarContentAlign) {
    HZHSearchBarContentAlignLeft,
    HZHSearchBarContentAlignCenter
};

@class HZHSearchBar;

@protocol HZHSearchBarDelegate <UIBarPositioningDelegate>

@optional

- (BOOL)searchBarShouldBeginEditing:(HZHSearchBar *_Nonnull)searchBar;                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(HZHSearchBar *_Nonnull)searchBar;                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(HZHSearchBar *_Nonnull)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(HZHSearchBar *_Nonnull)searchBar;                       // called when text ends editing
- (void)searchBar:(HZHSearchBar *_Nonnull)searchBar textDidChange:(NSString *_Nullable)searchText;   // called when text changes (including clear)
- (BOOL)searchBar:(HZHSearchBar *_Nonnull)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *_Nullable)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(HZHSearchBar *_Nonnull)searchBar;                     // called when keyboard search button pressed
- (void)searchBarBookmarkButtonClicked:(HZHSearchBar *_Nonnull)searchBar __TVOS_PROHIBITED; // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(HZHSearchBar *_Nonnull)searchBar __TVOS_PROHIBITED;   // called when cancel button pressed
- (void)searchBarResultsListButtonClicked:(HZHSearchBar *_Nonnull)searchBar NS_AVAILABLE_IOS(3_2) __TVOS_PROHIBITED; // called when search results button pressed

- (void)searchBar:(HZHSearchBar *_Nonnull)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0);

@end

@interface HZHSearchBar : UIView

@property(nullable,nonatomic,weak) id <HZHSearchBarDelegate> delegate;              // weak reference. default is nil
@property(nullable,nonatomic,copy)   NSString               *text;                  // current/starting search text
@property(nullable,nonatomic,copy)   NSString               *prompt;                // default is nil
@property(nullable,nonatomic,copy)   NSString               *placeholder;           // default is nil

@property(nullable,nonatomic,strong) UIFont                 *textFont;
@property(nullable,nonatomic,strong) UIFont                 *placeholderFont;
@property(nullable,nonatomic,strong) UIColor                *textColor;
@property(nullable,nonatomic,strong) UIColor                *placeholderColor;
@property(nullable,nonatomic,strong) UIColor                *textBackgroundColor;
@property(nullable,nonatomic,strong) UIImage                *backgroundIcon;
@property(nullable,nonatomic,strong) UIImage                *leftIcon;
@property(nullable,nonatomic,strong) UIImage                *rightIcon;
@property(nullable,nonatomic,strong) UIImage                *cancelButtonIcon;

@property(nonatomic,assign)          CGFloat                leftIconLeftMargin;
@property(nonatomic,assign)          CGFloat                leftIconRightMargin;

@property(nonatomic,assign)          CGFloat                textFieldLeftMargin;
@property(nonatomic,assign)          CGFloat                textFieldRightMargin;
@property(nonatomic,assign)          CGFloat                textFieldTopMargin;
@property(nonatomic,assign)          CGFloat                textFieldBottomMargin;

@property(nonatomic,assign)          UITextBorderStyle      textBorderStyle;
@property(nonatomic,assign)          UIKeyboardType         keyboardType;
@property(nonatomic,assign)          HZHSearchBarContentAlign    contentAlign;

@property(nullable,nonatomic,copy)   NSString               *cancelButtonText;
@property(nullable,nonatomic,strong) UIColor                *cancelButtonTextColor;
@property(nullable,nonatomic,strong) UIFont                 *cancelButtonTextFont;
@property(nonatomic,assign)          CGFloat                cancelButtonLeftMargin;

@property(nullable,nonatomic,strong) UIView *inputAccessoryView;
@property(nullable,nonatomic,strong) UIView *inputView;

// 设置键盘return类型
- (void) setReturnKeyboardTypeWithReturnKey :(UIReturnKeyType) returnKeyBoardType;

@end
