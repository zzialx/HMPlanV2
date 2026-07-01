//
//  WSDimensMacros.h
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#ifndef WSDimensMacros_h
#define WSDimensMacros_h

#define LL_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define LL_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define Iphone6Scale(x) ((x) * LL_SCREEN_WIDTH / 375.0f)

#define HeaderViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 30:40)
#define TopButtonHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?40 :50)
#define UI_Font_Cal  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 18.0f : 26.0f)
#define UI_Font_Cell  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 14.0f : 22.0f)

#define LOAD_IMAGE_Number10URL @"LOAD_IMAGE_Number10URL" /*日历右上图标*/
#define LOAD_IMAGE_Number12URL @"LOAD_IMAGE_Number12URL" /*日历左下图标*/
#define LOAD_IMAGE_Number13URL @"LOAD_IMAGE_Number13URL" /*日历右下图标*/

#define CALEND_DATESEL_START  @"CALEND_DATE_START" //日历可选开始日期
#define CALEND_DATESEL_END  @"CALEND_DATESEL_END"   //日历可选结束日期

#endif /* WSDimensMacros_h */
