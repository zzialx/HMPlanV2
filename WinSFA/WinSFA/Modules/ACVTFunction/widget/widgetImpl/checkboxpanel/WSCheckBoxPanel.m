//
//  WSCheckBoxPanel.m
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//


#import "WSCheckBoxPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WidgetConstant.h"
#import "I_W_DisplayValue.h"
#import "WSArrayValueChangeChecker.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSOptPhotoBrowseViewController.h"
#import "WSAllCheckBtn.h"

#define RADIOTAG 200

#define kOptionViewLeftSpace (INTERFACE_IS_PAD ? 20.0f : 10.0f)


@interface WSCheckBoxPanel ()
{
    BOOL _needRiseSelectionChange;
}

@property (nonatomic, assign) CGFloat optionViewHeight;


@property (nonatomic, strong)WSAllCheckBtn * checkAllBtn;///<全部选择框

@end

@implementation WSCheckBoxPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _needRiseSelectionChange = YES;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _selectedItems = [[NSMutableArray alloc] init];
        
        _optionViewArray = [[NSMutableArray alloc] init];
        
        self.xvalueChangeChecker = [[WSArrayValueChangeChecker alloc] init];
        
        return self;
    }
    return nil;
}

-(void)buildDisplayContent{
    
    [self removeAllSubviews];
    
    [self.optionViewArray removeAllObjects];
    
    [super buildDisplayContent];
    
    [self setAllCheckBtnUI];
    
    [self setUpSubviews];
}

- (void)setUpSubviews
{
    CGFloat height = 0;
    
    CGFloat left = MAIN_CELL_PADDING;
    
    if (![[xbuildInfo getWidgetId] isEqualToString:QST_TYPE_CN]) {
        height += self.titleLabel.height;
        
    }else {
        self.titleLabel.hidden = YES;
    }
    
    BOOL orientation = NO;
    
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientation = YES;
    }
    
    
    BOOL isReadOnly = NO;
    if ([xbuildInfo getReadOnly] && [[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        isReadOnly = YES;
    }
    
    NSInteger maxDisNumber  =  [self getDisPlayCheckBoxNumber];
    
    BOOL isInOneLine = NO;
    if (orientation == YES && self.dataSourceArray.count <= (maxDisNumber/2) && self.dataSourceArray.count > 0) {//当前行就可以展示下
        height = 0;
        isInOneLine = YES;
    }
    
    BOOL isHideOptionnName = NO;
    if ([[xbuildInfo getIsHideQstOptName] isEqualToString:@"1"]) {
        isHideOptionnName = YES;
    }
    
    height += MAIN_PADDING;
    
    BOOL isMultiseriate = NO;
    for (int i = 0; i < self.dataSourceArray.count; i++) {
        
        NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:i];
        
        CGRect optionRect = CGRectMake(left, height, self.width - 2 *left, MAIN_CELL_HEIGHT);
        CGFloat optionX;
        CGFloat optionY = height;
        
        
        if (orientation && maxDisNumber !=0) {
            
            CGFloat optionWidth = self.width/maxDisNumber;
            
            if (isInOneLine) {
                if (!self.titleLabel.hidden) {
                    optionX = (self.width - MAIN_CELL_PADDING - optionWidth * (i+1));
                }else{
                    optionX = (left + optionWidth * (i % maxDisNumber));
                }
                
            }else {
                optionX = (left + optionWidth * (i % maxDisNumber));
            }
            
            optionRect = CGRectMake(optionX, optionY, optionWidth, MAIN_CELL_HEIGHT);
            
            isMultiseriate = YES;
            
        }
        
        // MSTD-6639 间距要要比其他控件小
        UIFont *font = ([dataItem respondsToSelector:@selector(getDataItemPic)] && [[dataItem getDataItemPic] length] > 0) ?  FONT_SIZE_PINGFANG_MEDIUM(11) :  FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
        CGSize size = [[dataItem getDataItemName] ws_sizeWithFont:font constrainedToWidth:optionRect.size.width lineBreakMode:NSLineBreakByWordWrapping];
        size = [self.titleLabel labelAndPaddingResize:size ratio:kOptionViewHeight / MAIN_CELL_HEIGHT];
        
        if (size.height < kOptionViewHeight) {
            size.height = kOptionViewHeight;
        }
        optionRect.size.height = size.height;
        
        CGFloat gapHeight = 0;
        
        WSOptionView *optionView = [[WSOptionView alloc] initWithFrame:optionRect andDataItem:dataItem withMultiseriate:isMultiseriate isHideOptionnName:isHideOptionnName];
        optionView.tag = RADIOTAG + i ;
        
        [optionView.button setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        
        if ([self getReadOnly]) {
            [optionView.button setImage:[UIImage imageNamed:@"icn_check_2"] forState:UIControlStateSelected];
        }else {
            [optionView.button setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
        }
        
        if (isReadOnly) {
            [optionView optionViewEnable:NO];
        }
        
        
        optionView.delegate = self;
        
        [self addSubview:optionView];
        [self.optionViewArray addObject:optionView];
        
        
        if (orientation && maxDisNumber!= 0) {
            if ((i+1)%maxDisNumber == 0 ) {
                height +=optionView.height;
            }else if ( (i+1) == self.dataSourceArray.count){
                height += optionView.height;
            }
        }else{
            height += optionView.height;
        }
        height += gapHeight;
    }
    
    height += MAIN_PADDING;
    
    // 如果数据源仅有一项且为必填则直接选中该选项
    if ([[xbuildInfo getISRequire] isEqualToString:@"1"] && [self.dataSourceArray count] == 1) {
        [self setupSelectionBySelectItemIDArray:@[[[self.dataSourceArray firstObject] getDataItemID]]];
    }
    
    NSArray *selectItemIDArray = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    
    _originalValue = selectItemIDArray ;
    [self setupSelectionBySelectItemIDArray:selectItemIDArray];
    
    if (!self.titleLabel.hidden  && !isMultiseriate) {
        CGRect titleFrame = self.titleLabel.frame;
         /*Jira - MSTD-6841  分割线顶到头 create by sunhongfu 2017-11-8*/
        UIView *seperateLineView  = [[UIView alloc] initWithFrame:CGRectMake(SEPERATE_PADDING_Left, CGRectGetMaxY(titleFrame), self.width, MAIN_CELL_SEPERATOR_HEIGHT)];
        [seperateLineView setBackgroundColor:DETAIL_SEPERATE_LINE_COLOR];
        [self addSubview:seperateLineView];
        
    }
    
    if ([self.dataSourceArray count] == 1 && isInOneLine && isHideOptionnName) {
        CGFloat width = self.width - MAIN_CELL_PADDING * 2 - 60;
        CGRect labelFrame = self.titleLabel.frame;
        labelFrame.size.width = width;
        labelFrame.size.height = MAIN_CELL_HEIGHT;
        self.titleLabel.frame = labelFrame;
    }

    self.optionViewHeight = self.dataSourceArray.count > 0 ? height : self.titleLabel.height;
    
    CGRect rect = self.frame;
    rect.size.height = self.optionViewHeight;
    self.frame = rect;
    
    if ([[xbuildInfo getWidgetId] isEqualToString:QST_TYPE_CE]) {
        [self setTitleFoldEnable:YES];
        [self setIsTitleFold:YES];
    }
}

- (BOOL)getReadOnly
{
    BOOL isReadOnly = NO;
    if ([xbuildInfo getReadOnly] && [[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        isReadOnly = YES;
    }
    return isReadOnly;
}

- (void)setButton:(UIButton *)button selected:(BOOL)selected
{
    if ([self getReadOnly]) {
        if (selected) {
            UIImage *image = [UIImage scaledImageForName:@"icn_check_2" ofType:@"png"];
            [button setImage:image forState:UIControlStateNormal];
        }else {
            [button setImage:[UIImage scaledImageForName:@"icn_nocheck" ofType:@"png"] forState:UIControlStateNormal];
        }
    }
    
    [button setSelected:selected];
}

- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    [xdataSource getDataSourceFor:xbuildInfo];
    
    self.dataSourceArray = xdataSource.dataSourceArray;
    
}

- (void)setupSelectionBySelectItemIDArray:(NSArray *)selectItemIDArray
{
    for (NSString *selectItemID in selectItemIDArray) {
        for (WSOptionView *optionView in self.optionViewArray) {
            if ([[optionView.dataItem getDataItemID] isEqualToString:selectItemID]) {
                [self setButton:optionView.button selected:YES];
                if (![self.selectedItems containsObject:optionView.dataItem]) {
                    [self.selectedItems addObject:optionView.dataItem];
                }
                break;
            }
        }
    }
    if ([[xbuildInfo getAcvtMemo2] isEqualToString:@"1"]) {
        if (self.selectedItems.count == self.dataSourceArray.count) {
            _checkAllBtn.checkBtn.selected = YES;
        }else{
            _checkAllBtn.checkBtn.selected = NO;
        }
    }
    
}

//用NSString返回所选项的ID，多个选项以“,”分隔（与服务器所需的上传格式一致）
-(NSObject *)getResultDirectly{
    
    NSMutableArray *itemIDArray = [NSMutableArray array];
    for (NSObject<I_W_OptionDataItem> *dataItem in self.selectedItems) {
        [itemIDArray addObject:[dataItem getDataItemID]];
    }
    
    if ([itemIDArray count] > 0) {
        return [itemIDArray componentsJoinedByString:@","];
    }
    else
    {
        return nil;
    }
}

- (NSObject *)getResultPresentation {
    NSMutableArray *itemNameArray = [NSMutableArray array];
    for (NSObject<I_W_OptionDataItem> *dataItem in self.selectedItems) {
        [itemNameArray addObject:[dataItem getDataItemName]];
    }
    
    if ([itemNameArray count] > 0) {
        return [itemNameArray componentsJoinedByString:@","];
    }
    else
    {
        return nil;
    }
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    BOOL readonly = NO;
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        readonly = YES;
    }
    
    for (WSOptionView *optionView in self.optionViewArray) {
        if ([self getReadOnly]) {
            [optionView.button setImage:[UIImage scaledImageForName:@"icn_check_2" ofType:@"png"] forState:UIControlStateSelected];
        }else {
            [optionView.button setImage:[UIImage scaledImageForName:@"icn_check" ofType:@"png"] forState:UIControlStateSelected];
        }
        
        [optionView optionViewEnable:!readonly];
        
    }
}

- (void)setValidDataSourceFromScript:(NSString *)validDataSource
{
    NSArray *dataSourceArray = [validDataSource componentsSeparatedByString:@","];
    
    NSMutableArray *validDataArray = [[NSMutableArray alloc] init];
    for (NSString *dataName in dataSourceArray) {
        for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
            if ([dataName isEqualToString:[item getDataItemName]]) {
                [validDataArray addObject:item];
                break;
            }
        }
    }
    
    self.dataSourceArray = validDataArray;
    
    [self buildDisplayContent];
}

- (NSObject *)getCurrentValue {
    //勾选中之后会执行此方法
    NSMutableArray *itemIDArray = [NSMutableArray array];
    for (NSObject<I_W_OptionDataItem> *dataItem in self.selectedItems) {
        [itemIDArray addObject:[dataItem getDataItemID]];
    }
    
    if ([itemIDArray count] > 0) {
        return itemIDArray;
    }
    
    return nil;
    
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    if ([valuePresentation isEqualToString:@"all"]) {
        [self selectAllItems ];
        return;
    }
    NSArray *validValueArray = [valuePresentation componentsSeparatedByString:@","];
    NSMutableArray *valueIDArray = [[NSMutableArray alloc] init];
    for (NSString *dataName in validValueArray) {
        for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
            if ([dataName isEqualToString:[item getDataItemName]] ) {
                [valueIDArray addObject:[item getDataItemID]];
                break;
            }
        }
    }
    
    _needRiseSelectionChange = NO;
    [self setupSelectionBySelectItemIDArray:valueIDArray];
    _needRiseSelectionChange = YES;
    
}

- (CGFloat)getFoldedContentHeight {
    return self.optionViewHeight;
}

#pragma mark - WSOptionViewDelegate

- (void)optionView:(WSOptionView *)optionView didClickItem:(NSObject<I_W_OptionDataItem> *)dataItem
{
    [self setButton:optionView.button selected:!optionView.button.selected];
    if ([self.selectedItems containsObject:dataItem]) {
        [self.selectedItems removeObject:dataItem];
    }
    else
    {
        [self.selectedItems addObject:dataItem];
    }
    //SFA-33992 增加全选按钮
    if (self.optionViewArray.count == self.selectedItems.count) {
        self.checkAllBtn.checkBtn.selected = YES;
    }else{
        self.checkAllBtn.checkBtn.selected = NO;
    }
    
    
    if (!_needRiseSelectionChange) {
        return;
    }
    
    [self checkValueChange];
    
    [self qstLua];
}

//SFA 项目SFA-23371 sfa 达利（ios）：工作-考试答题-常识竞赛-点击继续-开始答题 答题时选择图中的选项时闪退
- (void)optionView:(WSOptionView *)optionView didClickItemImage:(UIImage *)image{
    
    
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *descriptes = [NSMutableArray array];
    for (WSOptionView *optionView in self.optionViewArray) {
        [images addObject:optionView.iconImageView.image];
        [descriptes addObject:[optionView.dataItem getDataItemName]];
    }
    
    NSInteger index = optionView.tag - RADIOTAG;
    UIViewController *currentVc = [[WSApplicationWindowsRelationManager sharedManager] getCurrentVC];
    
    WSOptPhotoBrowseViewController *photoBrowseVc = [[WSOptPhotoBrowseViewController alloc]initWithImageIDs:images withImageDescription:descriptes];
    [photoBrowseVc gotoPage:index];
    photoBrowseVc.enableEdit = NO;
    photoBrowseVc.isAllowDeletePhoto = NO;
    [currentVc presentViewController:photoBrowseVc animated:YES completion:nil];
    
    
}

- (NSInteger)getDisPlayCheckBoxNumber{
    
    CGFloat maxOptionNameWidth = 0.0;
    for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
        
        UIFont *font = [UIFont systemFontOfSize:UI_Font];
        
        CGSize optinSize = [[dataItem getDataItemName] ws_sizeWithFont:font constrainedToWidth:self.width lineBreakMode:NSLineBreakByWordWrapping];
        
        if (optinSize.width > maxOptionNameWidth) {
            maxOptionNameWidth = optinSize.width;
        }
    }
    return self.width/(maxOptionNameWidth + 80);
}

- (void)widgetDidLoadFinish {
    /* YIHAIKERRY-3084 问题加载完成后若无必要不执行脚本，如果安卓执行可以去掉这个屏蔽
    [self qstLua];
    */
}
- (void)qstLua
{
    //   董宏添加 MMSH-3227
    _resultCheck = [self getDisplayValuePresentation];
    if (!_resultCheck) {
        _resultCheck=@"";
    }
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}

//选中全部
- (void)selectAllItems {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.dataSourceArray.count; i++) {
        
        NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:i];
        NSString *itemId =  [dataItem getDataItemID];
        if(itemId) {
            [arr addObject:itemId];
        }
   
    }
    [self setupSelectionBySelectItemIDArray:arr];

}
#pragma mark----全选UI------
- (void)setAllCheckBtnUI{
    //全选按钮的特殊处理 memo2
    if ([[xbuildInfo getAcvtMemo2] isEqualToString:@"1"]) {
        self.titleLabel.frame = CGRectMake(self.titleLabel.origin.x, self.titleLabel.origin.y, SCREEN_WIDTH - self.titleLabel.origin.x, self.titleLabel.height);
        self.titleLabel.userInteractionEnabled = YES;
        self.titleLabel.text = @"";
        _checkAllBtn = [[WSAllCheckBtn alloc]initWithFrame:CGRectMake(0,0, self.titleLabel.width, self.titleLabel.height) btnName:[xbuildInfo getQuestName]];
        [self.titleLabel addSubview:_checkAllBtn];
        __weak __typeof__(self) weakSelf = self;
        self.checkAllBtn.selectAllBtnAction = ^(BOOL isAllSelect) {
            if (isAllSelect) {
                [weakSelf selectAllItems];
            }else{
                for (int i =0; i<self.optionViewArray.count; i++) {
                    WSOptionView * optionView = weakSelf.optionViewArray[i];
                    [weakSelf setButton:optionView.button selected:NO];
                    if ([weakSelf.selectedItems containsObject:optionView.dataItem]) {
                        [weakSelf.selectedItems removeObject:optionView.dataItem];
                    }
                }
            }
        };
    }
}

@end
