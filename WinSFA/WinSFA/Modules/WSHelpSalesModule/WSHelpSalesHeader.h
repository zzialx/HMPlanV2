//
//  WSHelpSalesHeader.h
//  WinSFA
//
//  Created by zzialx on 2025/5/7.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#ifndef WSHelpSalesHeader_h
#define WSHelpSalesHeader_h

//#import "WSHelpSalesViewConfig.h"
//#import "WSHelpSalesAlertView.h"

typedef enum {
    WSHelpSalesAlertButtonType_Visit,
    WSHelpSalesAlertButtonType_HelpSales,
    WSHelpSalesAlertButtonType_Confirm
} WSHelpSalesAlertButtonType;

typedef enum {
    WSHelpSalesTipsType_Visit,
    WSHelpSalesTipsType_HelpSales
} WSHelpSalesTipsType;

typedef void (^WSHelpSalesAlertViewCallBack)(WSHelpSalesAlertButtonType clickType);

typedef void (^WSHelpSalesTipsCallBack)(WSHelpSalesTipsType tipType);


#define kVisit_H            65.0f
#define kPadLR              16.0f
#define kConfirmBTN_H       40.0f
#define kContentBG_H        250.0f

#endif /* WSHelpSalesHeader_h */
