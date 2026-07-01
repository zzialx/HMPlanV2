//
//  WSSelectListNewTableviewCell.m
//  WinSFA
//
//  Created by zhiqing on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSelectListNewTableviewCell.h"
#import "PureLayout.h"
#import "WSServerIPList.h"
#import "WSBaseDictsDBService.h"
#import "WSInoutStoreTable.h"
#import "NSString+ServerUrl.h"
#import "WSRequestHelper.h"
#import "WSStoreInfoViewController.h"
#import "WSImagePathTable.h"
#import "NSString+Additions.h"
#import "UIButton+WebCache.h"
#import <CoordinateTransform/CoordinateTransform.h>
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSShowQstViewForStoreListCell.h"
#import "WSSelectScrollListTableViewCell.h"
#import "WSEnvrionment.h"
#import <Masonry.h>
#import "WSAttanceViewModel.h"

#define kView_Space_Left (INTERFACE_IS_PHONE ? 15 : 20)
#define kView_Space_StoreName_Icon_Left (INTERFACE_IS_PHONE ? 12 : 20)
#define kDetailFontSize  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 13.0f : 15.0f)
#define KLittleGap 8
#define KView_space 7

#define kView_Space_Top (INTERFACE_IS_PHONE ? 14 : 15)
#define kView_Height (INTERFACE_IS_PHONE ? 15 : 20)
#define UI_SubView_Font (INTERFACE_IS_PHONE ? 13.0f : 15.0f)
#define UI_SubView_Detail_Font (INTERFACE_IS_PHONE ? 10.0f : 15.0f)
#define kView_Space_CodeImg_Code (INTERFACE_IS_PHONE ? 5.0f : 8.0f)

#define K_VISIT_STATUS_LEFT_SPACE (INTERFACE_IS_PHONE ? 20 : 20)

#define K_NAV_BUTTON_WIDHT (INTERFACE_IS_PHONE ? 80 : 85)
#define K_NAV_BUTTON_HEGIHT (INTERFACE_IS_PHONE ? 18 : 20)

#define K_STORE_ICON_WIDHT   (INTERFACE_IS_PHONE ? 70: 90)
#define K_STORE_ICON_HEIGHT  (INTERFACE_IS_PHONE ? 70: 90)
#define k_STORE_ATTRIVIEW_SPACE  2.0f
#define k_STORE_VISIT_STATE_BUTTON_WIDTH  (INTERFACE_IS_PHONE ? 80.0f: 100.0f)

#define K_VISIT_DIS    5.0

#define K_STATUS_GRAY_COLOR  [UIColor colorWithHexString:@"#c7c9c7"]
//#define K_STATUS_GREEN_COLOR  [UIColor colorWithHexString:@"#5cc485"]
#define K_STATUS_YELLOW_COLOR  [UIColor colorWithHexString:@"#fbc84d"]

#define K_STATUS_GREEN_COLOR  [UIColor colorWithHexString:@"#A0CC79"]

#define K_STATUS_ORANGE_COLOR  [UIColor colorWithHexString:@"#FB8E66"]

#define K_STATUS_LIME_COLOR  [UIColor colorWithHexString:@"#9ec963"]

#define Today_Visit_State  @"今日拜访"

#define Month_Visit_State  @"本月已访"

#define Orange_Visit_State @"完美采集"

#define Orange_Agreement_Store @"完美协议门店"

#define ROLE @"无效拜访"

@interface WSSelectListNewTableviewCell ()
{
    WSSelectListNewTableviewCellStyle funcstyle;
    NSLayoutConstraint *storeNameLeftConstraint; // 门店名称左约束
    
    UIImageView * storeCodeImg; // 门店编码icon
    UIImageView * storeAddImg;  // 门店地址icon
    
    UIScrollView * storeAsattriView; // 门店编码后面的图片集合
    
    NSLayoutConstraint *storeIconLeftConstraint; // 门头照左约束
    NSLayoutConstraint *storeAsattriLeftConstraint; // 门店属性图标 左约束
    NSLayoutConstraint *storeAsattriRightConstraint; // 门店属性图标 右约束
    NSLayoutConstraint *storeAsattriHeightConstraint; // 门店属性图标 高度约束
    
    NSLayoutConstraint *storeVisitStateCentYConstraint; // 拜访状态图标centY约束
    NSLayoutConstraint *storeCodeTopConstraint; // 门店编码上部约束
    NSLayoutConstraint *storeAddrTopConstraint; // 门店地址上部约束
    NSLayoutConstraint *storeAddrHeightConstraint; // 门店地址高度约束
    NSLayoutConstraint *storeAddrImgTopConstraint; // 门店地址左边icon上部约束
    
    NSLayoutConstraint *nameWidthConstraint; // 门店名称宽度约束
    NSLayoutConstraint *visitPlanImgViewLeftConstraint; // 拜访状态左约束
    
    NSLayoutConstraint *prepareStateBtnYConstraint; // 准备状态底部约束
    NSLayoutConstraint *prepareStateBtnWidthConstraint; // 准备状态宽度约束
    NSLayoutConstraint *prepareStateBtnHeightConstraint; // 准备状态高度约束
    NSLayoutConstraint *storeVisitStateHeightConstraint; // 准备状态高度约束
    
    NSLayoutConstraint *lastManTopConstraint; // 代表上部约束
    NSLayoutConstraint *phoneBtnYConstraint; // 电话按钮约束
    
    
    NSInteger NaviDisNum;   // 导航按钮显示规则--NaviDisNum 按二进制位数看，如果右移两位后 对2取余数，如果等于1  则代表4位 是1，则不显示导航图标，只显示距离，没有导航功能  （具体看WSFuncsBean_opt 中naviDis 参数解释）
    CGFloat _cellWidth;  // cell 宽度
    BOOL isHideCode ; // 是否隐藏门店编码
}

@property (nonatomic,assign) CGFloat storeNameMaxWidth; // 门店名称最大显示宽度
@property (nonatomic , strong) UIView * lastBottomView; // 最后一行的view

@property (nonatomic, strong) UILabel * separateLabel;// 地图页面底部弹出视图 底部分割线

@property (nonatomic, strong) UIImageView * leftImageView; // 地图页面底部弹出视图 底部左边的icon

@property (nonatomic , strong) UILabel * visitContant; //地图页面底部弹出视图  拜访内容
@property (nonatomic , strong) UIView * storeListAcvtCodeView; // opt 的storeListAcvtCode 配置了，就显示此view；
@property (nonatomic , copy) NSString *acvtCode; // opt 中的storeListAcvtCode
@property (nonatomic , strong) WSBaseAcvtdisDBService * acvtdisService;
@property (nonatomic , strong) WSBaseAcvtDBService * acvtService;
@property (nonatomic , strong) WSFuncsBean_opt * currentOpt;
@property (nonatomic , strong) WSSelectScrollListTableViewCell * scrollListTableViewCell;
@property (nonatomic , assign) CGFloat prepareStateBtnTitleWidth;
@property (nonatomic , strong) NSMutableArray *horizontalDisplayArray;//水平展示的WSShowQstViewSingleLineModel的array
@property (nonatomic , strong) NSMutableArray *verticalDisplayArray;//垂直展示的WSShowQstViewSingleLineModel的array
@property (nonatomic , assign) BOOL isHorizontal;//WSShowQstViewSingleLineModel是否横行显示

@end


@implementation WSSelectListNewTableviewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSSelectListNewTableviewCellStyle)funcStyle isStoreInfo:(NSString *)isStoreInfo cellWidth:(CGFloat)cellWidth {
    funcstyle = funcStyle;
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.showIndicatorImage = NO;
        self.isChatVisible=NO;
        _isStoreInfo = isStoreInfo;
        _cellWidth = cellWidth;
        [self setUpSubViews];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}


-(WSBaseAcvtdisDBService *)acvtdisService{
    if (!_acvtdisService) {
        _acvtdisService = [[WSBaseAcvtdisDBService alloc]init];
    }
    return _acvtdisService;
}

-(WSBaseAcvtDBService *)acvtService{
    if (!_acvtService) {
        _acvtService = [[WSBaseAcvtDBService alloc]init];
    }
    return _acvtService;
}
-(void)setUpSubViews{
    
    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList) {
        
        NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
        if ([isUsePhotos isEqualToString:@"0"]) {
            userStoreIcon = NO;
        }else{
            userStoreIcon = YES;
        }
        
    }
    self.nameFontSize = [self getNameFontSize];
    self.storeIcon = [UIImageView newAutoLayoutView];
    self.storeNameLabel = [UILabel newAutoLayoutView];
    self.chatButton = [UIButton newAutoLayoutView];
    storeCodeImg = [UIImageView newAutoLayoutView];
    storeAddImg = [UIImageView newAutoLayoutView];
    storeCodeImg.image = [UIImage imageNamed:@"info_bianma_icon"];
    storeAddImg.image = [UIImage imageNamed:@"info_dizhi_icon"];
    
    
    CGFloat font = INTERFACE_IS_PAD ? (self.nameFontSize + 3):self.nameFontSize;
    self.storeNameLabel.font =[UIFont systemFontOfSize:font];
    self.storeNameLabel.numberOfLines = 0;
    self.storeNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.storeNameLabel.textColor = MAIN_TEXT_COLOR;
    
    self.storeCodeLabel = [UILabel newAutoLayoutView];
    self.storeCodeLabel.textColor = DETAIL_TEXT_COLOR;
    self.storeCodeLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    //新增
    self.storeIntimeLabel = [UILabel newAutoLayoutView];
    self.storeIntimeLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    self.storeIntimeLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    self.storeIntimeLabel.numberOfLines = 0;
    
    self.storeOuttimeLabel = [UILabel newAutoLayoutView];
    self.storeOuttimeLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    self.storeOuttimeLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    self.storeOuttimeLabel.numberOfLines = 0;
    
    self.storeDurationTimeLabel = [UILabel newAutoLayoutView];
    self.storeDurationTimeLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    self.storeDurationTimeLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    
    self.addressLabel = [UILabel newAutoLayoutView];
    self.addressLabel.textColor = DETAIL_TEXT_COLOR;
    CGFloat fontSize = INTERFACE_IS_PAD ? UI_SubView_Font:UI_SubView_Detail_Font;
    self.addressLabel.font = [UIFont systemFontOfSize:fontSize];
    self.addressLabel.numberOfLines = 0;
    self.addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.storeLastmanView = [UIImageView newAutoLayoutView];
    self.storeLastmanView.image = [UIImage imageNamed:@"icon_person"];
    [self.contentView addSubview:self.storeLastmanView];
    
    self.storeLastmanLabel = [UILabel newAutoLayoutView];
    self.storeLastmanLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    self.storeLastmanLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    
    self.lastDateImgView = [UIImageView newAutoLayoutView];
    self.lastDateImgView.image = [UIImage imageNamed:@"info_date_icon"];
    [self.contentView addSubview:self.lastDateImgView];
    self.storeLastDateLabel = [UILabel newAutoLayoutView];
    self.storeLastDateLabel.textColor = DETAIL_TEXT_COLOR;
    self.storeLastDateLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    
    
    self.storeLastTransactionImgView = [UIImageView newAutoLayoutView];
    self.storeLastTransactionImgView.image = [UIImage imageNamed:@"info_date_icon"];
    [self.contentView addSubview:self.storeLastTransactionImgView];
    
    self.storeLastTransactionLabe = [UILabel newAutoLayoutView];
    self.storeLastTransactionLabe.textColor = CELL_DETAIL_TEXTCOLOR;
    self.storeLastTransactionLabe.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    
    self.storeMonthVisitTimeImgView = [UIImageView newAutoLayoutView];
    self.storeMonthVisitTimeImgView.image = [UIImage imageNamed:@"icon_tag_grey"];
    [self.contentView addSubview:self.storeMonthVisitTimeImgView];
    
    self.storeMonthVisitTimeLable = [UILabel newAutoLayoutView];
    self.storeMonthVisitTimeLable.textColor = CELL_DETAIL_TEXTCOLOR;
    self.storeMonthVisitTimeLable.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    
    self.storeNavButton = [UIButton newAutoLayoutView];
    self.storeNavButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    
    self.visitPlanImgView = [UIImageView newAutoLayoutView];
    self.visitPlanImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.visitPlanImgView.image = [UIImage imageNamed:@"point_plan_icon"];//内
    
    [self.contentView addSubview:self.visitPlanImgView];
    self.visitPlanImgView.hidden=YES;
    
    
    storeAsattriView = [UIScrollView newAutoLayoutView];
    storeAsattriView.userInteractionEnabled = NO;
    [self.contentView addGestureRecognizer:storeAsattriView.panGestureRecognizer];
    
    [self.contentView addSubview:self.storeLastDateLabel];
    [self.contentView addSubview:self.storeLastTransactionLabe];
    [self.contentView addSubview:self.storeMonthVisitTimeLable];
    
    [self.contentView addSubview:self.storeCodeLabel];
    [self.contentView addSubview:self.storeNameLabel];
    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:storeCodeImg];
    [self.contentView addSubview:storeAddImg];
    [self.contentView addSubview:storeAsattriView];
    //新增
    [self.contentView addSubview:self.storeIntimeLabel];
    [self.contentView addSubview:self.storeOuttimeLabel];
    [self.contentView addSubview:self.storeDurationTimeLabel];
    
    self.storeNameLabel.backgroundColor = [UIColor clearColor];
    self.storeCodeLabel.backgroundColor = [UIColor clearColor];
    self.addressLabel.backgroundColor = [UIColor clearColor];
    self.storeLastmanLabel.backgroundColor = [UIColor clearColor];
    self.storeLastDateLabel.backgroundColor = [UIColor clearColor];
    self.storeLastTransactionLabe.backgroundColor = [UIColor clearColor];
    self.storeMonthVisitTimeLable.backgroundColor = [UIColor clearColor];
    
    self.storeNavButton.backgroundColor = [UIColor clearColor];
    self.chatButton.backgroundColor=[UIColor clearColor];
    self.chatButton.hidden=YES;
    [self.contentView addSubview:self.storeLastDateLabel];
    if (userStoreIcon) {
        [self.contentView addSubview:self.storeIcon];
        [self.storeIcon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        [self.storeIcon autoSetDimension:ALDimensionHeight toSize:K_STORE_ICON_HEIGHT];
        [self.storeIcon autoSetDimension:ALDimensionWidth toSize:K_STORE_ICON_WIDHT];
        [self.storeIcon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kView_Space_Top];
        
    }
    
    [self.storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kView_Space_Top];
    [self.storeNameLabel autoSetDimension:ALDimensionHeight toSize:kView_Height * 4 relation:NSLayoutRelationLessThanOrEqual];
    
    [storeAsattriView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.storeCodeLabel];
    storeAsattriHeightConstraint = [storeAsattriView autoSetDimension:ALDimensionHeight toSize:kView_Height];
    storeAsattriRightConstraint = [storeAsattriView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.contentView withOffset:-K_VISIT_STATUS_LEFT_SPACE];
    storeAsattriLeftConstraint =  [storeAsattriView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeCodeLabel];
    
    CGFloat textWidthRatio = [self getTextWidthRatio];
    
    nameWidthConstraint = [self.storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:textWidthRatio relation:NSLayoutRelationLessThanOrEqual];
    
    
    self.storeCodePadding = [self getStoreCodePadding];
    
    [storeCodeImg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeNameLabel withOffset:self.storeCodePadding];
    [storeCodeImg autoSetDimension:ALDimensionHeight toSize:kView_Height -3];
    [storeCodeImg autoSetDimension:ALDimensionWidth toSize:kView_Height - 3];
    
    storeAddrImgTopConstraint = [storeAddImg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:storeCodeImg withOffset:7];
    [storeAddImg autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];
    [storeAddImg autoSetDimension:ALDimensionWidth toSize:kView_Height - 3];
    
    
    storeCodeTopConstraint =  [self.storeCodeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeCodeImg];
    [self.storeCodeLabel autoSetDimension:ALDimensionHeight toSize:kView_Height];
    [self.storeCodeLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:INTERFACE_IS_PHONE ? 0.42 : 0.75 relation:NSLayoutRelationLessThanOrEqual];
    
    //新增
    [self.storeIntimeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeCodeImg];//顶部
    //    [self.storeIntimeLabel autoSetDimension:ALDimensionHeight toSize:kView_Height];//高
    [self.storeIntimeLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:INTERFACE_IS_PHONE ? 0.42 : 0.75 relation:NSLayoutRelationLessThanOrEqual];//宽
    
    [self.storeOuttimeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeIntimeLabel withOffset:7];//顶部
    //    [self.storeOuttimeLabel autoSetDimension:ALDimensionHeight toSize:kView_Height];
    [self.storeOuttimeLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:INTERFACE_IS_PHONE ? 0.42 : 0.75 relation:NSLayoutRelationLessThanOrEqual];
    
    [self.storeDurationTimeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeOuttimeLabel withOffset:7];//顶部
    [self.storeDurationTimeLabel autoSetDimension:ALDimensionHeight toSize:kView_Height];
    [self.storeDurationTimeLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:INTERFACE_IS_PHONE ? 0.42 : 0.75 relation:NSLayoutRelationLessThanOrEqual];
    
    
    storeAddrTopConstraint = [self.addressLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeAddImg ];
    // MSTD-7129 备注调整间距
    storeAddrHeightConstraint = [self.addressLabel autoSetDimension:ALDimensionHeight toSize:kView_Height relation:NSLayoutRelationGreaterThanOrEqual];
    
    
    if (userStoreIcon) {
        [storeCodeImg autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        [self.storeCodeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeCodeImg withOffset:kView_Space_CodeImg_Code];
        
        [storeAddImg autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        [self.addressLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeAddImg withOffset:kView_Space_CodeImg_Code];
        //
        [self.storeIntimeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        [self.storeOuttimeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        [self.storeDurationTimeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        
    }else{
        [storeCodeImg autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        [self.storeCodeLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeCodeImg withOffset:kView_Space_CodeImg_Code];
        
        [storeAddImg autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        [self.addressLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:storeAddImg withOffset:kView_Space_CodeImg_Code];
        //
        [self.storeIntimeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        [self.storeOuttimeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        [self.storeDurationTimeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        
        
    }
    //    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList ||
    //              funcstyle == WSSelectListNewTableViewCellStyleScrollList) {
    
    self.visitType = [UIImageView newAutoLayoutView];
    self.visitType.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.visitType];
    
    if (userStoreIcon) {
        [self.visitType autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_Left];
    }else{
        [self.visitType autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeNameLabel withOffset:kView_Space_Left];
    }
    
    [self.visitType autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kView_Space_Top];
    [self.visitType autoSetDimension:ALDimensionWidth toSize:2*kView_Height];
    [self.visitType autoSetDimension:ALDimensionHeight toSize:kView_Height];
    
    
    storeNameLeftConstraint = [self.storeNameLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.visitType withOffset:kView_Space_Left/2];
    
    [self.visitPlanImgView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.storeCodeLabel];
    [self.visitPlanImgView autoSetDimension:ALDimensionWidth toSize:kView_Height +5];
    [self.visitPlanImgView autoSetDimension:ALDimensionHeight toSize:kView_Height];
    visitPlanImgViewLeftConstraint =   [self.visitPlanImgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeCodeLabel withOffset:kView_Space_Left];
    
    //橙色采集
    [self orangeStoresVisitState];
    
    // 右侧的拜访状态及 准备状态
    [self storeVisitState];

    [self prepareStateBtn];
    
    //设置当月拜访
    [self monthVisitState];
    
    //设置橙色协议门店标识
    [self orangeAgreementStoresState];
    
}


-(void)addPhoneButton{
    if (self.store.phone.length > 0) {
        self.phoneButton.hidden = NO;
        [storeAsattriRightConstraint autoRemove];
        storeAsattriRightConstraint = [storeAsattriView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.phoneButton withOffset:-K_VISIT_STATUS_LEFT_SPACE];
    }else
        self.phoneButton.hidden = YES;
    
    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList) {
        
        [phoneBtnYConstraint autoRemove];
        if (self.store.attri.length > 0) {
            phoneBtnYConstraint = [self.phoneButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeAsattriView];
        }else if (!isHideCode){
            phoneBtnYConstraint = [self.phoneButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.storeCodeLabel];
        }else{
            phoneBtnYConstraint = [self.phoneButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.storeIcon];
        }
    }
}
#pragma -mark  泸州老窖显示门店拜访的内容
-(void)addVisitContantView{
    if (!self.separateLabel) {
        self.separateLabel = [UILabel newAutoLayoutView];
        UIColor *lineColor = [UIColor colorForKey:@"WorkFlowCellSeparatorLineColor"];
        if (!lineColor) {
            lineColor = DETAIL_SEPERATE_LINE_COLOR;
        }
        self.separateLabel.backgroundColor = lineColor;
        [self addSubview:self.separateLabel];
    }
    CGFloat height = 0.0;
    CGSize size = [self.store.visitcontent stringSizeWithFont:[UIFont systemFontOfSize:kDetailFontSize] width: self.width - 3*kView_Height - 6];
    height += size.height + 2 *KLittleGap;
    
    CGFloat cHeight = [WSSelectListNewTableviewCell getHeightForRowWithoutVisitContentViewWithStore:self.store cellWidth:self.width isHavePrepareButton:NO withOpt:_currentOpt];
    
    if (cHeight < K_STORE_ICON_HEIGHT + kView_Space_Top*2) {
        cHeight = K_STORE_ICON_HEIGHT + kView_Space_Top*2;
    }
    
    //    if (self.lastBottomView) {
    //        [self.separateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lastBottomView withOffset:KLittleGap * 0.5];
    //    }else{
    //         [self.separateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeIcon withOffset:kView_Space_Top];
    //    }
    
    [self.separateLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:cHeight];
    
    [self.separateLabel autoSetDimension:ALDimensionHeight toSize:0.5];
    [self.separateLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kView_Space_Left];
    [self.separateLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-2*kView_Space_Left];
    
    if (!self.leftImageView) {
        self.leftImageView = [UIImageView newAutoLayoutView];
        [self.leftImageView setImage:[UIImage imageNamed:@"icon_bar_blue"]];
        [self addSubview:self.leftImageView];
    }
    [self.leftImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separateLabel withOffset:KLittleGap];
    [self.leftImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kView_Space_Left];
    [self.leftImageView autoSetDimension:ALDimensionWidth toSize:3];
    [self.leftImageView autoSetDimension:ALDimensionHeight toSize:12];
    
    if (!self.visitContant) {
        self.visitContant = [UILabel newAutoLayoutView];
        self.visitContant.font = [UIFont systemFontOfSize:kDetailFontSize];
        self.visitContant.numberOfLines = 0;
        self.visitContant.textColor = CELL_DETAIL_TEXTCOLOR;
        [self addSubview:self.visitContant];
        
    }
    [self.visitContant autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.leftImageView withOffset:-2];
    [self.visitContant autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.leftImageView withOffset:kView_Space_Left];
    [self.visitContant  autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-3*kView_Space_Left - 6];
}


-(void)readyprepareState{
    NSLog(@"-----准备");
    if ([_delegate respondsToSelector:@selector(storePrepareWith: withDate:)]) {
        [_delegate storePrepareWith:_store withDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    }
}

-(void)setIsChatVisible:(BOOL)isChatVisible{
    _isChatVisible = isChatVisible;
    self.chatButton.hidden = !isChatVisible;
    self.chatImage.hidden = !isChatVisible;
}

- (void)setStore:(WSStoreBean *)store withOpt:(WSFuncsBean_opt *)opt
{
    if(opt.isChat && [opt.isChat isEqualToString:@"Y"]){
        self.isChatVisible=YES;
    }else{
        self.isChatVisible=NO;
    }
    
    if ([opt.isGps isEqualToString:@"N"]) {
        self.isDistance = NO;
    }else{
        self.isDistance = YES;
    }
    if (opt.naviDis && opt.naviDis.length > 0) {
        NaviDisNum = [opt.naviDis integerValue];
    }else{
        NaviDisNum = 2; // 这里是属于没配置的情况，默认距离，导航都显示
    }
    if ([opt.isCode isEqualToString:@"0"]) {
        isHideCode = YES;
    }
    if (opt.storeListAcvtCode.length > 0) {
        _acvtCode = opt.storeListAcvtCode;
    }
    self.store = store;
    self.currentOpt = opt;
    
}

-(void)setStore:(WSStoreBean *)store
{
    if (_store != store) {
        _store = store;
    }
    //MN-288 2018-02-03
    if(store.follow.length > 0)
        store.actionState = ActionFollow;
    
    self.lastBottomView = nil;
    //    // 有距离 才算位置，否则不显示距离    不要改变model数据,排序页面要距离的原始数值
    //    if ((store.distance.length> 0)&& !([store.distance rangeOfString:NSLocalizedString(@"loc_acc_unit", nil)].location != NSNotFound || [store.distance rangeOfString:NSLocalizedString(@"loc_acc_unit_km", nil)].location != NSNotFound) ) {
    //        store.distance = [WSLocationManager convertDistance:[store.distance doubleValue]];
    //    }
    
    // 门头照
    [self setStoreIcon];
    
    //加入聊天标识
    [self addChatImage];
    
    // 添加电话按钮
    [self addPhoneButton];
    
    NSString *storeName = [WSSelectListNewTableviewCell getStoreNameByStoreBean:store];
    CGSize  storeNameSize = [storeName ws_sizeWithFont:[UIFont systemFontOfSize: UI_SubView_Font + 1] constrainedToWidth:_storeNameMaxWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    _storeNameLabel.text = storeName;
    _storeCodeLabel.text = store.code;
    /*SFA-14468 逻辑修改,全部以lastBottomView为基准判断进行布局 create by sunhongfu 2017-11-24*/
    if (store.code.length > 0)
    {
        self.lastBottomView = _storeCodeLabel;
    }
    
    [storeAddrHeightConstraint autoRemove];
    
    if (store.addr.length > 0)
    {
        self.lastBottomView = _addressLabel;
        _addressLabel.text = store.addr;
        
        //MSTD-7512 2018-01-09
        CGSize addressSize = [store.addr ws_sizeWithFont:_addressLabel.font constrainedToWidth:CGRectGetWidth(_addressLabel.frame) lineBreakMode:NSLineBreakByCharWrapping];
        
        // MSTD-7333 地址切换为空的时候再显示非空，不设置的话高度变为 0
        storeAddrHeightConstraint = [self.addressLabel autoSetDimension:ALDimensionHeight toSize:addressSize.height relation:NSLayoutRelationGreaterThanOrEqual];
    }
    else
    {
        _addressLabel.text = @"";
        // MSTD-7442 地址为空时候的设置
        storeAddrHeightConstraint = [self.addressLabel autoSetDimension:ALDimensionHeight toSize:kView_Height relation:NSLayoutRelationLessThanOrEqual];
    }
    
    if (store.addr && store.addr.length > 0) {
        storeAddImg.hidden = NO;
    }else{
        storeAddImg.hidden = YES;
    }
    
    //    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList ||
    //        funcstyle == WSSelectListNewTableViewCellStyleScrollList
    //        ) {
    
    if ((storeNameSize.height > kView_Height) && INTERFACE_IS_PHONE) {
        [storeCodeTopConstraint autoRemove];
        storeCodeTopConstraint =  [self.storeCodeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:storeCodeImg];
        [storeAddrTopConstraint autoRemove];
        storeAddrTopConstraint = [self.addressLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:storeAddImg];
    }
    
    [_storeInfoButton setImage:[UIImage imageNamed:@"customer_icon_info@2x"] forState:UIControlStateNormal];
    
    // 设置拜访类型
    [self setVisitType];
    
    // 计划内图标显示与否
    if (store.plan || (store.isRouteStore && ![store.isRouteStore isEqualToString:@"0"])) {
        self.visitPlanImgView.hidden = NO;
    }else{
        self.visitPlanImgView.hidden = YES;
    }
    
    // 设置属性图标
    [self setStoreAsattriView];
    
    // 设置拜访状态
    [self setVisitStatus];
    
    // 可变选项---有值显示 没值隐藏
    [self addLastManViewWiht:store.last_man];
    
    [self addLastDateViewWith:store.last_date];
    
    [self addLastTransactionImgViewViewWith:store.last_transaction];
    
    [self addStoreMonthVistitViewWith:store.store_month_visit_time];
    
    if (_acvtCode) {
        [self addStoreListAcvtCodeView];
    }
    
    //当季拜访次数
    if (_store.last_num_q.length)
    {
        [self addStoreQuarterVisitTime:_store.last_num_q];
    }
    else
    {
        [self removeStoreQuarterVisitTime];
    }
    
    // 设置门店拜访状态的Y值  ---> 顺序要在lastBottomView 设置完成之后
    //更新拜访状态的约束
    [self setStoreVisitStatusY];
    
    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList) {
        // 导航按钮逻辑
        [self setStoreNavButton];
    }
    // 隐藏门店编码
    [self dealwithStoreCodeHide];
    
    if (store.visitcontent.length > 0) {
        [self addVisitContantView];
        [self.separateLabel setHidden:NO];
        [self.visitContant setHidden:NO];
        [self.leftImageView setHidden:NO];
        self.visitContant.text = store.visitcontent;
    }
    else{
        [self.separateLabel setHidden:YES];
        [self.visitContant setHidden:YES];
        [self.leftImageView setHidden:YES];
    }
    
    //SFA-22086 【泸州老窖】拜访轨迹第二层门店名称下方由原来的离店时间改为进店时间、离店时间、在店时间
//    if (store.inTime.length > 0) {   //进店时间显示在第一行，隐藏门店编码行
//        self.storeIntimeLabel.text = store.inTime;
//        CGSize inTimeSize = [self.storeIntimeLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font] constrainedToWidth:INTERFACE_IS_PHONE ? 0.42 : 0.75];
//        self.storeIntimeLabel.height = inTimeSize.height;
//        self.storeCodeLabel.hidden = YES;
//        storeCodeImg.hidden = YES;
//    }else {
//        self.storeIntimeLabel.text = @"";
//        if (isHideCode) {
//            storeCodeImg.hidden = YES;
//            _storeCodeLabel.hidden = YES;
//        }else {
//            storeCodeImg.hidden = NO;
//            _storeCodeLabel.hidden = NO;
//        }
//    }
//    if (store.outTime.length > 0) {
//        self.storeOuttimeLabel.text = store.outTime;
//        CGSize outTimeSize = [self.storeOuttimeLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font] constrainedToWidth:INTERFACE_IS_PHONE ? 0.42 : 0.75];
//        self.storeOuttimeLabel.height = outTimeSize.height;
//    }else {
//        self.storeOuttimeLabel.text = @"";
//    }
//    if (store.instore_time.length > 0) {
//        self.storeDurationTimeLabel.text = store.instore_time;
//    }else {
//        self.storeDurationTimeLabel.text = @"";
//    }
}

#pragma -mark  设置门头照
- (void)setStoreIcon{
    
    // MSTD-3636 与安卓逻辑保持一致，优先显示服务器回显照片
    if ([self.store.storeImg length] > 0){
        
        if ([self.store.storeImg rangeOfString:@"."].location != NSNotFound) {
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:self.store.storeImg] imageView:_storeIcon placeholderImage:[UIImage imageForName:@"shop_default@2x"]];
        }else{
            // 如果storeImg 是 IMG_IDX  则取本地图片的最后一张  SFA 项目 SFA-5467
            NSArray * imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:self.store.storeImg];
            if (imagePathArray.count) {
                
                WSImagePathObject * object = [imagePathArray lastObject];
                // object.img_path 是 回显的 @ 分割的串  则取服务器回显的url  SFA 项目 SFA-5467
                if ([object.img_path rangeOfString:@"@"].location != NSNotFound) {
                    NSString * url = [[object.img_path componentsSeparatedByString:@"@"] lastObject];
                    [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:url] imageView:_storeIcon placeholderImage:[UIImage imageNamed:@"shop_default"]];
                    
                }else{
                    
                    UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
                    if (image) {
                        _storeIcon.image = image;
                    }else{
                        _storeIcon.image = [UIImage imageForName:@"shop_default@2x"];
                        
                    }
                    
                }
            }
        }
        
    }
    else{
        
        NSString *local_image = [[WSInoutStoreTable sharedTable]getStoreLocalImageWithStore:self.store andOtherParam:nil andParamType:EParameterType_NULL];
        
        if (local_image && local_image.length >0 && ![local_image isEqualToString:@"null"]) {
            UIImage *localImage =[[SDImageCache sharedImageCache]imageFromKey:local_image fromDisk:YES];
            _storeIcon.image = localImage;
        }else{
            _storeIcon.image = [UIImage imageForName:@"shop_default@2x"];
        }
    }
}
#pragma -mark  导航按钮,距离(xxx  米 公里)
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
#pragma -mark  添加沟通标识
-(void)addChatImage{
    
    if(self.isChatVisible){
        [self.storeIcon addSubview:self.chatImage];
        [self.chatImage autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.chatImage autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [self.chatImage autoSetDimension:ALDimensionWidth toSize:self.chatImage.size.width];
        [self.chatImage autoSetDimension:ALDimensionHeight toSize:self.chatImage.size.height];
        [self.chatImage setContentMode:UIViewContentModeLeft];
        
        self.storeIcon.userInteractionEnabled = YES;
        
        // MSTD-4185 调整沟通图标的感应区域, 将门头照的区域设置为沟通图标的感应区。
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatButtonClick:)];
        singleFingerOne.numberOfTouchesRequired = 1; //手指数
        singleFingerOne.numberOfTapsRequired = 1; //tap次数
        singleFingerOne.delegate = self;
        
        [self.storeIcon addGestureRecognizer:singleFingerOne];
    }
    
}
#pragma -mark 设置拜访类型 -- for 联合利华
-(void)setVisitType{
    if ([self.store.visitType length] > 0) {
        self.visitType.hidden = NO;
        self.visitType.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@@2x", self.store.visitType]];
        [storeNameLeftConstraint autoRemove];
        if (userStoreIcon) {
            storeNameLeftConstraint = [self.storeNameLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.visitType withOffset:kView_Space_Left/2];
        }else{
            storeNameLeftConstraint = [self.storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        }
    }else {
        self.visitType.hidden = YES;
        [storeNameLeftConstraint autoRemove];
        if (userStoreIcon) {
            storeNameLeftConstraint = [self.storeNameLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        }else{
            storeNameLeftConstraint = [self.storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
        }
    }
}
#pragma -mark 设置属性图标
-(void)setStoreAsattriView{
    
    [storeAsattriLeftConstraint autoRemove];
    if (self.store.attri && self.store.attri.length > 0) {
        storeAsattriView.hidden = NO;
        
        if (self.store.plan) {
            if(self.visitPlanImgView){
                storeAsattriLeftConstraint =  [storeAsattriView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.visitPlanImgView];
            }
        }else{
            if(self.storeCodeLabel){
                storeAsattriLeftConstraint =  [storeAsattriView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeCodeLabel withOffset:k_STORE_ATTRIVIEW_SPACE];
            }
        }
        [storeAsattriView removeAllSubviews];
        
        NSArray * storeImgs = [self.store.attri componentsSeparatedByString:@","];
        CGFloat imgX = 0;
        for (int i = 0; i < storeImgs.count; i++) {
            //YIHAIKERRY-1265 （原来是kView_Height+5）
            if (i!=0) {
                
                imgX = i * (kView_Height) + (i + 1) * k_STORE_ATTRIVIEW_SPACE/*(kView_Space_Left - 2.5)*/;
            }
            UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgX  , 0, kView_Height, kView_Height)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            //            imgView.image = [UIImage imageNamed:@"tag_0"];
            NSString *imgURLStr = [WSHttpURLHelper getImageCompleteURL:storeImgs[i]];
            if ([imgURLStr hasSuffix:@"png"] || [imgURLStr hasSuffix:@"jpg"]) {
                [[WSRequestHelper shareInstance] downloadImageWithUrl:imgURLStr imageView:imgView completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                    //SFA-24951
                    if (image) {
                        CGSize imageSize = image.size;
                        [storeAsattriHeightConstraint autoRemove];
                        storeAsattriHeightConstraint = [storeAsattriView autoSetDimension:ALDimensionHeight toSize:imageSize.height/2];
                        imgView.frame = CGRectMake(imgX, 0, imageSize.height/2,imageSize.height/2);
                    }
                }];
            }else{
                
                //        SFA-17178 董宏 汉高返回带icon不需要拼接
                //                SFA-17840
                //                【ios】手机端汉高移动，门店列表门店没有显示小图标
                if([storeImgs[i] containsString:@"icon"])
                {
                    imgView.image = [UIImage imageNamed: storeImgs[i]];
                }
                else
                {
                    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", storeImgs[i]]];
                    
                }
            }
            [storeAsattriView addSubview:imgView];
            // SFA-21906 zhaodanyang
            CGFloat width = storeImgs.count * kView_Height + (storeImgs.count+1) * k_STORE_ATTRIVIEW_SPACE;
            storeAsattriView.contentSize = CGSizeMake(width, 0);
        }
    }else{
        storeAsattriView.hidden = YES;
    }
}

#pragma -mark  设置拜访状态
-(void)setVisitStatus{
    
    UIColor *stateColor;
    UIImage * bgVisitStatusImg = [UIImage imageNamed:@""];
    NSString * visitStateTitle = @"";
    
    if ([self.store.actionState isEqualToString:ActionDone]||[self.store.optName containsString:Today_Visit_State]) {  /* 0 未拜访  1 拜访完成  2 已拜访  3 拜访项已填写*/
        // 已拜访 '打钩'
        [_storeVisitState setTitle:@"" forState:UIControlStateNormal];
        //本地的优先级高于服务器的
        if ([self.store.actionState isEqualToString:ActionWorking]) {
            stateColor  = K_STATUS_YELLOW_COLOR;
            visitStateTitle = NSLocalizedString(@"planning_state", nil);
            bgVisitStatusImg =[UIImage imageNamed:@"bg_status_yellow"];
        }else{
            stateColor  = K_STATUS_GRAY_COLOR;
            bgVisitStatusImg =[UIImage imageNamed:@"bg_status_gray"];
            NSString * role = [WSAttanceViewModel getLoginUserRole];
            if([role isEqualToString:ROLE]){
                if(self.store.inTime&&self.store.outTime){
                    double enterStoretime = [self.store.inTime doubleValue];
                    double outStoretime = [self.store.outTime doubleValue];
                    double inStoreTime = outStoretime - enterStoretime;
                    if(outStoretime==0&&enterStoretime>0){
                        //未离开门店
                        LogInfo(@"未离开门店特殊处理,多人登录导致的问题");
                        visitStateTitle = NSLocalizedString(@"planning_state", nil);
                        stateColor  = K_STATUS_YELLOW_COLOR;
                        bgVisitStatusImg =[UIImage imageNamed:@"bg_status_yellow"];
                    }else{
                        if(inStoreTime < 5 * 60){
                            visitStateTitle = @"无效拜访";
                        }else{
                            visitStateTitle = NSLocalizedString(@"planned_state", nil);
                        }
                    }
                }else{
                    visitStateTitle = NSLocalizedString(@"planned_state", nil);
                }
            }else{
                visitStateTitle = NSLocalizedString(@"planned_state", nil);
            }           
        }
        
        
    }else if ([self.store.actionState isEqualToString:ActionWorking]){
        
        stateColor  = K_STATUS_YELLOW_COLOR;
        visitStateTitle = NSLocalizedString(@"planning_state", nil);
        bgVisitStatusImg =[UIImage imageNamed:@"bg_status_yellow"];
        
    }else if ([self.store.actionState isEqualToString:ActionNotStart] || self.store.actionState.length == 0){
        /*
         准备状态,  已准备    准备按钮为 '修改准备'
         未准备    准备按钮   '开始准备'
         */
        stateColor  = [UIColor clearColor];
        visitStateTitle = @"";
        bgVisitStatusImg =[UIImage imageNamed:@""];
    }else if ([self.store.actionState isEqualToString:ActionAlreadyFilledOut] || self.store.actionState.length == 0||[self.store.optName containsString:Today_Visit_State]){
        /*
         * 其中有一个拜访项已填写，列表cell显示已填写状态
         */
        stateColor  = [UIColor clearColor];
        visitStateTitle = @"";
        bgVisitStatusImg =[UIImage imageNamed:@"already_filled_out_icon"];
        [storeVisitStateHeightConstraint autoRemove];
        storeVisitStateHeightConstraint = [self.storeVisitState autoSetDimension:ALDimensionHeight toSize:25.0];
    }
    else if([self.store.actionState isEqualToString:ActionFollow]) //MN-288 2018-02-03
    {
        if([self.store.follow isEqualToString:@"0"])
        {
            stateColor = K_STATUS_YELLOW_COLOR;
            visitStateTitle = NSLocalizedString(@"not_follow", nil);
            bgVisitStatusImg = [UIImage scaledImageForName:@"bg_statusFollow_yellow" ofType:@"png"];
        }
        else if([self.store.follow isEqualToString:@"1"])
        {
            stateColor = K_STATUS_GRAY_COLOR;
            visitStateTitle = NSLocalizedString(@"already_follow", nil);
            bgVisitStatusImg = [UIImage scaledImageForName:@"bg_statusFollow_gray" ofType:@"png"];
        }
    }
    
    [_storeVisitState setTitleColor:stateColor forState:UIControlStateNormal];
    [_storeVisitState setBackgroundImage:bgVisitStatusImg forState:UIControlStateNormal];
    [_storeVisitState setTitle:visitStateTitle forState:UIControlStateNormal];
    
    // 根据状态 设置门店地址的宽度
    [storeAddressWidthConstraint autoRemove];
    
    if (self.store.actionState.length >0 && ![self.store.actionState isEqualToString:ActionNotStart]) {
        
        storeAddressWidthConstraint = [self.addressLabel autoSetDimension:ALDimensionWidth toSize:[self getStoreAddressLabelWidthIsHaveVisitState:YES]];
    }else{
        storeAddressWidthConstraint = [self.addressLabel autoSetDimension:ALDimensionWidth toSize:[self getStoreAddressLabelWidthIsHaveVisitState:NO]];
    }
}

#pragma -mark ------------------- 更新拜访状态以及橙色采集按钮的约束--------

-(void)setStoreVisitStatusY{
    if (self.isDistance) {
        if (funcstyle == WSSelectListNewTableViewCellStyleScrollList ) {
            storeVisitStateCentYConstraint = [self.storeVisitState autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.phoneButton withOffset:kView_Space_CodeImg_Code];
        
            }else{
                //橙色采集按钮修改约束,
                if ([self.store.optName containsString:@"完美已采集"]) {
                    [self.orangeStoresVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
                    }];
                }else{
                    //未下发，或者橙色未采集，未重新登录的情况下，橙色采集门店完成的情况下也要更新橙色门店按钮 yes代表橙色门店已访 本地已经橙色采集
                    if (self.store.answer.length>0) {
                        [self.orangeStoresVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
                        }];
                    }else{
                        [self.orangeStoresVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(0);
                        }];
                    }
                    
                }
                [self.orangeStoresVisitState updateConstraintsIfNeeded];

                //今日拜访  0 未拜访  1 拜访未离开  2 已拜访完成  3 未拜访原因
                if ([self.store.actionState isEqualToString:ActionNotStart]&&![self.store.optName containsString:Today_Visit_State]) {
                    //今日拜访。今日拜访状态，如果是今日已访问，那么肯定存在当月拜访
                    [self.storeVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(0);
                    }];
                }else{
                    [self.storeVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
                    }];
                }
                
                [self.storeVisitState updateConstraintsIfNeeded];

                //当月拜访
                if (![self.store.optName containsString:Month_Visit_State] ){
                    //服务器未下发本月已访，今日拜访已经完成
                    //未下发，未重新登录的情况下，今日已拜访的情况下也要更新当月拜访按钮
                    if ([self.store.actionState isEqualToString:ActionNotStart]&&![self.store.optName containsString:Today_Visit_State]) {
                        [self.monthVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(0);
                        }];
                    }else{
                        [self.monthVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
                        }];
                    }
                }else{
                    [self.monthVisitState mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
                    }];
                }
    
                [self.monthVisitState updateConstraintsIfNeeded];
                
                //橙色协议门店标识
                if ([self.store.optName containsString:@"完美协议门店"]) {
                    //下发的标识
                    [self.orangeAgreementStoresState mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
                    }];
                }else{
                    //隐藏样式
                    [self.orangeAgreementStoresState mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(0);
                    }];
                }
                
                [self.orangeAgreementStoresState updateConstraintsIfNeeded];
        }
    }
    
}
#pragma -mark  处理门店编码隐藏的情况
-(void)dealwithStoreCodeHide{
    if (isHideCode) {
        storeCodeImg.hidden = YES;
        _storeCodeLabel.hidden = YES;
        
        // 门店有计划内或属性图标
        if ((self.store.attri && self.store.attri.length > 0) || self.store.plan) {
            [visitPlanImgViewLeftConstraint autoRemove];
            if (self.store.plan) {
                visitPlanImgViewLeftConstraint = [self.visitPlanImgView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.storeNameLabel];
            }else{
                [storeAsattriLeftConstraint autoRemove];
                //YIHAIKERRY-1265 SFA 益海嘉里-深圳，门店列表，地图里面选择所对应的门店，门店图标应该显示在最左边，跟名称对齐。
                storeAsattriLeftConstraint =  [storeAsattriView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.storeNameLabel];
            }
        }else{
            [storeAddrTopConstraint autoRemove];
            [storeAddrImgTopConstraint autoRemove];
            storeAddrTopConstraint = [self.addressLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeNameLabel withOffset:7];
            storeAddrImgTopConstraint = [storeAddImg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeNameLabel withOffset:7];
        }
    }else{
        storeCodeImg.hidden = NO;
        _storeCodeLabel.hidden = NO;
    }
    
}

#pragma -mark 聊天入口
-(UIImageView *)chatImage{
    if (!_chatImage) {
        _chatImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ltfqan"]];
    }
    return _chatImage;
}

#pragma -mark 门店名称宽度比例
- (CGFloat)getTextWidthRatio {
    CGFloat textWidthRatio;
    if (userStoreIcon) {
        textWidthRatio = INTERFACE_IS_PHONE ? 0.42 : 0.65;
    } else {
        /*Jira - MSTD-6837  控制当没有图片 WSSelectListNewTableViewCellStyleScrollList 时候 storeNameLabel的长度  create by sunhongfu*/
        if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList )
        {
            textWidthRatio = INTERFACE_IS_PHONE ? 0.77 : 0.8;
        }
        
    }
    return textWidthRatio;
}
#pragma -mark 最近拜访人员
- (void)addLastManViewWiht:(NSString *)lastMan{
    if ([lastMan length] > 0) {
        self.storeLastmanLabel.hidden = NO;
        self.storeLastmanView.hidden = NO;
        // MSTD-7129 liran
        if (self.lastBottomView != self.addressLabel) {
            [self.addressLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lastBottomView?self.lastBottomView : self.storeNameLabel withOffset:kView_Space_Top/2];
        }
        [self.contentView addSubview:self.storeLastmanLabel];
        // MSTD-7442 地址为空的时候跟地址对齐，否则跟地址保持 padding 距离
        CGFloat paddingY = 0;
        if ([self.addressLabel.text length] > 0) {
            paddingY = kView_Space_Top/2;
        }
        [lastManTopConstraint autoRemove];
        lastManTopConstraint = [self.storeLastmanView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.addressLabel withOffset:paddingY];
        [self.storeLastmanView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeIcon withOffset:kView_Space_StoreName_Icon_Left];
        [self.storeLastmanView autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];
        [self.storeLastmanView autoSetDimension:ALDimensionWidth toSize:kView_Height - 3];
        
        [self.storeLastmanLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.storeLastmanView withOffset:-2];
        [self.storeLastmanLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeLastmanView withOffset:kView_Space_CodeImg_Code];
        
        [self.storeLastmanLabel autoSetDimension:ALDimensionHeight toSize:kView_Height];
        [self.storeLastmanLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.3];
        NSString * SRString = NSLocalizedString(@"last_man",nil);
        self.storeLastmanLabel.text = [NSString stringWithFormat:@"%@:%@",SRString,lastMan];
        self.lastBottomView = self.storeLastmanLabel;
    }else{
        
        self.storeLastmanLabel.hidden = YES;
        self.storeLastmanView.hidden = YES;
    }
    
}
#pragma -mark 最后一次拜访时间
-(void)addLastDateViewWith:(NSString *)lastDate{
    if ([lastDate length] > 0) {
        self.storeLastDateLabel.hidden = NO;
        self.lastDateImgView.hidden = NO;
        
        [self.lastDateImgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lastBottomView?self.lastBottomView : self.storeNameLabel withOffset:kView_Space_Top/2];
        [self.lastDateImgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:storeCodeImg];
        
        [self.lastDateImgView autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];
        [self.lastDateImgView autoSetDimension:ALDimensionWidth toSize:kView_Height - 3];
        
        [self.storeLastDateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.lastDateImgView withOffset:-2];
        [self.storeLastDateLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.lastDateImgView withOffset:kView_Space_CodeImg_Code];
        [self.storeLastDateLabel autoSetDimension:ALDimensionHeight toSize:kView_Height];
        [self.storeLastDateLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.5];
        self.storeLastDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"last_date", nil),lastDate];
        
        self.lastBottomView = self.storeLastDateLabel;
    }else {
        self.lastDateImgView.hidden = YES;
        self.storeLastDateLabel.hidden = YES;
    }
    
}

#pragma -mark 最近交易时间
-(void)addLastTransactionImgViewViewWith:(NSString *)lastTransaction{
    
    if ([lastTransaction length] > 0) {
        self.storeLastTransactionImgView.hidden = NO;
        self.storeLastTransactionLabe.hidden = NO;
        
        [self.storeLastTransactionImgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView: self.lastBottomView?self.lastBottomView : self.storeNameLabel  withOffset:5];
        [self.storeLastTransactionImgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:storeCodeImg];
        
        [self.storeLastTransactionImgView autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];
        [self.storeLastTransactionImgView autoSetDimension:ALDimensionWidth toSize:kView_Height - 3];
        
        [self.storeLastTransactionLabe autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.storeLastTransactionImgView];
        [self.storeLastTransactionLabe autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeLastTransactionImgView withOffset:kView_Space_CodeImg_Code];
        [self.storeLastTransactionLabe autoSetDimension:ALDimensionHeight toSize:kView_Height];
        [self.storeLastTransactionLabe autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.5];
        self.storeLastTransactionLabe.text = [NSString stringWithFormat:NSLocalizedString(@"最近交易:%@", nil),lastTransaction];
        self.lastBottomView = self.storeLastTransactionLabe;
        
    }else {
        self.storeLastTransactionImgView.hidden = YES;
        self.storeLastTransactionLabe.hidden = YES;
        
    }
}

#pragma -mark 当月拜访次数
-(void)addStoreMonthVistitViewWith:(NSString *)storeMonthVistitNum{
    if ([storeMonthVistitNum length] > 0) {
        self.storeMonthVisitTimeImgView.hidden = NO;
        self.storeMonthVisitTimeLable.hidden = NO;
        
        [self.storeMonthVisitTimeImgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView: self.lastBottomView?self.lastBottomView : self.storeNameLabel  withOffset:5];
        [self.storeMonthVisitTimeImgView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:storeCodeImg];
        
        [self.storeMonthVisitTimeImgView autoSetDimension:ALDimensionHeight toSize:kView_Height - 3];
        [self.storeMonthVisitTimeImgView autoSetDimension:ALDimensionWidth toSize:kView_Height - 3];
        
        [self.storeMonthVisitTimeLable autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.storeMonthVisitTimeImgView];
        [self.storeMonthVisitTimeLable autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.storeMonthVisitTimeImgView withOffset:kView_Space_CodeImg_Code];
        [self.storeMonthVisitTimeLable autoSetDimension:ALDimensionHeight toSize:kView_Height];
        [self.storeMonthVisitTimeLable autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.5];
        NSString * qstName = [self.acvtService queryQstWithAcvtQstCode:@"last_num"].qstName;
        self.storeMonthVisitTimeLable.text = [NSString stringWithFormat:NSLocalizedString(@"%@:%@", nil),qstName,storeMonthVistitNum];
        self.lastBottomView = self.storeMonthVisitTimeLable;
        
    }else {
        self.storeMonthVisitTimeImgView.hidden = YES;
        self.storeMonthVisitTimeLable.hidden = YES;
        
    }
}

//当季度拜访次数
- (void)addStoreQuarterVisitTime:(NSString *)last_num_q
{
    [self.contentView addSubview:self.storeQuarterVisitTimeImgView];
    [self.contentView addSubview:self.storeQuarterVisitTimeLable];
    _storeQuarterVisitTimeLable.text = [NSString stringWithFormat:@"当季已拜访次数%@",last_num_q];
    [self makeConstraints];
}

//当季度拜访次数 防止cell复用
- (void)removeStoreQuarterVisitTime
{
    [self.storeQuarterVisitTimeImgView removeFromSuperview];
    [self.storeQuarterVisitTimeLable removeFromSuperview];
}

- (void)makeConstraints
{
    CGFloat codePadding = 5;
    [self.storeQuarterVisitTimeImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.storeNameLabel);
        make.top.equalTo((self.lastBottomView?self.lastBottomView:self.storeNameLabel).mas_bottom).offset(codePadding);
        make.size.equalTo(CGSizeMake(self.storeQuarterVisitTimeLable.text.length>0? kView_Height - 3 : 0,self.storeQuarterVisitTimeLable.text.length>0? kView_Height - 3 : 0));
        
    }];
    
    [self.storeQuarterVisitTimeLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.storeQuarterVisitTimeImgView.mas_right).offset(codePadding);
        make.right.equalTo(self.mas_right).offset(-kView_Space_Left).priorityMedium();
        make.centerY.equalTo(self.storeQuarterVisitTimeImgView);
        
    }];
    if (self.storeQuarterVisitTimeLable.text.length) self.lastBottomView = self.storeQuarterVisitTimeLable;
}

-(void)addStoreListAcvtCodeView{
    [self.storeListAcvtCodeView removeAllSubviews];
    self.storeListAcvtCodeView = nil;
    NSArray * array = [self.acvtdisService queryAcvtDisWithStoreId:_store.Id acvtCode:_acvtCode qstType:@"T"];
    if (array.count == 0) {
        return;
    }
    [self.contentView addSubview:self.storeListAcvtCodeView];
    // SaaS蒙牛智网行动-经销商运营系统   MN-31
    WSShowQstViewForStoreListCellModel * viewModel = [[WSShowQstViewForStoreListCellModel alloc]init];
    viewModel.titleFont = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    viewModel.displayArray = array;
    /*
     WSShowQstViewSingleLineModel * lineModel = [[WSShowQstViewSingleLineModel alloc]init];
     lineModel.qstname = @"问题名称";
     lineModel.qstanwser = @"url@FF8C00@新鲜度";
     lineModel.qstdisplaymodel = @"BN";
     lineModel.groupName = @"horizontal";
     lineModel.hideQstName = @"1";
     WSShowQstViewSingleLineModel * lineModel2 = [[WSShowQstViewSingleLineModel alloc]init];
     lineModel2.qstname = @"问题名称1";
     lineModel2.qstanwser = @"url@FFFF00@新鲜度";
     lineModel2.qstdisplaymodel = @"BNICON";
     lineModel2.groupName = @"horizontal";
     lineModel2.hideQstName = @"1";
     WSShowQstViewSingleLineModel * lineModel3 = [[WSShowQstViewSingleLineModel alloc]init];
     lineModel3.qstname = @"问题名称2";
     lineModel3.qstanwser = @"url@FF00FF@新鲜度";
     lineModel3.qstdisplaymodel = @"BN";
     lineModel3.groupName = @"horizontal";
     //    lineModel3.hideQstName = @"1";
     viewModel.displayArray = @[lineModel,lineModel2,lineModel3];
     */
    
    CGSize viewSize = CGSizeMake(0, 0) ;
    if (array.count > 0) {
        viewSize = [self getStoreListAcvtCodeViewHeightWithDisplayArray:array isHavePrepareButton:NO];
        viewModel.horizontalDisplayArray = self.horizontalDisplayArray;
        viewModel.verticalDisplayArray = self.verticalDisplayArray;
    }
    
    [self.storeListAcvtCodeView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView: self.lastBottomView?self.lastBottomView : self.storeNameLabel  withOffset:5];
    [self.storeListAcvtCodeView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:storeCodeImg];
    [self.storeListAcvtCodeView autoSetDimension:ALDimensionHeight toSize:viewSize.height];
    //    SFA-24583
    //    SFA-立白-IOS-5s点订单详情按钮，反应不灵敏
    if (_prepareStateBtn) {
        [self.storeListAcvtCodeView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_prepareStateBtn];
    } else {
        
        [self.storeListAcvtCodeView autoSetDimension:ALDimensionWidth toSize:viewSize.width relation:NSLayoutRelationLessThanOrEqual];
    }
    
    WSShowQstViewForStoreListCell * view = [[WSShowQstViewForStoreListCell alloc]initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height) withModel:viewModel isHasQstHorizontal:self.isHorizontal tagBottom:nil];
    [self.storeListAcvtCodeView addSubview:view];
    //    int i = 0;
    //    for (NSString * answer in array) {
    //        UILabel * label = [[UILabel alloc]init];
    //        [self.storeListAcvtCodeView addSubview:label];
    //        label.frame = CGRectMake(0, i * ( kView_Height + 7), self.contentView.width * 0.5, kView_Height);
    //        label.text = answer;
    //        label.textColor = CELL_DETAIL_TEXTCOLOR;
    //        label.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    //        i++;
    //    }
}
#pragma -mark 获取门店地址的宽度
-(CGFloat)getStoreAddressLabelWidthIsHaveVisitState:(BOOL)isHaveVisitState{
    CGFloat storeAddressLabelWidth;
    if (userStoreIcon) {
        if (YES) {
            //判断是否有2个拜访状态，如果有2个以上的拜访状态就换行
            storeAddressLabelWidth =  _cellWidth - kView_Space_Left - K_STORE_ICON_WIDHT - kView_Space_StoreName_Icon_Left -  (kView_Height - 3) - 7 - kView_Space_Left - K_NAV_BUTTON_WIDHT;
        }else{
            storeAddressLabelWidth =  _cellWidth - kView_Space_Left - K_STORE_ICON_WIDHT - kView_Space_StoreName_Icon_Left -  (kView_Height - 3) - 7 - kView_Space_Left ;
        }
        
        
    }else{
        storeAddressLabelWidth =  _cellWidth - kView_Space_Left - 7 - (kView_Height - 3) - kView_Space_Left;
    }
    
    if (isHaveVisitState || funcstyle == WSSelectListNewTableViewCellStyleScrollList) {
        //    YIHAIKERRY-4153 donghong
        storeAddressLabelWidth = [self.scrollListTableViewCell getStoreAddressLabelWidthIsHaveVisitState:isHaveVisitState presentStoreAddressLabelWidth:storeAddressLabelWidth];
    }
    return storeAddressLabelWidth;
}

#pragma -mark 获取门店名称--可能会有这种拼接的情况
+ (NSString *)getStoreNameByStoreBean:(WSStoreBean *)storeBean {
    NSString *storeName = storeBean.name;
    if ([storeBean.row_number length] > 0) {
        if (storeBean.isShowMapCallout) {
            //  MN-1878   2018-4-19
            NSString * storeStyp = [NSString stringNotNilWithValue:storeBean.styp];
            storeName = [NSString stringWithFormat:@"%@ %@ %@",storeBean.row_number,storeStyp,storeBean.name];
        }else{
            storeName = [NSString stringWithFormat:@"%@.%@",storeBean.row_number,storeBean.name];
        }
        
    }
    return storeName;
}

#pragma -mark 设置准备状态
- (void)setPrepareState:(WSStorePrepareState)state prepareFuncsBean:(WSFuncsBean *)funcBean prepareAcvtBean:(WSAcvtBean *)acvtBean
{
    if ([self.store.state isEqualToString:@"0"]) {
        return;
    }
    
    [prepareStateBtnHeightConstraint autoRemove];
    [prepareStateBtnWidthConstraint autoRemove];
    
    [storeAddressWidthConstraint autoRemove];
    storeAddressWidthConstraint = [self.addressLabel autoSetDimension:ALDimensionWidth toSize:[self getStoreAddressLabelWidthIsHaveVisitState:YES]];
    
    NSString *title = nil;
    //这个判断条件是联合利华项目2016-8-23 加的，安卓没有这个判断条件暂时先屏蔽
    //    if ([self.store.actionState isEqualToString:ActionNotStart]) {
    UIColor *stateColor =  [UIColor colorForKey:@"StoreCellVisitStatusColor"] ? [UIColor colorForKey:@"StoreCellVisitStatusColor"] : K_STATUS_GRAY_COLOR;
    if (state == WSStorePrepareStateNotPrepare) {
        
        if ([funcBean.fv isEqualToString:UNILEVERORDERTEMPLATE_FV]) {
            title = NSLocalizedString( @"准备", nil);
        }
        
        _prepareStateBtn.hidden = NO;
        if ([funcBean.icon length] > 0) {
            //                [_prepareStateBtn sd_setImageWithURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:funcBean.icon]] forState:UIControlStateNormal];
            title = NSLocalizedString( @"noalready_prepare", nil);
            
            [_prepareStateBtn setBackgroundImage:[UIImage imageNamed:@"bg_status_gray"] forState:UIControlStateNormal];
        }else {
            [_prepareStateBtn setImage:[UIImage imageNamed:@"icon_zhongbei@2x"] forState:UIControlStateNormal];
        }
        
        
        [_prepareStateBtn setTitle:title forState:UIControlStateNormal];
        
        if ([acvtBean.acvtCode isEqualToString:STORE_PREPARE_ACVT_CODE]) {
            [_storeVisitState setImage:nil forState:UIControlStateNormal];
            [_storeVisitState setTitle:NSLocalizedString(@"noalready_prepare", nil) forState:UIControlStateNormal];
        }
        
    }else if (state == WSStorePrepareStateReady){
        
        if ([funcBean.fv isEqualToString:UNILEVERORDERTEMPLATE_FV]) {
            title = NSLocalizedString(@"修改", nil);
        }
        
        _prepareStateBtn.hidden = NO;
        if (![self.store.actionState isEqualToString:@"1"]) {
            
            if ([funcBean.iconOfDone length] > 0) {
                
                title = NSLocalizedString(@"already_prepare", nil);
                stateColor = K_STATUS_LIME_COLOR;
                [_prepareStateBtn setBackgroundImage:[UIImage imageNamed:@"bg_status_lime"] forState:UIControlStateNormal];
                
            }else {
                [_prepareStateBtn setImage:[UIImage imageNamed:@"icon_xiugai@2x"] forState:UIControlStateNormal];
            }
            
            [_prepareStateBtn setTitle:title forState:UIControlStateNormal];
            
            
            if ([acvtBean.acvtCode isEqualToString:STORE_PREPARE_ACVT_CODE]) {
                [_storeVisitState setImage:nil forState:UIControlStateNormal];
                [_storeVisitState setTitle:NSLocalizedString(@"already_prepare", nil) forState:UIControlStateNormal];
            }
            
        }
    }
    
    //        // MSTD-5955 单独处理未准备为英文字符时，过长导致显示不全的情况
    CGSize prepareStateBtnTitleSize = [title ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font] constrainedToHeight:K_NAV_BUTTON_HEGIHT lineBreakMode:NSLineBreakByCharWrapping];
    _prepareStateBtnTitleWidth = prepareStateBtnTitleSize.width + 15.0 > K_NAV_BUTTON_WIDHT ? prepareStateBtnTitleSize.width + 15.0 : K_NAV_BUTTON_WIDHT;
    
    if (_prepareStateBtnTitleWidth >= K_NAV_BUTTON_WIDHT) {
        self.prepareStateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -8);
        UIImage *prepareStateBtnBgImage = [UIImage imageNamed:@"bg_status_gray"];
        self.prepareStateBtn.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font - 1.0];
        
        prepareStateBtnHeightConstraint = [_prepareStateBtn autoSetDimension:ALDimensionHeight toSize:_prepareStateBtnTitleWidth * prepareStateBtnBgImage.size.height / prepareStateBtnBgImage.size.width];
    }else{
        prepareStateBtnHeightConstraint = [_prepareStateBtn autoSetDimension:ALDimensionHeight toSize:K_NAV_BUTTON_HEGIHT];
    }
    
    
    prepareStateBtnWidthConstraint = [_prepareStateBtn autoSetDimension:ALDimensionWidth toSize:_prepareStateBtnTitleWidth];
    
    if (funcBean.iconOfDone.length > 0 || funcBean.icon.length > 0) {
        [prepareStateBtnYConstraint autoRemove];
        // MSTD-7332 与安卓一致，有最近拜访时间则与最近拜访时间对齐
        if ([self.storeLastDateLabel.text length] > 0) {
            prepareStateBtnYConstraint =  [self.prepareStateBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.storeLastDateLabel];
        } else if (self.lastBottomView) {
            // SFA-24128 TO DO
            prepareStateBtnYConstraint =  [self.prepareStateBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.lastBottomView withOffset:5];
        } else {
            prepareStateBtnYConstraint =   [self.prepareStateBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kView_Space_Left];
        }
    }
    [_prepareStateBtn setTitleColor:stateColor forState:UIControlStateNormal];
    //    }
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


-(void)chatButtonClick:(UIButton *)button{
    if(self.delegate && [self.delegate respondsToSelector:@selector(chatButtonPressDown:)]){
        [self.delegate chatButtonPressDown:self.store];
    }
}

#pragma -mark 应用跳转 到高地地图
- (void)navButtonClick:(UIButton *)button {
    if (self.store.latitude && self.store.longitude) {
        
        [WSTLAlertManager addMapNavigationCustomAlertViewWithStorebean:self.store];
        
        return;
    }
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:NSLocalizedString(@"无门店经纬度!", nil) tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
}

#pragma -mark 拨号
- (void)callButtonClick:(UIButton *)button {
    NSString *phone = self.store.phone;
    if (!phone || phone.length == 0) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"phone_no_set", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]];
    if ([[UIApplication sharedApplication] canOpenURL:telUrl]) {
        [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:nil];
    }
}



- (void)resetPhone {
    // 已经设置过则不需要重置
    if (self.store.phone && self.store.phone.length > 0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeInfoHasArrived:)
                                                 name:NOTIFY_STOREINFO
                                               object:nil];
    
    
    [[WSRequestHelper shareInstance] appGetStoreInfobyStoreId:self.store.Id notifyName:NOTIFY_STOREINFO styp:self.store.styp];
}

- (void)storeInfoHasArrived:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_STOREINFO object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    if (error) {
        LogError(@"%@",error);
    } else {
        NSDictionary *responsedic = [info objectFromJSONString];
        
        NSString *objIdString = STOREINFO_UPDATE;
        
        NSArray *sInfo = [responsedic objectForKey:objIdString];
        NSDictionary *dic = [sInfo objectAtIndex:0];
        if (dic) {
            NSString *phone = [dic objectForKey:STOREINFO_LINKTEL];
            self.store.phone = phone;
        }
    }
    
}

- (CGSize)getStoreListAcvtCodeViewHeightWithDisplayArray:(NSArray *)array isHavePrepareButton :(BOOL) isHavePrepareButton
{
    BOOL isHorizontal = NO;
    CGFloat HWidth = 0;
    CGFloat viewHeight = 0;
    
    if (isHavePrepareButton) {
        
        _prepareStateBtnTitleWidth = K_NAV_BUTTON_WIDHT;
        
    }
    
    CGFloat maxWidth = self.contentView.width - kView_Space_Left - K_STORE_ICON_WIDHT - kView_Space_Left;
    if (_prepareStateBtnTitleWidth > 0) {
        if (_prepareStateBtnTitleWidth >= K_NAV_BUTTON_WIDHT) {
            maxWidth -= (_prepareStateBtnTitleWidth + 5 + 8);
        } else {
            maxWidth -= _prepareStateBtnTitleWidth;
        }
    }
    CGSize size = CGSizeMake(0, viewHeight);
    if (!self.horizontalDisplayArray) {
        self.horizontalDisplayArray = [NSMutableArray arrayWithCapacity:10];
    }
    if (!self.verticalDisplayArray) {
        self.verticalDisplayArray = [NSMutableArray arrayWithCapacity:10];
    }
    [self.horizontalDisplayArray removeAllObjects];
    [self.verticalDisplayArray removeAllObjects];
    if (array.count > 0) {
        for (WSShowQstViewSingleLineModel * tempModel in array) {
            NSString *titileString = [WSShowQstViewForStoreListCell getTitleString:tempModel];
            UIFont *titleFont = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
            if ([tempModel.groupName hasPrefix:@"horizontal"]) {
                CGFloat titleWidth = [titileString ws_sizeWithFont:titleFont constrainedToHeight:kView_Height].width;
                HWidth += titleWidth + (2 * 5);
                if (HWidth > maxWidth) {
                    isHorizontal = NO;
                    viewHeight += KView_space;
                }
                if(!isHorizontal || (self.storeListAcvtCodeView.width > 0 && HWidth > self.storeListAcvtCodeView.width)) {
                    isHorizontal = YES;
                    //                    HWidth = 0;
                    viewHeight += kView_Height ;
                }
                [self.horizontalDisplayArray addObject:tempModel];
                
            } else {
                CGFloat titleHeight= [titileString ws_sizeWithFont:titleFont constrainedToWidth:maxWidth].height;
                viewHeight += (titleHeight > kView_Height ? titleHeight : kView_Height);
                [self.verticalDisplayArray addObject:tempModel];
            }
        }
    }
    self.isHorizontal = isHorizontal;
    size = CGSizeMake(maxWidth, viewHeight);
    return size;
}

#pragma mark - 门店状态点击响应方法
- (void)storeVisitStateClick:(UIButton *)button
{
    if([self.store.actionState isEqualToString:ActionFollow] && self.store.follow.length > 0)
    {
        if ([self.delegate respondsToSelector:@selector(isFollowButtonClick:)])
            [self.delegate isFollowButtonClick:self.indexPath];
    }
}
- (CGFloat)getNameFontSize
{
    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList) {
        
        return UI_SubView_Font;
    }
    return  UI_SubView_Font + 3;
}
-(CGFloat)getStoreCodePadding {
    
    CGFloat codePadding = 7;
    if (funcstyle == WSSelectListNewTableviewCellStyleStoreVisitList) {
        
        return codePadding;
    }
    return codePadding * 2 + MAIN_CELL_SEPERATOR_HEIGHT;
}

#pragma mark---------------计算Cell高度---------------
+(CGFloat)heightForRowWithStore:(WSStoreBean *)store cellWidth:(CGFloat)cellWidth isHavePrepareButton:(BOOL)isHavePrepareButton withOpt:(WSFuncsBean_opt *)opt{
    
    CGFloat height = [WSSelectListNewTableviewCell getHeightForRowWithoutVisitContentViewWithStore:store cellWidth:cellWidth isHavePrepareButton:isHavePrepareButton withOpt:opt];
    
    if ([store.visitcontent length] > 0) {
        
        if (height < K_STORE_ICON_HEIGHT + kView_Space_Top*2) {
            height = K_STORE_ICON_HEIGHT + kView_Space_Top;
        }
        
        CGSize size = [store.visitcontent stringSizeWithFont:[UIFont systemFontOfSize:kDetailFontSize] width: cellWidth -3*kView_Space_Left - 6];
        height += size.height + 2 *KLittleGap +  kView_Space_Top;
        
        if (height < K_STORE_ICON_HEIGHT + kView_Space_Top*2) {
            return K_STORE_ICON_HEIGHT + kView_Space_Top*3 + size.height + 2 *KLittleGap;
        }
        
    }
    // 没有store.last_man或store.last_date  保持门店照片的上下间距
    if (height < K_STORE_ICON_HEIGHT + kView_Space_Top*2) {
        return K_STORE_ICON_HEIGHT + kView_Space_Top*2;
    }
    
    
    return height;
}

+ (CGFloat)getHeightForRowWithoutVisitContentViewWithStore:(WSStoreBean *)store cellWidth:(CGFloat)cellWidth isHavePrepareButton:(BOOL)isHavePrepareButton withOpt:(WSFuncsBean_opt *)opt
{
    /*
     动态计算高度
     1.门店名称  门店地址动态计算
     2.门店编码   拜访人员及日期高度固定
     */
    
    
    CGFloat height = kView_Space_Top;
    
    CGFloat textWidthRatio;
    CGFloat storeAddressWidth;
    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    if ([isUsePhotos isEqualToString:@"0"]) {
        textWidthRatio = INTERFACE_IS_PHONE ? 0.77 : 0.8;
        storeAddressWidth = cellWidth - kView_Space_Left - (kView_Height - 3) - 7 -kView_Space_Left;
    }else{
        textWidthRatio = INTERFACE_IS_PHONE ? 0.42 : 0.65;
        if (YES) {
            //判断是否有2个拜访状态，如果有2个以上的拜访状态就换行
            storeAddressWidth = cellWidth - kView_Space_Left - K_STORE_ICON_WIDHT - kView_Space_StoreName_Icon_Left - (kView_Height - 3) - 7 - kView_Space_Left - K_NAV_BUTTON_WIDHT;
        }else{
            storeAddressWidth = cellWidth - kView_Space_Left - K_STORE_ICON_WIDHT - kView_Space_StoreName_Icon_Left - (kView_Height - 3) - 7 - kView_Space_Left;
        }
        
    }
    // 如果有拜访状态显示，减去状态按钮的宽度
    if ((store.actionState.length >0 && ![store.actionState isEqualToString:ActionNotStart]) ||isHavePrepareButton ) {
        //        storeAddressWidth = storeAddressWidth - k_STORE_VISIT_STATE_BUTTON_WIDTH;
    }
    
    CGFloat width = textWidthRatio * cellWidth;
    CGFloat storeNameWidth = width;
    // 没有距离的时候，门店名称的宽度需要改变
    if (store.distance.length == 0 && INTERFACE_IS_PHONE) {
        storeNameWidth = (textWidthRatio + 0.25) * cellWidth;
    }
    NSString *storeName = [WSSelectListNewTableviewCell getStoreNameByStoreBean:store];
    
    CGSize  size = [storeName ws_sizeWithFont:[UIFont systemFontOfSize:INTERFACE_IS_PAD ? (UI_SubView_Font + 3):UI_SubView_Font] constrainedToWidth:storeNameWidth lineBreakMode:NSLineBreakByCharWrapping];
    /*门店名称*/
    height += size.height;
    height += 7;
    
    /*门店编码*/
    if (![opt.isCode isEqualToString:@"0"]|| store.attri || store.plan) {
        height += kView_Height;
        height += 7;
    }
    
    CGFloat addrFontSize = INTERFACE_IS_PAD ? UI_SubView_Font:UI_SubView_Detail_Font;
    
    /*门店地址*/
    if (store.addr.length > 0) {
        CGSize addrSize = [store.addr ws_sizeWithFont:[UIFont systemFontOfSize:addrFontSize] constrainedToWidth:storeAddressWidth lineBreakMode:NSLineBreakByCharWrapping];
        height += MAX(addrSize.height, kView_Height);
        height += 7;
    }else{
        //SFA-33992有任意一状态就添加，橙色采集或者未离开店或者已拜访或者本月已访
        if ([store.optName containsString:Month_Visit_State]||[store.optName containsString:Today_Visit_State]||[store.optName containsString:Orange_Visit_State]) {
            height += kView_Height;
        }
    }
    
    /*拜访人员及日期*/
    if ([store.last_man length] > 0) {
        height += kView_Height;
        height += 7;
        
    }
    if ([store.last_date length] > 0) {
        height += kView_Height;
        height += 7;
        
    }
    
    if ([store.last_transaction length] > 0) {
        height += kView_Height;
        height += 7;
        
    }
    
    if ([store.store_month_visit_time length] > 0) {
        height += kView_Height;
        height += 7;
        
    }
    
    if ([store.last_num_q length] > 0) {
        height += kView_Height;
        height += 7;
        
    }
    
    if ([store.last_man length] == 0  && [store.last_date length] == 0 && [store.last_transaction length] ==0  && [store.store_month_visit_time length] ==0 &&((store.actionState &&  ![store.actionState isEqualToString:@"0"])||isHavePrepareButton)){
//        if (!opt.storeListAcvtCode) {  // MN-1746关注按钮
//            height += K_NAV_BUTTON_HEGIHT;
//            height += 7;
//        }
    }
    if ([store.inTime length] > 0) {
        height += [store.inTime ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font] constrainedToWidth:INTERFACE_IS_PHONE ? cellWidth*0.42 : cellWidth*0.75 margin:7.0];
        
    }
    
    if ([store.outTime length] > 0) {
        height += [store.outTime ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font] constrainedToWidth:INTERFACE_IS_PHONE ? cellWidth*0.42 : cellWidth*0.75 margin:7.0];
        
    }
    
    if ([store.instore_time length] > 0) {
        height += [store.instore_time ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font] constrainedToWidth:INTERFACE_IS_PHONE ? cellWidth*0.42 : cellWidth*0.75 margin:7.0];
        
    }
    //SFA-26115
    if (isHavePrepareButton && [[WSSelectListNewTableviewCell new].storeLastDateLabel.text length] > 0) {
        height += kView_Height;
        height += 7;
    } else {
        height += K_NAV_BUTTON_HEGIHT;
    }
    
    if (opt.storeListAcvtCode) {
        NSArray * array = [[[WSBaseAcvtdisDBService alloc]init] queryAcvtDisWithStoreId:store.Id acvtCode:opt.storeListAcvtCode qstType:@"T"];
        if (array.count > 0) {
            CGSize acvtCodeViewSize = [[WSSelectListNewTableviewCell  new] getStoreListAcvtCodeViewHeightWithDisplayArray:array isHavePrepareButton:isHavePrepareButton];
            height += acvtCodeViewSize.height;
        }
        height += 7;
    }
    //    SFA-23144    董宏
    if ((store.actionState.length >0 && ![store.actionState isEqualToString:ActionNotStart])) {
        //        height += K_NAV_BUTTON_HEGIHT;
        //        height += kView_Space_Left;
    }
    
    
    return height;
}
#pragma mark----------------loadlazyView-----
#pragma mark----------------新增月访按钮、橙色门店按钮
- (UIButton*)monthVisitState{
    if (_monthVisitState==nil) {
        _monthVisitState = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_monthVisitState];
        [_monthVisitState mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.storeVisitState.mas_top).offset(-K_VISIT_DIS);
            make.centerX.equalTo(self.storeVisitState);
            make.width.mas_equalTo(K_NAV_BUTTON_WIDHT);
            make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
        }];
        [_monthVisitState setNeedsUpdateConstraints];
        [_monthVisitState setBackgroundImage:[UIImage imageNamed:@"monthlogo"] forState:UIControlStateNormal];
        [_monthVisitState setTitleColor:K_STATUS_GREEN_COLOR forState:UIControlStateNormal];
        [_monthVisitState setTitle:Month_Visit_State forState:UIControlStateNormal];
        _monthVisitState.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
        _monthVisitState.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _monthVisitState.clipsToBounds = YES;
    }
    return _monthVisitState;
}
- (UIButton*)orangeStoresVisitState{
    if (_orangeStoresVisitState==nil) {
        _orangeStoresVisitState = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_orangeStoresVisitState];
        [_orangeStoresVisitState mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-K_VISIT_DIS);
            make.right.equalTo(self.contentView).offset(-kView_Space_Left);
            make.width.mas_equalTo(K_NAV_BUTTON_WIDHT);
            make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
        }];
        [_orangeStoresVisitState setNeedsUpdateConstraints];
        [_orangeStoresVisitState setTitleColor:K_STATUS_ORANGE_COLOR forState:UIControlStateNormal];
        [_orangeStoresVisitState setBackgroundImage:[UIImage imageNamed:@"orangelogo"] forState:UIControlStateNormal];
        [_orangeStoresVisitState setTitle:Orange_Visit_State forState:UIControlStateNormal];
        _orangeStoresVisitState.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
        _orangeStoresVisitState.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _orangeStoresVisitState.clipsToBounds = YES;

    }
    return _orangeStoresVisitState;
}
- (UIButton*)orangeAgreementStoresState{
    if (_orangeAgreementStoresState==nil) {
        _orangeAgreementStoresState = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_orangeAgreementStoresState];
        [_orangeAgreementStoresState mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.monthVisitState.mas_top).offset(-K_VISIT_DIS);
            make.left.equalTo(self.monthVisitState.mas_left);
            make.width.mas_equalTo(K_NAV_BUTTON_WIDHT + 10);
            make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
        }];
        [_orangeAgreementStoresState setNeedsUpdateConstraints];
        [_orangeAgreementStoresState setTitleColor:K_STATUS_YELLOW_COLOR forState:UIControlStateNormal];
        [_orangeAgreementStoresState setBackgroundImage:[UIImage imageNamed:@"bg_status_yellow"] forState:UIControlStateNormal];
        [_orangeAgreementStoresState setTitle:Orange_Agreement_Store forState:UIControlStateNormal];
        _orangeAgreementStoresState.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
        _orangeAgreementStoresState.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -4);
        _orangeAgreementStoresState.clipsToBounds = YES;

    }
    return _orangeAgreementStoresState;
}
#pragma mark-----拜访状态按钮
- (UIButton*)storeVisitState{
    if (_storeVisitState==nil) {
        // 右侧的拜访状态
        _storeVisitState = [UIButton buttonWithType:UIButtonTypeCustom]; // 宽度没设置
        [_storeVisitState setTitleColor:CELL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        [_storeVisitState addTarget:self action:@selector(storeVisitStateClick:) forControlEvents:UIControlEventTouchUpInside]; //MN-288 2018-02-03
        [self.contentView addSubview:_storeVisitState];
        
        [_storeVisitState mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.orangeStoresVisitState.mas_top).offset(-K_VISIT_DIS);
            make.centerX.equalTo(self.orangeStoresVisitState);
            make.width.mas_equalTo(K_NAV_BUTTON_WIDHT);
            make.height.mas_equalTo(K_NAV_BUTTON_HEGIHT);
        }];
        [_storeVisitState setNeedsUpdateConstraints];
        _storeVisitState.clipsToBounds = YES;
        _storeVisitState.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
        _storeVisitState.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _storeVisitState.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    }
    return _storeVisitState;
}
#pragma mark-----准备状态按钮
- (UIButton*)prepareStateBtn{
    if (_prepareStateBtn ==nil) {
        _prepareStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prepareStateBtn addTarget:self action:@selector(readyprepareState) forControlEvents:UIControlEventTouchUpInside];
        _prepareStateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [self.contentView addSubview:_prepareStateBtn];
        _prepareStateBtn.titleLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
        [_prepareStateBtn setTitleColor:K_STATUS_GRAY_COLOR forState:UIControlStateNormal];
        _prepareStateBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        prepareStateBtnYConstraint =  [_prepareStateBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kView_Space_Left];
        [_prepareStateBtn autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.contentView withOffset:-kView_Space_Left];
        prepareStateBtnHeightConstraint = [_prepareStateBtn autoSetDimension:ALDimensionHeight toSize:K_NAV_BUTTON_HEGIHT];
        prepareStateBtnWidthConstraint = [_prepareStateBtn autoSetDimension:ALDimensionWidth toSize:K_NAV_BUTTON_WIDHT];
    }
    return _prepareStateBtn;
}

-(UIButton *)phoneButton{
    if (!_phoneButton) {
        _phoneButton = [UIButton newAutoLayoutView];
        [self.contentView addSubview:self.phoneButton];
        [self.phoneButton autoSetDimension:ALDimensionWidth toSize:24];
        [self.phoneButton autoSetDimension:ALDimensionHeight toSize:24];
        [self.phoneButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:26.0];
        UIImage *telImage = [UIImage imageNamed:@"icon_call"];
        telImage = [telImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _phoneButton.tintColor = MAIN_TINT_COLOR;
        [_phoneButton setImage:telImage forState:UIControlStateNormal];
        [_phoneButton addTarget:self action:@selector(callButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _phoneButton;
}
- (WSSelectScrollListTableViewCell *)scrollListTableViewCell
{
    if (!_scrollListTableViewCell) {
        
        _scrollListTableViewCell = [[WSSelectScrollListTableViewCell alloc] initWithFrame:self.bounds];
    }
    return _scrollListTableViewCell;
}
-(UIView *)storeListAcvtCodeView{
    if (!_storeListAcvtCodeView) {
        _storeListAcvtCodeView = [[UIView alloc]init];
    }
    return _storeListAcvtCodeView;
}

-(UIImageView *)storeQuarterVisitTimeImgView{
    if (!_storeQuarterVisitTimeImgView) {
        _storeQuarterVisitTimeImgView = [[UIImageView alloc]init];
        _storeQuarterVisitTimeImgView.image = [UIImage imageNamed:@"icon_tag_grey"];
    }
    return _storeQuarterVisitTimeImgView;
}

-(UILabel *)storeQuarterVisitTimeLable{
    if (!_storeQuarterVisitTimeLable) {
        _storeQuarterVisitTimeLable = [[UILabel alloc]init];
        _storeQuarterVisitTimeLable.textColor = CELL_DETAIL_TEXTCOLOR;
        _storeQuarterVisitTimeLable.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font10or15];
        // _storeQuarterVisitTimeLable.text = @"当季拜访次数:12";
    }
    return _storeQuarterVisitTimeLable;
}
@end
