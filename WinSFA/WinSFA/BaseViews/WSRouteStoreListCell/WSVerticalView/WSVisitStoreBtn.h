//
//  WSVisitStoreBtn.h
//  WMDragView
//
//  Created by admin on 2022/10/25.
//  Copyright © 2022 zhengwenming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger,VisitStoreType) {
    
    VisitStoreTypeInvalid           = 1 << 0,   //无效拜访
    VisitStoreTypeToday             = 1 << 1,   //今日已访
    VisitStoreTypeMoth              = 1 << 2,   //本月已访
    VisitStoreTypeOrange            = 1 << 4,   //橙色协议门店
    VisitStoreTypeOrangeHas         = 1 << 5,   //橙色已采集
    VisitStoreTypePaying            = 1 << 6,   //付费未采集 Wellness角色
    VisitStoreTypePaid              = 1 << 7,   //付费已采集 Wellness角色
    VisitStoreTypeMainShelf         = 1 << 8,   //主货架/二次陈列已采集 TSKF角色
    VisitStoreTypeMainShelfCollect  = 1 << 9,   //主货架/二次陈列未采集 TSKF角色
    VisitStoreTypeNotLeave          = 1 << 10,  //未离开门店
    VisitNoStoreTypeOrange          = 1 << 11,  //橙色未采集
    VisitStoreTypeMonthNumber       = 1 << 12,  //本月拜访频次
    VisitStoreTypeRouteVisitState   = 1 << 13,  //路线拜访状态
    VisitStoreTypeOTO               = 1 << 14,  //OTO未采集
    VisitStoreTypeOTOHas            = 1 << 15,   //OTO已采集
    VisitStoreTypeiIdeal            = 1 << 16,   //OTC完美协议门店
    VisitStoreTypeOrangeQualified   = 1 << 17,   //完美已达标
    VisitStoreTypeOrangeNoQualified = 1 << 18,   //完美未达标
    VisitStoreTypeHelpSalesState    = 1 << 19,  //门店已助销

};

#define Visit_Sate_NotLeave         @"未离开门店"
#define Invalid_Visit_Sate          @"无效拜访"
#define Today_Visit_State           @"今日拜访"
#define Today_Visit_State_Title     @"今日已访"
#define Month_Visit_State           @"本月已访"
#define Orange_Visit_State          @"完美已采集"
#define Orange_NoVisit_State        @"完美未采集"
#define Orange_Visit_State_Title    @"完美已采集"
#define Orange_Agreement_Store      @"完美协议门店"
#define Orange_Agreement_Store_ONE  @"完美协议门店"
#define Visit_Paing_Store           @"付费未采集"
#define Visit_Paid_Store            @"付费已采集"
#define Visit_Store_MainShelf       @"主货架/二次陈列未采集"
#define Visited_Store_MainShelf     @"主货架/二次陈列已采集"
#define Month_Visit_Number          @"本月已拜访"
#define Visit_Route_State_1         @"路线内已访"
#define OTO_Visit_State             @"OTO已采集"
#define OTO_NoVisit_State           @"OTO未采集"
#define Orange_Visit_Qualified      @"完美采集已达标"
#define Orange_Visit_NoQualified    @"完美采集未达标"
#define HelpSales_Visit_State       @"本月已助销"
#define Month_Help_Visit_Number     @"本月已助销 :"    //助销次数

//==========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

@interface WSVisitStoreBtn : UIButton

@property (nonatomic, assign) VisitStoreType visitStoreType;

@end

NS_ASSUME_NONNULL_END
//==========================================================================================================================================


