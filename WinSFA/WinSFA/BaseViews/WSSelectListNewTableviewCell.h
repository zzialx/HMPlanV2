//
//  WSSelectListNewTableviewCell.h
//  WinSFA
//
//  Created by zhiqing on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSBaseTableViewCell.h"
#import "WSFuncsBean_opt.h"

#define STORE_LIST_CELL_DEFAULT_HEIGHT (INTERFACE_IS_PAD ? 110 :105)

typedef NS_ENUM(NSInteger,WSStorePrepareState) {
    
    WSStorePrepareStateNotPrepare, //未准备
    WSStorePrepareStateReady   //已准备
    
};

typedef NS_ENUM(NSInteger,WSSelectListNewTableviewCellStyle) {
    WSSelectListNewTableviewCellStyleStoreVisitList, // 门店拜访
    WSSelectListNewTableViewCellStyleScrollList      // 门店拜访滚动列表
};

@protocol WSSelectListNewTableviewCellDelegate <NSObject>

@optional

#pragma mark - 门店准备 store 门店对象 date 准备日期
-(void)storePrepareWith:(WSStoreBean *)store withDate:(NSString *)date;

#pragma mark - 聊天入口store 门店对象
-(void)chatButtonPressDown:(WSStoreBean*)store;

#pragma mark - 是否关注按键点击 indexPath:索引路径 //MN-288 2018-02-03
- (void)isFollowButtonClick:(NSIndexPath *)indexPath;

@end


@interface WSSelectListNewTableviewCell : WSBaseTableViewCell
{
    NSLayoutConstraint *storeAddressWidthConstraint; // 门店地址宽度约束
    BOOL userStoreIcon ; // 是否使用门头照
}
/**
 *  公用部分
 */
@property(nonatomic,strong) UIImageView *storeIcon; // 门店icon

@property(nonatomic,strong) UILabel *storeNameLabel; // 门店名称          

@property(nonatomic,strong) UILabel *storeCodeLabel;    // 门店编码 +

@property(nonatomic,strong) UILabel *addressLabel;      // 门店地址

@property (nonatomic,strong) UIImageView * storeLastmanView;

@property (nonatomic,strong) UILabel *storeLastmanLabel; // 最后一次拜访业代人员名称;

@property (nonatomic,strong) UIImageView * lastDateImgView;//最后一次拜访日期前面的icon

@property (nonatomic,strong) UILabel *storeLastDateLabel; // 最后一次拜访日期

@property (nonatomic,strong) UIImageView *storeLastTransactionImgView;//最近交易时间前面的icon

@property (nonatomic, strong) UILabel *storeLastTransactionLabe; //最近交易时间

@property (nonatomic,strong) UIButton *storeNavButton; // 跳转到地图导航按钮

@property (nonatomic,strong) UIButton *phoneButton; // 拨打电话

@property (nonatomic,strong) UIButton *chatButton; //跳转到聊天按钮
@property (nonatomic,strong) UIImageView * chatImage;//聊天图片
@property (nonatomic,strong) UIImageView *storeMonthVisitTimeImgView;
@property (nonatomic, strong) UILabel *storeMonthVisitTimeLable; //当月拜访次数

@property (nonatomic,strong) UIImageView *storeQuarterVisitTimeImgView;//季度拜访次数
@property (nonatomic, strong) UILabel *storeQuarterVisitTimeLable; //季度拜访次数
@property(nonatomic,strong) WSStoreBean * store; // 门店数据

@property(nonatomic,weak) id <WSSelectListNewTableviewCellDelegate> delegate;
/**
 *  门店列表部分
 */
@property(nonatomic,strong) UIImageView *visitPlanImgView;         // 计划内外
/**
 *  门店拜访部分
 */
@property(nonatomic,strong) UIButton *storeInfoButton; // 查看门店信息的按钮

@property(nonatomic,strong) UIImageView *visitType;     // 拜访的类型(到店/电话)

@property(nonatomic,strong) UIButton * storeVisitState;       // 拜访状态

@property(nonatomic,strong) UIButton * monthVisitState;       ///<本月拜访状态

@property(nonatomic,strong) UIButton * orangeStoresVisitState;       ///<橙色门店拜访状态

@property(nonatomic,strong) UIButton * orangeAgreementStoresState;       ///<橙色协议门店标识

@property(nonatomic,strong) UIButton *prepareStateBtn;     // 准备状态

@property(nonatomic,copy) NSString *isStoreInfo;   // 是否显示门店信息按钮

@property(assign,nonatomic) BOOL isChatVisible; //是否显示聊天按钮
@property(assign,nonatomic) BOOL isDistance; //是否显示距离按钮  ---> 可以确定 拜访状态的位置和显示图片还是显示字

@property (nonatomic, strong) NSIndexPath *indexPath; //索引路径 MN-288 2018-02-03

//SFA-22086 【泸州老窖】拜访轨迹第二层门店名称下方由原来的离店时间改为进店时间、离店时间、在店时间
@property(nonatomic,strong) UILabel *storeIntimeLabel;    // 进店时间
@property(nonatomic,strong) UILabel *storeOuttimeLabel;    // //离店时间
@property(nonatomic,strong) UILabel *storeDurationTimeLabel;    // 在店时间
@property(nonatomic,assign) CGFloat nameFontSize;    //标题的字体
@property(nonatomic,assign) CGFloat storeCodePadding;    //门店编码相对门店标题的上下边距


/**
 初始化方法
 
 @param style 样式
 @param reuseIdentifier 重用标识
 @param funcStyle 自定义样式
 @param isStoreInfo 是否显示门店信息按钮
 @param cellWidth cell宽度
 @return cell对象
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSSelectListNewTableviewCellStyle)funcStyle isStoreInfo:(NSString *)isStoreInfo cellWidth:(CGFloat)cellWidth;

/**
 设置准备状态
 
 @param state 准备状态
 @param funcBean 菜单对象
 @param acvtBean 问卷对象
 */
- (void)setPrepareState:(WSStorePrepareState)state prepareFuncsBean:(WSFuncsBean *)funcBean prepareAcvtBean:(WSAcvtBean *)acvtBean;


/**
 获取门店列表的高度
 
 @param store 门店数据模型
 @param cellWidth  cell 的宽度
 @param isHavePrepareButton 是否有准备按钮
 @return 列表高度
 */
+ (CGFloat )heightForRowWithStore:(WSStoreBean *)store  cellWidth:(CGFloat)cellWidth isHavePrepareButton:(BOOL)isHavePrepareButton withOpt:(WSFuncsBean_opt *)opt;

// 如果在opt中配置了某些参数会影响cell 的样式，需要在此方法中做判断
- (void)setStore:(WSStoreBean *)store withOpt:(WSFuncsBean_opt *)opt;

- (void)resetPhone;
//标题字体大小
- (CGFloat)getNameFontSize;
@end

