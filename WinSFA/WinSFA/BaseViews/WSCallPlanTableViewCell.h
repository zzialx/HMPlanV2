//
//  WSCallPlanTableViewCell.h
//  WinSFA
//
//  Created by winchannel on 2017/1/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,WSCallPlanTableViewCellStyle) {
    WSCallPlanTableViewCellStyleDefault,
    WSCallPlanTableViewCellStyleVisitSubempStore,//下级门店拜访
    WSCallPlanTableViewCellStyleVisitCount,//拜访次数
    WSCallPlanTableViewCellStyleRedisOther,//根据redis显示的其他类型
};
@protocol WSCallPlanTableViewCellDelegate <NSObject>

- (void)didSelectedWithStoreCode:(NSString *)storeCode;

- (void)didSelectedWithStoreCode:(NSString *)storeCode otherParams:(NSDictionary *)otherParams;

@end

@interface WSCallPlanTableViewCell : UITableViewCell


@property (nonatomic,strong) UILabel *serialNumberlabel;//序列号

@property (nonatomic,strong) UILabel *storeNameLabel;//门店名称

@property (nonatomic, strong)UILabel *visitSubStoresLabel;//下属门店做拜访计划数量

@property (nonatomic,strong) UILabel *storeCodeLabel; //门店编码

@property (nonatomic, strong)UILabel *storeVisitCountLabel; //拜访次数

@property (nonatomic , strong) UIView *storeListAcvtCodeView; // opt 的storeListAcvtCode 配置了，就显示此view；

@property (nonatomic, strong)UILabel *visitPupose;//拜访目的

@property (nonatomic, strong)UILabel *redisOtherLabel; //回显其他信息（暂时只用到上次拜访提醒的回显）

@property (nonatomic, strong)UIButton *selectedNoteButton;//计划状态

@property (nonatomic, strong) UIImageView *storeStateView;

@property (nonatomic, strong) UIScrollView *attriView;//门店类型

@property (nonatomic, strong)NSObject<I_W_Cell> *sb;

@property (nonatomic, strong)NSString *seialNumberStr;

@property (nonatomic, strong)NSString *visitCount;

@property (nonatomic, copy) NSString *redisOtherSubtitle;

@property (nonatomic, weak) id<WSCallPlanTableViewCellDelegate>delegate;

- (void)setStore:(NSObject<I_W_Cell> *)store withOpt:(WSFuncsBean_opt *)opt;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSCallPlanTableViewCellStyle)funcStyle;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSCallPlanTableViewCellStyle)funcStyle withvisitedSubStores:(NSString *)visitedSubStores;

// SFA-23593 IOS：SFA立白【经销商】拜访计划设置优化需求-逾期天数手机端展示开发
- (CGFloat)heightForRowWithStore:(NSObject<I_W_Cell> *)aStore WithCellWidth:(CGFloat)cellWidth withFuncStyle:(WSCallPlanTableViewCellStyle)funcStyle;


@end
