//
//  WSSelectVisitListTableViewCell.m
//  WinSFA
//
//  Created by mac on 2018/9/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSelectVisitListTableViewCell.h"
#import "PureLayout.h"

#define K_NAV_BUTTON_HEGIHT (INTERFACE_IS_PHONE ? 15 : 20)
#define UI_SubView_Font (INTERFACE_IS_PHONE ? 13.0f : 15.0f)

@interface WSSelectVisitListTableViewCell()
{
    NSInteger NaviDisNum;   // 导航按钮显示规则--NaviDisNum 按二进制位数看，如果右移两位后 对2取余数，如果等于1  则代表4位 是1，则不显示导航图标，只显示距离，没有导航功能  （具体看WSFuncsBean_opt 中naviDis 参数解释）
    NSLayoutConstraint *nameWidthConstraint; // 门店名称宽度约束
    
    BOOL userStoreIcon ; // 是否使用门头照

}
@end
@implementation WSSelectVisitListTableViewCell


#pragma -mark 门店名称宽度比例
- (CGFloat)getTextWidthRatio {
    CGFloat textWidthRatio;

    textWidthRatio = INTERFACE_IS_PHONE ? 0.77 : 0.8;

    return textWidthRatio;
}

#pragma -mark  导航按钮，距离 （xxx  米 公里）
-(void)setStoreNavButton{
    self.storeNavButton.hidden = NO;
    [nameWidthConstraint autoRemove];
    if ([self.store.distance length] > 0) {
        nameWidthConstraint = [self.storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:[self getTextWidthRatio] relation:NSLayoutRelationLessThanOrEqual];
        
        /*3设置地图导航按钮的位置*/
        // 按二进制数据位数看， 如果末位为 0 并且配置不等于0 的情况则添加 导航按钮
        if (NaviDisNum % 2 == 0 &&  NaviDisNum != 0) {
            
            [self.contentView addSubview:self.storeNavButton];
            
            [self.storeNavButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:K_VISIT_STATUS_LEFT_SPACE];
            [self.storeNavButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.storeNameLabel withOffset:-2];
            [self.storeNavButton autoSetDimension:ALDimensionHeight toSize:K_NAV_BUTTON_HEGIHT];
            
            self.store.distance = [self strChange:self.store.distance];
            [self.storeNavButton setTitleColor:CELL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
            //            [self.storeNavButton setTitle:self.store.distance forState:UIControlStateNormal];旧的
            // 有距离 才算位置，否则不显示距离
            if ((self.store.distance.length> 0)&& !([self.store.distance rangeOfString:NSLocalizedString(@"loc_acc_unit", nil)].location != NSNotFound || [self.store.distance rangeOfString:NSLocalizedString(@"loc_acc_unit_km", nil)].location != NSNotFound) ) {
                [self.storeNavButton setTitle:[WSLocationManager convertDistance:[self.store.distance doubleValue]] forState:UIControlStateNormal];
            }
            //MN-1415 2018-03-26
            else if(self.store.distance.length > 0)
                [self.storeNavButton setTitle:self.store.distance forState:UIControlStateNormal];
            
            /* NaviDisNum 按二进制位数看，如果右移两位后 对2取余数，如果等于1  则代表4位 是1，则不显示导航图标，只显示距离，没有导航功能  （具体看WSFuncsBean_opt 中naviDis 参数解释）*/
            if ((NaviDisNum >> 2) % 2 == 1 ) {
                
            }else{
                
                [self.storeNavButton setImage:[UIImage imageNamed:@"icon_distance"] forState:UIControlStateNormal];
                [self.storeNavButton addTarget:self action:@selector(navButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self.storeNavButton.titleLabel setFont:[UIFont systemFontOfSize:UI_SubView_Font -2]  ];
        }
        
    }else{
        CGFloat width = [self getTextWidthRatio];
        if (INTERFACE_IS_PHONE) {
            width = width + 0.25;
        }
        nameWidthConstraint = [self.storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:width relation:NSLayoutRelationLessThanOrEqual];
        
        self.storeNavButton.hidden = YES;
    }
    
}

-(void)setUpSubViews{
    CGFloat nameFontSize;

    [super setUpSubViews];
    
    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    if ([isUsePhotos isEqualToString:@"0"]) {
        userStoreIcon = NO;
    }else{
        userStoreIcon = YES;
    }
    nameFontSize = UI_SubView_Font;
    
//    [self.contentView addSubview:self.storeIcon];
//    [self.storeIcon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
//    [self.storeIcon autoSetDimension:ALDimensionHeight toSize:K_STORE_ICON_HEIGHT];
//    [self.storeIcon autoSetDimension:ALDimensionWidth toSize:K_STORE_ICON_WIDHT];
//    [self.storeIcon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kView_Space_Top];
//    
//    [storeCodeImg autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
//    [self.storeCodeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeCodeImg withOffset:kView_Space_CodeImg_Code];
//    
//    [storeAddImg autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
//    [self.addressLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeAddImg withOffset:kView_Space_CodeImg_Code];
//    //
//    [self.storeIntimeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
//    [self.storeOuttimeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
//    [self.storeDurationTimeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
    
}

- (NSString *)strChange:(NSString *)str
{
    NSRange range = [str rangeOfString:@"."];
    if (range.location != NSNotFound) {
        if (range.location==1) {
            return str;
        }
        else
        {
            NSInteger num;
            NSString *unit;
            if (str.length>range.location+2) {
                num = [[str substringWithRange:NSMakeRange(0,range.location+2)] integerValue];
                unit = [str substringWithRange:NSMakeRange(range.location+2,str.length-range.location-2)];
                return [NSString stringWithFormat:@"%ld%@",num,unit];
            }
            
            return str;
        }
    }
    else
    {
        return str;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
