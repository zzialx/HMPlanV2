//
//  WSCallPlanTableViewCell.m
//  WinSFA
//
//  Created by winchannel on 2017/1/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCallPlanTableViewCell.h"
#import "NSString+Additions.h"
#import "WSHttpURLHelper.h"
#import "WSStoreBean+Plan.h"
#import "NSString+ServerUrl.h"
#import "WSRequestHelper.h"
#import "WSShowQstViewForStoreListCell.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSCallPlanViewController.h"


#define kSelectBtnWidth 33.0f
#define kLabelLeftGap 5.0f
#define kStoreNameLabelTopGap 5.0f
#define kSelectBtnLeftSapce 8.0f
#define kVisitCountLabelHeight 22.0f
#define kStoreNameLabelHeight 20.0f
#define kStoreNameLabelRightSpace 20.0f
#define kStoreNameLabelBottomSpace 5.0f
#define kStoreCodeLabelHeight 15.0f
#define kOtherRedisLabelHeight 15.0f
#define kSelectBtnRightSpace 10.0f
#define kNumberLabelLeftGap 8.0f
#define KNumberlabelWith 20.0f
#define KStoreStateViewWidth 15
#define KStoreTypeViewWidth 20
#define KStoreTypeViewHeight 15
#define KStoreAttriViewSapce 5

#define UI_SubView_Detail_Font (INTERFACE_IS_PHONE ? 10.0f : 15.0f)
#define K_NAV_BUTTON_WIDHT (INTERFACE_IS_PHONE ? 60 : 85)



@interface WSCallPlanTableViewCell (){
    WSCallPlanTableViewCellStyle funcstyle;
    CGRect rightAccessoryViewFrame;
    NSObject<I_W_Cell> *_storeBean;
    //NSString *_seialNumberStr;
    NSString *_visitedSubStores;
    //NSString *_visitedCount;
    
}

@property (nonatomic , strong) WSBaseAcvtdisDBService *acvtdisService;
@property (nonatomic , copy) NSString *acvtCode; // opt 中的storeListAcvtCode
@property (nonatomic, assign) CGFloat storeListAcvtCodeHeight;
@property (nonatomic, strong) UIView *lastBottomView;
@property (nonatomic , strong) NSArray * storeListAcvtCodeArray;

@end

@implementation WSCallPlanTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSCallPlanTableViewCellStyle)funcStyle{
    
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier withFuncStyle:funcStyle withvisitedSubStores:nil];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFuncStyle:(WSCallPlanTableViewCellStyle)funcStyle withvisitedSubStores:(NSString *)visitedSubStores{
    
    funcstyle = funcStyle;
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _visitedSubStores = visitedSubStores;
        //_visitedCount = visitedCount;
    }

    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSLog(@"--------------------%@", self);
    
    if (_storeBean) {
        [self resetSubviews];
    }
}

- (void)setStore:(NSObject<I_W_Cell> *)store withOpt:(WSFuncsBean_opt *)opt{
    [self setSb:store];
    if (opt.storeListAcvtCode.length > 0) {
        _acvtCode = opt.storeListAcvtCode;
    }
}

- (void)setSb:(NSObject<I_W_Cell> *)sb{
    _storeBean = sb;
}

- (void)setSubViews{
    
    UIView* lineView=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, self.width, 1)];
    lineView.backgroundColor= [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1];
    lineView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:lineView];
    
    rightAccessoryViewFrame = CGRectMake(self.width - kSelectBtnWidth - kSelectBtnRightSpace, (self.height - kSelectBtnWidth)/2.0, kSelectBtnWidth, kSelectBtnWidth);
    
    UIButton *selectedBtn = [[UIButton alloc]initWithFrame:rightAccessoryViewFrame];
    selectedBtn.backgroundColor = [UIColor clearColor];
    [selectedBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [selectedBtn setImage:[UIImage scaledImageForName:@"check_false" ofType:@"png"] forState:UIControlStateNormal];
    [selectedBtn setImage:[UIImage scaledImageForName:@"check_true" ofType:@"png"] forState:UIControlStateSelected];
    selectedBtn.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin;
    self.selectedNoteButton = selectedBtn;
    [self.contentView addSubview:selectedBtn];
    
    UILabel *serialNumberlabel = [[UILabel alloc]initWithFrame:CGRectMake(kNumberLabelLeftGap, (self.height - KNumberlabelWith)/2.0, KNumberlabelWith, KNumberlabelWith)];
    serialNumberlabel.backgroundColor = [UIColor clearColor];
    serialNumberlabel.textColor = [UIColor grayColor];
    serialNumberlabel.textAlignment = NSTextAlignmentCenter;
    serialNumberlabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [serialNumberlabel setFont:[UIFont systemFontOfSize:14]];
    self.serialNumberlabel = serialNumberlabel;
    [self.contentView addSubview:serialNumberlabel];
    
    UILabel *storeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(serialNumberlabel.right + kLabelLeftGap, kStoreNameLabelTopGap, rightAccessoryViewFrame.origin.x -serialNumberlabel.right  - 2*kLabelLeftGap - KStoreStateViewWidth, kStoreNameLabelHeight)];
    storeNameLabel.backgroundColor = [UIColor clearColor];
    storeNameLabel.numberOfLines = 0;
    storeNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    storeNameLabel.textAlignment = NSTextAlignmentLeft;
    [storeNameLabel setFont:[UIFont systemFontOfSize:14]];
    storeNameLabel.autoresizingMask=UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth ;
    self.storeNameLabel = storeNameLabel;
    [self.contentView addSubview:storeNameLabel];
    
    
    UIImageView *stateView = [[UIImageView alloc]initWithFrame:CGRectMake(storeNameLabel.right ,kStoreNameLabelTopGap , KStoreStateViewWidth, KStoreStateViewWidth)];
    stateView.backgroundColor = [UIColor whiteColor];
    self.storeStateView = stateView;
    [self.contentView addSubview:stateView];
    
    
    UILabel *storeCodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(serialNumberlabel.right + kLabelLeftGap, storeNameLabel.bottom + kStoreNameLabelBottomSpace ,rightAccessoryViewFrame.origin.x - serialNumberlabel.right -2* kLabelLeftGap - KStoreStateViewWidth, kStoreCodeLabelHeight)];
    storeCodeLabel.backgroundColor = [UIColor clearColor];
    storeCodeLabel.textColor = [UIColor grayColor];
    storeCodeLabel.textAlignment = NSTextAlignmentLeft;
    storeCodeLabel.numberOfLines = 1;
    storeCodeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [storeCodeLabel setFont:[UIFont systemFontOfSize:13]];
    storeCodeLabel.autoresizingMask=UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth ;
    self.storeCodeLabel = storeCodeLabel;
    [self.contentView addSubview:storeCodeLabel];
    self.lastBottomView = storeCodeLabel;
    
    UIScrollView *storeAttriView = [[UIScrollView alloc]initWithFrame:CGRectMake(storeCodeLabel.right ,storeCodeLabel.top ,rightAccessoryViewFrame.origin.x - storeCodeLabel.right  , KStoreTypeViewHeight)];
    storeAttriView.backgroundColor = [UIColor whiteColor];
    [storeAttriView setShowsHorizontalScrollIndicator:NO];
    self.attriView = storeAttriView;
    [self.contentView addSubview:storeAttriView];

    if (funcstyle == WSCallPlanTableViewCellStyleVisitSubempStore){
        [self.selectedNoteButton removeFromSuperview];
        
        UILabel *visitSubStoresLabel =[[UILabel alloc]initWithFrame:CGRectMake(self.width - 22 - kSelectBtnRightSpace, (self.height - 22)/2.0, 22, 22)];
        visitSubStoresLabel.backgroundColor = [UIColor colorWithRed:0.96f green:0.40f blue:0.40f alpha:1.00f];
        [visitSubStoresLabel setFont:[UIFont systemFontOfSize:12]];
        visitSubStoresLabel.textColor = [UIColor whiteColor];
        visitSubStoresLabel.textAlignment = NSTextAlignmentCenter;
        visitSubStoresLabel.layer.cornerRadius = 22 / 2.0;
        visitSubStoresLabel.clipsToBounds = YES;
        visitSubStoresLabel.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin;
        self.visitSubStoresLabel = visitSubStoresLabel;
        [self.contentView addSubview:visitSubStoresLabel];
    }
    else if (funcstyle == WSCallPlanTableViewCellStyleVisitCount){
        
        NSString *visitCount = @"已拜访1次";
        CGSize countSize = [visitCount ws_sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToWidth:self.width];
        countSize.width += 5;
        
        UILabel *visitCountLabel = [[UILabel alloc]initWithFrame:CGRectMake( selectedBtn.left - countSize.width - kSelectBtnLeftSapce  , (self.height - kVisitCountLabelHeight)/2.0, countSize.width, kVisitCountLabelHeight)];
        visitCountLabel.backgroundColor = [UIColor clearColor];
        visitCountLabel.textColor = [UIColor grayColor];
        visitCountLabel.textAlignment = NSTextAlignmentCenter;
        [visitCountLabel setFont:[UIFont systemFontOfSize:13]];
         visitCountLabel.autoresizingMask= UIViewAutoresizingFlexibleLeftMargin;
        self.storeVisitCountLabel = visitCountLabel;
        [self.contentView addSubview:visitCountLabel];
        
        self.storeNameLabel.frame = CGRectMake(serialNumberlabel.right + kLabelLeftGap, kStoreNameLabelTopGap, visitCountLabel.left -serialNumberlabel.right  - 2*kLabelLeftGap - KStoreStateViewWidth, kStoreNameLabelHeight);
        
        self.storeCodeLabel.frame = CGRectMake(serialNumberlabel.right + kLabelLeftGap, storeNameLabel.bottom + kStoreNameLabelBottomSpace, visitCountLabel.left -serialNumberlabel.right  - 2*kLabelLeftGap - KStoreStateViewWidth, kStoreCodeLabelHeight);

    }
    else if (funcstyle == WSCallPlanTableViewCellStyleRedisOther){
        
        UILabel *redisOtherLabel = [[UILabel alloc]initWithFrame:CGRectMake(serialNumberlabel.right + kLabelLeftGap, storeCodeLabel.bottom + kStoreNameLabelBottomSpace, rightAccessoryViewFrame.origin.x - serialNumberlabel.right -2* kLabelLeftGap - KStoreStateViewWidth, 0.0)];
        redisOtherLabel.backgroundColor = [UIColor clearColor];
        redisOtherLabel.textColor = [UIColor grayColor];
        redisOtherLabel.textAlignment = NSTextAlignmentLeft;
        [redisOtherLabel setFont:[UIFont systemFontOfSize:13]];
        redisOtherLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.redisOtherLabel = redisOtherLabel;
        [self.contentView addSubview:redisOtherLabel];
        
    }
     [self addStoreListAcvtCodeView];
}

- (void)resetSubviews
{
    [self.contentView removeAllSubviews];
    [self setSubViews];
    
    if (funcstyle == WSCallPlanTableViewCellStyleRedisOther) {
//        self.storeNameLabel.text = [NSString stringWithFormat:@"%@-%@", [_storeBean getCode], [_storeBean getName]];
        self.redisOtherLabel.text = self.redisOtherSubtitle;
    }
//    else{
        self.storeNameLabel.text = [_storeBean getName];
        self.storeCodeLabel.text = [_storeBean getCode];
//    }
    

    self.serialNumberlabel.text = nil;
    self.storeVisitCountLabel.text = nil;
    self.storeStateView.image = nil;
    
//    CGFloat storeNameWidth = rightAccessoryViewFrame.origin.x -self.serialNumberlabel.right  - 2*kLabelLeftGap - KStoreStateViewWidth;
//    if (funcstyle == WSCallPlanTableViewCellStyleVisitCount) {
//        storeNameWidth = self.storeVisitCountLabel.left - self.serialNumberlabel.right  - 2*kLabelLeftGap - KStoreStateViewWidth;
//    }
    
    NSLog(@" contenviewWidth = %f",self.width);
    CGFloat rightAccessoryViewMinX = self.width - kSelectBtnWidth - kSelectBtnRightSpace;
    CGFloat serialNumberlabelMaxX = kNumberLabelLeftGap + KNumberlabelWith;
    CGFloat storeNameWidth = rightAccessoryViewMinX - serialNumberlabelMaxX - 2*kLabelLeftGap - KStoreStateViewWidth;
    
    if (funcstyle == WSCallPlanTableViewCellStyleVisitCount) {
        NSString *visitCount = @"已拜访1次";
        CGSize countSize = [visitCount ws_sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToWidth:self.width];
        countSize.width += 5;
        
        CGFloat visitCoutLabelMinX = rightAccessoryViewMinX - countSize.width - kSelectBtnLeftSapce;
        
        storeNameWidth = visitCoutLabelMinX - serialNumberlabelMaxX  - 2*kLabelLeftGap - KStoreStateViewWidth;
    }
    
    CGSize storeNameSize = [self.storeNameLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:storeNameWidth lineBreakMode:NSLineBreakByCharWrapping];
    CGSize storeCodeSize = [self.storeCodeLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:storeNameWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    self.storeNameLabel.frame = CGRectMake(self.serialNumberlabel.right + kLabelLeftGap, kStoreNameLabelTopGap, storeNameSize.width, storeNameSize.height);
    [self.storeCodeLabel setTop:self.storeNameLabel.bottom + kStoreNameLabelBottomSpace];
    [self.storeCodeLabel setSize:storeCodeSize];
    
    if (funcstyle == WSCallPlanTableViewCellStyleRedisOther) {
        if (self.redisOtherLabel.text && self.redisOtherLabel.text.length > 0) {
            self.redisOtherLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [self.redisOtherLabel setSize:CGSizeMake(storeNameWidth, kOtherRedisLabelHeight)];
            self.lastBottomView = self.redisOtherLabel;

        }

    }
    
    self.storeStateView.frame = CGRectMake(self.storeNameLabel.right, self.storeNameLabel.top, self.storeStateView.width, self.storeStateView.height);
    
    CGFloat attriViewWidth = 0.0 ;
    if (funcstyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
        attriViewWidth = self.visitSubStoresLabel.left - _storeCodeLabel.right;
    }else if (funcstyle == WSCallPlanTableViewCellStyleVisitCount){
        attriViewWidth = _storeVisitCountLabel.left - _storeCodeLabel.right;
    }else{
        attriViewWidth = _selectedNoteButton.left - _storeCodeLabel.right;
    }
    self.attriView.frame = CGRectMake(self.storeCodeLabel.right, self.storeCodeLabel.top, attriViewWidth, self.attriView.height);


    if ([_storeBean isKindOfClass:[WSStoreBean class]]) {
        WSStoreBean *tempStore = (WSStoreBean *)_storeBean;
        if (tempStore.stateUrl.length > 0) {
             NSString *imageStr = [WSHttpURLHelper getImageCompleteURL:tempStore.stateUrl];
            [[WSRequestHelper shareInstance] downloadImageWithUrl:imageStr imageView:self.storeStateView];
        }
        if (tempStore.attri && tempStore.attri.length >0) {
            CGFloat imgX = 0;
            NSArray *storeImages = [tempStore.attri componentsSeparatedByString:@","];
            for (int i = 0; i  < storeImages.count; i ++) {
                NSString *imgURLstr = [storeImages[i] buildupUrl];
                imgX = i * (KStoreTypeViewWidth + KStoreAttriViewSapce);
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, 0, KStoreTypeViewWidth , KStoreTypeViewHeight)];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [_attriView addSubview:imageView];
                if ([imgURLstr hasSuffix:@"png"]||[imgURLstr hasSuffix:@"jpg"]) {
                    
                    [[WSRequestHelper shareInstance] downloadImageWithUrl:imgURLstr imageView:imageView];
                }
                else
                {
                    if([storeImages[i] containsString:@"icon"])
                    {
                        imageView.image = [UIImage imageNamed: storeImages[i]];
                    }
                    else
                    {
                        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", storeImages[i]]];
                        
                    }
                }
                self.attriView.contentSize = CGSizeMake((KStoreTypeViewWidth + KStoreAttriViewSapce)*storeImages.count, KStoreTypeViewHeight);
            }
        }
       
    }
    
    if ([_storeBean isKindOfClass:[WSStoreBean class]]) {
        WSStoreBean *sb = (WSStoreBean *)_storeBean;
        [self.selectedNoteButton setSelected:sb.bPlanned];
        if (sb.bPlanned == YES) {
            self.serialNumberlabel.text = _seialNumberStr;
        }
    }else{
        WSSubempstoreBean *sb = (WSSubempstoreBean *)_storeBean;
        [self.selectedNoteButton setSelected:sb.bPlanned];
        if (sb.bPlanned == YES) {
            self.serialNumberlabel.text = _seialNumberStr;
        }
    }
    if (funcstyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
        if (_visitedSubStores && _visitedSubStores.length > 0) {
            self.visitSubStoresLabel.text = _visitedSubStores;
            self.serialNumberlabel.text = _seialNumberStr;
        }
    }else if (funcstyle == WSCallPlanTableViewCellStyleVisitCount){
        self.storeVisitCountLabel.text =  _visitCount;
    }

    [self.storeListAcvtCodeView setTop:self.lastBottomView.bottom + kStoreNameLabelBottomSpace];
    [self.storeListAcvtCodeView setHeight:self.storeListAcvtCodeHeight];
}

- (void)btnClick:(id)sender{
    
    NSDictionary *otherParams = nil;
    NSString *storeId = [_storeBean getId];
    if (storeId) {
        otherParams = @{@"storeId":storeId};
    }
    if ([_storeBean getCode] && [_storeBean getCode].length > 0 ) {
        [self.delegate didSelectedWithStoreCode:[_storeBean getCode] otherParams:otherParams];
    }else if ([_storeBean getName] && [_storeBean getName].length > 0){
        [self.delegate didSelectedWithStoreCode:[_storeBean getName] otherParams:otherParams];
    }
}
#pragma mark- 获取StoreListAcvtCodeView 的高度  TO DO
- (CGFloat)getStoreListAcvtCodeViewHeightWithDisplayArray:(NSArray *)array
{
    BOOL isHorizontal = NO;
    CGFloat HWidth = 0;
    CGFloat acvtCodeViewHeight = 0;
    CGFloat maxWidth = rightAccessoryViewFrame.origin.x - self.serialNumberlabel.right -2* kLabelLeftGap - KStoreStateViewWidth;
        for (WSShowQstViewSingleLineModel * tempModel in array) {
            NSString *titileString = [WSShowQstViewForStoreListCell getTitleString:tempModel];
            UIFont *titleFont = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
            if ([tempModel.groupName hasPrefix:@"horizontal"]) {
                if(!isHorizontal) {
                    if (HWidth > maxWidth) {
                        isHorizontal = NO;
                    } else {
                        isHorizontal = YES;
                    }
                    CGFloat titleWidth = [titileString ws_sizeWithFont:titleFont constrainedToHeight:kView_Height].width;
                    HWidth += titleWidth + 7;
                    acvtCodeViewHeight += kView_Height + 7;
                }
                
            } else {
                CGFloat titleHeight= [titileString ws_sizeWithFont:titleFont constrainedToWidth:maxWidth].height;
                acvtCodeViewHeight += (titleHeight > kView_Height ? titleHeight : kView_Height) + 7;
            }
        }
    return acvtCodeViewHeight;
}
- (CGFloat)heightForRowWithStore:(NSObject<I_W_Cell> *)aStore WithCellWidth:(CGFloat)cellWidth withFuncStyle:(WSCallPlanTableViewCellStyle)funcStyle{
    
    NSArray *array = [self.acvtdisService queryAcvtDisWithStoreId:[_storeBean getId] acvtCode:_acvtCode qstType:@"T"];
    self.storeListAcvtCodeArray = array;
    
    CGFloat viewHeight = 0;
    if (self.storeListAcvtCodeArray.count > 0) {
      viewHeight +=[self getStoreListAcvtCodeViewHeightWithDisplayArray:self.storeListAcvtCodeArray];
    }
    self.storeListAcvtCodeHeight = viewHeight;
    NSString *storeName = [aStore getName];
    NSString *storeCode = [aStore getCode];

    CGFloat rightAccessoryViewMinX = cellWidth - kSelectBtnWidth - kSelectBtnRightSpace;
    CGFloat serialNumberlabelMaxX = kNumberLabelLeftGap + KNumberlabelWith;
    CGFloat storeNameWidth = rightAccessoryViewMinX - serialNumberlabelMaxX - 2*kLabelLeftGap - KStoreStateViewWidth;

    if (funcStyle == WSCallPlanTableViewCellStyleVisitCount) {
        NSString *visitCount = @"已拜访1次";
        CGSize countSize = [visitCount ws_sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToWidth:cellWidth];
        countSize.width += 5;
        
        CGFloat visitCoutLabelMinX = rightAccessoryViewMinX - countSize.width - kSelectBtnLeftSapce;
        
        storeNameWidth = visitCoutLabelMinX - serialNumberlabelMaxX  - 2*kLabelLeftGap - KStoreStateViewWidth;
    }
    
//    self ws_sizeWithFont:font constrainedToWidth:width lineBreakMode:NSLineBreakByWordWrapping
    CGSize storeNameSize = [storeName ws_sizeWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:storeNameWidth lineBreakMode:NSLineBreakByCharWrapping];
    CGSize storeCodeSize = [storeCode ws_sizeWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:storeNameWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat cellHeight = storeNameSize.height + storeCodeSize.height;
    if ([storeCode isEqualToString:@"NEW-18167"]) {
        NSLog(@"storeCode  ======= ");
    }
    return  cellHeight + kStoreNameLabelTopGap * 3 + self.storeListAcvtCodeHeight + kStoreNameLabelTopGap;
    
//    if (cellHeight < 40) {
//        return INTERFACE_IS_PAD ? 60:50;
//    }else{
//
//        return cellHeight + 15;
//    }

}

-(UIView *)storeListAcvtCodeView{
    if (!_storeListAcvtCodeView) {
        _storeListAcvtCodeView = [[UIView alloc]init];
    }
    return _storeListAcvtCodeView;
}

-(WSBaseAcvtdisDBService *)acvtdisService{
    if (!_acvtdisService) {
        _acvtdisService = [[WSBaseAcvtdisDBService alloc]init];
    }
    return _acvtdisService;
}

// SFA-23593 IOS：SFA立白【经销商】拜访计划设置优化需求-逾期天数手机端展示开发
-(void)addStoreListAcvtCodeView{
    [self.storeListAcvtCodeView removeAllSubviews];
    self.storeListAcvtCodeView = nil;
    if (self.storeListAcvtCodeArray.count == 0) {
        return;
    }
    [self.contentView addSubview:self.storeListAcvtCodeView];
    // SaaS蒙牛智网行动-经销商运营系统   MN-31
    WSShowQstViewForStoreListCellModel * viewModel = [[WSShowQstViewForStoreListCellModel alloc]init];
    viewModel.titleFont = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
    viewModel.displayArray = self.storeListAcvtCodeArray;
    
    /*
     WSShowQstViewSingleLineModel * lineModel = [[WSShowQstViewSingleLineModel alloc]init];
     lineModel.qstname = @"逾期1天";
     lineModel.qstanwser = @"@#FFF02D71";
     lineModel.qstdisplaymodel = @"BN";
     lineModel.groupName = @"horizontal";
     lineModel.hideQstName = @"0";
     WSShowQstViewSingleLineModel * lineModel2 = [[WSShowQstViewSingleLineModel alloc]init];
     lineModel2.qstname = @"问题名称1";
     lineModel2.qstanwser = @"66@FFFF00@新鲜度";
     lineModel2.qstdisplaymodel = @"BNICON";
     lineModel2.groupName = @"horizontal";
     lineModel2.hideQstName = @"0";
     WSShowQstViewSingleLineModel * lineModel3 = [[WSShowQstViewSingleLineModel alloc]init];
     lineModel3.qstname = @"问题名称2";
     lineModel3.qstanwser = @"url@FF00FF";
     lineModel3.qstdisplaymodel = nil;
     lineModel3.groupName = nil;
     //    lineModel3.hideQstName = @"1";
     
     WSShowQstViewForStoreListCellModel * viewModel = [[WSShowQstViewForStoreListCellModel alloc]init];
     viewModel.titleFont = [UIFont systemFontOfSize:UI_SubView_Detail_Font];
     viewModel.displayArray = @[lineModel,lineModel2,lineModel3];
     
     */
    
    //    MN-3208
    //    CLONE - 蒙牛（ios）-拜访-门店列表-欠款图标样式开发
    //    CGFloat viewHeight = 0;
    //    if (viewModel.displayArray.count > 0) {
    //        for (WSShowQstViewSingleLineModel * tempModel in viewModel.displayArray) {
    //            if ([tempModel.groupName hasPrefix:@"horizontal"]) {
    //                viewHeight = kView_Height;
    //            } else {
    //                viewHeight += kView_Height + 7;
    //            }
    //        }
    //    }
    //    self.storeListAcvtCodeHeight = viewHeight;
    
    CGFloat storeListAcvtCodeViewWidth = rightAccessoryViewFrame.origin.x - self.serialNumberlabel.right -2* kLabelLeftGap - KStoreStateViewWidth;
  
    self.storeListAcvtCodeView.frame = CGRectMake(self.serialNumberlabel.right + kLabelLeftGap, self.lastBottomView.bottom + kStoreNameLabelBottomSpace ,storeListAcvtCodeViewWidth, kStoreCodeLabelHeight);
    
    
    
    BOOL isHorizontal = NO;
    if (self.storeListAcvtCodeArray.count > 0) {
        //SFA-24364
        NSMutableArray *horizontalDisplayArray = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *verticalDisplayArray = [NSMutableArray arrayWithCapacity:10];
        for (WSShowQstViewSingleLineModel * tempModel in self.storeListAcvtCodeArray) {
            if ([tempModel.groupName hasPrefix:@"horizontal"]) {
                isHorizontal = YES;
                [horizontalDisplayArray addObject:tempModel];
            } else {
                [verticalDisplayArray addObject:tempModel];
            }
        }
        viewModel.horizontalDisplayArray = horizontalDisplayArray;
        viewModel.verticalDisplayArray = verticalDisplayArray;
    }
    NSString *tagBottom = nil;
    if ([self.delegate isKindOfClass:[WSCallPlanViewController class]]) {
        WSCallPlanViewController * call = (WSCallPlanViewController*)self.delegate;
        tagBottom = call.currentFuncs.opt.tagBottom;
    }
    
    WSShowQstViewForStoreListCell * view = [[WSShowQstViewForStoreListCell alloc]initWithFrame:CGRectMake(0, 0,self.storeListAcvtCodeView.width, self.storeListAcvtCodeHeight) withModel:viewModel isHasQstHorizontal:isHorizontal tagBottom:tagBottom];
    [self.storeListAcvtCodeView addSubview:view];
    
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
