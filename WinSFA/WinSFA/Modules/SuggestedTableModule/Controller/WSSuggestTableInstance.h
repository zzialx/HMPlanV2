//
//  WSSuggestTableInstance.h
//  WinSFA
//
//  Created by HZH on 16/9/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#ifndef WSSuggestTableInstance_h
#define WSSuggestTableInstance_h

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define VIEWBROADCOLOR  [[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:0.5] CGColor]
#define POP_MAIN_THEME_COLOR 0xF27142
#define POP_STATIC_FONT_COLOR 0x9B412E

#define POP_CREATE_NEW_VIEWWIDTH 450
#define POP_CREATE_NEW_VIEWHEIGHT 330

#define POPVIEWWIDTH 450
#define POPVIEWHEIGHT 370

#define k_UISCREN_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 1024)
#define k_UISCREN_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 768)

#define HSELF_VIEW_FRAME_ORIGIN_X self.view.frame.origin.x
#define HSELF_VIEW_FRAME_ORIGIN_Y self.view.frame.origin.x
#define HSELF_VIEW_FRAME_SIZE_WIDTH self.view.frame.size.width
#define HSELF_VIEW_FRAME_SIZE_HEIGHT self.view.frame.size.height

 // 用家建议单模板类型
#define HSuggestTableForHomeModelStyleDish      @"01"  // 菜式应用
#define HSuggestTableForHomeModelStyleFormula   @"02"  // 配方应用

// 用家建议配方产品形式
#define HSuggestTableForHomeFormulaProductCompare    @"01"  // 对比产品
#define HSuggestTableForHomeFormulaProductSelfMake   @"02"  // 自制配方


#endif /* WSSuggestTableInstance_h */
