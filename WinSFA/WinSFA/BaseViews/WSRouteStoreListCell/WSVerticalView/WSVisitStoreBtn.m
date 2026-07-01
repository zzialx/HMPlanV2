//
//  WSVisitStoreBtn.m
//  WMDragView
//
//  Created by admin on 2022/10/25.
//  Copyright © 2022 zhengwenming. All rights reserved.
//

#import "WSVisitStoreBtn.h"

#define NotLeavStore_BG         @"bg_status_yellow"
#define TodayVisitStore_BG      @"bg_status_gray"
#define RouteVisitState_BG      @"bg_status_red"
#define MonthVisitStore_BG      @"monthlogo"
#define OrangeVisitStore_BG     @"orangelogo"
#define SpecialVisitStore_BG    @"sprecial_bg"
#define MONTHNUMBER_BG          @"huise_bg"
#define K_STATUS_GRAY_COLOR     [UIColor colorWithHexString:@"#c7c9c7"]
#define K_STATUS_YELLOW_COLOR   [UIColor colorWithHexString:@"#fbc84d"]
#define K_STATUS_GREEN_COLOR    [UIColor colorWithHexString:@"#A0CC79"]
#define K_STATUS_ORANGE_COLOR   [UIColor colorWithHexString:@"#FB8E66"]
#define K_STATUS_RED_COLOR      [UIColor colorWithHexString:@"#F94A4B"]
#define K_STATUS_LIME_COLOR     [UIColor colorWithHexString:@"#9ec963"]
#define K_STATUS_SPE_COLOR      [UIColor colorWithHexString:@"#28A707"]
#define K_STATUS_DGRAY_COLOR    [UIColor colorWithHexString:@"#6D7278"]
//==========================================================================================================================================

@implementation WSVisitStoreBtn

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.titleLabel.font = [UIFont systemFontOfSize:9.0f];
//        self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, -5.0f);
//        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setVisitStoreType:(VisitStoreType)visitStoreType {
    
    switch (visitStoreType) {
            
        case VisitStoreTypeInvalid:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_ Invalid_visit"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeToday:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_today_visited"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeMoth:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_visit_month"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeOrange:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_orange_store"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeiIdeal:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_orange_store"] forState:UIControlStateNormal];

        }
        break;
            
        case VisitNoStoreTypeOrange:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_orange_no_finish"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeOrangeHas:
        {
            [self setBackgroundImage:[UIImage imageNamed:OrangeVisitStore_BG] forState:UIControlStateNormal];
            [self setTitle:Orange_Visit_State_Title forState:UIControlStateNormal];
            [self setTitleColor:K_STATUS_ORANGE_COLOR forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypePaying:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_visit_no_pay"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypePaid:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_visit_payed"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeMainShelf:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_maintwo_no_visit"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeMainShelfCollect:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_maintwo_visited"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeNotLeave:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_not_leave_store"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeMonthNumber:
        {
            [self setBackgroundImage:[UIImage imageNamed:MONTHNUMBER_BG] forState:UIControlStateNormal];
            [self setTitleColor:K_STATUS_DGRAY_COLOR forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeRouteVisitState:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_route_visited"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeOTO:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_oto_no_visit"] forState:UIControlStateNormal];
        }
        break;
           
        case VisitStoreTypeOTOHas:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_oto_visited"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeOrangeQualified:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"ic_orange_qualified"] forState:UIControlStateNormal];
        }
        break;
            
        case VisitStoreTypeOrangeNoQualified:  {
            
            [self setBackgroundImage:[UIImage imageNamed:@"ic_orange_no_qualified"] forState:UIControlStateNormal];
        }
        break;
        case VisitStoreTypeHelpSalesState:  {
            
            [self setBackgroundImage:[UIImage imageNamed:@"ic_help_visited"] forState:UIControlStateNormal];
        }
        break;
        default:
            break;
    }
}

@end
//==========================================================================================================================================


