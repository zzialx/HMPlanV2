//
//  WSInventoruHeader.h
//  WinSFA
//
//  Created by zzialx on 2025/7/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#ifndef WSInventoruHeader_h
#define WSInventoruHeader_h

#define LINE_COLOR     WIN_RGBCOLOR(225.0, 225.0, 225.0)

#define DNM_W      70.0

#define BCJYSL_W   90.0

#define BCJYSL_CONTENT_W   90.0f

#define PAD_P_LR           10.0f

#define PAD_P_TL           20.0f

#define BTN_PAD_TL         10.0f

#define BTN_PAD_LR         20.0f


#define HEADER_TITLE_FONT    FONT(14.0)

#define HEADER_TITLE_COLOR   WIN_RGBCOLOR(0.0, 0.0, 0.0)

#define BCJYSL_O_W           60.0

#define BCJYSL_CONTENT_O_W   60.0f

#define LIGHT_CELL_COLOR     WIN_RGBCOLOR(185.0, 51.0, 43.0)

#define STOCK_OUT_DNM_W      90.0f

#define STOCK_OUT_CELL_W      90.0f


typedef enum {
    WinWorkPopupTypeDefault,///默认样式
    WinWorkPopupTypeOrder,///建议订单单样式
    WinWorkPopupTypeStock,///库存提醒单样式
    WinWorkPopupTypeDouble ///双提醒样式
} WinWorkPopupType;



#endif /* WSInventoruHeader_h */
