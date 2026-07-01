//
//  WSRadioButtonPanel.m
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRadioButtonPanel.h"
#import "WidgetConstant.h"
#import "I_W_DataSource.h"
#import "WSRadioOptView.h"
#import "WSOptionView.h"
#import "I_W_DisplayValue.h"
#import "WSStringValueChangeChecker.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSOptPhotoBrowseViewController.h"

#define RADIOTAG 200

#define kOptionViewLeftSpace (INTERFACE_IS_PAD ? 20.0f : 10.0f)
#define kOptionViewContentSpace 12

@interface WSRadioButtonPanel ()<WSOptionViewDelegate>

@property (nonatomic, strong) NSObject<I_W_OptionDataItem>   *currentSelectItem;

@property (nonatomic, strong) NSMutableArray    *optionViewArray;
@property (nonatomic, strong) NSMutableArray    *optionWidthArray;
@property (nonatomic, assign) CGFloat           optionTotalWidth;

@property (nonatomic, strong) NSArray   *dataSourceArray;

@property (nonatomic, assign) CGFloat maxHorizontalOptionNameWidth;

@property (nonatomic, assign)BOOL isNeedDrag;

@end

@implementation WSRadioButtonPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        istrigselected =NO;
        self.optionViewArray = [NSMutableArray array];
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        _isNeedDrag = NO;
    
        return self;
    }
    
    return nil;
}


- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource
{
    [super loadDataSource:datasource];
    
    [datasource getDataSourceFor:xbuildInfo];
    
    self.dataSourceArray = (NSArray *)xdataSource.dataSourceArray;
}

- (void)buildDisplayContent
{
    [self removeAllSubviews];
    
    [self.optionViewArray removeAllObjects];
    
    [super buildDisplayContent];
    
    CGFloat height = self.titleLabel.height;
    
    
    BOOL isReadOnly = [self getReadOnly];
    
    BOOL orientation = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientation = YES;
    }

    NSInteger maxDisNumberInline  =  [self getHorizontalMaxNumberWithWidth:(self.width - self.titleLabel.right - 3*MAIN_CELL_PADDING)];
    
    NSInteger maxDisNmuber = 0;
    BOOL isMultiseriate = NO; // 一行显示多个，折行显示
    
    // MN-1955 新增memo4存放多行显示一行最大显示个数
    if ([xbuildInfo getAcvtMemo4].length > 0 && [[xbuildInfo getAcvtMemo4] integerValue] > 0) {
        isMultiseriate = YES;
        maxDisNmuber = [[xbuildInfo getAcvtMemo4] integerValue];
        _maxHorizontalOptionNameWidth = (self.width - 2* MAIN_CELL_PADDING)/maxDisNmuber;
    }else
        maxDisNmuber = [self getHorizontalMaxNumberWithWidth:( self.width - 2* MAIN_CELL_PADDING)];
    
    
    NSInteger maxDisNmuberInMultiseriate = (self.width - 2*MAIN_CELL_PADDING)/_maxHorizontalOptionNameWidth;
    
    BOOL isInOneLine = NO;// 标题与opt选项 分行显示
    BOOL isInOneLineTitleAndOpt = NO; // 标题与opt一行显示
    NSObject<I_W_OptionDataItem> *oneDataItem = [self.dataSourceArray firstObject];
    if ([oneDataItem respondsToSelector:@selector(getDataItemPic)] && [[oneDataItem getDataItemPic] length] > 0) {
        _isNeedDrag = YES;
    }else if (self.dataSourceArray.count >0 && self.dataSourceArray.count <= maxDisNumberInline && orientation == YES){
        isInOneLineTitleAndOpt = YES;
        isInOneLine = YES;
    }else if (self.dataSourceArray.count >0 && self.dataSourceArray.count <= maxDisNmuber && orientation == YES){
        isInOneLine = YES;
    }else if (0){
        isMultiseriate = YES;
    }
    
    //MN-2652 2018-06-01
    CGFloat tempWidth = (self.width - self.optionTotalWidth - MAIN_CELL_PADDING);
    CGFloat snapScrollViewOffX = ((isInOneLineTitleAndOpt ? ((self.titleLabel.hidden == YES) ? MAIN_CELL_PADDING : tempWidth) : MAIN_CELL_PADDING));
    //CGFloat snapScrollViewOffX = isInOneLineTitleAndOpt ? self.width - self.optionTotalWidth - MAIN_CELL_PADDING:  MAIN_CELL_PADDING;
    CGFloat snapScrollViewOffY = isInOneLineTitleAndOpt ? 0.0 : height;
    CGFloat snapScrollViewWidth =  isInOneLineTitleAndOpt ? (self.optionTotalWidth )  : (self.width - MAIN_CELL_PADDING * 2 );
    CGFloat snapScroollViewHeight = self.height  - snapScrollViewOffY;
    
    UIScrollView *snapScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(snapScrollViewOffX, snapScrollViewOffY, snapScrollViewWidth, snapScroollViewHeight)];
    snapScrollView.backgroundColor = [UIColor clearColor];
    snapScrollView.bounces=NO;
    [self addSubview:snapScrollView];
    
   // YIHAIKERRY-1260
 //   snapScrollView.autoresizingMask=  UIViewAutoresizingFlexibleHeight ;
    snapScrollView.showsHorizontalScrollIndicator=NO;

    CGFloat contentWidth = 0.0f;
    // MSTD-6803  MSTD-6639 选项标题一行显示的时候，选项行间距是标准高度，否则间距变小
    CGFloat optionY = isInOneLine ? 0 : MAIN_PADDING;
    CGFloat left = 0.0;
    CGFloat yOffSet = 0.0;
    
    BOOL hasPic = NO;

    for (int i = 0; i < self.dataSourceArray.count; i++) {
        
        CGRect optionRect = CGRectMake(left, optionY, snapScrollView.width, MAIN_CELL_HEIGHT);
        CGFloat optionX = left;
        NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:i];
        CGFloat optionWidth = 0.0;
        if (isInOneLineTitleAndOpt || isInOneLine || _isNeedDrag) {
            yOffSet = 0;
            if (_isNeedDrag) {
                 optionWidth = _maxHorizontalOptionNameWidth;
            }else{
                optionWidth = [self.optionWidthArray[i] floatValue];
            }
            optionY = yOffSet;
            left += kOptionViewContentSpace;
        }else if (isMultiseriate){
            optionWidth = _maxHorizontalOptionNameWidth;
            left += kOptionViewContentSpace;
        }else{
            optionWidth = snapScrollView.width;
        }
        optionRect = CGRectMake(optionX, optionY, optionWidth, MAIN_CELL_HEIGHT);

        // MSTD-6639 间距要要比其他控件小
        UIFont *font = ([dataItem respondsToSelector:@selector(getDataItemPic)] && [[dataItem getDataItemPic] length] > 0) ?  FONT_SIZE_PINGFANG_MEDIUM(11) :  FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
        CGSize size = [[dataItem getDataItemName] ws_sizeWithFont:font constrainedToWidth:optionRect.size.width lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat ratio = isInOneLineTitleAndOpt ? 1.0 : (kOptionViewHeight / MAIN_CELL_HEIGHT);
        size = [self.titleLabel labelAndPaddingResize:size ratio:ratio];

        optionRect.size.height = size.height;
        
        if ([dataItem respondsToSelector:@selector(getDataItemPic)]) {
            if ([[dataItem getDataItemPic] length] > 0) {
                hasPic = YES;
            }
        }
        WSOptionView *optionView = [[WSOptionView alloc] initWithFrame:optionRect andDataItem:dataItem withMultiseriate:isMultiseriate];
        optionView.tag = RADIOTAG + i ;
        left += optionView.width;
        [optionView.button setImage:[UIImage imageNamed:@"selected_no_radio"] forState:UIControlStateNormal];
        [optionView.button setImage:[UIImage imageNamed:@"selected_yes_radio"] forState:UIControlStateSelected];

        if (isReadOnly) {
            [optionView optionViewEnable:NO];
        }

        optionView.delegate = self;
        [snapScrollView addSubview:optionView];
        //[self addSubview:optionView];

        [self.optionViewArray addObject:optionView];


        if (isMultiseriate) {
            if ((i + 1)% maxDisNmuberInMultiseriate  == 0) {
                optionY +=optionView.height;
                left = 0.0;
            }
        }else if (isInOneLine || isInOneLineTitleAndOpt || _isNeedDrag){
            if ((i +1) == self.dataSourceArray.count) {
                optionY += optionView.height;
            }
        }else{
            optionY += optionView.height;
            left = 0.0;
         }
    }
    if (isInOneLineTitleAndOpt) {
        optionY += 10;
    } else {
        optionY += 10 + MAIN_PADDING;
    }
    // 如果数据源仅有一项且为必填则直接选中该选项
    if ([[xbuildInfo getISRequire] isEqualToString:@"1"] && [self.dataSourceArray count] == 1) {
        [self setCurrentSelectItem:[self.dataSourceArray firstObject]];
    }
    
    NSString *selectItemID = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    [self setCurrentSelectItemByID:selectItemID];

    _originalValue = selectItemID;
    
    WSOptionView *lastOptionView = [self.optionViewArray lastObject];
    if (lastOptionView) {
        contentWidth = lastOptionView.right;
    }
    if (_isNeedDrag && contentWidth > snapScrollView.width) {
        snapScrollView.contentSize = CGSizeMake(contentWidth, 0);

    }
    if (isInOneLine) {
        height += 0;
        
        self.titleLabel.frame = CGRectMake(self.titleLabel.left, (height - self.titleLabel.height)/2, self.titleLabel.width, self.titleLabel.height);
    }
    
   
    float lineGap = 0.0f;
    if (hasPic) {
        lineGap = MAIN_PADDING;
    }
    
    CGFloat scrollHeight = lastOptionView.bottom;
    if (!isInOneLine && self.dataSourceArray.count > 0) {
        scrollHeight += MAIN_PADDING;
    }
    CGRect scrollViewRect = snapScrollView.frame;
    scrollViewRect.size.height = scrollHeight;
    scrollViewRect.origin.y = scrollViewRect.origin.y + lineGap;
    snapScrollView.frame = scrollViewRect;
    
    CGRect rect = self.frame;
    rect.size.height = snapScrollView.bottom;
    self.frame = rect;
    //横线覆盖表格的问题
    if (!self.titleLabel.hidden  && !isMultiseriate) {
        CGRect titleFrame = self.titleLabel.frame;
        /*Jira - MSTD-6841  分割线顶到头 create by sunhongfu 2017-11-8*/
        //SFA-15964
        UIView *seperateLineView  = [[UIView alloc] initWithFrame:CGRectMake(SEPERATE_PADDING_Left, CGRectGetMaxY(self.frame)-MAIN_CELL_SEPERATOR_HEIGHT, self.width , MAIN_CELL_SEPERATOR_HEIGHT)];
        [seperateLineView setBackgroundColor:DETAIL_SEPERATE_LINE_COLOR];
        [self addSubview:seperateLineView];
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
            UIImage *image = [UIImage imageNamed:@"selected_yes_radio_disabled"];
            [button setImage:image forState:UIControlStateNormal];
        }else {
            [button setImage:[UIImage imageNamed:@"selected_no_radio_disabled"] forState:UIControlStateNormal];
        }
    }
    
    [button setSelected:selected];
}

- (void)setCurrentSelectItemByID:(NSString *)selectItemID
{
    if (selectItemID.length == 0) {
        _currentSelectItem = nil;
    }
    for (WSOptionView *optionViewObj in self.optionViewArray) {
        NSString *optName = [optionViewObj.dataItem getDataItemName];
        NSString *optId = [optionViewObj.dataItem getDataItemID];
        
        NSArray *arr = [selectItemID componentsSeparatedByString:@","];
        if (arr && arr.count > 0) {
            for (NSString *selID in arr) {
                if ([optId isEqualToString:selID] || [optName isEqualToString:selID]) {
                    
                    [self setButton:optionViewObj.button selected:YES];
                    
                    _currentSelectItem = optionViewObj.dataItem;
                    _resultCheck = [_currentSelectItem getDataItemName];
                }
                else
                {
                    [self setButton:optionViewObj.button selected:NO];
                }
            }
        } else {
            [self setButton:optionViewObj.button selected:NO];
        }
    }
    // SFA-14896 按照安卓逻辑 设置值后触发脚本
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    
}

- (void)setCurrentSelectItem:(NSObject<I_W_OptionDataItem> *)currentSelectItem
{
    if ([self.optionViewArray count]==1 && istrigselected) {
        
        [self setCurrentSelectedItem:currentSelectItem];
        
        return;
    }else{
    
       if (_currentSelectItem != currentSelectItem  && istrigselected) {
        
            [self setCurrentSelectedItem:currentSelectItem];
       }
    }
}


-(void)setCurrentSelectedItem:(NSObject<I_W_OptionDataItem> *)currentSelectItem{
    
    
    _currentSelectItem = currentSelectItem;
    
    for (WSOptionView *optionViewObj in self.optionViewArray) {
        if (optionViewObj.dataItem == currentSelectItem) {
            
            BOOL selected =YES ;
            if (self.optionViewArray.count == 1 && optionViewObj.button.isSelected) {
            
                    selected = NO;
                    _currentSelectItem = nil;
               
            }
            [self setButton:optionViewObj.button selected:selected];
        }
        else
        {
            [self setButton:optionViewObj.button selected:NO];
        }
    }

}

-(NSObject *)getResultDirectly{
    
    if (self.currentSelectItem) {
        return [self.currentSelectItem getDataItemID];
    }
    else
    {
        return nil;
    }
}

- (NSObject *)getResultPresentation {
    if (self.currentSelectItem) {
        return [self.currentSelectItem getDataItemName];
    }
    else
    {
        return nil;
    }
}

// 刷新其显示的值(value应该对象其选项的id)
- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    if(value){
       [self setCurrentSelectItemByID:(NSString *)value];
    }
    /*执行lua*/
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}


- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
 
    BOOL readonly = [self getReadOnly];
    
    for (WSOptionView *optionView in self.optionViewArray) {
        
        [optionView optionViewEnable:!readonly];
        
        if (!readonly) {
            [optionView.button setImage:[UIImage imageNamed:@"selected_no_radio"] forState:UIControlStateNormal];
            [optionView.button setImage:[UIImage imageNamed:@"selected_yes_radio"]forState:UIControlStateSelected];
        }else {
            [optionView.button setImage:[UIImage imageNamed:@"selected_no_radio"]forState:UIControlStateNormal];
            [optionView.button setImage:[UIImage imageNamed:@"selected_yes_radio"]forState:UIControlStateSelected];
        }
    }
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {

    NSString *itemID;

    for (NSObject<I_W_OptionDataItem> *item in self.dataSourceArray) {
        if ([[item getDataItemName] isEqualToString:valuePresentation]) {
            itemID = [item getDataItemID];
            break;
        }
    }
    
    if (!itemID) {
        itemID = valuePresentation;
    }
    
    [self setCurrentSelectItemByID:itemID];
}



- (void)widgetDidLoadFinish {
    /* YIHAIKERRY-3084 问题加载完成后若无必要不执行脚本，如果安卓执行可以去掉这个屏蔽
    // YIHAIKERRY-2308 对照安卓逻辑此问题无值时，也需要走脚本
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0 /*&& _originalValue* /) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    */
}

- (NSInteger)getHorizontalMaxNumberWithWidth:(CGFloat)width{
    if (self.optionWidthArray) {
        [self.optionWidthArray removeAllObjects];
    } else {
        self.optionWidthArray = [NSMutableArray array];
    }
    UIImage *image = [UIImage scaledImageForName:@"selected_no_radio" ofType:@"png"];
    CGFloat imageWidth = image.size.width;
    NSInteger maxNumber = 0;
    CGFloat maxOptionNameWidth = 0.0;
    self.optionTotalWidth = 0.0;
    
    for (int i = 0 ; i < self.dataSourceArray.count; i ++) {
        NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:i];
        UIFont *font = FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
        
        if ([dataItem respondsToSelector:@selector(getDataItemPic)] && [[dataItem getDataItemPic] length] > 0) {
            _isNeedDrag = YES;
            font =  FONT_SIZE_PINGFANG_MEDIUM(11);
        }
        
        CGSize optionSize = [[dataItem getDataItemName] ws_sizeWithFont:font constrainedToWidth:self.width lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat optionWidth = optionSize.width + MAIN_PADDING + imageWidth;
        if (optionWidth < OPTVIEW_ICONIMAGEVIEW_WH && _isNeedDrag) {
            optionWidth = OPTVIEW_ICONIMAGEVIEW_WH;
        }
        CGFloat optionspace = (i == self.dataSourceArray.count - 1 ) ? 0.0 :kOptionViewContentSpace;
        CGFloat optionTotalWidth =  optionWidth + optionspace;
        maxOptionNameWidth += optionTotalWidth;
        
        if (_maxHorizontalOptionNameWidth == 0.0 || _maxHorizontalOptionNameWidth < optionWidth) {
            _maxHorizontalOptionNameWidth = optionWidth;
        }
        [self.optionWidthArray addObject:[NSNumber numberWithFloat:optionWidth]];
        if (width < maxOptionNameWidth) {
            continue;
        } else {
            self.optionTotalWidth += optionTotalWidth;
            maxNumber ++;
        }
    }
    return maxNumber;
    
}

#pragma mark - WSOptionViewDelegate

- (void)optionView:(WSOptionView *)optionView didClickItem:(NSObject<I_W_OptionDataItem> *)dataItem
{
    istrigselected =YES;
    
    // SFA-17151 董宏
    if(dataItem == self.currentSelectItem){
        self.currentSelectItem = nil;
        _resultCheck = nil;
    }
    else{
        self.currentSelectItem = dataItem;
        _resultCheck = [dataItem getDataItemName];
    }

    
    [self checkValueChange];
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}

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
#pragma mark -
#pragma mark I_Lua_Target_Operator method

//- (NSObject *)getDisplayValuePresentation{
//    
//    NSString *result = nil;
//    
//    if (_originalValue) {
//        for (NSObject<I_W_OptionDataItem> *item in xdataSource.dataSourceArray) {
//            if ([[item getDataItemID] isEqualToString:(NSString *)_originalValue]) {
//                result = [item getDataItemName];
//                break;
//            }
//        }
//    }
//    
//    return result;
//}


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

@end
