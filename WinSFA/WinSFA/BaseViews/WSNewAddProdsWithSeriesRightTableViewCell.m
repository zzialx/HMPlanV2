//
//  WSNewAddProdsWithSeriesRightTableViewCell.m
//  WinSFA
//
//  Created by HZH on 2017/9/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNewAddProdsWithSeriesRightTableViewCell.h"
#import "WSDataGridRightTableModel.h"
#import "WSDataGridComponentView.h"
#import "WSNewAddProdsWithSeriesRightTableViewCellContentView.h"
#import "WSNewAddProdsWithSeriesRightTableViewEditView.h"
#import "WSProdHttpService.h"
#import "WSProdSalesDetailView.h"

#define kLeftTableCellTextSize 13.0
#define kLeftTableCellSpace 5.0

#define kLeftTableCellHeight 40.0

#define kCheckboxImageViewSize 20.0

@interface WSNewAddProdsWithSeriesRightTableViewCell () <WSNewAddProdsWithSeriesRightTableViewCellContentViewDelegate>


@property (nonatomic, strong) WSDataGridComponentView *gridView;
@property (nonatomic, assign) CGFloat originSelfHeight;
@property (nonatomic, strong) UIView *imagesBgView;
@property (nonatomic, assign) CGFloat imageViewHeight;
@property (nonatomic, strong) WSNewAddProdsWithSeriesRightTableViewCellContentView *cellContentView;
@property (nonatomic, strong) WSNewAddProdsWithSeriesRightTableViewEditView * editView;

@property (nonatomic, strong) WSProdHttpService *service;


@end

@implementation WSNewAddProdsWithSeriesRightTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //        if (!IOS7_OR_LATER) {
        //            self.selectionStyle = UITableViewCellSelectionStyleNone;
        //        }
        _originSelfHeight = self.frame.size.height;
        _imageViewHeight = 0.0;
        
        [self setupSubviews];
        //        self.separatorLineColor = RGBCOLOR(218, 218, 218);//[UIColor colorWithHexString:@"#c7c7c7"];
        
    }
    
    return self;
}

- (void)setupSubviewsWithDisplayStyleAcvtView
{
    if (!_cellContentView) {
        _cellContentView = [[WSNewAddProdsWithSeriesRightTableViewCellContentView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) andAllNeedParams:_allNeedParamsArray];
        
        
        [self.contentView addSubview:_cellContentView];
    }
    
    _cellContentView.cellContentViewDelegate = self;
    _cellContentView.currentStore = _currentStore;
    _cellContentView.prodBean = _prodBean;
    _cellContentView.prodKeyValueCacheDataDic = _prodKeyValueCacheDataDic;
    _cellContentView.currentTableItem = _currentTableItem;
    _cellContentView.luaScriptString = _luaScriptString;
    //    _cellContentView.prodBean = _prodBean;
    
    _cellRealHeight = _cellContentView.frame.size.height;
    
    NSLog(@"++++++++++++++setupSubviewsWithDisplayStyleAcvtView  cellRealHeight = %.1f", _cellRealHeight);
    
}

- (void)setupSubviews
{
    //SFA-21341
    [self.contentView removeAllSubviews];
    
    self.checkboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, (self.height - kCheckboxImageViewSize)/2, kCheckboxImageViewSize, kCheckboxImageViewSize)];
    [self.checkboxImageView setImage:[UIImage imageNamed:@"icn_nocheck"]];
    
    [self.contentView addSubview: self.checkboxImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.highlightedTextColor = MAIN_TINT_COLOR;
    
    [self.contentView addSubview:self.titleLabel];
    
    self.inventoryLabel = [[UILabel alloc] init];
    
    self.inventoryLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize];
    self.inventoryLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    //    self.inventoryLabel.numberOfLines = 0;
    self.inventoryLabel.textAlignment = NSTextAlignmentLeft;
    self.inventoryLabel.highlightedTextColor = MAIN_TINT_COLOR;
    
    [self.contentView addSubview:self.inventoryLabel];
    
    [self addSalesButtonToView];//SFA-24275  IOS：SFA立白【经销商】订单-添加产品促销活动信息显示需求

}
- (void) addSalesButtonToView {
    
    self.salesButton = [[UIButton alloc]init];
    self.salesButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize];
    [self.salesButton setTitle:@"促销详情" forState:UIControlStateNormal];
    [self.salesButton setTitleColor:MAIN_TINT_COLOR forState:UIControlStateNormal];
    [self.salesButton addTarget:self action:@selector(salesButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.salesButton];
}

- (void)setIsChecked:(BOOL)isChecked
{
    _isChecked = isChecked;
    
    if (_displayStyle == HNewAddProdsWithSeriesDisplayStyleAcvtView) {
        _cellContentView.isChecked = _isChecked;
        self.isFolded = !_isChecked;
    }
    
    if (_isChecked) {
        [self.checkboxImageView setImage:[UIImage imageNamed:@"icn_check"]];
        self.contentView.backgroundColor = [UIColor whiteColor];
        _gridView.hidden = NO;
        _editView.hidden = NO;

    }else{
        [self.checkboxImageView setImage:[UIImage imageNamed:@"icn_nocheck"]];
//        self.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        self.contentView.backgroundColor = [UIColor whiteColor];
        _gridView.hidden = YES;
        _editView.hidden = YES;

    }
    if (_gridView) {
        if (_gridView.hidden) {
            CGRect cellFrame = self.frame;
            cellFrame.size.height = self.frame.size.height + _imageViewHeight;
            self.frame = cellFrame;
        }else{
            CGRect cellFrame = self.frame;
            cellFrame.size.height = self.frame.size.height + _imageViewHeight + _gridView.frame.size.height;
            
            self.frame = cellFrame;
        }
        
    }
    if (_editView) {
        if (_editView.hidden) {
            CGRect cellFrame = self.frame;
            cellFrame.size.height = self.frame.size.height + _imageViewHeight;
            self.frame = cellFrame;
        }else{
            CGRect cellFrame = self.frame;
            cellFrame.size.height = self.frame.size.height + _imageViewHeight + _editView.frame.size.height;
            
            self.frame = cellFrame;
        }

    }
   
}

- (void)setNeedAddEditParamsArray:(NSArray *)needAddEditParamsArray
{
    _needAddEditParamsArray = needAddEditParamsArray;
    
    /**
    if (_gridView) {
        [_gridView removeFromSuperview];
        _gridView = nil;
    }
    
    if (_needAddEditParamsArray && _needAddEditParamsArray.count > 0 && _gridView == nil) {
        [self addNeedEditParamsGridView];
    }
     */
    
    //SFA-24166  新需求，用下面的UI，不用上面的Ui
    if (_editView) {
        [_editView removeFromSuperview];
        _editView = nil;
    }
    if (_needAddEditParamsArray && _needAddEditParamsArray.count > 0 && _editView == nil) {
        [self setupSubviewsWithNew];
    }
    
}

- (void)setAllNeedParamsArray:(NSArray *)allNeedParamsArray
{
    _allNeedParamsArray = allNeedParamsArray;
    
    if (_displayStyle == HNewAddProdsWithSeriesDisplayStyleAcvtView) {
        [self setupSubviewsWithDisplayStyleAcvtView];
        
    }else if (_displayStyle == HNewAddProdsWithSeriesDisplayStyleGridView) {
        [self setupSubviews];
    }else{
        [self setupSubviews];
    }
    
}

- (void)setCurrentTableItem:(WSTableItem *)currentTableItem
{
    _currentTableItem = currentTableItem;
    
}

- (void)setLuaScriptString:(NSString *)luaScriptString
{
    _luaScriptString = luaScriptString;
    
}

- (void)setProdBean:(WSProdBean *)prodBean
{
    _prodBean = prodBean;
    
}

- (void)setIsFolded:(BOOL)isFolded
{
    _isFolded = isFolded;
    
    _cellContentView.isFolded = _isFolded;
    
    [self resetSubviewsFrame];
    
}

- (void)setRightTableModel:(WSNewAddProdsWithSeriesModel *)rightTableModel
{
    rightTableModel.isFolded = self.isFolded;
    _rightTableModel = rightTableModel;
    
    //    CGRect cellFrame = self.frame;
    //    cellFrame.size.height = _rightTableModel.cellRealHeight;
    //    self.frame = cellFrame;
    
    _cellContentView.rightTableModel = _rightTableModel;
//    [self setIsFolded:rightTableModel.isFolded];
//    [self setIsChecked:rightTableModel.isChecked];
    
}

- (void)addNeedEditParamsGridView
{
    WSDataGridRightTableModel *dataGridRightTableModel = [[WSDataGridRightTableModel alloc] init];
//    NSString *typeAndBrandStr = [NSString stringWithFormat:@"%@", dictBean.name];
    
    dataGridRightTableModel.isNeedHideFirstColAndKeepBlank = YES;
    dataGridRightTableModel.topTypeIndex = 0;
//    dataGridRightTableModel.firstColWidth = self.currentFuncs.wfcol;
    dataGridRightTableModel.firstColWidth = 10.0;
    dataGridRightTableModel.title = @"";
    dataGridRightTableModel.isExPanded = NO;
    dataGridRightTableModel.secondTypeIndex = _secondTypeIndex;

    dataGridRightTableModel.gridColParamArray = _needAddEditParamsArray;
    if (_prodBean) {
        dataGridRightTableModel.prodsArray = @[_prodBean];
    }
    dataGridRightTableModel.prodKeyValueCacheDataDic = _prodKeyValueCacheDataDic;
    
    if (dataGridRightTableModel.prodsArray.count > 0) {
        
        
        CGFloat y = CGRectGetMaxY(self.titleLabel.frame) > CGRectGetMaxY(self.checkboxImageView.frame) ? CGRectGetMaxY(self.titleLabel.frame) : CGRectGetMaxY(self.checkboxImageView.frame);
        if(self.inventoryLabel.text.length>0)
        {
            y = CGRectGetMaxY(self.inventoryLabel.frame) + kLeftTableCellSpace;
        }
        _gridView = [[WSDataGridComponentView alloc] initWithFrame:CGRectMake(0, y + _imageViewHeight, self.width, dataGridRightTableModel.gridComViewHeight + 5) andDataModel:dataGridRightTableModel /*andIsEcho:YES*/];
        
        [self.contentView addSubview:_gridView];
        
    }
    
}
//SFA-24166  IOS：SFA立白【经销商】订单添加产品优化需求——添加产品页面数量子数量优化
//新的UI，老的废弃，用这个
- (void)setupSubviewsWithNew
{
    WSDataGridRightTableModel *dataGridRightTableModel = [[WSDataGridRightTableModel alloc] init];
    
    dataGridRightTableModel.isNeedHideFirstColAndKeepBlank = YES;
    dataGridRightTableModel.topTypeIndex = 0;
    dataGridRightTableModel.firstColWidth = 10.0;
    dataGridRightTableModel.title = @"";
    dataGridRightTableModel.isExPanded = NO;
    dataGridRightTableModel.secondTypeIndex = _secondTypeIndex;
    
    dataGridRightTableModel.gridColParamArray = _needAddEditParamsArray;
    if (_prodBean) {
        dataGridRightTableModel.prodsArray = @[_prodBean];
    }
    dataGridRightTableModel.gridComViewHeight = 51;//
    dataGridRightTableModel.prodKeyValueCacheDataDic = _prodKeyValueCacheDataDic;
    
    if (dataGridRightTableModel.prodsArray.count > 0) {
        
        
        CGFloat y = CGRectGetMaxY(self.titleLabel.frame) > CGRectGetMaxY(self.checkboxImageView.frame) ? CGRectGetMaxY(self.titleLabel.frame) : CGRectGetMaxY(self.checkboxImageView.frame);
        if(self.inventoryLabel.text.length>0)
        {
            y = CGRectGetMaxY(self.inventoryLabel.frame) + kLeftTableCellSpace;
        }
        _editView = [[WSNewAddProdsWithSeriesRightTableViewEditView alloc] initWithFrame:CGRectMake(0, y + _imageViewHeight , self.width, dataGridRightTableModel.gridComViewHeight ) andDataModel:dataGridRightTableModel /*andIsEcho:YES*/];
        
        [self.contentView addSubview:_editView];
        
    }
    
}
- (void)setProdTypeImageUrls:(NSString *)prodTypeImageUrls
{
    _prodTypeImageUrls = prodTypeImageUrls;
    
    if (_imagesBgView) {
        [_imagesBgView removeFromSuperview];
        _imagesBgView = nil;
    }
    if (prodTypeImageUrls && prodTypeImageUrls.length > 0) {
        [self setupImageViewsWithImageUrls:_prodTypeImageUrls];
    }else{
        _imageViewHeight = 0.0;
    }
    
}

- (void)setupImageViewsWithImageUrls:(NSString *)imageUrls
{
    NSArray *imageUrlsArray = [imageUrls componentsSeparatedByString:@","];
    
    CGFloat y = CGRectGetMaxY(self.titleLabel.frame) > CGRectGetMaxY(self.checkboxImageView.frame) ? CGRectGetMaxY(self.titleLabel.frame) : CGRectGetMaxY(self.checkboxImageView.frame);
    if(self.inventoryLabel.text.length>0)
    {
        y = CGRectGetMaxY(self.inventoryLabel.frame) + kLeftTableCellSpace;
    }
    _imagesBgView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.width, 30.0)];
    for (int i = 0; i < imageUrlsArray.count; i ++) {
        NSString *imageUrl = [imageUrlsArray objectAtIndex:i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40 + 30.0 * i, 5, 20, 20)];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:imageUrl]] placeholderImage:nil options:SDWebImageRetryFailed];
        
        [_imagesBgView addSubview:imageView];
    }
    
    _imageViewHeight = _imagesBgView.frame.size.height;
    
    [self addSubview:_imagesBgView];
}

- (void)setSecondTypeIndex:(NSInteger)secondTypeIndex
{
    _secondTypeIndex = secondTypeIndex;
}

- (void)cellContentViewIsFoldedValueChanged:(BOOL)isFolded
{
    _isFolded = isFolded;
    
    [self resetSubviewsFrame];
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(needUpdateCell:atIndexPath:)]) {
        [self.cellDelegate needUpdateCell:self atIndexPath:_indexPath];
    }
    
}

- (void)cellDataModelValueIsChanged
{
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(needUpdateCell:atIndexPath:)]) {
        [self.cellDelegate needUpdateCell:self atIndexPath:_indexPath];
    }
    
}

- (void)totalSumPriceIsChanged
{
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(needRefreshTotalPrice)]) {
        [self.cellDelegate needRefreshTotalPrice];
    }
    
}

- (void)cellHeightIsChanged
{
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(needUpdateCellHeight)]) {
        [self.cellDelegate needUpdateCellHeight];
    }
    
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    [self resetSubviewsFrame];
    
}

- (void)resetSubviewsFrame
{
    [self.checkboxImageView setFrame:CGRectMake(10.0, (_originSelfHeight - kCheckboxImageViewSize)/2, kCheckboxImageViewSize, kCheckboxImageViewSize)];
    
    CGFloat titleLabelWidth = self.contentView.frame.size.width - 20.0 - kCheckboxImageViewSize;
    
    CGSize tempTitleStringSize = [self.titleLabel.text ws_sizeWithFont:[UIFont fontWithName:@"PingFangSC-Medium" size:kLeftTableCellTextSize] constrainedToWidth:titleLabelWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    [self.titleLabel setFrame:CGRectMake(kCheckboxImageViewSize + 20.0, 0.0, titleLabelWidth, tempTitleStringSize.height)];
    
    [self.inventoryLabel setFrame:CGRectMake(kCheckboxImageViewSize + 20.0, CGRectGetMaxY(self.titleLabel.frame) + kLeftTableCellSpace, titleLabelWidth, kLeftTableCellTextSize)];
    
    CGFloat buttonWidth = 60;
    [self.salesButton setFrame:CGRectMake(self.frame.size.width - buttonWidth - 15 , CGRectGetMaxY(self.titleLabel.frame) + kLeftTableCellSpace, buttonWidth, kLeftTableCellTextSize)]; //和库存label水平

    
    CGFloat y = CGRectGetMaxY(self.titleLabel.frame) > CGRectGetMaxY(self.checkboxImageView.frame) ? CGRectGetMaxY(self.titleLabel.frame) : CGRectGetMaxY(self.checkboxImageView.frame);

    if(self.inventoryLabel.text.length>0)
    {
        y = CGRectGetMaxY(self.inventoryLabel.frame) + kLeftTableCellSpace;
    }
    
    if (_imagesBgView) {

        _imagesBgView.frame = CGRectMake(0, y, self.width, 30.0);

        y = CGRectGetMaxY(_imagesBgView.frame);

    }
    //SFA-21333  SFA-立白-IOS-带有“新”“特”字的产品，选中一个，下边的产品有些错位 2018-6-23
    _gridView.frame = CGRectMake(0, y , self.width, _gridView.frame.size.height);
    
    _editView.frame = CGRectMake(0, y , self.width, _editView.frame.size.height);

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setGridBecomeFirstResponder {
    if (_gridView) {
        [_gridView setGridBecomeFirstResponder];
    }
    if (_editView) {
        [_editView setGridBecomeFirstResponder];
    }
}

#pragma mark - 按钮点击事件

- (void)salesButtonClicked {
    
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    
    CGRect buttonRect=[self.salesButton convertRect: self.salesButton.bounds toView:window];
    
    [self.salesButton setTitle:@"加载中..." forState:UIControlStateNormal];
    //先请求。成功回来后弹出试图
    //弹出促销详情视图
    self.service.objID = @"queryOrderProductInfo";
    [self.service getSalesDetailStringWithStoreId:self.currentStore.Id prodId:self.prodBean.Id CompletionBlock:^(NSArray *array, NSError *error) {
        [self.salesButton setTitle:@"促销详情" forState:UIControlStateNormal];
        
        // 弹出提示框时收起键盘，防止键盘遮挡无法操作页面的情况
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        if (array && array.count > 0) {
            NSDictionary *dic = [array firstObject];
            NSString *content = dic[@"content"];
            //弹出
            WSProdSalesDetailView *detail = [[WSProdSalesDetailView alloc]initWithContentString:content selectButtonRect:buttonRect];
            [detail showSalesDetailView];
            
        }
    }];
    
}

-(WSProdHttpService *)service {
    if (!_service) {
        _service =  [[WSProdHttpService alloc] init];
    }
    return _service;
}
@end
