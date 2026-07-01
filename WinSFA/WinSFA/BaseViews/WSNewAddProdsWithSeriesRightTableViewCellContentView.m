//
//  WSNewAddProdsWithSeriesRightTableViewCellContentView.m
//  WinSFA
//
//  Created by HZH on 2017/12/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNewAddProdsWithSeriesRightTableViewCellContentView.h"
#import "WSAcvtScrollView.h"
#import "WSAcvtView.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSTableItem.h"
#import "WSNewAddProdsWithSeriesRightTableViewCell.h"
#import "WSNewAddProdsWithSeriesModel.h"
#import "WSBaseDropListPanel.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "I_W_DataSource.h"
#import "WSTextViewPanel.h"

#define hImageViewLeftOrRightPadding 10.0
#define hImageViewTopOrBottomPadding 10.0

#define hTitleViewLeftOrRightPadding 10.0
#define hTitleViewTopOrBottomPadding 10.0

#define hCheckboxViewLeftOrRightPadding 10.0
#define hCheckboxViewTopOrBottomPadding 10.0

#define hFoldBtnViewHeight 0.0
#define hImageViewHeight   60.0
#define hProdNameTitleViewHeight   35.0
#define hProdDetailSubtitleViewHeight   20.0
#define hCheckboxImageViewHeight 20.0

#define hCollectBannerViewHeight 20.0
#define hStarImageViewLeftOrRightPadding 2.5
#define hStarImageViewTopOrBottomPadding 2.5

#define hStarButtonLeftPadding 15
#define hStarButtonRightPadding 13
#define hStarLableWidth 25

#define kProdNameTitleColor        ([UIColor colorForKey:@"ProdNameTitle"] ? [UIColor colorForKey:@"ProdNameTitle"] : MAIN_TEXT_COLOR)
#define kProdNameTitleFont           ([UIFont fontForKey:@"ProdNameTitle"] ? [UIFont fontForKey:@"ProdNameTitle"] : FONT_SIZE_PINGFANG_REGULAR(12.0))

@interface WSNewAddProdsWithSeriesRightTableViewCellContentView () <WSAcvtViewDelegate>

@property (nonatomic, strong) WSAcvtBean *currentAcvtBean;
@property (nonatomic, strong) WSAcvtView  *acvtview;
@property (nonatomic, strong) UIImageView *prodImageView;
@property (nonatomic, strong) UILabel *prodNameTitleLabel;
@property (nonatomic, strong) UILabel *prodDetailSubtitleLabel;
@property (nonatomic, strong) UIButton *foldBtn;
@property (nonatomic, strong) UIImageView *checkboxImageView;
@property (nonatomic, strong) NSArray *allNeedParamsArray;
@property (nonatomic, strong) UIView *secondPartContentView;
@property (nonatomic, strong) WSAcvtModel *currentAcvtModel;
@property (nonatomic, strong) WSWidget *prodIdWidget;

@property (nonatomic, strong) UIButton *starButton;
@property (nonatomic, strong) UILabel *starLabel;
@property (nonatomic, assign) BOOL isCollected;
//商品没有被收藏的图片名称
@property (nonatomic, copy) NSString *unCollectedImageName;
//商品有被收藏的图片名称
@property (nonatomic, copy) NSString *colllectedImageName;

@property (nonatomic, assign) CGFloat prodContentHeight;

@end

@implementation WSNewAddProdsWithSeriesRightTableViewCellContentView

- (instancetype)initWithFrame:(CGRect)frame andAllNeedParams:(NSArray *)paramsArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _allNeedParamsArray = paramsArray;
        
    }
    
    return self;
}

- (void)setupSubviews
{
    self.unCollectedImageName = [self.currentTableItem.opt.isCollectionStyle isEqualToString:FUNCS_OPT_IS_COLLECTION_IMG] ? @"icon_star_empty":@"icon_star_unchecked";
    self.colllectedImageName = [self.currentTableItem.opt.isCollectionStyle isEqualToString:FUNCS_OPT_IS_COLLECTION_IMG]?@"icon_star" :@"icon_star_checked";
    [self initWithProdStyleWithString:self.currentTableItem.opt.isCollectionStyle];
    
    _checkboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - hCheckboxViewLeftOrRightPadding - hCheckboxImageViewHeight, hCheckboxViewTopOrBottomPadding, hCheckboxImageViewHeight, hCheckboxImageViewHeight)];
    [_checkboxImageView setImage:[UIImage imageNamed:@"icn_nocheck"]];
    
    [self addSubview: _checkboxImageView];
    
    CGFloat titleLabelWidth = self.frame.size.width - (hImageViewLeftOrRightPadding + hFoldBtnViewHeight + hImageViewLeftOrRightPadding + hImageViewHeight + hTitleViewLeftOrRightPadding + hCheckboxViewLeftOrRightPadding * 2 + hCheckboxImageViewHeight);
    
    self.prodNameTitleLabel.text = _prodBean.name;
    
    // SFA益海嘉里YIHAIKERRY-4296 产品添加页面字体加大加粗后，产品名称显示不全 (动态的计算产品名称的高)
    CGFloat prodNameTitleWidth = (CGRectGetMaxX(self.prodImageView.frame) + hCheckboxViewLeftOrRightPadding * 3 + hCheckboxImageViewHeight + hTitleViewLeftOrRightPadding *2);
    CGSize labelSize = [self.prodNameTitleLabel.text boundingRectWithSize:CGSizeMake(prodNameTitleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.prodNameTitleLabel.font} context:nil].size;
    self.prodNameTitleLabel.height = labelSize.height > 0 ? labelSize.height : hProdNameTitleViewHeight ;
    CGFloat prodNameTitleAndSubTitleHeight = labelSize.height + hProdNameTitleViewHeight;
    self.prodContentHeight = hImageViewHeight > prodNameTitleAndSubTitleHeight ? hImageViewHeight: prodNameTitleAndSubTitleHeight;

    
    _prodDetailSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(hImageViewLeftOrRightPadding + hFoldBtnViewHeight + hImageViewLeftOrRightPadding + hImageViewHeight + hTitleViewLeftOrRightPadding, CGRectGetMaxY(self.prodNameTitleLabel.frame), titleLabelWidth, hProdNameTitleViewHeight)];
    
    _prodDetailSubtitleLabel.textColor = [UIColor darkGrayColor];
    _prodDetailSubtitleLabel.font = FONT_SIZE_PINGFANG_REGULAR(11.0);
    _prodDetailSubtitleLabel.numberOfLines = 2;
    //    _prodDetailSubtitleLabel.text = [NSString stringWithFormat:@"1件   3盒   25.05元"];
    
    [self addSubview:_prodDetailSubtitleLabel];
    
    
    if (_currentTableItem.opt.hNewStyleProdSelect.length > 0 && [_currentTableItem.opt.hNewStyleProdSelect isEqualToString:@"1"]) {
        _foldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_foldBtn setFrame:CGRectMake(hImageViewLeftOrRightPadding, hImageViewTopOrBottomPadding, hFoldBtnViewHeight, hFoldBtnViewHeight)];
        UIImage *checkImage = [UIImage imageNamed:@"brand_checked"];
        UIImage *uncheckImage = [UIImage imageNamed:@"brand_unchecked"];
        
        [_foldBtn setImage:uncheckImage forState:UIControlStateNormal];
        [_foldBtn setImage:checkImage forState:UIControlStateSelected];
        [_foldBtn addTarget:self action:@selector(foldComView:) forControlEvents:UIControlEventTouchUpInside];
        _foldBtn.selected = NO;
        //        [self addSubview:_foldBtn];
        
        _currentAcvtModel = [self getAcvtModelWithProdBean:_prodBean];
        
        [WSDataSourceManager sharedInstance].currentActiveModel = _currentAcvtModel;
        
        //    _contentScrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(0.0, hImageViewTopOrBottomPadding * 3 + hImageViewHeight, self.frame.size.width, self.frame.size.height) andAcvtBean:_currentAcvtModel.currentAcvtBean];
        //    _contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.acvtview = [[WSAcvtView alloc] initWithFrame:CGRectMake(0.0, hImageViewTopOrBottomPadding * 2 + self.prodContentHeight, self.frame.size.width, self.frame.size.height) andAcvtBean:_currentAcvtModel.currentAcvtBean qstArray:nil];
        //    self.acvtView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        //    self.acvtview = _contentScrollView.acvtView;
        //    [self.acvtview checkAndExecuteAcvtLuaScript];
        

        // MN-2441 未显示的时候不需要执行脚本
        //        [self.acvtview buildDisplayContent];

        // MN-2441 挪动到显示的时候调用
//        [self.acvtview buildDisplayContent];
    

        //        for (WSWidget *widget in self.acvtview.widgetArray) {
        //            WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];
        //
        //            if ([qst.qstId isEqualToString:@"prodId"]) {
        //                _prodIdWidget = widget;
        //                break;
        //            }
        //        }

//        for (WSWidget *widget in self.acvtview.widgetArray) {
//            WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];
//
//            if ([qst.qstId isEqualToString:@"prodId"]) {
//                _prodIdWidget = widget;
//                break;
//            }
//        }

        
        for (WSWidget *widget in self.acvtview.widgetArray) {
            WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];
            
            if ([qst.qstId isEqualToString:@"prodId"]) {
                _prodIdWidget = widget;
                break;
            }
        }
        
        self.acvtview.acvtViewDelegate = self;
        
        [self addSubview:self.acvtview];
        
        self.acvtview.hidden = YES;
        
        [self resetFrame];
    }
    
    //    _rightTableModel.cellRealHeight = self.frame.size.height;
    //
    //    if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellDataModelValueIsChanged)]) {
    //        [self.cellContentViewDelegate cellDataModelValueIsChanged];
    //    }
}

#pragma mark 商品显示样式
- (void) initWithProdStyleWithString : (NSString *) collectionStyle
{
    UIImage *starImage = [UIImage imageNamed:self.unCollectedImageName];
    CGSize starImageSize = starImage.size;
    
    
    if ([collectionStyle isEqualToString:FUNCS_OPT_IS_COLLECTION_IMG]) {
        
        self.starButton.frame = CGRectMake(hStarButtonLeftPadding, hTitleViewTopOrBottomPadding, starImageSize.width, starImageSize.height);
        
        self.starLabel.frame = CGRectMake(hStarButtonRightPadding, self.starButton.height+hTitleViewTopOrBottomPadding+5, hStarLableWidth, 10);
        [self addSubview:self.starLabel];
        
        self.prodNameTitleLabel.frame = CGRectMake(hStarButtonLeftPadding+self.starButton.width+hStarButtonLeftPadding, hTitleViewTopOrBottomPadding, 180, hProdNameTitleViewHeight);
    }
    else{
        //商品图片
        self.prodImageView.frame = CGRectMake(hImageViewLeftOrRightPadding + hFoldBtnViewHeight + hImageViewLeftOrRightPadding, hImageViewTopOrBottomPadding, hImageViewHeight, hImageViewHeight);
        [[WSRequestHelper shareInstance]  downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:_prodBean.url] imageView:_prodImageView placeholderImage:[UIImage imageForName:@"place_holder"]];
        [self addSubview:self.prodImageView];
        
        self.starButton.frame = CGRectMake(self.prodImageView.width - starImageSize.width+hImageViewLeftOrRightPadding*2, hImageViewTopOrBottomPadding, starImage.size.width, starImageSize.height);
        
        self.prodNameTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.prodImageView.frame)+hImageViewLeftOrRightPadding, hTitleViewTopOrBottomPadding, (CGRectGetMaxX(self.prodImageView.frame) + hCheckboxViewLeftOrRightPadding * 3 + hCheckboxImageViewHeight + hTitleViewLeftOrRightPadding *2), hProdNameTitleViewHeight);
    }
    
    
    [self addSubview:self.starButton];
    [self addSubview:self.prodNameTitleLabel];
}

- (UIButton *)starButton{
    if (_starButton == nil) {
        _starButton = [[UIButton alloc]init];
        [_starButton setImage:[UIImage imageNamed:self.unCollectedImageName] forState:UIControlStateNormal];
        [_starButton setImage:[UIImage imageNamed:self.colllectedImageName] forState:UIControlStateSelected];
        [_starButton addTarget:self action:@selector(collectProduct:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _starButton;
}

- (UILabel *)prodNameTitleLabel{
    if (_prodNameTitleLabel == nil) {
        _prodNameTitleLabel = [[UILabel alloc]init];
        _prodNameTitleLabel.textColor = MAIN_TEXT_COLOR;
        _prodNameTitleLabel.font = kProdNameTitleFont;
        _prodNameTitleLabel.numberOfLines = 0;
        _prodNameTitleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _prodNameTitleLabel;
}

- (UILabel *)starLabel{
    if (_starLabel == nil) {
        _starLabel = [[UILabel alloc]init];
        _starLabel.text = NSLocalizedString(@"product_collection", nil);
        _starLabel.textAlignment = NSTextAlignmentCenter;
        _starLabel.font = FONT_SIZE_PINGFANG_REGULAR(9.0);
        _starLabel.textColor = GRAY_TEXT_COLOR;
    }
    return _starLabel;
}

- (UIImageView *)prodImageView{
    if (_prodImageView == nil) {
        _prodImageView = [[UIImageView alloc]init];
        _prodImageView.image = [UIImage imageForName:@"place_holder"];
    }
    return _prodImageView;
}


- (void)resetFrame
{
//    CGRect scrollViewframe = _contentScrollView.frame;
//    scrollViewframe.size.height = self.acvtview.height;
//    _contentScrollView.frame = scrollViewframe;
    
    CGRect frame = self.frame;
    if (self.acvtview.hidden) {
        frame.size.height = hImageViewTopOrBottomPadding * 2 + self.prodContentHeight;
    }else{
        frame.size.height = self.acvtview.height + hImageViewTopOrBottomPadding * 2 + self.prodContentHeight;
    }
    self.frame = frame;
    
    _rightTableModel.cellRealHeight = self.frame.size.height;
    
    NSLog(@"---------setupSubviews  height = %.1f  %.1f", frame.size.height, self.acvtview.height);
}

- (WSAcvtModel *)getAcvtModelWithProdBean:(WSProdBean *)product
{
    WSAcvtBean *acvtBean = [[WSAcvtBean alloc] initAcvtBeanWithTableItem:_currentTableItem withItemId:[product getDataItemID] withItemName:[product getDataItemName] withLuaScript:_luaScriptString];


    NSMutableDictionary *pushDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
//    WSTableItem *tableItem = _currentTableItem;
    
    WSProdBean *currentProd = (WSProdBean *)product;
    
    NSString *jsonStr = [currentProd yy_modelToJSONString];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
    
    [pushDictionary setObject:(currentProd.Id.length > 0 ? currentProd.Id :@"" ) forKey:@"prodId"];
    [pushDictionary setObject:@"addProdPage" forKey:@"prodSource"];
    
    int widgetIndex = 0;
    
    for (WSAcvtBean_qst *qst in acvtBean.qsts) {

        if (qst.qstId.length > 0 && ([qst.qstId isEqualToString:@"prodId"] || [qst.qstId isEqualToString:@"prodSource"])) {
            
        }else{
            NSString *keyStr = [NSString stringWithFormat:@"%@_%@", product.Id, qst.qstId];
            NSString *valueStr = [_prodKeyValueCacheDataDic objectForKey:keyStr];
            if (valueStr && valueStr.length > 0) {
                qst.defaultValue = valueStr;
            }else{
                NSString *dsStr = qst.ds;
                if ([dsStr isEqualToString:@"barcode"]) {
                    dsStr = @"barcod";
                }
                if (dsStr.length > 0 && [dic.allKeys containsObject:dsStr]) {
                    valueStr = [product valueForKey:dsStr];
                    if (keyStr.length > 0) {
                        [_prodKeyValueCacheDataDic setObject:valueStr forKey:keyStr];
                        WSWidget *widget = [self.acvtview.widgetArray objectAtIndex:widgetIndex];
                        [widget setCurrentValueWithPresentation:valueStr];
                    }
                }
            }
            
            [pushDictionary setObject:(valueStr.length <= 0 ? @"" : valueStr) forKey:qst.qstId];
        }

        widgetIndex ++;
    }
    
//    for(int column = 1; column < tableItem.paramArray.count + 1; ++column)
//    {
//        if(tableItem.paramArray.count > column - 1)
//        {
//            WSFuncsBean_Param *param = [tableItem.paramArray objectAtIndex:column - 1];
//            NSString *vaule = @"";
//            [pushDictionary setObject:(vaule.length <= 0 ? @"" : vaule) forKey:param.col];
//
//        }
//    }
    
    WSAcvtModel *acvtModel = [[WSAcvtModel alloc]init];
    acvtModel.currentAcvtBean = acvtBean;
    acvtModel.hasLocalData = YES;
    acvtModel.qstDBValueDictionary = [pushDictionary mutableCopy];
    acvtModel.currentStore = self.currentStore;
//    acvtModel.currentSubEmpStore = self.currentSubEmpStore;
    
    return acvtModel;

}

- (void)setIsFolded:(BOOL)isFolded
{
    _isFolded = isFolded;
    _foldBtn.selected = !_isFolded;
    
    if (_foldBtn.selected) {
        self.acvtview.hidden = NO;
        [self layoutSubviews];
    }else{
        self.acvtview.hidden = YES;
        [self layoutSubviews];
    }
    
    if (_rightTableModel.isFolded != _isFolded) {
        _rightTableModel.isFolded = _isFolded;
        
        if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellDataModelValueIsChanged)]) {
//            [self.cellContentViewDelegate cellDataModelValueIsChanged];
        }
    }
    
//    [self resetFrame];

}

- (void)setRightTableModel:(WSNewAddProdsWithSeriesModel *)rightTableModel
{
    _rightTableModel = rightTableModel;
    
    _isCollected = rightTableModel.isCollected;
    
    _starButton.selected = _isCollected;
    
    _prodDetailSubtitleLabel.text = _rightTableModel.subDisplayString;
    
    if (_prodDetailSubtitleLabel.text.length == 0) {
        _prodDetailSubtitleLabel.height = 0.0f;
        self.prodContentHeight = hImageViewHeight > (self.prodContentHeight - hProdNameTitleViewHeight) ? hImageViewHeight: self.prodContentHeight - hProdNameTitleViewHeight;
        self.acvtview.frame = CGRectMake(0.0, hImageViewTopOrBottomPadding * 2 + self.prodContentHeight, self.frame.size.width, self.frame.size.height);
        [self resetFrame];
    }else{
        _prodDetailSubtitleLabel.height = hProdNameTitleViewHeight;
    }

//    [self setIsFolded:_rightTableModel.isFolded];
    
    // MN-1458 加入勾选显示副标题的逻辑
    if (!_rightTableModel.isFolded) {
        
        _currentAcvtModel = nil;
        _currentAcvtModel = [self getAcvtModelWithProdBean:_prodBean];
        
        [WSDataSourceManager sharedInstance].currentActiveModel = _currentAcvtModel;
        
        // MN-2441
        if (!self.isBuildDisplayContent) {
            self.isBuildDisplayContent = YES;
            
            [WSDataSourceManager sharedInstance].currentActiveModel = _currentAcvtModel;
            [self.acvtview buildDisplayContent];
            
            for (WSWidget *widget in self.acvtview.widgetArray) {
                WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];
                
                if ([qst.qstId isEqualToString:@"prodId"]) {
                    _prodIdWidget = widget;
                    break;
                }
            }
        }

        
//        if (![_prodIdWidget getResultDirectly] || [NSString stringNotNilWithValue:[_prodIdWidget getResultDirectly]].length <= 0) {
            [_prodIdWidget reloadCurrentWidgetWithValue:_prodBean.Id];
//        }
        
        [self.acvtview checkAndExecuteAcvtLuaScript];

        NSMutableDictionary * dict = (NSMutableDictionary *)[self.acvtview getAllDataAboutQstIdAndValue];
        [dict removeObjectForKey:@"prodId"];
        
        [self setProdDetailSubtitleWithValueDict:dict];
        
        [self resetFrame];

    }else{
        [self setProdDetailSubtitleWithValueDict:nil];
    }
}

- (void)foldComView:(id)sender
{
    NSLog(@"foldComView");
    _isFolded = !_isFolded;
    
//    [self setIsFolded:_isFolded];
    
//    if (_foldBtn.selected) {
//        self.acvtview.hidden = NO;
//        [self layoutSubviews];
//    }else{
//        self.acvtview.hidden = YES;
//        [self resetFrame];
//    }
    
//    if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellContentViewIsFoldedValueChanged:)]) {
//        [self.cellContentViewDelegate cellContentViewIsFoldedValueChanged:_isFolded];
//    }
//    [self resetFrame];
    
    _rightTableModel.isFolded = _isFolded;
//    _rightTableModel.cellRealHeight = self.frame.size.height;
    
    if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellDataModelValueIsChanged)]) {
        [self.cellContentViewDelegate cellDataModelValueIsChanged];
    }
}

- (void)setProdBean:(WSProdBean *)prodBean
{
    _prodBean = prodBean;
    _prodNameTitleLabel.text = _prodBean.name;


}

- (void)setProdKeyValueCacheDataDic:(NSMutableDictionary *)prodKeyValueCacheDataDic
{
    _prodKeyValueCacheDataDic = prodKeyValueCacheDataDic;
    
    for (WSWidget *widget in self.acvtview.widgetArray) {
        WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];
        
        NSString *valueStr = [_prodKeyValueCacheDataDic objectForKey:[NSString stringWithFormat:@"%@_%@", _prodBean.Id, qst.qstId]];
        
        if (valueStr && valueStr.length > 0) {
            [widget reloadCurrentWidgetWithValue:valueStr];
        }else
        {
//            donghong YIHAIKERRY-2788  与安卓逻辑同
            if ([[widget.xbuildInfo getISRequire]isEqualToString:@"1"] && [[widget.xbuildInfo getAcvtQstType]isEqualToString:@"DV"] && [widget.xdataSource.dataSourceArray count]==1) {
                continue;
            }
            [widget reloadCurrentWidgetWithValue:@""];
        }
    }

}

- (void)setCurrentTableItem:(WSTableItem *)currentTableItem
{
    _currentTableItem = currentTableItem;
    
}

- (void)setLuaScriptString:(NSString *)luaScriptString
{
    _luaScriptString = luaScriptString;
    
    if (!_prodNameTitleLabel) {

        [self setupSubviews];

    }

}

- (void)acvtViewWidget:(WSWidget *)widget valueChanged:(BOOL)isValueChangedCompareWithOrigin
{
    
    // WSBaseDropListPanel 单位变化咱不需要触发处理脚本，否则会引起混乱
    if (isValueChangedCompareWithOrigin && !_isFolded && ![widget isKindOfClass:[WSBaseDropListPanel class]] && ![widget.getReadonly boolValue] && !widget.isHidden) {
    
        if (![_prodIdWidget getResultDirectly] || [NSString stringNotNilWithValue:[_prodIdWidget getResultDirectly]].length <= 0) {
            [_prodIdWidget reloadCurrentWidgetWithValue:_prodBean.Id];
        }
        
        _currentAcvtModel = nil;
        _currentAcvtModel = [self getAcvtModelWithProdBean:_prodBean];

        [WSDataSourceManager sharedInstance].currentActiveModel = _currentAcvtModel;
        
        WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];

        NSString *valueStr = [NSString stringNotNilWithValue:[widget getResultDirectly]];
        
        NSString *keyStr = [NSString stringWithFormat:@"%@_%@", _prodBean.Id, qst.qstId];
        
        [_prodKeyValueCacheDataDic setObject:valueStr forKey:keyStr];
        
        //问题脚本可在此方法内执行
        for (WSWidget *widget in self.acvtview.widgetArray) {
            [self.acvtview executeLuaScript:widget.xbuildInfo widget:widget];
        }
        
        if ([self.acvtview checkLuaScriptWhenUpload]) {
            NSMutableDictionary * dict = (NSMutableDictionary *)[self.acvtview getAllDataAboutQstIdAndValue];
            [dict removeObjectForKey:@"prodId"];
            
            
            for (NSString *keyString in dict.allKeys) {
                NSString *cacheKeyStr = [NSString stringWithFormat:@"%@_%@", _prodBean.Id, keyString];
                NSString *cacheValueStr = [dict objectForKey:keyString];
                if (cacheValueStr && cacheValueStr.length > 0) {
                    [_prodKeyValueCacheDataDic setObject:cacheValueStr forKey:cacheKeyStr];
                }else{
                    [_prodKeyValueCacheDataDic removeObjectForKey:cacheKeyStr];
                }
                
            }
            
            
            // 多次调用脚本导致cell复用的混乱
            [self setProdDetailSubtitleWithValueDict:dict];
            //YIHAIKERRY-4139
            // 益海嘉里-上海：订单管理：在添加产品页面输入备注，备注输入框会遮挡列表下发产品信息
            if ([widget isKindOfClass:[WSTextViewPanel class]]) {
                if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellHeightIsChanged)]) {
                    [self.cellContentViewDelegate cellHeightIsChanged];
                }
            }

        }

    }
}

- (void)setProdDetailSubtitleWithValueDict:(NSDictionary *)valueDict
{
    NSString *subtitleStr = @"";

    NSString *invValueStr = [valueDict objectForKey:@"inv"];
    
    if (invValueStr && invValueStr.length > 0) {
        subtitleStr = [NSString stringWithFormat:@"库存：%@ \n", invValueStr];
    }
    
    NSString *oosValueStr = [valueDict objectForKey:@"oos"];
    
    if (oosValueStr && oosValueStr.length > 0) {
        subtitleStr = [NSString stringWithFormat:@"%@%@", subtitleStr, oosValueStr];
    }
    
    NSString *ordValueStr = [valueDict objectForKey:@"ord"];
    
    if (ordValueStr && ordValueStr.length > 0) {
//        subtitleStr = [NSString stringWithFormat:@"%@共%@元", subtitleStr, ordValueStr];
    }
    
//    NSString *distValueStr = [valueDict objectForKey:@"dist"];
//
//    if (distValueStr) {
//        subtitleStr = [NSString stringWithFormat:@"%@  %@  %@", [valueDict objectForKey:@"pri"], [valueDict objectForKey:@"ord"], [valueDict objectForKey:@"dist"]];
//
//        if ([distValueStr floatValue] == 0.0) {
//            subtitleStr = @"";
//        }
//    }else{
//        subtitleStr = [NSString stringWithFormat:@"%@  %@  %@", [valueDict objectForKey:@"pri"], [valueDict objectForKey:@"oos"], [valueDict objectForKey:@"ord"]];
//        NSString *ordValueStr = [valueDict objectForKey:@"ord"];
//
//        if (!ordValueStr || ordValueStr.length <= 0) {
//            subtitleStr = @"";
//        }else{
//            if ([ordValueStr floatValue] == 0.0) {
//                subtitleStr = @"";
//            }
//        }
//    }
    
    _rightTableModel.subDisplayString = subtitleStr;
    _rightTableModel.isFolded = _isFolded;
    
//    if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellDataModelValueIsChanged)]) {
//        [self.cellContentViewDelegate cellDataModelValueIsChanged];
//        _prodDetailSubtitleLabel.text = _rightTableModel.subDisplayString;
//
//    }
    
    if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(totalSumPriceIsChanged)]) {
        [self.cellContentViewDelegate totalSumPriceIsChanged];
        _prodDetailSubtitleLabel.text = _rightTableModel.subDisplayString;
        
    }
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    
    if (_isChecked) {
        [_checkboxImageView setImage:[UIImage imageNamed:@"icn_check"]];
        self.backgroundColor = [UIColor whiteColor];
    }else{
        [_checkboxImageView setImage:[UIImage imageNamed:@"icn_nocheck"]];
        //        self.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    //    [self layoutIfNeeded];

}

//- (void)setIsCollected:(BOOL)isCollected
//{
//    _isCollected = isCollected;
//
//    if (_isCollected) {
//        [_starImageView setImage:[UIImage imageNamed:@"icon_star_checked"]];
//
//    }else{
//        [_starImageView setImage:[UIImage imageNamed:@"icon_star_unchecked"]];
//    }
//}

- (void)collectProduct:(UIButton *)sender
{
    _isCollected = !_isCollected;
    
    sender.selected = _isCollected;
    
    _rightTableModel.isCollected = _isCollected;
    
    if (self.cellContentViewDelegate && [self.cellContentViewDelegate respondsToSelector:@selector(cellDataModelValueIsChanged)]) {
        [self.cellContentViewDelegate cellDataModelValueIsChanged];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self resetFrame];
    
//    if ([self.superview.superview isKindOfClass:[WSNewAddProdsWithSeriesRightTableViewCell class]]) {
//        WSNewAddProdsWithSeriesRightTableViewCell *view = (WSNewAddProdsWithSeriesRightTableViewCell *)self.superview.superview;
//        if (view.height != self.height + self.origin.y) {
//            CGFloat height  = self.height + self.origin.y;
//            
//            CGRect newFrame = view.frame;
//            newFrame.size.height = height;
//            view.frame = newFrame;
//            
//            [view layoutSubviews];
//        }
//    }

    
//    NSLog(@"---------layoutSubviews  height = %.1f  %.1f", _contentScrollView.frame.size.height, self.acvtview.height);
    
}

@end
