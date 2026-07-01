//
// Created by sam wang on 13-6-5.
//
// Copyright (c) 2013年 WinChannel. All rights reserved.
//

//color 宏
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define HColorFromHex(s)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#define RGB_COLOR(_STR_) ([UIColor colorWithRed:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(1, 2)] UTF8String], 0, 16)] intValue] / 255.0 green:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(3, 2)] UTF8String], 0, 16)] intValue] / 255.0 blue:[[NSString stringWithFormat:@"%lu", strtoul([[_STR_ substringWithRange:NSMakeRange(5, 2)] UTF8String], 0, 16)] intValue] / 255.0 alpha:1.0])

#define WIN_RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define WIN_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

// 默认背景颜色
#define COMMEN_VIEW_BGCOLOR RGBCOLOR(235,235,235)

/*
 *屏幕宽度
 */
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)
#define FRAME_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
#define FRAME_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height

#define WIN_SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)

/*
 *屏幕高度
 */

#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)

#define WIN_SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)
/*
 * iPhone statusbar 高度
 */
#define PHONE_STATUSBAR_HEIGHT 20
/*
 * iPhone 屏幕尺寸
 */
#define PHONE_SCREEN_SIZE (CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - PHONE_STATUSBAR_HEIGHT))

/*
 *log长度
 */
#define LOG_LENGTH 1000

/*
 * iPhone or iPad
 */
#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

typedef enum
{
    WCDatasUploadTypeDefault = 0,
    WCDatasUploadTypeAddNewStore = 1,
    WCDatasUploadTypeModifyAddedNewStore = 2,
    WCDatasUploadTypeAddAcvt = 3
}WCDatasUploadType;

// ------- UI 调整 -------
// 间距
#define SEPERATE_PADDING_Left        0.0f
#define MAIN_PADDING                 12.0
#define MAIN_BIG_PADDING             15.0f
#define MAIN_HORIZONTAL_GROUP_SPACE  10.0f

#define MAIN_CELL_PADDING            (INTERFACE_IS_PHONE ? 15.0f : 15.0f)
#define GROUP_CELL_PADDING           10.0
#define MAIN_WIDGET_PADDING          (INTERFACE_IS_PAD ? 20.0f : 0.0f)
#define MAIN_TEXT_IMG_PADDING        5.0

// 宽高
#define MAIN_CELL_HEIGHT             44.0f 
#define OPERATION_CELL_HEIGHT        100.0
#define OPERATION_HEIGHT             80.0
#define MAP_CELL_HEIGHT              240.0
#define MAIN_BUTTON_HEIGHT           32.0
#define MAIN_TEXTFIELD_HEIGHT        34.0
#define PHOTO_PANEL_HEIGHT           (PHOTO_VIEW_WH + MAIN_CELL_PADDING)
#define MAIN_SEPERATOR_HEIGHT        2.0
#define MAIN_CELL_SEPERATOR_HEIGHT   (1.0 / [UIScreen mainScreen].scale)
#define MAIN_BOTTOM_SEPERATOR_HEIGHT 16.0
#define MAIN_SECTION_HEIGHT         34.0


#pragma mark - 之下 sunhongfu加 门店列表用
#define kView_Space_Left (INTERFACE_IS_PHONE ? 15 : 20)
#define K_VISIT_STATUS_LEFT_SPACE (INTERFACE_IS_PHONE ? 20 : 20)
#define kViewForStoreList_Space_Top (INTERFACE_IS_PHONE ? 14 : 15)
#define kView_Space_StoreName_Icon_Left (INTERFACE_IS_PHONE ? 12 : 20)
#define kView_Space_StoreList_CodeImg_Code (INTERFACE_IS_PHONE ? 5.0f : 8.0f)

#define kView_Height15               15.0
#define kView_Height (INTERFACE_IS_PHONE ? 15 : 20)
#define K_STORE_ICON_WIDHT   (INTERFACE_IS_PHONE ? 70: 90)
#define K_STORE_ICON_HEIGHT  (INTERFACE_IS_PHONE ? 70: 90)
#define K_NAV_BUTTON_STOREList_WIDHT (INTERFACE_IS_PHONE ? 60 : 85)
#define STORE_LIST_CELL_DEFAULT_HEIGHT (INTERFACE_IS_PAD ? 110 :105)
#define k_STORE_VISIT_STATE_BUTTON_WIDTH  (INTERFACE_IS_PHONE ? 80.0f: 100.0f)


#define UI_SubViewForStoreList_Font13or15 (INTERFACE_IS_PHONE ? 13.0f : 15.0f)
#define UI_SubView_Detail_Font10or15 (INTERFACE_IS_PHONE ? 10.0f : 15.0f)

#define K_STATUS_GRAY_COLOR  [UIColor colorWithHexString:@"#c7c9c7"]
#define K_STATUS_YELLOW_COLOR  [UIColor colorWithHexString:@"#fbc84d"]
#define K_STATUS_LIME_COLOR  [UIColor colorWithHexString:@"#9ec963"]
#pragma mark - 之上

// SFA-18024 iPad 高度比例不要超过一半，否则弹出页面的高度可能小于该高度，导致子视图比父视图页面高
#define POP_VIEW_MAX_HEIGHT         (SCREEN_HEIGHT * (INTERFACE_IS_PHONE ?  0.55 : 0.6))

#define MAIN_CELL_SEPERATOR_LENGTH   20.0

#define MAIN_BUTTON_WH               30.0
#define MAIN_SMALL_BUTTON_WIDTH      20.0
#define MAIN_CELL_BUTTON_WH          44.0
#define PHOTO_VIEW_WH                (INTERFACE_IS_PHONE ? 74.0f : 120.0f)
#define OPTVIEW_ICONIMAGEVIEW_WH  70.0


#define POP_VIEW_WIDTH_RATIO         (INTERFACE_IS_PHONE ? 0.77 : 0.37)   //popview.width / screen.width
#define BTN_CORNER_RADIUS_RAITO      0.125 // btn.height *  0.125
#define SIDE_VIEW_WIDTH_RATIO        0.4

// 字体
#define MAIN_FONT_LINE_HEIGHT        2.0
#define FONT_SIZE_DESC               12     // 32px
#define FONT_SIZE_GRID               10.5   // 28px
#define FONT_SIZE_MAIN               11     // 30px
#define FONT_SIZE_TITLE              13     // 34px
 //iOS9.0以后系统自带了平方字体PingFangSC，低于iOS9用默认的字体
//#define FONT_SIZE_PINGFANG_MEDIUM [UIFont fontWithName:@"PingFangSC-Medium" size:FONT_SIZE_DESC] ? [UIFont fontWithName:@"PingFangSC-Medium" size:FONT_SIZE_DESC] : [UIFont systemFontOfSize:FONT_SIZE_DESC]

#define FONT_SIZE_PINGFANG_MEDIUM(FontSize) [UIFont fontWithName:@"PingFangSC-Medium" size:FontSize] ? [UIFont fontWithName:@"PingFangSC-Medium" size:FontSize] : [UIFont systemFontOfSize:FontSize]
#define FONT_SIZE_PINGFANG_REGULAR(FontSize) [UIFont fontWithName:@"PingFangSC-Regular" size:FontSize] ? [UIFont fontWithName:@"PingFangSC-Regular" size:FontSize] : [UIFont systemFontOfSize:FontSize]

#define FONT_SIZE_PINGFANG_Light(FontSize) [UIFont fontWithName:@"PingFangSC-Light" size:FontSize] ? [UIFont fontWithName:@"PingFangSC-Light" size:FontSize] : [UIFont systemFontOfSize:FontSize]

// 颜色

#define MAIN_TINT_COLOT              [UIColor colorForKey:@"MainTintColor"]
#define MAIN_TINT_COLOR              ([UIColor colorForKey:@"MainTintColor"] ? [UIColor colorForKey:@"MainTintColor"] : [UIColor colorWithRed:57.0f/255 green:131.0f/255 blue:248.0f/255 alpha:1.0f] )

#define MAIN_TEXT_COLOR              [UIColor colorWithRed:51.0f/255 green:51.0f/255 blue:51.0f/255 alpha:1.0f]      //#333333
#define DETAIL_TEXT_COLOR            [UIColor colorWithRed:102.0f/255 green:102.0f/255 blue:102.0f/255 alpha:1.0f]   //#666666
#define LIGHT_TEXT_COLOR             [UIColor colorWithRed:207.0f/255 green:207.0f/255 blue:207.0f/255 alpha:1.0f]   //#cfcfcf
#define GRAY_TEXT_COLOR              [UIColor colorWithRed:153.0f/255 green:153.0f/255 blue:153.0f/255 alpha:1.0f]   //#999999
#define WARNING_TEXT_COLOR           [UIColor colorWithRed:254.0f/255 green:73.0f/255 blue:60.0f/255 alpha:1.0f]     //#fe493c 红色
#define PLACEHOLDER_COLOR            [UIColor colorWithRed:0.0f/255 green:0.0f/255 blue:25.5f/255 alpha:0.22f]

#define MAIN_TEXT_DISABLE_COLOR      [UIColor colorWithRed:150.0f/255 green:150.0f/255 blue:150.0f/255 alpha:1.0f]   //#969696
#define MAIN_CELL_DISABLE_COLOR      [UIColor colorWithRed:250.0f/255 green:250.0f/255 blue:250.0f/255 alpha:1.0f]   //#fafafa

#define MAIN_CELL_SELECTED_COLOR     [UIColor colorWithRed:249.0f/255 green:249.0f/255 blue:249.0f/255 alpha:1.0f]  //#f9f9f9

#define GROUP_TABLE_BG_COLOR         [UIColor colorWithRed:231.0f/255 green:235.0f/255 blue:237.0f/255 alpha:1.0f]  //#e7ebed
#define MAIN_SEARCH_BG_COLOR         [UIColor colorWithRed:243.0f/255 green:243.0f/255 blue:243.0f/255 alpha:1.0f]  //#f3f3f3
#define POP_WINDOW_TOP_COLOR         [UIColor colorWithRed:249.0f/255 green:249.0f/255 blue:249.0f/255 alpha:1.0f]  //#f9f9f9
#define POP_WINDOW_BG_COLOR          [UIColor colorWithWhite:0 alpha:0.3]
#define WARNING_BTN_COLOR            [UIColor colorWithRed:254.0f/255 green:73.0f/255 blue:60.0f/255 alpha:1.0f]     //#fe493c 红色
#define BTN_GRAY_BG_COLOR            [UIColor colorWithRed:243.0f/255 green:243.0f/255 blue:243.0f/255 alpha:1.0f]     //#f3f3f3
#define BTN_GRAY_BORDER_COLOR        [UIColor colorWithRed:220.0f/255 green:220.0f/255 blue:220.0f/255 alpha:1.0f] 
#define GRID_BG_COLOR                [UIColor colorWithRed:237.0f/255 green:237.0f/255 blue:237.0f/255 alpha:1.0f]   //#ededed

#define MAIN_SEPERATE_LINE_COLOR     [UIColor colorWithRed:212.0f/255 green:212.0f/255 blue:212.0f/255 alpha:1.0f]  //#d4d4d4
#define DETAIL_SEPERATE_LINE_COLOR   [UIColor colorWithRed:232.0f/255 green:232.0f/255 blue:232.0f/255 alpha:1.0f]  //#e8e8e8
#define MAIN_TABLEVIEW_SEPERATE_COLOR   [UIColor colorWithRed:232.0f/255 green:232.0f/255 blue:232.0f/255 alpha:1.0f]  //#e8e8e8

//2018-01-09-MSTD-7508
#define GRID_MAIN_TEXT_COLOR            [UIColor colorWithRed:0.0f/255 green:0.0f/255 blue:0.0f/255 alpha:1.0f]         //#000000
#define GRID_MAIN_TEXT_DISABLE_COLOR    ([UIColor colorForKey:@"GridTableContentReadonlyColor"] ?  : [UIColor colorWithRed:153.0f/255 green:153.0f/255 blue:153.0f/255 alpha:1.0f] )//#ff999999

#define MultilevelMenu_Normal_Color                       @"#000000"
#define MultilevelMenu_BackGroundView_Color               @"#f1f1f1"
#define MultilevelMenu_Selected_Color                     @"#0084ff"
#define MultilevelMenu_SeparatorLine_Normal_Color         @"#d4d4d4"
#define kWord_Font_28px                                   14.5f
// 按钮状态颜色透明度
#define ALPHA_PRESSED               0.8
#define ALPHA_DISABLED              0.5

// 动画时间
#define MAIN_ANIM_DURATION           0.3

// 通知
#define LOGIN_SAAS_NOTIFY                                   @"loginSaas"           // 登录SAAS
#define CHECK_UPGRADE_NOTIFY                                @"checkUpgrade"        // 检查版本

// 状态栏高度
#define StatusBarHeight         [[UIApplication sharedApplication] statusBarFrame].size.height
// 导航栏高度
#define NavigationBarHeight     (StatusBarHeight + 44)


#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX SCREEN_WIDTH >=375.0f && SCREEN_HEIGHT >=812.0f&& kIs_iphone
//tabbar高度
#define kTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + 34.0):(49.0))


#ifndef    weakify_self
#if __has_feature(objc_arc)
#define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
#else
#define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
#endif
#endif
#ifndef    strongify_self
#if __has_feature(objc_arc)
#define strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
#else
#define strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
#endif
#endif

#define FONT(s) [UIFont systemFontOfSize:s]

#define ISNULL(x) ((x) == nil || [x isEqual:[NSNull null]] ? @"" : (x))
