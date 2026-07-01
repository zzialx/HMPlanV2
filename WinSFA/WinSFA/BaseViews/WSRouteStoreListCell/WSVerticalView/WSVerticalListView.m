//
//  WSVerticalListView.m
//  WMDragView
//
//  Created by admin on 2022/10/25.
//  Copyright © 2022 zhengwenming. All rights reserved.
//

#import "WSVerticalListView.h"
#import "Masonry.h"
#import "WSVisitStoreBtn.h"
#import "NSMutableAttributedString+Addtions.h"

#define k_VLV_ELEMENT_HEIGHT 17.0f //元素高度
//==========================================================================================================================================

@interface WSVerticalListView ()

@property (nonatomic, strong) UIStackView *stackView; //堆栈视图

@end
//==========================================================================================================================================

@implementation WSVerticalListView

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
    
        [self addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    return self;
}

#pragma mark - 获取stackView方法
- (UIStackView *)stackView {
    
    if (!_stackView) {
        
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 2.0f;
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.axis = UILayoutConstraintAxisVertical;
        _stackView.backgroundColor = UIColor.whiteColor;
    }
    return _stackView;
}

#pragma mark - 设置拜访状态方法
- (void)setVisitList:(NSArray *)visitStateList {
    
    [self.stackView removeAllSubviews];
    
    WSVisitStoreBtn *monthVisitNumberBtn = nil; //本月拜访次数
    WSVisitStoreBtn *specialVisitStateBtn = nil;//付费采集(Wellness角色) || 主货架/二次陈列已采集（TSKF）
    WSVisitStoreBtn *orangeVisitStateBtn = nil; //橙色采集
    WSVisitStoreBtn *otoVisitStateBtn = nil;    //oto采集
    WSVisitStoreBtn *todayVisitStateBtn = nil;  //今日拜访
    WSVisitStoreBtn *orangeStateBtn = nil;      //橙色协议门店
    WSVisitStoreBtn *routeVisitStateBtn = nil;  //路线拜访状态
    WSVisitStoreBtn *monthVisitStateBtn = nil;  //本月拜访
    WSVisitStoreBtn *notLeaveBtn = nil;         //未离开门店
    WSVisitStoreBtn *monthHelpVisitStateBtn = nil; //本月已助销状态
    WSVisitStoreBtn *monthHelpVisitNumberBtn = nil; //本月已助销次数
    if (visitStateList.count == 0) {
        
        WSVisitStoreBtn *visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
        visitStoreBtn.backgroundColor = [UIColor clearColor];
        [self.stackView addArrangedSubview:visitStoreBtn];
        
        [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.stackView.mas_width);
            make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
        }];
        return;
    }
    
    for (int i = 0; i < visitStateList.count; i++) {
        
        NSString *visiStateStr = [visitStateList objectAtIndex:i];
        
        if ([visiStateStr containsString:Month_Visit_Number]) {
                    
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (monthVisitNumberBtn) {
                visitStoreBtn = monthVisitNumberBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                monthVisitNumberBtn = visitStoreBtn;
                monthVisitNumberBtn.visitStoreType = VisitStoreTypeMonthNumber;
                [self.stackView addArrangedSubview:visitStoreBtn];
                        
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
   
                UILabel *ttileLab = [WSVerticalListView titleLabelWithTitle:visiStateStr];
                if(ttileLab){
                    [visitStoreBtn addSubview:ttileLab];
                            
                    [ttileLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(visitStoreBtn).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
                    }];
                }
              
            }
    
            continue;
        }
        //本月已助销次数
        if ([visiStateStr containsString:Month_Help_Visit_Number]) {
            
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (monthHelpVisitNumberBtn) {
                visitStoreBtn = monthHelpVisitStateBtn;
            }else{
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                monthHelpVisitNumberBtn = visitStoreBtn;
                monthHelpVisitNumberBtn.visitStoreType = VisitStoreTypeMonthNumber;
                [self.stackView addArrangedSubview:visitStoreBtn];
                        
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
                        
            }
            NSString *monthHelpVisitNumber = [NSString stringWithFormat:@"%@", visitStateList[1]];
            [self.stackView addArrangedSubview:monthHelpVisitStateBtn];
            
            UILabel *ttileLab = [WSVerticalListView titleLabelWithTitle:monthHelpVisitNumber];
            if (ttileLab) {
                [monthHelpVisitNumberBtn addSubview:ttileLab];
                [ttileLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(monthHelpVisitNumberBtn).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
                }];
            }
            
            continue;
        }
        //门店已助销状态
        if ([visiStateStr containsString:HelpSales_Visit_State]) {
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (monthHelpVisitStateBtn) {
                visitStoreBtn = notLeaveBtn;
            } else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                monthHelpVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
            monthHelpVisitStateBtn.visitStoreType = VisitStoreTypeHelpSalesState;
        }
        
        if ([visiStateStr containsString:Visit_Paing_Store] || [visiStateStr containsString:Visit_Paid_Store] ||
            [visiStateStr containsString:Visit_Store_MainShelf] || [visiStateStr containsString:Visited_Store_MainShelf]) {
                    
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (specialVisitStateBtn) {
                visitStoreBtn = specialVisitStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                specialVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                        
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
                    
            if ([visiStateStr containsString:Visit_Paing_Store]) {
                visitStoreBtn.visitStoreType = VisitStoreTypePaying;
            }
            else if ([visiStateStr containsString:Visit_Paid_Store]) {
                visitStoreBtn.visitStoreType = VisitStoreTypePaid;
            }
            else if ([visiStateStr containsString:Visit_Store_MainShelf]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeMainShelfCollect;
            }
            else if ([visiStateStr containsString:Visited_Store_MainShelf]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeMainShelf;
            }
                    
            continue;
        }
        
        if ([visiStateStr containsString:Orange_NoVisit_State] || [visiStateStr containsString:Orange_Visit_State] ||
            [visiStateStr containsString:Orange_Visit_Qualified] || [visiStateStr containsString:Orange_Visit_NoQualified]) {
                    
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (orangeVisitStateBtn) {
                visitStoreBtn = orangeVisitStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                orangeVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                        
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
                    
            if ([visiStateStr containsString:Orange_NoVisit_State]) {
                visitStoreBtn.visitStoreType = VisitNoStoreTypeOrange;
            }
            else if ([visiStateStr containsString:Orange_Visit_State]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeOrangeHas;
            }
            else if ([visiStateStr containsString:Orange_Visit_Qualified]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeOrangeQualified;
            }
            else if ([visiStateStr containsString:Orange_Visit_NoQualified]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeOrangeNoQualified;
            }
                    
            continue;
        }
        
        if ([visiStateStr containsString:OTO_NoVisit_State] || [visiStateStr containsString:OTO_Visit_State]) {
            
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (otoVisitStateBtn) {
                visitStoreBtn = otoVisitStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                otoVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
            
            if ([visiStateStr containsString:OTO_NoVisit_State]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeOTO;
            }
            else if ([visiStateStr containsString:OTO_Visit_State]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeOTOHas;
            }
            
            continue;
        }
        
        if ([visiStateStr containsString:Today_Visit_State] || [visiStateStr containsString:Today_Visit_State_Title] ||
            [visiStateStr containsString:Invalid_Visit_Sate]) {
                    
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (todayVisitStateBtn) {
                visitStoreBtn = todayVisitStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                todayVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                        
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
                    
            if ([visiStateStr containsString:Today_Visit_State]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeToday;
            }
            else if ([visiStateStr containsString:Today_Visit_State_Title]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeToday;
            }
            else if ([visiStateStr containsString:Invalid_Visit_Sate]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeInvalid;
            }
                    
            continue;
        }
        
        if ([visiStateStr containsString:Orange_Agreement_Store_ONE] || [visiStateStr containsString:Orange_Agreement_Store]) {
            
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (orangeStateBtn) {
                visitStoreBtn = orangeStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                orangeStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
            
            if ([visiStateStr containsString:Orange_Agreement_Store_ONE]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeiIdeal;
            }
            else if ([visiStateStr containsString:Orange_Agreement_Store]) {
                visitStoreBtn.visitStoreType = VisitStoreTypeOrange;
            }
            
            continue;
        }
        
        if ([visiStateStr containsString:Visit_Route_State_1]) {
            
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (routeVisitStateBtn) {
                visitStoreBtn = routeVisitStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                routeVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
            
            visitStoreBtn.visitStoreType = VisitStoreTypeRouteVisitState;
            
            continue;
        }
        
        if ([visiStateStr containsString:Month_Visit_State]) {
            
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (monthVisitStateBtn) {
                visitStoreBtn = monthVisitStateBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                monthVisitStateBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
            
            visitStoreBtn.visitStoreType = VisitStoreTypeMoth;
            
            continue;
        }
        if ([visiStateStr containsString:Visit_Sate_NotLeave]) {
            
            WSVisitStoreBtn *visitStoreBtn = nil;
            if (notLeaveBtn) {
                visitStoreBtn = notLeaveBtn;
            }
            else {
                visitStoreBtn = [WSVisitStoreBtn buttonWithType:UIButtonTypeCustom];
                notLeaveBtn = visitStoreBtn;
                [self.stackView addArrangedSubview:visitStoreBtn];
                
                [visitStoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self.stackView.mas_width);
                    make.height.mas_equalTo(k_VLV_ELEMENT_HEIGHT);
                }];
            }
            
            visitStoreBtn.visitStoreType = VisitStoreTypeNotLeave;
            
            continue;
        }
    }
}
#pragma mark - # 获取拜访内容标题
+ (UILabel*)titleLabelWithTitle:(NSString*)titleContent{
    if (titleContent.length==0) {
        return nil;
    }
    NSMutableAttributedString *attributedText = [NSMutableAttributedString getCustomAttributeWithContent:titleContent];
    UILabel * tileLab = [[UILabel alloc]init];
    tileLab.attributedText = attributedText;
    tileLab.textAlignment = NSTextAlignmentCenter;
    return tileLab;
    
}

@end
//==========================================================================================================================================
