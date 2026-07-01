//
//  WidgetConstant.h
//  WinSFA
//
//  Created by winchannel on 15/3/11.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_WidgetConstant_h
#define WinSFA_WidgetConstant_h

#define kLabelLeftSpace (INTERFACE_IS_PAD ? 20.0f : 10.0f)

#define K_I_BUTTON_WIDTH (42)

#define LABEL_LIST_SPACE_HEIGHT (5)

#define CHECK_LIST_HEIGHT       (44)

#define BOTTOM_SPACE_HEIGHT     (10)


#define CHECK_LIST_CELL_HEIGHT  (CHECK_LIST_HEIGHT)

#define DROPLIST_CELL_TEXT_FONT [UIFont systemFontOfSize:(INTERFACE_IS_PAD ? 18.0 : 15.0)]

#define kScanButtonBaseTag 10000


#define DEFAULT_VALUE @""

#define LABEL_COLOR_DEFAULT         [UIColor blackColor]

#define UI_Font_DEFAULT_SIZE  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15.0f : 18.0f)


#define IS_IPHONE4S (([[UIScreen mainScreen] bounds].size.height-480)? NO:YES)

#define LABLE_DEFAULT_HIGHT 1000

#define WSImg(name) [UIImage imageNamed:name]

#define WSRect(x,y,w,h) CGRectMake(x,y,w,h)

#define ZERORECT WSRect(0,0,0,0)

#pragma mark checkBox

#define TITLE_AND_OPTION_SAPCE_HEIGHT   (10)

#define CELL_HEIGHT                     (40)

#define OPTION_LABEL_START_X            (10)

#define UI_BASE_TAG                     (300)

#define DEBUG_FOR_ACVT  0

#pragma mark - 

#pragma mark PT

#define kTypeNameKey   @"typeName"
#define kTypeIDKey     @"typeId"
#define kPhotosKey     @"photos"

#pragma mark -

#pragma mark AcvtDataGridViewPanel

#define PARAM_KEY_VISIBLE_PRODUCTS @"PARAM_KEY_VISIBLE_PRODUCTS"
#define PARAM_KEY_ALL_PRODUCTS     @"PARAM_KEY_ALL_PRODUCTS"


#define DISPLAYMODE_SMALL_RATIO        0.8

#pragma mark -

#endif
