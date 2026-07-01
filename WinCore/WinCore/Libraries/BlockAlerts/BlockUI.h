//
//  BlockUI.h
//
//  Created by Gustavo Ambrozio on 14/2/12.
//

#ifndef BlockUI_h
#define BlockUI_h

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
#define NSTextAlignmentCenter       UITextAlignmentCenter
#define NSLineBreakByWordWrapping   UILineBreakModeWordWrap
#define NSLineBreakByClipping       UILineBreakModeClip

#endif

#ifndef IOS_LESS_THAN_6
#define IOS_LESS_THAN_6 !([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)
#endif

#ifndef IOS_LESS_THAN_7
#define IOS_LESS_THAN_7 !([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#endif

#define NeedsLandscapePhoneTweaks (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)

#define IsIPADLanscapeUI (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) &&UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


// Action Sheet constants

#define kActionSheetBounce         10
#define kActionSheetBorder         10
#define kActionSheetButtonHeight   45
#define kActionSheetTopMargin      15

#define kActionSheetTitleFont           [UIFont systemFontOfSize:18]
#define kActionSheetTitleTextColor      [UIColor whiteColor]
#define kActionSheetTitleShadowColor    [UIColor blackColor]
#define kActionSheetTitleShadowOffset   CGSizeMake(0, -1)

#define kActionSheetButtonFont          [UIFont boldSystemFontOfSize:20]
#define kActionSheetButtonTextColor     [UIColor whiteColor]
#define kActionSheetButtonShadowColor   [UIColor blackColor]
#define kActionSheetButtonShadowOffset  CGSizeMake(0, -1)

#define kActionSheetBackground              @"action-sheet-panel.png"
#define kActionSheetBackgroundCapHeight     30


// Alert View constants

//为了定制UI，新增了一些宏定义，并在代码里做了兼容

#define kPopupAnimationDuration 1.0
#define kFadeAnimationDuration 0.5
#define kFPS 60

#define kAlertViewBorder         (IsIPADLanscapeUI ? 10 : 10)
#define kAlertViewWidth              (IsIPADLanscapeUI ? 300 : 250)
#define kAlertViewBounce              20
#define kAlertViewLabelLeftMargin    (IsIPADLanscapeUI ? 20 : 20)

#define kAlertViewButtonBLeftMargin  (IsIPADLanscapeUI ? 0 : 0)
#define kAlertButtonHeight           (IsIPADLanscapeUI ? 50 : 50)

#define kAlertViewTitleLabelTopGap    (IsIPADLanscapeUI ? 25 : 25)
#define kAlertViewMessageLabelTopGap  (IsIPADLanscapeUI ? 20 : 15)
#define kAlertViewButtonTopGap        (IsIPADLanscapeUI ? 5 : 5)
#define kAlertViewButtonGap            1


#define kAlertViewTitleFont             ([UIFont boldFontForKey:@"AlertViewTitle"] ? [UIFont boldFontForKey:@"AlertViewTitle"] : (INTERFACE_IS_PHONE ? [UIFont boldSystemFontOfSize:14] : [UIFont boldSystemFontOfSize:16]))
#define kAlertViewTitleTextColor        ([UIColor colorForKey:@"AlertViewTitle"] ? [UIColor colorForKey:@"AlertViewTitle"] : MAIN_TINT_COLOT)
#define kAlertViewTitleBackgroudColor        ([UIColor colorForKey:@"AlertViewTitleBackgroudColor"] ? [UIColor colorForKey:@"AlertViewTitleBackgroudColor"] : [UIColor clearColor])

#define kAlertViewTitleShadowColor      [UIColor clearColor]
#define kAlertViewTitleShadowOffset     CGSizeMake(0, 0)

#define kAlertViewMessageFont           ([UIFont fontForKey:@"AlertViewText"] ? [UIFont fontForKey:@"AlertViewText"] : [UIFont systemFontOfSize:14])
#define kAlertViewMessageTextColor      ([UIColor colorForKey:@"AlertViewText"] ? [UIColor colorForKey:@"AlertViewText"] : MAIN_TEXT_COLOR)
#define kAlertViewMessageShadowColor    [UIColor clearColor]
#define kAlertViewMessageShadowOffset   CGSizeMake(0, 0)

#define kAlertViewButtonFont                ([UIFont fontForKey:@"AlertViewButtonTitle"] ? [UIFont fontForKey:@"AlertViewButtonTitle"] : (INTERFACE_IS_PHONE ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:16]))
#define kAlertViewButtonTextColor           ([UIColor colorForKey:@"AlertViewButtonTitle"] ? [UIColor colorForKey:@"AlertViewButtonTitle"] : MAIN_TEXT_COLOR)
#define kAlertViewButtonShadowColor         [UIColor clearColor]
#define kAlertViewButtonShadowOffset        CGSizeMake(0, 0)
#define kAlertViewButtonBackgroundColor     ([UIColor colorForKey:@"AlertViewButtonBackgroudColor"] ? [UIColor colorForKey:@"AlertViewButtonBackgroudColor"] : [UIColor whiteColor])
#define kAlertViewButtonBackgroundColorHL   ([UIColor highlightColorForKey:@"AlertViewButtonBackgroudColor"] ? [UIColor highlightColorForKey:@"AlertViewButtonBackgroudColor"] : [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0])


#define kAlertViewBackground                @"alert-window.png"
#define kAlertViewBackgroundLandscape       @"alert-window-landscape.png"
#define kAlertViewBackgroundCapHeight       38
#define kAlertViewBackgroundColor           ([UIColor colorForKey:@"AlertViewBackgroudColor"] ? [UIColor colorForKey:@"AlertViewBackgroudColor"] : [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0])
#define kAlertViewBackgroundCornerRadius    4.0f

#endif
