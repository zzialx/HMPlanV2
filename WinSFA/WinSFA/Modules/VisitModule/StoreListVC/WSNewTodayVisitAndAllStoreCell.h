//
//  WSNewTodayVisitAndAllStoreCell.h
//  WinSFA
//
//  Created by sunhongfu on 2017/12/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean_opt.h"

typedef NS_ENUM(NSInteger,WSNewStorePrepareState) {
    
    WSNewStorePrepareStateNotPrepare, //未准备
    WSNewStorePrepareStateReady   //已准备
    
};

@protocol WSNewTodayVisitAndAllStoreCellDelegate <NSObject>


/**
 门店准备
 @param store 门店对象
 @param date 准备日期
 */
-(void)storePrepareWith:(WSStoreBean *)store withDate:(NSString *)date;

/**
 聊天入口
 @param store 门店对象
 */
-(void)chatButtonPressDown:(WSStoreBean*)store;

@end

@interface WSNewTodayVisitAndAllStoreCell : UITableViewCell
{
    CGFloat storeIconTopSpace;
    CGFloat storeIconleftSpace;
    CGFloat firstLabelTopSpace;
    CGFloat firstForSecondLabelSpace;
    CGFloat labelSpace;
    CGFloat nameLabelForStoreAsattriViewSpace;
    CGFloat codePadding;
    CGFloat storeAsattriViewWidth;
    NSString *prepareAndVisitStateBtnText;//记录prepareAndVisitStateBtn 的titleLabel的text  直接取有问题  不准确
}
/**
 *  公用部分
 */
@property(nonatomic,strong) UIImageView *storeIcon; //门店icon
@property(nonatomic,strong) UIImageView *storeSelect; //选择按钮

@property(nonatomic,strong) UILabel *storeNameLabel; //门店名称

@property(nonatomic,strong) UIImageView * storeCodeImg; //门店编码icon
@property(nonatomic,strong) UILabel *storeCodeLabel; //门店编码 +

@property(nonatomic,strong) UIScrollView * storeAsattriView; //门店编码后面的图片集合

@property(nonatomic,strong) UIImageView * storeAddImg; //门店地址icon
@property(nonatomic,strong) UIImageView * addressImg; //门店地址icon
@property(nonatomic,strong) UILabel *addressLabel; //门店地址

@property(nonatomic,strong) UIImageView * storeLastmanView;//最后一次拜访业代人员icon
@property(nonatomic,strong) UILabel *storeLastmanLabel; //最后一次拜访业代人员名称;

@property(nonatomic,strong) UIImageView * lastDateImgView;//最后一次拜访日期前面的icon
@property(nonatomic,strong) UILabel *storeLastDateLabel; //最后一次拜访日期

@property(nonatomic,strong) UIImageView *storeLastTransactionImgView;//最近交易时间前面的icon
@property(nonatomic,strong) UILabel *storeLastTransactionLabe; //最近交易时间

@property(nonatomic,strong) UIButton *storeNavButton; //跳转到地图导航按钮

@property(nonatomic,strong) UIImageView * chatImage;//聊天图片点击由storeIcon响应

@property(nonatomic,strong) UIImageView *storeMonthVisitTimeImgView;
@property(nonatomic,strong) UILabel *storeMonthVisitTimeLable; //当月拜访次数

@property(nonatomic,strong) WSStoreBean * store; //门店数据

@property(nonatomic,strong) UIImageView *visitPlanImgView; //计划内外
//@property(nonatomic,strong) UIButton *storeVisitState; //拜访状态
@property(nonatomic,strong) UIButton *prepareAndVisitStateBtn; //准备和拜访状态
@property(assign,nonatomic) BOOL isChatVisible; //是否显示聊天按钮
@property(assign,nonatomic) BOOL isDistance; //是否显示距离按钮  ---> 可以确定 拜访状态的位置和显示图片还是显示字
@property(nonatomic,assign) WSNewStorePrepareState prepareState;//记录自己的准备状态,VC外部调用
@property(nonatomic,weak) id <WSNewTodayVisitAndAllStoreCellDelegate> delegate;
//已下载详细数据的标示  YIHAIKERRY-3241 新增的
@property(nonatomic,strong) UIImageView *loadTag;

/**
 初始化方法
 
 @param style 样式
 @param reuseIdentifier 重用标识
 @param cellWidth cell宽度
 @return cell对象
 */
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

/**
 如果在opt中配置了某些参数会影响cell 的样式，需要在此方法中做判断  通过funcBean acvtBean 设置准备状态
 
 @param store 门店信息
 @param funcBean 菜单对象
 @param acvtBean 问卷对象
 */
- (void)setStore:(WSStoreBean *)store withOpt:(WSFuncsBean_opt *)opt prepareFuncsBean:(WSFuncsBean *)funcBean prepareAcvtBean:(WSAcvtBean *)acvtBean;

/**
 获取门店列表的高度
 
 @param store 门店数据模型
 @param cellWidth  cell 的宽度
 @param isHavePrepareButton 是否有准备按钮
 @return 列表高度
 */
+ (CGFloat )heightForRowWithStore:(WSStoreBean *)store  cellWidth:(CGFloat)cellWidth isHavePrepareButton:(BOOL)isHavePrepareButton withOpt:(WSFuncsBean_opt *)opt;

@end
