//
//  BaseGrideViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSBaseGrideViewController.h"
#import "DataGridComponent.h"
#import "WSFuncsBean.h"
#import "WSFuncsBean_Param.h"
#import "WSAppData.h"
#import "WSStoreBean.h"
#import "WSStoreBean_prod.h"
#import "WSDictBean.h"
#import "WSReasonViewController.h"
#import "WSCurrentTime.h"
#import "WSProdBean.h"
#import "WSProdBeanArray.h"
#import "WSDictBean.h"
#import "WSFptTable.h"
#import "WSFdtTable.h"
//#import "ConfigFileController.h"
#import "WSAcvtViewController.h"
#import "WSAcvtBean.h"
#import "WSSelectListView.h"
#import "WSAbnormalDetailAcvtViewController.h"
#import "GridNameLabel.h"
#import "WSGridTextInputViewController.h"
#import "WCPopListView.h"
#import "UILabel+Additional.h"
#import "WSMultipleChoiceLabel.h"
#import "WSPhotoGalleryViewController.h"
#import "PhotoTypeButton.h"
#import "WCURLUILabel.h"
#import "WSMultipleChoiceLabel.h"
#import "WSDicBeanItemOfChoice.h"
#import "WSMultipleChoiceViewController.h"
#import "WSProductBeanItemofChoice.h"
#import "WSServerIPList.h"
#import "UIButton+Filter.h"
#import "WSValidateData.h"
#import "WSAcvtButtonForTB.h"
#import "WSGettingValues.h"
#import "WSDatePickerLabel.h"
#import "WSFuncsBean_other.h"
#import "WSNRLabel.h"
#import "WSQRTypeView.h"
#import "WSFormulaStringCalcUtility.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
#import "WSLuaScript.h"

#import "WSBaseStoreProdDisTable.h"
#import "WSEnvrionment.h"
#import "WinSFA.h"
#import "WSBaseDictsDBService.h"
#import "NSString+Additions.h"
#import "WSBaseDataGridComponentDataSource.h"
#import "WSSingleSelectAndSearchViewController.h"
#import "WSBaseAcvtDBService.h"
#import "NSString+ServerUrl.h"

#define SHORT_COLUMN_WIDTH          @"100"
#define DEFAULT_COLUM_WIDTH          @"150"
#define GRIDVIEWTAG                 1000
#define kRadioButtonBaseTag     10000
//表格提示标签Tag 专用
#define NoticeLabelTag  20000



@interface WSBaseGrideViewController()<WCPopListViewDelegate,WSMultipleChoiceDelegate,ZJPSelectListDelegate,singleSelectAndSearchDelegate,UIActionSheetDelegate>
{
    CGRect dataGridComponentRect;
    CGFloat moreHeight;
    BOOL _isAllProducts;
    BOOL _isFirstLoadView;
}
@property (nonatomic, strong) WSSelectListView *currentSelectListView;
@property (nonatomic, strong) PhotoTypeButton *currentPhotoButton;
@property (nonatomic, strong) NSMutableDictionary *cliclkRowDictioanry;
@property (nonatomic, assign) CGFloat gridViewChangeHeight;


@end

@implementation WSBaseGrideViewController
//@synthesize m_DataBaseDatas;
//@synthesize m_dataSources;
//@synthesize m_moreProds;
//@synthesize m_moreProdsCount;
@synthesize formulaDictionary = _formulaDictionary;
@synthesize abnormalReasonDict = _abnormalReasonDict;
@synthesize resonButtons = _resonButtons;
@synthesize isValueChange = _isValueChange;

- (void)reLayoutButtonAndGridViewWithIsAllProducts:(BOOL)isAllProducts
{
    
}

-(void)productReason:(id)sender
{

    WSAcvtButtonForTB *button = (WSAcvtButtonForTB *)sender;
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *l_acvts = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:button.iFilter];

    
    WSAcvtBean* l_acvt = nil;
    if([l_acvts count]>0)
        l_acvt = [l_acvts objectAtIndex:0];
    
    WSAbnormalDetailAcvtViewController* l_avc = [[WSAbnormalDetailAcvtViewController alloc]initWithAcvt:l_acvt Funcs:self.currentFuncs Store:self.currentStore Section:((UIButton *)sender).tag + 1 andIdentify:button.iIdentifyId];
    l_avc.parentGridVC = self;
    l_avc.dictRow = button.iRow;
    
    [l_avc setParentBtn:sender];
    
    [self.navigationController pushViewController:l_avc animated:YES];
}

- (void)checkBoxPressed:(id)sender{
    if ([self.baseDataGridComponentDataSource.currentQst.readonly isEqualToString:@"1"]) {
        return;
    }
    self.isValueChange = YES;
    // 兼容COL_TYPCHECKBOX 和 COL_TYPCHECKBOXALL 类型
    if ([sender isKindOfClass:[WSCheckBox class]]) {
        WSCheckBox *checkBoxSelected = (WSCheckBox *)sender;
        
        checkBoxSelected.isClicked = YES;
        
        NSString* i_isSelected = @"0";

        if (checkBoxSelected.selected) {
            [checkBoxSelected setSelected:NO];
            i_isSelected = @"0";
        }else{
            [checkBoxSelected setSelected:YES];
            i_isSelected = @"1";
        }
        
        WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:checkBoxSelected.iColumn];
        id data = [self.m_dataSources objectAtIndex:checkBoxSelected.iRow];//TODO：将来需要重构m_DataBaseDatas，使类型确定

        
        if ([data isKindOfClass:[WSProdBean class]]) {
            [_prod_cacheDataMDictionary setObject:i_isSelected forKey:[NSString stringWithFormat:@"%@_%@", [(WSProdBean *)data Id], param.col]];
        }else if ([data isKindOfClass:[WSProductObject class]]) {
            [_prod_cacheDataMDictionary setObject:i_isSelected forKey:[NSString stringWithFormat:@"%@_%@", [(WSProductObject *)data prod_id], param.col]];
        }
        
        
        //增加逻辑针对 COL_TYPCHECKBOXALL 类型
        if ([checkBoxSelected.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
            BOOL resultSelected = checkBoxSelected.selected;
            BOOL isHeaderCheckBox = NO;
            
            //判断是否表头checkBox ,定义见 DataGridComponent.m ,目前表头嵌入checkBox只支持除第0列以外的列。
            
            if ([self.checkBoxesArrayOfHeaderView containsObject:sender]) {
                isHeaderCheckBox = YES;
            }
            
            // 采集表格每一项UI针对一种产品，目前没有找到内存数据项，只能遍历UI
            if (isHeaderCheckBox) {
                
                //查找表格中数组里同列checkBox
                for (NSArray *arrayTemp in self.datas) {
                    for (id objectTemp in arrayTemp) {
                        if ([objectTemp isKindOfClass:[WSCheckBox class]]) {
                            WSCheckBox *checkBoxTemp = (WSCheckBox *)objectTemp;
                            if (checkBoxTemp.iColumn == checkBoxSelected.iColumn) {
                                [checkBoxTemp setSelected:resultSelected];
                            }
                        }
                    }
                }
                
            }else{
                
                if (resultSelected) {
                    
                    //所有的产品
                    NSInteger countPro = 0;
                    //被选中的产品
                    NSInteger countSelected = 0;
                    for (NSArray *arrayTemp in self.datas) {
                        for (id objectTemp in arrayTemp) {
                            if ([objectTemp isKindOfClass:[WSCheckBox class]]) {
                                WSCheckBox *checkBoxTemp = (WSCheckBox *)objectTemp;
                                if (checkBoxTemp.iColumn == checkBoxSelected.iColumn) {
                                    if (checkBoxTemp.selected) {
                                        countSelected = countSelected + 1;
                                    }
                                    countPro = countPro + 1;
                                }
                            }
                        }
                    }
                    //所有产品该列都被选中，则全部选择项为选中状态
                    if (countPro == countSelected
                        &&  [self.checkBoxesArrayOfHeaderView count] > 0) {
                        for (id temp in self.checkBoxesArrayOfHeaderView) {
                            if ([temp isKindOfClass:[WSCheckBox class]]) {
                                WSCheckBox *checkBoxTemp = (WSCheckBox *)temp;
                                if (checkBoxTemp.iColumn == checkBoxSelected.iColumn) {
                                    
                                    [checkBoxTemp setSelected:YES];
                                }
                                
                            }
                        }
                    }
                    
                }else{
                    
                    //取消选中一项CheckBox，则重置同列 checkBoxALL 的selected状态
                    if (self.checkBoxesArrayOfHeaderView
                        && [self.checkBoxesArrayOfHeaderView count] > 0) {
                        for (WSCheckBox *checkBoxTemp in self.checkBoxesArrayOfHeaderView) {
                            if (checkBoxTemp.iColumn == checkBoxSelected.iColumn) {
                                [checkBoxTemp setSelected:resultSelected];
                            }
                        }
                    }
                }
                
            }
        }
        
    }else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        NSMutableArray *array = [self.datas objectAtIndex:btn.tag];
        if (((UIButton *)sender).selected) {
            [(UIButton *)sender setSelected:NO];
        }else{
            
            NSInteger l_datasColumns = [self.titles count]-1;
            for (NSInteger j = 0; j < l_datasColumns; j++) {
                WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
                id item = [array objectAtIndex:j+1]; // +1 is for title (0 column)
                if ( (param.isMutex) && [item isKindOfClass:[UIButton class]] ) {
                    [((UIButton *)item) setSelected:NO];
                }
            } // end for
            
            [(UIButton *)sender setSelected:YES];
        }
    }
    
}

- (void)radioButtonPressed: (id)sender{
    self.isValueChange = YES;
    if ([sender isKindOfClass:[UIButton class]]) {
        WSRadioButton *clickButton = (WSRadioButton *)sender;
        NSInteger clickRow = clickButton.iRow;
        NSArray *rowViews = [self.datas objectAtIndex:clickRow];
        [rowViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[WSRadioButton class]]) {
                WSRadioButton *tempRadio = (WSRadioButton *)obj;
                if (tempRadio != clickButton && tempRadio.iRow == clickRow) {
                    [tempRadio setCurSelected:NO];
                }
            }
        }];
        [clickButton setCurSelected:!clickButton.selected];
    }
}


-(NSInteger)getSpecIndexbyParam:(WSFuncsBean_Param*)param
{
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPEC];
    int index = 0;
    for(NSString* targetCol in spec)
    {
        if([targetCol isEqualToString:param.col])
            return index;
        index++;
    }
    
    return 100;
}

// 找到用来回显数据的index。
// param.redis 为0 不回显
// param.redis 为1 回显 pram.col 在storeproddis节点对应的index下的数据
// param.redis 为（列：oos）则回显 00s在storeproddis节点对应的index下的数据
-(NSInteger)getProdspecRedisIndexbyParam:(WSFuncsBean_Param*)param
{
    NSString *paramRedis = nil;
    if (param.redis && [param.redis isEqualToString:@"0"]) {
        return NSNotFound;
    }
    if (param.redis && [param.redis isEqualToString:@"1"]) {
        paramRedis = param.col;
    } else if (param.redis && [param.redis length] > 0) {
        paramRedis = param.redis;
    }
    
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (spec == nil) {
        spec= [WSAppData getObjectbyKey:PRODSPEC];
    }
    for (NSInteger i =0;i < [spec count]; i++) {
        NSString *specIndexString  = [spec objectAtIndex:i];
        if (specIndexString &&[specIndexString isEqualToString:paramRedis]) {
            return i;
        }
    }
    return NSNotFound;
}


-(NSInteger)getSpecRedisIndexbyParam:(WSFuncsBean_Param*)param
{
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPEC];
    int index = 0;
    if ([param.redis isEqualToString:@"1"])
    {
        for(NSString* targetCol in spec)
        {
            if([targetCol isEqualToString:param.col])
                return index;
            index++;
        }
    }
    else {
        for(NSString* targetCol in spec)
        {
            if([targetCol isEqualToString:param.redis])
                return index;
            index++;
        }
        
    }
    //NSLog(@"%d",NONEEXIST);
    return NONEEXIST;
}


-(void)setColumnsDatasOfTitles
{
    if([self.titles count]==0)
    {
        {
            NSString *item = nil;
            if ([self.currentFuncs.opt.name isKindOfClass:[NSString class]]) {
                item = self.currentFuncs.opt.name;
            } else if ([self.currentFuncs.opt.title isKindOfClass:[NSString class]]) {
                item = self.currentFuncs.opt.title;
            } else if ([self.currentFuncs.ds isKindOfClass:[NSString class]] && ([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC])) {
                item = NSLocalizedString(@"default_left_attach_header_label", nil);
            } else {
                item =  NSLocalizedString(@"table_dict_title_project", nil); //项目
            }
            [self.titles addObject:item];
        }
        
        NSInteger paramCount = [self.currentFuncs.paramArray count];
        for(NSInteger i = 0 ; i < paramCount; i++)
        {
            WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
            [self.titles addObject:fb_Param.name];
        }
        
    }
    
}
//提取setColumnViewcintroller中重复的部分为函数 by yanguoshuai at 2012－04－09
-(void)setColumnWidth:(NSString *)a_Width paramCount:(NSInteger)a_paramCount
{
    [self.colWidth addObject:a_Width];
    for( NSInteger i = 0; i < a_paramCount; i++)
    {
        WSFuncsBean_Param *fb = nil;
        NSInteger unitValue = UNIT_WIDTH_DEFAULT;
        
        
        fb = [self.currentFuncs.paramArray objectAtIndex:i];
        
        if (fb.charNum.integerValue > 0)
        {
            if ([fb.tpy isEqualToString:@"N"]   ||
                [fb.tpy isEqualToString:@"C"]   ||
                [fb.tpy isEqualToString:@"CHT"] ||
                [fb.tpy isEqualToString:@"R"]   ||
                [fb.tpy isEqualToString:@"D"]   ||
                [fb.tpy isEqualToString:@"P"]   ||
                [fb.tpy isEqualToString:@"DT"]  ||
                [fb.tpy isEqualToString:@"SD"]  ||
                [fb.tpy isEqualToString:COL_TYPCHECKBOXALL]
                )
            {// 数字 标点 按钮 中文  单位字符的宽度
                unitValue =  UINIT_WIDTH_OTHER;
            }
            else if ([fb.tpy isEqualToString:@"T"])
            {// 字母 单位字符的宽度
                unitValue = UINIT_WIDTH_T;
            }
            else if ([fb.tpy isEqualToString:@"B"])
            {// 按钮  待测试
                unitValue = UINIT_WIDTH_B;
            }
            
            if ([fb.tpy isEqualToString:COL_TYPCHECKBOXALL])
            {
                //表头包含checkBox的列宽需要特殊处理 (多选项控件UI占2字节宽度（多选项图片）, 其他则是文字显示宽度) 如有改变则调整
                [self.colWidth addObject:[NSString stringWithFormat:@"%ld_%ld", (long)(fb.charNum.integerValue - 2) * unitValue ,2 * (long)unitValue]];
            }else{
                
                [self.colWidth addObject:[NSString stringWithFormat:@"%ld", (long)fb.charNum.integerValue * unitValue]];
            }
            
            
        }
        else if(fb.wcol > 0)
        {
            if ([fb.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                
                [self.colWidth addObject:[NSString stringWithFormat:@"%ld_%ld", (long)fb.wcol,(long)fb.wcol]];
            }else{
                
                [self.colWidth addObject:[NSString stringWithFormat:@"%ld", (long)(long)fb.wcol]];
            }
            
        }
        else
        {
            if ([fb.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                
                [self.colWidth addObject:[NSString stringWithFormat:@"%@_%@", a_Width,a_Width]];
            }else{
                
                [self.colWidth addObject:a_Width];
            }
            
        }
    }
}

-(void)setColunmViewWidth
{
    if(self.colWidth==nil)
    {
        NSMutableArray* colArray = [[NSMutableArray alloc]init];
        self.colWidth = colArray;
    }
    [self.colWidth removeAllObjects];
    NSInteger paramCount = [self.currentFuncs.paramArray count];
    
    
    CGFloat detailSizeWidth = DETAILSIZEWIDTH;
    NSString *fwol = nil;
    if (paramCount>1)
    {
        fwol = ((self.currentFuncs.fCharNum > 0) ? [NSString stringWithFormat:@"%d", self.currentFuncs.fCharNum * (int)detailSizeWidth] : [NSString stringWithFormat:@"%d", self.currentFuncs.wfcol]);
        if (fwol.integerValue <=0) {
            fwol = SHORT_COLUMN_WIDTH;
        }
    }
    else
    {
        fwol = ((self.currentFuncs.fCharNum > 0) ? [NSString stringWithFormat:@"%d", self.currentFuncs.fCharNum * (int)detailSizeWidth] : [NSString stringWithFormat:@"%d", self.currentFuncs.wfcol]);
        if (fwol.integerValue <=0) {
            fwol = DEFAULT_COLUM_WIDTH;
        }
    }
    if (fwol) {
        [self setColumnWidth:fwol paramCount:paramCount];
    }
    
}

//插入行的第一列
-(UILabel*)setFirstColumnDataWithIndex:(NSInteger)aIndex Datas:(NSArray*)aDatas
{
    //first column width
    NSString *firstWidth = [self.colWidth objectAtIndex:0];
    int width = [firstWidth intValue];
    NSString *titleText = nil;
    //第一列的view和数据
    //    GridNameLabel *l_title_view = [[[GridNameLabel alloc] initWithFrame:CGRectMake(0,0,width,29)]autorelease];
    //    l_title_view.userInteractionEnabled = TRUE;
    
    
    
    
    WCURLUILabel *l_title_view = [[WCURLUILabel alloc] initWithFrame:CGRectZero];
    
    //    l_title_view.iImageURL = @"http://demo.winchannel.net:10334/photos/message_2013-03-01/testinfo.jpg";
    //第一列的数据
    if ([self respondsToSelector:@selector(getDataSourcesWithIndex:Other:)]) {
        l_title_view.text = [self performSelector:@selector(getDataSourcesWithIndex:Other:) withObject:[NSNumber numberWithInteger:aIndex] withObject:aDatas];
        titleText = l_title_view.text;
    }
    if ([self respondsToSelector:@selector(getDetailProductNameWithIndex:Other:)]) {
        l_title_view.detailText = [self performSelector:@selector(getDetailProductNameWithIndex:Other:) withObject:[NSNumber numberWithInteger:aIndex] withObject:aDatas];
        if (!titleText) {
            titleText = l_title_view.detailText;
        }
    }
    if ([self respondsToSelector:@selector(getDataSourcesIdWithIndex:Other:)]) {
        NSString *l_title_tag = [self performSelector:@selector(getDataSourcesIdWithIndex:Other:) withObject:[NSNumber numberWithInteger:aIndex]  withObject:aDatas];
        l_title_view.tag = [l_title_tag integerValue];
    }
    
    UIFont *font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
    l_title_view.font = font;
    l_title_view.textAlignment = NSTextAlignmentCenter;
    l_title_view.numberOfLines = 2;
    l_title_view.lineBreakMode = NSLineBreakByCharWrapping;
   
    //根据产品名称重新计算第一列宽度
    if (titleText) {
        [self resetTitleViewFrame:l_title_view byText:titleText andWidth:width];
    }
    
    
    id obj = [aDatas objectAtIndex:aIndex];
    if ( [obj isKindOfClass:[WSProdBean class]]) {
        WSProdBean *bean = [aDatas objectAtIndex:aIndex];
        l_title_view.productID = bean.Id;
        if (bean.url != nil && [bean.url length] > 0) {
            NSString *url = [bean.url buildupUrl];
            //            NSLog(@"%@", url);
            l_title_view.iImageURL = url;
        }
        
    }else if ([obj isKindOfClass:[WSDictBean class]]){
        WSDictBean *bean = [aDatas objectAtIndex:aIndex];
        l_title_view.tag = [bean.Id integerValue];
    }
    
    return l_title_view;
}

- (void)resetTitleViewFrame:(WCURLUILabel *)l_title_view byText:(NSString *)text andWidth:(CGFloat)width {
    CGFloat maxWdith = self.view.width - MAIN_PADDING;
    if (width > maxWdith) {
        width = maxWdith;
    }
    
    CGSize titleSize = [text ws_sizeWithFont:l_title_view.font constrainedToWidth:width];
    CGFloat titleHeight = titleSize.height;
    if (titleHeight < DATAGRID_CELL_HEIGHT_DEFAULT) {
        titleHeight = DATAGRID_CELL_HEIGHT_DEFAULT;
    } else {
        titleHeight += MAIN_PADDING * 2;
    }
    
    l_title_view.frame = CGRectMake(MAIN_PADDING, 0, width, titleHeight);

}

//数据库的数据
-(NSString*)getDatasFromDataBase:(WSFuncsBean_Param*)aParam Data:(id)aData
{
    if ([self respondsToSelector:@selector(getDatasFromDataBaseWithParam:Data:)]) {
        NSString* l_quary_value = [self performSelector:@selector(getDatasFromDataBaseWithParam:Data:) withObject:aParam withObject:aData];
        if(l_quary_value != nil && ![l_quary_value isEqualToString:@"null"])
        {
            return l_quary_value;
        }else{
            return @"";
        }
        
    }
    return nil;
}

-(WSHTextField*)setGrideViewDataKindOfTextField:(WSFuncsBean_Param*)aParam
                                           data:(id)aData
                                      lastValue:(NSInteger)lastValue
                                           iRow:(NSInteger)row
                                        iColumn:(NSInteger)column{
    
    if ([aParam.tpy isEqualToString:COL_TYPNUM]||[aParam.tpy isEqualToString:COL_TYPTEXT]||[aParam.tpy isEqualToString:COL_TYPCHT]||[aParam.tpy isEqualToString:COL_TYPCHTS]||[aParam.tpy isEqualToString:COL_TYPL])
    {
        //判断是否为最后一个文本框
        if (_lastValueColunm < column) {
            _lastValueColunm = column;
        }
        if ( row == lastValue -1 && column == _lastValueColunm) {
            _isLastText =YES ;
        }
        else {
            _isLastText = NO;
        }
        
        float maxValue = 0;
        if([aData isKindOfClass:[WSProdBean class]] && aParam.alert != nil){
            WSProdBean* prodBean=(WSProdBean*)aData;
            if([prodBean.price isKindOfClass:[NSNumber class]]){
                maxValue=prodBean.price.floatValue;
            }
        }
        WSHTextField *textfield =[[WSHTextField alloc]initWithFrame:CGRectMake(0, 0, aParam.wcol/*79*/, 29) Param:aParam maxValue:maxValue isLastText:_isLastText];
        textfield.backgroundColor = [UIColor grayColor];
        textfield.textColor = [UIColor blackColor];
//        textfield.currentFuncs=self.currentFuncs;
        if(aParam.readonly == 1) {
            textfield.enabled = NO;
            textfield.textColor = [UIColor grayColor];
        }
        textfield.tag = [self getSpecIndexbyParam:aParam];
        textfield.font = [UIFont systemFontOfSize:UI_Font];
        textfield.textAlignment = NSTextAlignmentLeft;
        textfield.delegate = self;
        textfield.m_isGride = YES;
        
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.borderStyle = UITextBorderStyleNone;
//        textfield.layer.borderWidth = 1.0;
//        textfield.layer.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1].CGColor;
//        textfield.layer.cornerRadius = 5.0;
        textfield.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
        textfield.iRow = (int)row;
        textfield.iColumn = (int)column; //(表格内的列值，比表头少一列)
        textfield.m_col = aParam.col;
        if(aParam.idefault){
            textfield.text = aParam.idefault;
        }
        

        //设置回显值时暂不校验（否则如果服务器给的回显值不符合校验，进入页面时可能会弹出许多提示框），上传时会统一校验。
        BOOL old = textfield.isNeedValidateText;
        textfield.isNeedValidateText = NO;
        
        // 解决SFA-5208，修改本地回显值，再点击品牌系列然后退出会保留修改值的问题
        if (self.currentFuncs.opt.needSelect
            && [self.currentFuncs.opt.needSelect length] > 0)
        {
            NSString *value = nil;
            
            if ([aData isKindOfClass:[WSProdBean class]]) {
                value = [_prod_cacheDataMDictionary objectForKey:[NSString stringWithFormat:@"%@_%@", [(WSProdBean *)aData Id], aParam.col]];
            }else if ([aData isKindOfClass:[WSProductObject class]]) {
                value = [_prod_cacheDataMDictionary objectForKey:[NSString stringWithFormat:@"%@_%@", [(WSProductObject *)aData prod_id], aParam.col]];
            }
            
            if (value) {
                textfield.text = value;
            }
            
        }else{
            // 服务端回显
            if ([self serverRedisWith:aParam]) {
                // 产品属性回显 需要配置采集项ds属性
                // readonly值为1时上传数据不回传
                if(aParam.ids
                   && [aParam.ids length] > 0){
                    
                    if([aData isKindOfClass:[WSProdBean class]]){
                        WSProdBean* prodBean=(WSProdBean*)aData;
                        BOOL hasColProperty = [self getVariableWithClass:[WSProdBean class] varName:aParam.ids];
                        if (hasColProperty) {
                            textfield.text = [NSString stringWithValue:[prodBean valueForKey:aParam.ids]];
                        }
                    }
                }else{
                    if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                        NSString *reDisplayText = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:aData];
                        if ([reDisplayText isKindOfClass:[NSString class]]) {
                            textfield.text = reDisplayText;
                        }
                    }
                }
            }
            
            //查询结果 本地显示
            if ([self nativeRedis]) {
                if ((aParam.readonly != 1) || !aParam.redis)
                {
                    NSString *value = nil;
                    if ([self respondsToSelector:@selector(getDatasFromDataBaseWithParam:Data:)]) {
                        
                        NSString* l_quary_value = [self performSelector:@selector(getDatasFromDataBaseWithParam:Data:) withObject:aParam withObject:aData];
                        if(l_quary_value != nil) {
                            if ([l_quary_value isEqualToString:@"null"]) {
                                value = @"";
                            }else {
                                value = l_quary_value;
                            }
                        }
                    }
                    
                    if (value) {
                        textfield.text = value;
                    }else if ([self.m_DataBaseDatas count] > 0) {
                        textfield.text = value;
                    }
                    
                }else if(aParam.redis){ //只要设置本地回显为真，就支持回显。（与该控件是否只读无关）
                    NSString *value = nil;
                    if ([self respondsToSelector:@selector(getDatasFromDataBaseWithParam:Data:)]) {
                        NSString* l_quary_value = [self performSelector:@selector(getDatasFromDataBaseWithParam:Data:) withObject:aParam withObject:aData];
                        if(l_quary_value != nil) {
                            if ([l_quary_value isEqualToString:@"null"]) {
                                value = @"";
                            }else {
                                value = l_quary_value;
                            }
                        }
                    }
                    if (value) {
                        textfield.text = value;
                    }
                }
            }
        }
        
        textfield.isNeedValidateText = old;
        
        if (textfield.text && maxValue > 0) {
            float alertValue = [aParam.alert floatValue];
            float textValue = [[textfield getTextValue] floatValue];
            if (textValue < (1 - alertValue) * maxValue || textValue > (1 + alertValue) * maxValue) {
                textfield.textColor = [UIColor redColor];
            }
            else
            {
                textfield.textColor = [UIColor blackColor];
            }
        }
        
        return textfield ;
    }
    return nil;
}

- (NSString *)getRedisFromServerWithParam:(WSFuncsBean_Param *)param data:(id)data {
    
    // 需要回显的值
    __block NSString *redis = nil;
    NSString *currenProdId = nil;
    if ([data isKindOfClass:[WSProdBean class]]) {
        currenProdId = [(WSProdBean *)data Id];
    }
    
    //Note: 检测是否存在funccode，如果存在返回index，index == -1标示不存在。
    NSInteger fcIndex = -1;
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (!spec || [spec count] < 1) {
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    NSUInteger tmp = [spec indexOfObject:@"funccode"];
    if (NSNotFound != tmp) {
        fcIndex = tmp;
    }

    WSBaseStoreProdDisTable *baseStoreProdDisTable = [WSBaseStoreProdDisTable sharedTable];
    NSArray *names = @[@"store_id",@"prod_id" ];
    NSArray *values = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:currenProdId]];
    if (fcIndex != -1) {
        names = @[@"store_id",@"prod_id",@"funccode"];
        values= @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:currenProdId],[NSString stringNotNilWithValue:self.currentFuncs.fc]];
    }
    NSArray *prods = [baseStoreProdDisTable queryWithNames:names ArgumentsValue:values];
    WSBaseStoreProdDisObject *baseStoreProdDisObject = [prods firstObject];
    /*要判断这个object是否有param.col那个字段然后取值*/
    NSString *colName = ([param.redis length] > 0 && ![param.redis isEqualToString:@"1"] && ![param.redis isEqualToString:@"0"])? param.redis : param.col;
    BOOL hasColProperty = [self getVariableWithClass:[baseStoreProdDisObject class] varName:colName];
    if (hasColProperty) {
        redis = [baseStoreProdDisObject valueForKey:colName];
    }else {
        NSLog(@"baseStoreProdDisObject is no property %@",colName);
    }


    return redis;
}

- (BOOL)isRedisMoreHome {
    if (self.currentFuncs.opt.isRedisMoreHome && [self.currentFuncs.opt.isRedisMoreHome isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

/**
 *  表格本地数据回显（优于服务器回显）
 *
 *  @param
 *
 *  @return bool
 */
- (BOOL)nativeRedis {
    BOOL redis = YES;
//    NSString *dateType = self.currentFuncs.dateTyp;
//    if (dateType && [dateType isEqualToString:@"E"] ) {
//        redis = NO;
//    } else if (dateType && [dateType isEqualToString:@"D"]){
//        // 当天回显
//        redis = YES;
//    }else {
//        redis = YES;
//    }
    return redis;
}

/**
 *  服务器数据回显
 *
 *  @param   WSFuncsBean_Param
 *
 *
 *  @return bool
 */

- (BOOL)serverRedisWith:(WSFuncsBean_Param *)param {
    BOOL serverRedis = YES;
    if (!param.redis
        || (param.redis && [param.redis isEqualToString:@"0"])
        || (param.redis && [param.redis length] < 1)) {
        serverRedis = NO;
    }
    return serverRedis;
}


- (WSRadioButton *)grideViewDataKindOfRadioButton:(WSFuncsBean_Param*)aParam
                                             Data:(id)aData {
    WSRadioButton *radioButton = [WSRadioButton buttonWithType:UIButtonTypeCustom];
    radioButton.frame = CGRectMake(0, 0, 0, 0);
    radioButton.tag = [self getSpecIndexbyParam:aParam];
    [radioButton addTarget:self action:@selector(radioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [radioButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"] forState:UIControlStateSelected];
    [radioButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"] forState:UIControlStateHighlighted];
    [radioButton setImage:[UIImage scaledImageForName:@"selected_no_radio" ofType:@"png"] forState:UIControlStateNormal];
    //服务端回显
    if ([self serverRedisWith:aParam]) {
        
        
        if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
            NSString* l_quary_value = nil;
            if ([aData isKindOfClass:[WSDictBean class]]) {
                WSDictBean *dictBean = (WSDictBean *)aData;
                l_quary_value = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:dictBean];
            }
            if (l_quary_value && [l_quary_value length] > 0 && [l_quary_value isEqualToString:@"1"]) {
                [radioButton setCurSelected:YES];
            }else{
                [radioButton setCurSelected:NO];
            }
        }
    }
    //查询结果
    if ([self nativeRedis]) {
        NSString *i_isSelected = [self getDatasFromDataBase:aParam Data:aData];
        if([i_isSelected isKindOfClass:[NSString class]] && [i_isSelected isEqualToString:@"1"]) {
            [radioButton setCurSelected:YES];
        }
        else if([i_isSelected isEqualToString:@"0"]) {
            [radioButton setCurSelected: NO];
        }else if ([aParam.idefault isEqualToString:@"1"]) {
            [radioButton setCurSelected:YES];
        }
        
        if (aParam.readonly == 1) {
            radioButton.userInteractionEnabled = NO;
        }
    }else {
        if ([aParam.idefault isEqualToString:@"1"]) {
            [radioButton setCurSelected:YES];
        }
    }
    return radioButton;
}

-(WSCheckBox*)setGrideViewDataKindOfButton:(WSFuncsBean_Param*)aParam
                                      Data:(id)aData iRow:(NSInteger)row
                                   iColumn:(NSInteger)column
{
    WSCheckBox *checkButton = [WSCheckBox buttonWithType:UIButtonTypeCustom];
    checkButton.tag = [self getSpecIndexbyParam:aParam];
    checkButton.frame = CGRectMake(0, 0, 0, 0);
    checkButton.iRow = (int)row;
    checkButton.iColumn = (int)column; //(表格内的列值，比表头少一列)
    [checkButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
    [checkButton setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
//    [checkButton setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
    [checkButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    if (aParam.readonly == 1) {
        checkButton.userInteractionEnabled = NO;
        [checkButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        [checkButton setImage:[UIImage imageNamed:@"icn_check_2"] forState:UIControlStateSelected];
    }

    // 解决SFA-5208，修改本地回显值，再点击品牌系列然后退出会保留修改值的问题
    if (self.currentFuncs.opt.needSelect
        && [self.currentFuncs.opt.needSelect length] > 0)
    {
        NSString* i_isSelected = @"0";

        if ([aData isKindOfClass:[WSProdBean class]]) {
            i_isSelected = [_prod_cacheDataMDictionary objectForKey:[NSString stringWithFormat:@"%@_%@", [(WSProdBean *)aData Id], aParam.col]];
        }else if ([aData isKindOfClass:[WSProductObject class]]) {
            i_isSelected = [_prod_cacheDataMDictionary objectForKey:[NSString stringWithFormat:@"%@_%@", [(WSProductObject *)aData prod_id], aParam.col]];
        }
        
        if([i_isSelected isKindOfClass:[NSString class]] && [i_isSelected isEqualToString:@"1"])
            checkButton.selected = YES;
        else if([i_isSelected isEqualToString:@"0"])
            checkButton.selected = NO;
        if (aParam.readonly == 1) {
            checkButton.userInteractionEnabled = NO;
        }
    }else{
        
        //服务端回显
        if ([self serverRedisWith:aParam]) {
            NSString* i_isSelected = @"0";

            if ([aParam.idefault isEqualToString:@"1"]) {
                i_isSelected = @"1";
            }else if ([aParam.idefault isEqualToString:@"0"]) {
                i_isSelected = @"0";
            }
            if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                NSString *defaultData = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:aData];
                if ([defaultData length] > 0) {
                    i_isSelected = defaultData;
                }
            }
            if ([i_isSelected isKindOfClass:[NSNumber class]]) {
                i_isSelected = [(NSNumber*)i_isSelected stringValue];
            }
            if ( [i_isSelected isEqual:[NSNull null]]) {
                i_isSelected = @"0";
            }
            
            
            if([i_isSelected isKindOfClass:[NSString class]] && [i_isSelected isEqualToString:@"1"])
                checkButton.selected = YES;
            else if([i_isSelected isEqualToString:@"0"])
                checkButton.selected = NO;
            
        }

        
        //查询结果
        if ([self nativeRedis]) {
            NSString* i_isSelected = @"0";
            
            if (aParam.idefault && aParam.idefault.length > 0) {
                checkButton.isClicked = YES;
            }
            
            i_isSelected = [self getDatasFromDataBase:aParam Data:aData];
            
            if([i_isSelected isKindOfClass:[NSString class]] && [i_isSelected isEqualToString:@"1"])
                checkButton.selected = YES;
            else if([i_isSelected isEqualToString:@"0"])
                checkButton.selected = NO;
            

            if (aParam.readonly == 1) {
                checkButton.userInteractionEnabled = NO;
            }
        }else {
            if ([aParam.idefault isEqualToString:@"1"]) {
                checkButton.selected = YES;
            }else if([aParam.idefault isEqualToString:@"0"])
                checkButton.selected = NO;

        }

    }
    
    return checkButton;
}


-(UIButton*)setGrideViewDataKindOfBadReason:(WSFuncsBean_Param*)aParam
{
    if([aParam.tpy isEqualToString:COL_TYPBUTTON])
    {
        WSAcvtButtonForTB *button = [WSAcvtButtonForTB buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5.0f;
        button.backgroundColor = [UIColor lightGrayColor];
        button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        button.frame = CGRectMake(0, 0, aParam.wcol, 29);
        button.tag = [self getSpecIndexbyParam:aParam];
        button.iFilter = aParam.filter;
        [button setTitle:aParam.buttonname == nil ? NSLocalizedString(@"w_select", nil) : aParam.buttonname forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor]  forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor]  forState:UIControlStateSelected];
        [button addTarget:self action:@selector(productReason:) forControlEvents:UIControlEventTouchUpInside];
        if (!_resonButtons) {
            _resonButtons = [[NSMutableArray alloc] initWithCapacity:[self.m_dataSources count]];
        }
        [self.resonButtons addObject:button];
        return button;
    }
    return nil;
    
}

- (PhotoTypeButton *)setGrideViewDataKindOfPhotoButton:(WSFuncsBean_Param *)aParam Data:(id)aData{
    if ([aParam.tpy isEqualToString:COL_TYPPHOTO]) {
        PhotoTypeButton *button = [[PhotoTypeButton alloc] init];
        button.maxPhotoCount = [aParam.max integerValue];
        button.tag = [self getSpecIndexbyParam:aParam];
        button.isSupperLocalPhoto = aParam.isSupperLocalPhoto;
        
        // 如果需要回显 //查询结果
        if ([self nativeRedis]) {
            if ((aParam.readonly != 1) || !aParam.redis)
            {
                NSString *imageIDS = [self getDatasFromDataBase:aParam Data:aData];
                NSArray *array =  [imageIDS componentsSeparatedByString:@","];
                NSMutableArray *imageIdArray = [NSMutableArray arrayWithArray:array];
                // 过滤掉imageId为空的字符串
                for (NSString *imageId in imageIdArray) {
                    if ([imageId length] == 0) {
                        [imageIdArray removeObject:imageId];
                    }
                }
                if (imageIdArray && [imageIdArray count] > 0) {
                    button.photoIDArray = [NSMutableArray arrayWithArray:imageIdArray];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:PhotoTypeButton_Notification object:nil];
                }
            }
        }
        
        button.customDelegate = self;
        return button;
    }
    return nil;
}

- (WSSelectListView *)setGrideViewDataKindofSelectList:(WSFuncsBean_Param *)aParam Data:(id)aData
{
    if ([aParam.tpy isEqualToString:COL_TYPDT] || [aParam.tpy isEqualToString:COL_TYPSD]) {
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:aParam.filter];
        
        NSMutableArray *nameList = [[NSMutableArray alloc] init];
        NSMutableArray *dictList = [[NSMutableArray alloc] init];
        for (WSDictBean *db in filterArray)
        {
            [nameList addObject:db.name];
            [dictList addObject:db];
        }
        
        NSInteger width=100;
        if ([aParam.charNum intValue] > 0){
            
            width = [aParam.charNum intValue] * UINIT_WIDTH_OTHER ;
            
        }else if(aParam.wcol>0){
            
            width=aParam.wcol;
        }
        
        WSSelectListViewSelectMode selectMode = WSSelectListViewSelectModeSingleSelection;
        if ([aParam.tpy isEqualToString:COL_TYPDT])
        {
            selectMode = WSSelectListViewSelectModeSingleSelection;
            //加入一个空白选项，用于单选取消选择
            [nameList insertObject:@"" atIndex:0];
            WSDictBean *dictBean = [[WSDictBean alloc]init];
            dictBean.Id = kBlankItemID;
            dictBean.name = kBlankItemName;
            [dictList insertObject:dictBean atIndex:0];
            
        }
        else if ([aParam.tpy isEqualToString:COL_TYPSD])
        {
            selectMode = WSSelectListViewSelectModeMultipleChoice;
        }
        
        WSSelectListView *list = [[WSSelectListView alloc] initWithFrame:CGRectMake(0, 0, width, 30) style:UITableViewStylePlain selectMode:selectMode];
        //        WSSelectListView *list = [[WSSelectListView alloc] initWithFrame:CGRectMake(0, 0, width, 30) style:UITableViewStylePlain];
        list.content = nameList;
        list.contentDicts = dictList;
        list.layer.cornerRadius = 5.0f;
        list.tag = [self getSpecIndexbyParam:aParam];
        
        if ([aParam.tpy isEqualToString:COL_TYPDT]) {
            
            NSString *selectItem = nil;
            
            if ([self serverRedisWith:aParam]) {

                if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                    NSString* l_quary_value = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:aData];
                    if (l_quary_value && [l_quary_value length] > 0) {
                        
                        for (WSDictBean *db in filterArray) {
                            if ([db.Id isEqualToString:l_quary_value]) {
                                selectItem = [db.name copy];
                                break;
                            }
                        }
                        
                    }
                }
   
            }
            if ([self nativeRedis]) {
                NSString *l_quary_value = [self getDatasFromDataBase:aParam Data:aData];
                if (l_quary_value && [l_quary_value length] > 0) {
                    selectItem = l_quary_value;
                }else if ([self.m_DataBaseDatas count] > 0) {
                    //如果本地想取消选择，即选择空值，存储后取出也是空值，如果不加此判断，会一直显示原来server给的回显值。 self.m_DataBaseDatas count > 0说明已在本地上传过，如果此时为空，说明就是想要空值（取消原来的选择），顾特意设为空值。
                    selectItem = l_quary_value;
                }
            }
            
            if (selectItem && [selectItem length] > 0) {
                
                __block NSInteger index = -1;
                
                if (selectItem != nil && [selectItem length] > 0) {
                    [list.content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *element = (NSString *)obj;
                        if ([element isEqualToString:selectItem]) {
                            index = idx;
                            *stop = YES;
                        }
                    }];
                    if (index > -1) {
                        list.selectedIndex = index;
                    }
                }else{
                    list.selectedIndex = -1;
                }
            }else{
                list.selectedIndex = -1;
            }
            
        }
        else if ([aParam.tpy isEqualToString:COL_TYPSD]) {
            NSMutableArray *selectedItems = nil;
            if ([self nativeRedis]) {
                //查询结果
                if ((aParam.readonly != 1) || !aParam.redis)
                {
                    NSString *strDb = [self getDatasFromDataBase:aParam Data:aData];
                    if (strDb && [strDb length] > 0) {
                        NSArray *valueArray = [strDb componentsSeparatedByString:@","];
                        if (valueArray && [valueArray count] > 0) {
                            selectedItems = [NSMutableArray array];
                            for (NSString *value in valueArray) {
                                NSInteger index = [nameList indexOfObject:value];
                                if (index != NSNotFound) {
                                    [selectedItems addObject:[NSNumber numberWithInteger:index]];
                                }
                            }
                        }
                    }
                    
                }
            }
            if (selectedItems && [selectedItems count] > 0) {
                [list setSelectedIndexArray:selectedItems];
            }
        }
        return list;
    }
    
    return nil;
    
}

- (UILabel *)setGrideViewDataKindofMultipleChoice:(WSFuncsBean_Param *)aParam Data:(id)aData;
{
    WSMultipleChoiceLabel *lable = nil;
    if ([aParam.tpy isEqualToString:COL_TYPSD]) {
        lable = [[WSMultipleChoiceLabel alloc] initWithFrame:CGRectMake(0, 0, 79, 29)];
        lable.font = [UIFont systemFontOfSize:UI_Font];
        lable.filter = aParam.filter;
        if (aParam.ids != nil && [aParam.ids length] > 0) {
            [lable.iInfos  setObject:aParam.ids forKey:@"ds"];
        }
        
        lable.layer.borderWidth = 1.0;
        lable.layer.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1].CGColor;
        lable.layer.cornerRadius = 5.0;
        lable.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
        lable.userInteractionEnabled = YES;
        lable.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popMultipleChoice:)];
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.numberOfTapsRequired = 1;
        [lable addGestureRecognizer:tapGesture];
        lable.tag = [self getSpecIndexbyParam:aParam];
        if ([self nativeRedis]) {
            //查询结果
            if ((aParam.readonly != 1) || !aParam.redis)
            {
                NSString *strDb = [self getDatasFromDataBase:aParam Data:aData];
                lable.iContent = (strDb != nil && [strDb length] > 0) ? strDb : nil;//[self getDatasFromDataBase:aParam Data:aData];
                NSArray *array = [lable.iContent componentsSeparatedByString:@","];
                lable.text = [NSString stringWithFormat:@"%lu", (unsigned long)[array count]];
            }
            
        }
        return lable;
    }
    return lable;
}

-(WSQRTypeView*)setGrideViewDataKindOfQRTypeView:(WSFuncsBean_Param*)aParam
                                      Data:(id)aData;
{
    WSQRTypeView * qrTypeButton = [[WSQRTypeView alloc]init];
    qrTypeButton.tag = [self getSpecIndexbyParam:aParam];
    if ([aParam.filter isEqualToString:SCAN_BARCODE]) {
        qrTypeButton.isScanQRCode = NO;
    }
    //服务端回显
    if ([self serverRedisWith:aParam]) {
        
        
        if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
            NSString* l_quary_value = nil;
            if ([aData isKindOfClass:[WSDictBean class]]) {
                WSDictBean *dictBean = (WSDictBean *)aData;
                l_quary_value = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:aParam withObject:dictBean];
            }
            
            if (l_quary_value && [l_quary_value length] > 0 && [l_quary_value isEqualToString:@"1"]) {
                [qrTypeButton setTitle:l_quary_value forState:UIControlStateNormal];
                [qrTypeButton setImage:nil forState:UIControlStateNormal];
            }else{
                [qrTypeButton setTitle:nil forState:UIControlStateNormal];
                
                [qrTypeButton setImage:[UIImage scaledImageForName:@"qr_code" ofType:@"png"] forState:UIControlStateNormal];            }
        }
    }
    // 本地回显
    if ([self nativeRedis]) {
        if ((aParam.readonly != 1) || !aParam.redis) {
            NSString *strDb = [self getDatasFromDataBase:aParam Data:aData];
            NSLog(@"setGrideViewDataKindOfQRTypeView ----%@",strDb);
            if (strDb && strDb.length > 0) {
                [qrTypeButton setTitle:strDb forState:UIControlStateNormal];
                [qrTypeButton setImage:nil forState:UIControlStateNormal];
                
            }else{
                [qrTypeButton setTitle:nil forState:UIControlStateNormal];
                
                [qrTypeButton setImage:[UIImage scaledImageForName:@"qr_code" ofType:@"png"] forState:UIControlStateNormal];
                
            }

        }
    }
    
    return qrTypeButton;
}

- (void)popMultipleChoice:(UITapGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded ) {
        WSMultipleChoiceLabel *label = (WSMultipleChoiceLabel *)sender.view;
        NSString *ds = [label.iInfos objectForKey:@"ds"];

        NSMutableArray *nameList = [[NSMutableArray alloc] init];
        NSArray *filterArray = [label.filter componentsSeparatedByString:@","];
        
        
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        for (NSString *filter in filterArray) {
            
            NSString *brand = [service queryBrandIdByFilter:filter searchQuestion:self.currentFuncs.opt.searchQuestion];
            
            WSProdBeanArray* pba = [WSAppData getObjectbyKey:PRODS];
            NSArray *prods = [pba getProdsWithBrandId:brand andProductType:ds];
            if (!prods || [prods count] == 0) return;
            for (WSProdBean *bean in prods) {
                WSProductBeanItemofChoice *item = [[WSProductBeanItemofChoice alloc] initWithProductBean:bean] ;
                
                [nameList addObject:item];
            }
        }
        
        NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
        if (label.iContent != nil && ![label.iContent isEqualToString:@""]) {
            NSArray *arry = [label.iContent componentsSeparatedByString:@","];
            for (NSString *name in arry) {
                for (id<WSBaseItemOfChoice> obj in nameList) {
                    if ([obj conformsToProtocol:@protocol(WSBaseItemOfChoice)]) {
                        if ([name isEqualToString:obj.name]) {
                            [selectedItems addObject:obj];
                            break;
                        }
                    }
                }
            }
        }
        
        if ([nameList count] > 0) {
            WSMultipleChoiceViewController *vc = [[WSMultipleChoiceViewController alloc] initWithSourceArray:nameList andResultsArray:selectedItems];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:vc];
            vc.iSourceView = label;
            vc.delegate = self;
            [self presentViewController:navc animated:YES completion:^{
                // Can do something
            }];
        }
    }
}

#pragma mark - WCMultipleChoiceViewController delegate

- (void)multipleChoiceViewController:(UIViewController *)aVc withResults:(NSArray *)aChoices
{
    WSMultipleChoiceViewController *vc = (WSMultipleChoiceViewController *)aVc;
    WSMultipleChoiceLabel *lable = (WSMultipleChoiceLabel *)vc.iSourceView;
    lable.text = [NSString stringWithFormat:@"%lu", (unsigned long)[aChoices count]];
    
    if ([aChoices count] > 0) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
        for (id<WSBaseItemOfChoice> obj in aChoices) {
            if ([obj conformsToProtocol:@protocol(WSBaseItemOfChoice)]) {
                [array addObject:obj.name];
            }
        }
        NSString *newContent = [array componentsJoinedByString:@","];
        if (![lable.iContent isEqualToString:newContent]) {
            lable.isValueChange = YES;
        }
        lable.iContent = newContent;
    } else {
        if (nil != lable.iContent) {
            lable.isValueChange = YES;
        }
        lable.iContent = nil;
    }
}

/*
// 加载数据 回显的已填写的数据（不包括表格左侧的产品）
- (void)loadRedisDataBaseDatas {
    _m_DataBaseDatas = [[NSMutableArray alloc]init];
    if ([self respondsToSelector:@selector(getDataBaseDatas)]) {
        [_m_DataBaseDatas addObjectsFromArray:[self performSelector:@selector(getDataBaseDatas)]];
    }
}
*/

- (void)initDataSource {
    
    
    if (!_baseDataGridComponentDataSource) {
        _baseDataGridComponentDataSource = [[WSBaseDataGridComponentDataSource alloc] initWithStore:self.currentStore func:self.currentFuncs ownViewController:self andCurrentTableItem:nil andBrandId:self.iBrandId];
        self.m_dataSources = [NSMutableArray arrayWithArray:_baseDataGridComponentDataSource.dataSource];
        self.m_DataBaseDatas = [NSMutableArray arrayWithArray:_baseDataGridComponentDataSource.m_DataBaseDatas];
        self.prod_cacheDataMDictionary = _baseDataGridComponentDataSource.dataSourceCache;
        self.moreProductArray = _baseDataGridComponentDataSource.moreProductArray;
    }else {
        self.m_DataBaseDatas = [NSMutableArray arrayWithArray:_baseDataGridComponentDataSource.m_DataBaseDatas];
    }
    
    if (self.currentFuncs.opt.needSelect
        && [self.currentFuncs.opt.needSelect length] > 0){
        if (self.mSearchGridviewuploadDataSources == nil) {
            self.mSearchGridviewuploadDataSources = [NSMutableArray arrayWithCapacity:1];
            [self.mSearchGridviewuploadDataSources addObjectsFromArray:self.m_DataBaseDatas];
        }
    }
    
    if (_prod_cacheDataMDictionary == nil) {
        _prod_cacheDataMDictionary = [[NSMutableDictionary alloc] init];
    }
    
    
    if ([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC]) {
        // 妮维雅 如果要显示已填写的产品
        if (self.showAddedProds) {
            if ([self.m_addedDataSources count] > 0) {

                NSArray *m_dsIds = [self.m_dataSources valueForKeyPath:@"@distinctUnionOfObjects.Id"];
                if ([self.m_addedDataSources count] > 0) {
                    for (WSProdBean *prodBean in self.m_addedDataSources) {
                        if (![m_dsIds containsObject:prodBean.Id]) {
                            [self.m_dataSources addObject:prodBean];
                        }
                    }
                }
            }else{
                if ([self.m_DataBaseDatas count] > 0) {
                    
                    NSArray *m_dsIds = [self.m_dataSources valueForKeyPath:@"@distinctUnionOfObjects.Id"];
                    NSArray * l_dataSources= [self getProdsWithBrandId:self.currentFuncs];
                    for (WSProdBean* pb in l_dataSources) {
                        for (WSProductObject* object  in self.m_DataBaseDatas) {
                            NSString *prod_id =object.prod_id;
                            if ([prod_id isEqualToString:pb.Id]) {
                                if (![self.m_addedDataSources containsObject:pb] && ![m_dsIds containsObject:pb.Id]) {
                                    [self.m_addedDataSources addObject:pb];
                                }
                                break;
                            }
                        }
                    }

                    [self.m_dataSources  addObjectsFromArray:self.m_addedDataSources];
                }
            }
        }
    }

    
    
}

- (void)setProdCacheData
{
    NSInteger l_dataSourcesCount = [self.m_dataSources count];
    //去掉第一列的总数
    NSInteger l_datasColumns = 0;
    
    l_datasColumns = (![self.currentFuncs.fv isEqualToString:@"V20T02"]) ? ([self.titles count] - 1) : [self.titles count];
    /*  当前页面 push 到其它页面，并发生内存警告时
     *  在 iOS 6.0 以前的版本会重新调用 loadView
     *  此时界面上的数据不应该重算
     *  注意:此待定方法是基于调用 more（更多） 页面时
     *      加能添加，不能减少，如果减少，切内存警告会出现问题
     */
    if ([self.datas count] == [self.m_dataSources count]) {
        return;
    }
    
    NSInteger startPosition = 0;
    //修改self.m_moreProdsCount!=0 为self.m_moreProdsCount>0 by yanguoshuai at 2012-04-09
    if(self.m_moreProdsCount > 0)
        startPosition = l_dataSourcesCount - self.m_moreProdsCount;
    if(self.m_moreProdsCount == NONEEXIST)
        startPosition = l_dataSourcesCount;
    
    for (NSInteger i = startPosition; i < l_dataSourcesCount; i++) {
        
        //工作提醒时为1(fv = V20T02 还有V20T05)
        int jstart = ([self.currentFuncs.fv isEqualToString:@"V20T02"]) ? 1 : 0;
        
        for (int j = jstart; j < l_datasColumns; j++) {
            
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
            id data = [self.m_dataSources objectAtIndex:i];//TODO：将来需要重构m_DataBaseDatas，使类型确定
            
            NSString *value = nil;
            if ([self respondsToSelector:@selector(getDatasFromDataBaseWithParam:Data:)]) {
                NSString* l_quary_value = [self performSelector:@selector(getDatasFromDataBaseWithParam:Data:) withObject:param withObject:data];
                if(l_quary_value != nil) {
                    if ([l_quary_value isEqualToString:@"null"]) {
                        value = @"";
                    }else {
                        value = l_quary_value;
                    }
                }
            }
            if (value && ![value isEqualToString:@""]) {
                
                if ([data isKindOfClass:[WSProdBean class]]) {
                    [_prod_cacheDataMDictionary setObject:value forKey:[NSString stringWithFormat:@"%@_%@", [(WSProdBean *)data Id], param.col]];
                }else if ([data isKindOfClass:[WSProductObject class]]) {
                    [_prod_cacheDataMDictionary setObject:value forKey:[NSString stringWithFormat:@"%@_%@", [(WSProductObject *)data prod_id], param.col]];
                }
                
            }else{
                NSString *value = nil;
                if ([self respondsToSelector:@selector(getDatasFromDataBaseWithParam:Data:)]) {
                    NSString* l_quary_value = [self performSelector:@selector(getDatasFromDataBaseWithParam:Data:) withObject:param withObject:data];
                    if(l_quary_value != nil) {
                        if ([l_quary_value isEqualToString:@"null"]) {
                            value = @"";
                        }else {
                            value = l_quary_value;
                        }
                    }
                }
                if (value && ![value isEqualToString:@""]) {
                    if ([data isKindOfClass:[WSProdBean class]]) {
                        [_prod_cacheDataMDictionary setObject:value forKey:[NSString stringWithFormat:@"%@_%@", [(WSProdBean *)data Id], param.col]];
                    }else if ([data isKindOfClass:[WSProductObject class]]) {
                        [_prod_cacheDataMDictionary setObject:value forKey:[NSString stringWithFormat:@"%@_%@", [(WSProductObject *)data prod_id], param.col]];
                    }
                }
                
            }
        }
    }
    
}

-(void)setGrideViewData
{
//    SFA-17743 董宏 在 paramArray 为0 的时候增加 ds 是否是 prod的判断
    if([self.currentFuncs.paramArray count] < 1 && !([self.currentFuncs.ds isKindOfClass:[NSString class]] && [self.currentFuncs.ds isEqualToString:DS_PROD]))
        return;
    
    //填充表头数据
    [self setColumnsDatasOfTitles];
    //设置表的宽度
    [self setColunmViewWidth];
    


    //将本地回显有值的更多数据添加到首页表格中。
    [self addMoreProductToGrideView];
    
    if (_isFirstLoadView) {
        [self setProdCacheData];
    }else{
        
    }
    
    _isFirstLoadView = NO;
    
    NSInteger l_dataSourcesCount = [self.m_dataSources count];
    //去掉第一列的总数
    NSInteger l_datasColumns = 0;
    
    l_datasColumns = (![self.currentFuncs.fv isEqualToString:@"V20T02"]) ? ([self.titles count] - 1) : [self.titles count];
    /*  当前页面 push 到其它页面，并发生内存警告时
     *  在 iOS 6.0 以前的版本会重新调用 loadView
     *  此时界面上的数据不应该重算
     *  注意:此待定方法是基于调用 more（更多） 页面时
     *      加能添加，不能减少，如果减少，切内存警告会出现问题
     */
    if ([self.datas count] == [self.m_dataSources count]) {
        return;
    }
    
    NSInteger startPosition = 0;
    //修改self.m_moreProdsCount!=0 为self.m_moreProdsCount>0 by yanguoshuai at 2012-04-09
    if(self.m_moreProdsCount > 0)
        startPosition = l_dataSourcesCount - self.m_moreProdsCount;
    if(self.m_moreProdsCount == NONEEXIST)
        startPosition = l_dataSourcesCount;
    
    for (NSInteger i = startPosition; i < l_dataSourcesCount; i++) {
        
        NSMutableArray *l_rowView = [[NSMutableArray alloc]  initWithCapacity:[self.titles count]];
        
        UILabel* first_label = [self setFirstColumnDataWithIndex:i Datas:self.m_dataSources];

        //插入行的第一列
        [l_rowView insertObject:first_label atIndex:0];
        
        
        NSMutableArray *formulaStringArray = [NSMutableArray arrayWithCapacity:1];
        //工作提醒时为1(fv = V20T02 还有V20T05)
        int jstart = ([self.currentFuncs.fv isEqualToString:@"V20T02"]) ? 1 : 0;
        
        for (int j = jstart; j < l_datasColumns; j++) {
            
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j];
            id data = [self.m_dataSources objectAtIndex:i];//TODO：将来需要重构m_DataBaseDatas，使类型确定
            
            WSHTextField* l_textField = [self setGrideViewDataKindOfTextField:param data:data lastValue:l_dataSourcesCount  iRow:i  iColumn:j];
            if (jstart == 1 && j < [self.titles count]) {
                l_textField.iColumnName = [self.titles objectAtIndex:j];
                l_textField.prodName = first_label.text;
            }else if (jstart == 0 && j + 1 < [self.titles count]){
                l_textField.iColumnName = [self.titles objectAtIndex:j + 1];
                l_textField.prodName = first_label.text;
            }
            if(l_textField != nil)
            {
                
                [self setDependedInfoWith:l_textField withParam:param withRow:(int)i andColumn:(int)j];
                
                if (param.value && [param.value length] > 0)
                {
                    NSString *originalKey = [NSString stringWithFormat:@"%ldvalue%@",(long)i,param.value];
                    [self.formulaDictionary  setObject:l_textField forKey:originalKey];
                    
                    NSString *formulaString = [originalKey copy];
                    [formulaStringArray addObject:formulaString];
                }
                
                if (param.reg && [param.reg length] > 0)
                { //支持正则表达式验证
                    
                    NSString *title = @"";
                    if (j+1 < [self.titles count]) {
                        
                        title = [self.titles objectAtIndex: j + 1];
                    }else{
                        LogError(@"【%d】 数组下标越界！！！", __LINE__);
                    }
                    
                    id bean = [self.m_dataSources objectAtIndex:i];
                    
                    if ([param.reg rangeOfString:@"memo"].length > 0) {
                        
                        NSString * regex = @"^memo([1-9]|10)$";
                        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                        
                        if([pred evaluateWithObject:param.reg]){
                            
                            //精确到单元格
                            if (bean && [bean isKindOfClass:[WSProdBean class]]) {
                                
                                WSProdBean *prodBean = (WSProdBean *)bean;
                                NSString *regTemp = nil;
                                
                                if ([param.reg isEqualToString:@"memo1"]) {
                                    regTemp = prodBean.memo1;
                                }else if ([param.reg isEqualToString:@"memo2"]){
                                    regTemp = prodBean.memo2;
                                }else if ([param.reg isEqualToString:@"memo3"]){
                                    regTemp = prodBean.memo3;
                                }else if ([param.reg isEqualToString:@"memo4"]){
                                    regTemp = prodBean.memo4;
                                }else if ([param.reg isEqualToString:@"memo5"]){
                                    regTemp = prodBean.memo5;
                                }else if ([param.reg isEqualToString:@"memo6"]){
                                    regTemp = prodBean.memo6;
                                }else if ([param.reg isEqualToString:@"memo7"]){
                                    regTemp = prodBean.memo7;
                                }else if ([param.reg isEqualToString:@"memo8"]){
                                    regTemp = prodBean.memo8;
                                }else if ([param.reg isEqualToString:@"memo9"]){
                                    regTemp = prodBean.memo9;
                                }else if ([param.reg isEqualToString:@"memo10"]){
                                    regTemp = prodBean.memo10;
                                }
                                
                                if (regTemp
                                    && [regTemp length] > 0) {
                                    l_textField.m_reg = regTemp;
                                    l_textField.m_regname = [NSString stringWithFormat:@"%@ 的 %@ 列 \n 【%@】",prodBean.name,title, NSLocalizedString(@"fill_not_correct", nil)];
                                }
                                
                            }
                            
                            if (!l_textField.m_reg || [l_textField.m_reg length] < 1) {
                                LogError(@"reg %@ 在 WSProdBean 类里没有可匹配的属性字段 ！！！" ,param.reg);
                            }
                        }else{
                            
                            LogError(@"WSFuncsBean_Param 类的属性reg字段内容非法！！！");
                            
                        }
                    }else{
                        //表格以列为单位验证
                        l_textField.m_reg = param.reg;
                        
                        if (bean && [bean isKindOfClass:[WSProdBean class]]) {
                            
                            WSProdBean *prodBean = (WSProdBean *)bean;
                            l_textField.m_regname = [NSString stringWithFormat:@"%@ 的 %@ 列 \n 【%@】",prodBean.name,title, NSLocalizedString(@"fill_not_correct", nil)];
                        }
                    }
                }
                
                [l_rowView addObject:l_textField];
            }
            
            if ([param.tpy isEqualToString:COL_TYPR]) {
                WSRadioButton *radioButton = [self grideViewDataKindOfRadioButton:param Data:[self.m_dataSources objectAtIndex:i]];
                if (radioButton  !=nil) {
                    [self setDependedInfoWith:radioButton withParam:param withRow:(int)i andColumn:(int)j];
                    radioButton.iRow = (int)i;
                    radioButton.iColumn = j;
                    [l_rowView addObject:radioButton];
                }
            }
            if ([param.tpy isEqualToString:COL_TYPCHECKBOX]) {
                
                WSCheckBox *checkBoxBtn = [self setGrideViewDataKindOfButton:param Data:[self.m_dataSources objectAtIndex:i] iRow:i  iColumn:j];
                if (checkBoxBtn != nil) {
                    [self setDependedInfoWith: checkBoxBtn withParam:param withRow:(int)i andColumn:(int)j];
                    checkBoxBtn.tpy = COL_TYPCHECKBOX;
                    [l_rowView addObject:checkBoxBtn];
                }
            }
            
            //新增全选或全取消 选择框
            if ([param.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                
                WSCheckBox *checkBoxBtn = [self setGrideViewDataKindOfButton:param Data:[self.m_dataSources objectAtIndex:i] iRow:i  iColumn:j];
                if (checkBoxBtn != nil) {
                    [self setDependedInfoWith: checkBoxBtn withParam:param withRow:(int)i andColumn:(int)j];
                    checkBoxBtn.iRow = (int)i;
                    checkBoxBtn.iColumn = j; //列值计算同表头一致。
                    checkBoxBtn.tpy = COL_TYPCHECKBOXALL;
                    [l_rowView addObject:checkBoxBtn];
                }
            }
            
            if ([param.tpy isEqualToString:COL_TYPDATE] ||[param.tpy isEqualToString:COL_TYPYM]) {
                WSDatePickerLabel *view = [[WSDatePickerLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100) param:param];
                view.tag = [self getSpecIndexbyParam:param];
                if (view) {
                    view.iRow = (int)i;
                    view.iColumn = j; //列值计算同表头一致。
                    [self setDependedInfoWith:view withParam:param withRow:(int)i andColumn:(int)j];
                    if ([self serverRedisWith:param]) {
                        
                        if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                            NSString *reDisplayText = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:param withObject:data];
                            if ([reDisplayText isKindOfClass:[NSString class]]) {
                                view.text = reDisplayText;
                            }
                        }
                    }
                    
                    /*本地回显*/
                    if ([self nativeRedis]) {
                        if ([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC]) {
                            for (WSProductObject* object  in self.m_DataBaseDatas) {
                                NSString *prod_id =object.prod_id;
                                WSProdBean *prodBean = [self.m_dataSources objectAtIndex:i];
                                if ([prod_id isEqualToString:prodBean.Id]) {
                                    NSString *value = [object valueForKey:param.col];
                                    if (value && ![value isEqualToString:@"null"]) {
                                        view.text = value;
                                    }
                                    break;
                                }
                            }
                        } else if ([self.currentFuncs.ds isEqualToString:DICTS]) {
                            for (WSDictObject *object in self.m_DataBaseDatas) {
                                NSString *dict_id = object.dict_id;
                                WSDictBean *dictBean = [self.m_dataSources objectAtIndex:i];
                                if ([dict_id isEqualToString:dictBean.Id]) {
                                    NSString *value = [object valueForKey:param.col];
                                    if (value && ![value isEqualToString:@"null"]) {
                                        view.text = value;
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                
                
                if ([param.tpy isEqualToString:COL_TYPDATE]) {
                    [view createDatePickerIconWith:WSDatePickerLabelModeDate];
                }else  if ([param.tpy isEqualToString:COL_TYPYM]) {
                    [view createDatePickerIconWith:WSDatePickerLabelModeYM];
                }else {
                    [view createDatePickerIconWith:WSDatePickerLabelModeDate];
                }
                /*
                 view无text时 显示icon
                 */
                if (view.text == nil) {
                    [view addTimeImageToView];
                }else {
                    [view changeStyle];
                }
                if(param.readonly == 1) {
                    view.userInteractionEnabled = NO;
                }
                [l_rowView addObject:view];
            }
            
            if ([param.tpy isEqualToString:COL_TYPLNR]) {
                
                WSNRLabel * label = [[WSNRLabel alloc] initWithFrame:CGRectMake(0, 0, param.wcol, 29)];
                label.iRow = i;
                label.iColumn = j;
                label.tag = [self getSpecIndexbyParam:param];
                label.font = [UIFont systemFontOfSize:UI_Font];
                label.textColor = [UIColor blackColor];
                
                if ([self serverRedisWith:param]) {
                    if ([self respondsToSelector:@selector(getDefaultDataWithParam:Others:)]) {
                        NSString *reDisplayText = [self performSelector:@selector(getDefaultDataWithParam:Others:) withObject:param withObject:[self.m_dataSources objectAtIndex:i]];
                        if ([reDisplayText isKindOfClass:[NSString class]]) {
                            label.text = reDisplayText;
                        }
                    }
                }
                
                [l_rowView addObject:label];
            }
            
            
            WSAcvtButtonForTB* l_badReason = (WSAcvtButtonForTB *)[self setGrideViewDataKindOfBadReason:param];
            if(l_badReason != nil)
            {
                l_badReason.tag = l_badReason.tag + i;
                //增加行列属性
                l_badReason.iRow = (int)i;
                l_badReason.iColumn = j;
                l_badReason.iIdentifyId = [self getIdentifyFromData:[self.m_dataSources objectAtIndex:i]];
                [self setDependedInfoWith:l_badReason withParam:param withRow:(int)i andColumn:(int)j];
                [l_rowView addObject:l_badReason];
            }
            
            WSSelectListView *list = [self setGrideViewDataKindofSelectList:param Data:[self.m_dataSources objectAtIndex:i]];
           
            list.selectListDelegate = self;
            if (list != nil) {
                list.iRow = (int)i;
                list.iColumn = j;
                list.iColumnName = [self.titles objectAtIndex:j + 1];
                list.prodName = first_label.text;
                [self setDependedInfoWith:list withParam:param withRow:(int)i andColumn:(int)j];
                [l_rowView addObject:list];
            }
            
            
            
            if ([param.tpy isEqualToString:COL_TYPPHOTO]) {
                
                if (!_abnormalReasonDict) {
                    _abnormalReasonDict = [[NSMutableDictionary alloc] initWithCapacity:2];
                }
                
                PhotoTypeButton *button = [self setGrideViewDataKindOfPhotoButton:param Data:[self.m_dataSources objectAtIndex:i]];
                button.iRow = (int)i;
                button.iColumn = j;
                [self setDependedInfoWith:button withParam:param withRow:(int)i andColumn:(int)j];
                
                NSString* mImageIdx=[NSString stringWithFormat:@"%@_%@",self.currentFuncs.fc,self.md5];
                NSString* cellKey=[NSString stringWithFormat:@"%ld_%@", (long)i, param.col];
                button.imageMD5 = [Md5Manager getMd5ByEmpId:nil
                                                    sotreId:nil
                                                    bizDate:nil
                                                   funcCode:nil
                                                     acvtId:mImageIdx
                                                       memo:cellKey];
                
                [l_rowView addObject:button];
            }
            
            if ([param.tpy isEqualToString:COL_TYPQR]) {
                WSQRTypeView * qrView = [self setGrideViewDataKindOfQRTypeView:param Data:[self.m_dataSources objectAtIndex:i]];
                qrView.iRow = (int)i;
                qrView.iColumn = j;
                if ([param.filter isEqualToString:SCAN_BARCODE]) {
                    qrView.isScanQRCode = NO;
                }
                [self setDependedInfoWith:qrView withParam:param withRow:(int)i andColumn:(int)j];

                [l_rowView addObject:qrView];
            }

        }
        
        if (self.currentFuncs.readonly == 1) {
            for (NSInteger i = 0; i < [l_rowView count]; i++) {
                NSObject *object = l_rowView[i];
                if ([object isKindOfClass:[UIView class]]) {
                    UIView *view = (UIView *)object;
                    view.userInteractionEnabled = NO;
                }
            }
        }
        
        for (NSString *formulaString in formulaStringArray) {
            if (formulaString && [formulaString length] > 0) {
                NSString *newFormulaString = [NSString stringWithString:formulaString];
                for (id view in l_rowView) {
                    if ([view isKindOfClass:[WSHTextField class]]) {
                        WSHTextField *listenerView = (WSHTextField *)view;
                        
                        if ([formulaString rangeOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col]].length > 0) {
                            NSString *key = [NSString stringWithFormat:@"{%ldrow:%dcolumn}",(long)i,listenerView.iColumn];
                            if (![self.formulaDictionary objectForKey:key]) {
                                [self.formulaDictionary  setValue:listenerView forKey:key];
                                [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:listenerView];
                                
                                [[NSNotificationCenter defaultCenter] addObserver:self
                                                                         selector:@selector(textFieldTextDidChange:)
                                                                             name:UITextFieldTextDidChangeNotification
                                                                           object:listenerView];
                            }
                            newFormulaString = [newFormulaString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",listenerView.m_col] withString:key];
                        }
                    }
                }
                id objectTemp = [self.formulaDictionary objectForKey:formulaString];
                [self.formulaDictionary setValue:objectTemp forKey:newFormulaString];
                if (![newFormulaString isEqualToString:formulaString]) {
                    [self.formulaDictionary removeObjectForKey:formulaString];
                }
            }
        }
        [self.datas addObject:l_rowView];
    }
    /*点击更多产品之后  第一列宽重新计算变小问题*/
    self.firstColumnMaxWidth = [self.colWidth firstObject];
}

- (NSString *)getIdentifyFromData:(id)aData
{
    return nil;
}

-(void)updateValueInTextFiled:(UITextField *)textFiled
{
    NSString *key = [[self.formulaDictionary allKeysForObject:textFiled] objectAtIndex:0];
    NSRange range = [key rangeOfString:@"value"];
    NSString *calString = [key substringFromIndex:(range.location + range.length)];
    LogInfo(@"计算公式替换前 : %@",calString);
    //
    NSArray *keysArray = [self.formulaDictionary allKeys];
    BOOL formulaError = NO;
    for (NSString *item in keysArray)
    {
        if (!([item rangeOfString:@"value"].length > 0) && [calString rangeOfString:item].length > 0 )
        {
            id tempText = [self.formulaDictionary objectForKey:item];
            
            if ([tempText isKindOfClass:[WSHTextField  class]]) {
                WSHTextField *textField = (WSHTextField *)tempText;
                if (textField.text && [[textField getTextValue] length] > 0) { //未填写不代表是零
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:[NSString stringWithFormat:@"%f" ,[textField getTextValue].doubleValue]];
                }else{
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:@"0.0"];

                }
            }else if ([tempText isKindOfClass:[UITextField  class]]) {
                UITextField *textField = (UITextField *)tempText;
                if (textField.text && [textField.text length] > 0) { //未填写不代表是零
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:[NSString stringWithFormat:@"%f" ,textField.text.doubleValue]];
                }else{
                    calString  = [calString stringByReplacingOccurrencesOfString:item withString:@"0.0"];
                }
            }
        }
    }
    LogInfo(@"计算公式替换后 : %@",calString);
    
    if (formulaError) {
        LogInfo(@"计算表达式出错，无法继续计算");
        textFiled.text = @"";
        return ;
    }
    /*
    NSString *value = [WSFormulaStringCalcUtility calcComplexFormulaString:calString];
     */
    NSString *value = [[WSLuaScript getInstance] arithmeticExpressions:calString];
    
    if ([textFiled isKindOfClass:[WSHTextField  class]]) {
        WSHTextField * wstextfield = (WSHTextField *)textFiled;
        
        if ([self.currentFuncs.fc isEqualToString:@"FDT_116"])
        {
            value = [NSString stringWithFormat:@"%.0f%@",[value doubleValue]*100,@"%"];
        }
        else
        {
            if ([wstextfield.m_pcs isEqualToString:@"0"]) {
                
                value = [NSString stringWithFormat:@"%.0f",[value doubleValue]];
            }else{
                
                value = [NSString stringWithFormat:@"%.2f",[value doubleValue]];
            }
        }
    }
    textFiled.text  = value;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    //公式运算
    if([self.formulaDictionary count] > 0){
        
        NSArray *tfArray = [self.formulaDictionary allValues];
        if ([tfArray containsObject:textField]) {
            NSArray *keysArray = [self.formulaDictionary allKeys];
            NSString *col = [[self.formulaDictionary allKeysForObject:textField] firstObject];
            if (col && [col length] > 0) {
                for (NSString *item in keysArray)
                {
                    if (([item rangeOfString:@"value"].length > 0)&&([item rangeOfString:col].length > 0))
                    {
                        [self updateValueInTextFiled:[self.formulaDictionary objectForKey:item]];
                    }
                }
            }
        }
    }
    
    
    
    
    if ([textField isKindOfClass:[WSHTextField class]] ) {
        WSHTextField *wsTextFiled = (WSHTextField *)textField;
        
        if (wsTextFiled.m_isGride == NO) {
            return;
        }
        WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:wsTextFiled.iColumn];
        id data = [self.m_dataSources objectAtIndex:wsTextFiled.iRow];//TODO：将来需要重构m_DataBaseDatas，使类型确定
        
        if ([data isKindOfClass:[WSProdBean class]]) {
            [_prod_cacheDataMDictionary setObject:wsTextFiled.text forKey:[NSString stringWithFormat:@"%@_%@", [(WSProdBean *)data Id], param.col]];
        }else if ([data isKindOfClass:[WSProductObject class]]) {
            [_prod_cacheDataMDictionary setObject:wsTextFiled.text forKey:[NSString stringWithFormat:@"%@_%@", [(WSProductObject *)data prod_id], param.col]];
        }
    
        
        if (wsTextFiled.m_alert != nil && wsTextFiled.m_maxValue > 0) {
            float alertValue = [wsTextFiled.m_alert floatValue];
            float value = [wsTextFiled getTextValue].floatValue;
            if (value < (1 - alertValue) * wsTextFiled.m_maxValue || value > (1 + alertValue) * wsTextFiled.m_maxValue) {
                wsTextFiled.textColor = [UIColor redColor];
            }
            else
            {
                wsTextFiled.textColor = [UIColor blackColor];
            }
        }
        
        
        
        // 支持公式计算
        if (wsTextFiled.m_col
            && [wsTextFiled.m_col length] > 0
            && self.expressionDictionary
            && [self.expressionDictionary count] > 0) {
            
            NSArray * allKeys = [self.expressionDictionary allKeys];
            
            NSMutableArray *keys = [NSMutableArray arrayWithCapacity:2];
            
            for (NSString *keyTemp in allKeys) {
                if ([keyTemp rangeOfString:wsTextFiled.m_col].length > 0) {
                    [keys addObject:keyTemp];
                }
            }
            
            for (NSString *keyTemp in keys) {
                
                if ([keyTemp rangeOfString:@"sum"].length > 0) {
                    id temp = [self.expressionDictionary objectForKey:keyTemp];
                    if ([temp isKindOfClass:[WSHTextField class]]) {
                        //总和
                        WSHTextField *expressionText = (WSHTextField *)temp;
                        expressionText.text = @"0";
                        BOOL isFloating = NO;
                        if (expressionText.m_max
                            && [expressionText.m_max rangeOfString:@"."].length > 0) {
                            
                            isFloating = YES;
                        }
                        
                        for (NSArray * rowArray in self.datas) {
                            //健壮性编码
                            if (wsTextFiled.iColumn + 1 >= [rowArray count] ) {
                                LogError(@"【%d】 数组下标越界 ! \n", __LINE__);
                                return;
                            }
                            
                            id objectTemp = [rowArray objectAtIndex:wsTextFiled.iColumn + 1];
                            if ([objectTemp isKindOfClass:[WSHTextField class]]) {
                                WSHTextField *mWSHTextField = (WSHTextField *)objectTemp;
                                if (isFloating) {
                                    
                                    NSString *formatStirng = nil;
                                    if(expressionText.m_pcs
                                       && [expressionText.m_pcs length] > 0
                                       && [expressionText.m_pcs integerValue] > 0){
                                        
                                        formatStirng = [NSString stringWithFormat:@"%%.%ldf" , (long)[expressionText.m_pcs integerValue]];
                                    }
                                    if (formatStirng) {
                                        expressionText.text = [NSString stringWithFormat:formatStirng,([[expressionText getTextValue] floatValue] +  [[mWSHTextField getTextValue] floatValue])];
                                    }else{
                                        expressionText.text = [NSString stringWithFormat:@"%f",([[expressionText getTextValue] floatValue] +  [[mWSHTextField getTextValue] floatValue])];
                                    }
                                    
                                }else{
                                    
                                    expressionText.text = [NSString stringWithFormat:@"%lli",([[expressionText getTextValue] longLongValue] +  [[mWSHTextField getTextValue] longLongValue])];
                                }
                                
                            }
                        }
                        
                        //总和超出限制则提示用户，并取消用户输入
                        if (expressionText.m_max
                            && [expressionText.text longLongValue] > [expressionText.m_max longLongValue] )
                        {
                            if (isFloating) {
                                
                                NSString *formatStirng = nil;
                                if(expressionText.m_pcs
                                   && [expressionText.m_pcs length] > 0
                                   && [expressionText.m_pcs integerValue] > 0){
                                    
                                    formatStirng = [NSString stringWithFormat:@"%%.%ldf" , (long)[expressionText.m_pcs integerValue]];
                                }
                                if (formatStirng) {
                                    expressionText.text = [NSString stringWithFormat:formatStirng,([[expressionText getTextValue] floatValue] -  [[wsTextFiled getTextValue] floatValue])];
                                }else{
                                    expressionText.text = [NSString stringWithFormat:@"%f",([[expressionText getTextValue] floatValue] -  [wsTextFiled.text floatValue])];
                                }
                            }else{
                                
                                expressionText.text = [NSString stringWithFormat:@"%lli",([[expressionText getTextValue] longLongValue] -  [[wsTextFiled getTextValue] longLongValue])];
                            }
                            wsTextFiled.text = @"";
                            NSString *title = NSLocalizedString(@"input_number_max", nil);
                            // 最大输入数字的提示根据服务端配置的m_max来显示的
                            title = [NSString stringWithFormat:@"【%@】%@:%@",expressionText.placeholder ,title, expressionText.m_max];
                            
                            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                
                        }
                        
                    }
                }
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    dataGridComponentRect = CGRectZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    self.m_moreProdsCount = 0;
    self.firstColumnMaxWidth = @"0";
    self.showAddedProds = YES;
    _isFirstLoadView = YES;
    self.formulaDictionary = [[NSMutableDictionary alloc] init];
    
    if (self.currentStore.inReadonlyMode) {
        for (NSArray *viewArray in self.datas) {
            for (UIView *view in viewArray) {
                view.userInteractionEnabled = NO;
            }
        }
    }
}


- (void) loadGridViewSearchBar
{
    if (self.currentFuncs.opt.needSelect
        && [self.currentFuncs.opt.needSelect length] > 0) {

        if (self.m_addedDataSources == nil) {
            self.m_addedDataSources = [NSMutableArray arrayWithCapacity:1];
        }
        if ([self.currentFuncs.opt.needSelect integerValue] == 1) {
            // 添加搜索框 搜索框暂不添加
            if (self.dataGridView.serieLinkHeadView) {
                [self.dataGridView.serieLinkHeadView removeFromSuperview];
                self.y_point = 0;
            }
            _firstGridSearchView = [[WSGridSearchView alloc] initWithFrame:CGRectMake(0,  self.y_point, self.view.frame.size.width, 44) funcs:self.currentFuncs md5:self.md5];
            _firstGridSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _firstGridSearchView.drid = self.currentStore.drId;
            
//            if (_firstGridSearchView.uploadedEditedProds && _firstGridSearchView.uploadedEditedProds.count > 0 && (!self.m_addedDataSources || [self.m_addedDataSources count] <= 0)) {
//                self.m_addedDataSources = _firstGridSearchView.uploadedEditedProds;
//            }
            
            _firstGridSearchView.delegate = self;
            [self.contentScrollView addSubview:_firstGridSearchView];
            self.y_point = self.y_point + CGRectGetHeight(_firstGridSearchView.frame);
        }else if ([self.currentFuncs.opt.needSelect integerValue] == 2){
            _serieLinkView = [[WSSerieLinkView alloc] initWithFrame:CGRectMake(0,  self.y_point,self.view.frame.size.width, 44) brandFilter:self.currentFuncs.filter superProdGridMd5:self.md5];
            _serieLinkView.delegate = self;
            [self.contentScrollView addSubview:_serieLinkView];
            self.y_point =  self.y_point + CGRectGetHeight(_serieLinkView.frame);
            
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isAllProducts = YES;
    
    // 启动依赖关系
    for (int n = 0; n < [self.datas count]; n++) {
        NSArray *viewArray = [self.datas objectAtIndex:n];
        for (int m = 0; m < [viewArray count]; m++) {
            id obj = [viewArray objectAtIndex:m];
            if (obj != nil && [obj respondsToSelector:@selector(startObservingEntity)]) {
                [obj startObservingEntity];
            }
        }
    }
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollViewContent:) name:GAIN_KEYBORE_HEIGHT_NOTIFICTION_NAME object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduceScrollViewContentSizeHeight) name:UIKeyboardWillHideNotification object:nil];
}

/*
- (void)changeScrollViewContent:(NSNotification*)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyBord_height = [userInfo[WS_KEYBORD_HEIGTH] floatValue];
    CGFloat acvtView_move_height = [userInfo[WS_ACVT_VIEW_MOVE_HEIGHT] floatValue];
    self.gridViewChangeHeight = keyBord_height;
    if (acvtView_move_height < 0) {
        self.gridViewChangeHeight = keyBord_height + acvtView_move_height;
    }
    
    self.gridViewChangeHeight -= 44;
    
    CGRect rect = self.dataGridView.frame;
    dataGridComponentRect = rect;
    rect.size.height -= self.gridViewChangeHeight;
    self.dataGridView.frame = rect;
//    self.contentSize = CGSizeMake(self.acvtView.width, self.acvtView.height + self.scrollViewChangeHeight);
}


- (void)reduceScrollViewContentSizeHeight {
    if (self.gridViewChangeHeight > 0) {
        self.dataGridView.frame = dataGridComponentRect;
    }
}
 */

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    for ( NSMutableArray * textView in self.datas ) {
        for (WSHTextField *textField in textView) {
            if (textField.editing) {
                [textField resignFirstResponder];
                return ;
            }
        }
    }
}


- (void)createDataGridView
{
    if (self.y_point < 1) {
        self.y_point = 0;
    }
    
//    DataGridComponentDataSource*  comData = [[DataGridComponentDataSource alloc] init];
    WSBaseDataGridComponentDataSource *comData = _baseDataGridComponentDataSource;
    
    comData.titles = self.titles;
    comData.data = self.datas;
    comData.columnWidth = self.colWidth;
    comData.currentTableItem = [[WSTableItem alloc] initWithFuncsBean:self.currentFuncs];

    
    NSInteger maxRow = self.currentFuncs.maxRow;
    if(maxRow > comData.data.count+1){
        maxRow = comData.data.count+1;
    }
    
    if (maxRow <= 0) {
        maxRow = comData.data.count+1;
        /*当需要用选择品牌或者系列来展示时候，初始化的时候表格高度为 0*/
        
    }
    
//    NSInteger maxRow = comData.data.count+1;  //默认为最大行数，最后reDrawGrideWithHeight方法会根据屏幕自适应
    
    /*当只有表头 且需要用选品牌来显示的时候*/
    if (maxRow == 1) {
        if ([self.currentFuncs.opt.needSelect length] > 0) {
            maxRow = 0;
        }else{
            maxRow = comData.data.count+1;
        }
    }
    
    CGFloat heiht = maxRow * DATAGRID_CELL_HEIGHT_DEFAULT;
    
    DataGridComponent*  compView = [[DataGridComponent alloc]
                                    initWithFrame:
                                    CGRectMake(0, self.y_point, CGRectGetWidth(self.view.bounds), heiht) data:comData funcs:self.currentFuncs isAllProducts:_isAllProducts isDrawSerieLink:YES];
    
    compView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // 如果是只读的，不让用户继续操作表格   SFA 箭牌 WRIGLEY-1758
    if (self.currentStore.inReadonlyMode) {
        [self setGridReadonly];
    }

    if ([compView.cellHeightDic count] > 0) {
        CGFloat realAllHeight = compView.headerHeight;
        for (NSInteger i = 0; i < maxRow - 1; i++) {
            CGFloat cellHeight = [[compView.cellHeightDic objectForKey:[NSNumber numberWithInteger:i]] floatValue];
            realAllHeight += cellHeight;
        }
        
        CGRect newFrame = compView.frame;
        newFrame.size.height = realAllHeight;
        compView.frame = newFrame;
    }
    
    self.dataGridView = compView;
    
    [self.contentScrollView addSubview:compView];
    
    self.y_point+= compView.height + 10;
    
    
    // 根据显示的数据的不同情况 判断是否应该显示提示 如果显示 判断应该提示什么内容
    
    UILabel *notice_label = nil;
    // 提示向左滑动
    BOOL should_notice_swap_left = NO;
    // 提示向上滑动
    BOOL should_notice_swap_up = NO;
    NSString *infoToNotice = @"";
    // 判断提示的信息
    if ([compView.dataSource.columnWidth count]) {
        // 列数大于1 对其宽度的判断
        float width = compView.contentWidth + [[compView.dataSource.columnWidth objectAtIndex:0] floatValue];
        if (width > SCREEN_WIDTH - MAIN_PADDING * 2 && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))
        {
            should_notice_swap_left = YES;
        }
    }
    if (self.m_dataSources.count > self.currentFuncs.maxRow - 1)
    {
        should_notice_swap_up = YES;
    }
    
    if (should_notice_swap_up)
    {
        // 提示向上滑动
        infoToNotice = NSLocalizedString(@"more_content_scroll_top", nil);
        if (should_notice_swap_left) {
            // 提示向上和向左滑动
            infoToNotice = NSLocalizedString(@"more_content_scroll_top_left", nil);
        }
    }
    else if(should_notice_swap_left)
    {
        // 提示向左滑动
        infoToNotice = NSLocalizedString(@"more_content_scroll_left", nil);
    }
    
    if (should_notice_swap_left || should_notice_swap_up) {
        notice_label = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, self.y_point, self.view.frame.size.width - MAIN_PADDING * 2, 30)];
        notice_label.backgroundColor = [UIColor clearColor];
        notice_label.textColor = [UIColor redColor];
        UIFont *font = [UIFont systemFontOfSize:13];
        notice_label.font = font;
        notice_label.text = infoToNotice;
        notice_label.textAlignment = NSTextAlignmentCenter;
        notice_label.tag = NoticeLabelTag;
        [notice_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentScrollView addSubview:notice_label];
        self.y_point += 30;
    }
    // add by xiajunling 2014-07-01 把表头视图里包含的多选项放到datas数组里 ，并监听按钮事件。 （支持CA类型）
    NSMutableArray *checkBoxArrayTemp = [NSMutableArray arrayWithCapacity:5];
    while ([compView.checkBoxArray count]>0) {
        
        id checkBoxObj = [compView.checkBoxArray firstObject];
        if ([checkBoxObj isKindOfClass:[WSCheckBox class]]) {
            
            WSCheckBox *checkButton = (WSCheckBox *)checkBoxObj;
            [checkButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            //判断是否表头checkBox 定义见 DataGridComponent.m ,目前表头嵌入checkBox只支持除第0列以外的列。
            NSInteger column = checkButton.iColumn;
            //获取列的类型 col属性值 好从m_DataBaseDatas里获取相应数据
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:column - 1];
            
            //获取产品数量
            NSInteger countPro = [self.m_dataSources count];
            for (id objTemp in self.m_dataSources) {
                if ( [objTemp isKindOfClass:[WSProdBean class]]) {
                    WSProdBean *prodBean = (WSProdBean *)objTemp;
                    
                    for (WSProductObject* object in self.m_DataBaseDatas) {
                        NSString *prodID = [NSString stringWithFormat:@"%@",object.prod_id];
                        NSString *colString = [NSString stringWithFormat:@"%@",[object valueForKey:param.col]];
                        if ([prodBean.Id isEqualToString:prodID]
                            && [colString isEqualToString:@"1"]) {
                            countPro = countPro -1;
                        }
                    }
                }else if( [objTemp isKindOfClass:[WSDictBean class]]){
                    WSDictBean *dictBean = (WSDictBean *)objTemp;
                    for (NSDictionary * dicData in self.m_DataBaseDatas) {
                        NSString *dict_id = [NSString stringWithFormat:@"%@",[dicData objectForKey:@"dict_id"]];
                        NSString *colString = [NSString stringWithFormat:@"%@",[dicData objectForKey:param.col]];
                        if ([dictBean.name isEqualToString:dict_id]
                            && [colString isEqualToString:@"1"]) {
                            countPro = countPro -1;
                        }
                    }
                    
                }
            }
            //所有产品都被选中，则全部选择项为选中状态
            if (countPro < 1) {
                [checkButton setSelected:YES];
            }
            
            [checkBoxArrayTemp addObject:checkButton];
        }
        
        [compView.checkBoxArray  removeObject:checkBoxObj];
    }
    
    compView.checkBoxArray = nil;
    
    if (!self.checkBoxesArrayOfHeaderView) {
        self.checkBoxesArrayOfHeaderView = [NSMutableArray arrayWithCapacity:5];
    }
    [self.checkBoxesArrayOfHeaderView removeAllObjects];
    if ([checkBoxArrayTemp count]>0) {
        [self.checkBoxesArrayOfHeaderView addObjectsFromArray:checkBoxArrayTemp];
    }
    
}


/*表格支持只读*/
- (void)setGridReadonly {
    for (NSInteger i = 0; i < [self.datas count]; i++) {
        NSMutableArray *rowViews = [self.datas objectAtIndex:i];
        for (NSInteger j = 0; j < [rowViews count]; j++) {
            UIView *view = rowViews[j];
            if ([view isKindOfClass:[UIView class]]) {
                view.userInteractionEnabled = NO;
            }
        }
    }
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)textWatcher:(id)sender
{
    
}


- (void)photoTypeButtonClick:(PhotoTypeButton *)aPhotoTypeButton {
    self.currentPhotoButton = aPhotoTypeButton;
    if (aPhotoTypeButton.photoIDArray == nil) {
        aPhotoTypeButton.photoIDArray = [[NSMutableArray alloc] init];
    }
    
    if (aPhotoTypeButton.isSupperLocalPhoto) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"cancel_label" destructiveButtonTitle:nil otherButtonTitles:@"photo_library", @"camera_capture", nil];
        // 显示
        [actionsheet showInView:self.view];

    }else{
        WSPhotoGalleryViewController *pgVc = [[WSPhotoGalleryViewController alloc] initWithImageIDArray:aPhotoTypeButton.photoIDArray];
        pgVc.delegate = self;
        pgVc.currentStore = self.currentStore;
        pgVc.maxPhotoCount = aPhotoTypeButton.maxPhotoCount;
        LogInfo(@"Going to class WSPhotoGalleryViewController");
        [self.navigationController pushViewController:pgVc animated:YES];
    }

}

#pragma mark - UIActionSheetDelegate实现代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        NSLog(@"点击了相册按钮");
        WSPhotoGalleryViewController *pgVc = [[WSPhotoGalleryViewController alloc] initWithImageIDArray:self.currentPhotoButton.photoIDArray];
        pgVc.delegate = self;
        pgVc.storeName = self.currentStore.name;
        pgVc.maxPhotoCount = self.currentPhotoButton.maxPhotoCount;
        pgVc.imagePickerControllerSourceType = UIImagePickerControllerSourceTypePhotoLibrary + 1;
        LogInfo(@"Going to class WSPhotoGalleryViewController");
        [self.navigationController pushViewController:pgVc animated:YES];
    }
    else if (1 == buttonIndex)
    {
        NSLog(@"点击了拍照按钮");
        WSPhotoGalleryViewController *pgVc = [[WSPhotoGalleryViewController alloc] initWithImageIDArray:self.currentPhotoButton.photoIDArray];
        pgVc.delegate = self;
        pgVc.storeName = self.currentStore.name;
        pgVc.maxPhotoCount = self.currentPhotoButton.maxPhotoCount;
        pgVc.imagePickerControllerSourceType = UIImagePickerControllerSourceTypeCamera + 1;
        LogInfo(@"Going to class WSPhotoGalleryViewController");
        [self.navigationController pushViewController:pgVc animated:YES];
    }
    else if (2 == buttonIndex)
    {
        NSLog(@"点击了取消按钮");
    }
    
}

- (void)photoGallery:(WSPhotoGalleryViewController *)photoGallery addImage:(NSString *)imageID {
    self.currentPhotoButton.isValueChange = YES;
}

- (void)photoGalleryDeletePhoto:(WSPhotoBrowserViewController *)photoGallery {
    self.currentPhotoButton.isValueChange = YES;
}

- (void)updatePhotoData:(WSPhotoGalleryViewController *)aPhotoGalleryViewController photoArray:(NSMutableArray *)images {
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoTypeButton_Notification object:nil];
}

#pragma mark - WCPopListView delegate
- (void)popListViewDidSelectedEnd:(WCPopListView *)popListView {
    NSString *items = nil;
    UILabel *labe = (UILabel *)[popListView getFromView];
    NSArray *selectedArray = [popListView getSelectedArray];
    if ([selectedArray count] > 0) {
        items = [selectedArray componentsJoinedByString:@","];
    }
    labe.text = items;
}

#pragma mark WSSelectListView Methods
- (void)popupSelectListViewDidAppear:(WSSelectListView *)aSelectListView{
    

       NSMutableArray *content =  [NSMutableArray arrayWithArray:aSelectListView.contentDicts];
       //[content removeObjectAtIndex:0];
    
        self.currentSelectListView = aSelectListView;
        WSSingleSelectAndSearchViewController *ssvc = [[WSSingleSelectAndSearchViewController alloc]init];
        ssvc.selectedDelegate = self;
        [ssvc setItemArray:content];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ssvc];
        [self presentViewController:nc animated:YES completion:nil];
    
    
}
#pragma mark singleSelectAndSearchDelegate Methods
- (void)singleSelectAndSearchView:(WSSingleSelectAndSearchViewController *)singleSelectAndSearchView didSelectedItem:(id<I_W_OptionDataItem>)item
{
     WSDictBean *selectElement = (WSDictBean *)item;
    if (selectElement && selectElement.name.length >0) {
         __block NSInteger index = -1;
        
        [self.currentSelectListView.content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            NSString *element = (NSString *)obj;
            if ([element isEqualToString:selectElement.name]) {
                index = idx;
                *stop = YES;
            }
        }];
        if (index > -1) {
            self.currentSelectListView.selectedIndex = index;
        }
        
    }else{
        self.currentSelectListView.selectedIndex = 0;
    }
}


#pragma mark - private function
- (void)setDependedInfoWith:(id<WSValidateData>)aProtocal withParam:(WSFuncsBean_Param *)aParam withRow:(NSInteger)aRow andColumn:(NSInteger)aColumn
{
    if (aProtocal != nil && [aProtocal respondsToSelector:@selector(setNotificationPrefix:andRow:andColumn:andDataType:)]) {
        if (aParam.iDependon != nil && [aParam.iDependon length] > 0) {
            
            if ([aProtocal isKindOfClass:[UIView class]]) {
                UIControl *control = (UIControl *)aProtocal;
                [control setEnabled:NO];
            }
            
            NSArray *array = [aParam.iDependon componentsSeparatedByString:@"|"];
            if ([array count] > 1) {
                aProtocal.iLogicType = WSValidateDataLogicOR;
            }else{
                array = [aParam.iDependon componentsSeparatedByString:@"&"];
                aProtocal.iLogicType = WSValidateDataLogicAND;
            }
            
            for (NSString *dependoncol in array) {
                for (int i = 0; i < [self.currentFuncs.paramArray count]; i++) {
                    @autoreleasepool {
                        WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:i];
                        if (param.col != nil && [param.col isEqualToString:dependoncol/*aParam.iDependon)*/]) {
                            NSString *prefix = [NSString stringWithFormat:@"%@-%@", self.currentFuncs.fc, dependoncol];
                            [aProtocal setNotificationPrefix:prefix andRow:(unsigned int)aRow andColumn:(unsigned int)i andDataType:WSValidateDataDependOtherData];
                        }
                        
                        NSArray *array = [param.iDependon componentsSeparatedByString:@"|"];
                        for (NSString *dependoncolName in array) {
                            if (aParam.col != nil && [aParam.col isEqualToString:dependoncolName]) {
                                NSString *prefix = [NSString stringWithFormat:@"%@-%@", self.currentFuncs.fc, dependoncolName];
                                [aProtocal setNotificationPrefix:prefix andRow:(unsigned int)aRow andColumn:(unsigned int)aColumn andDataType:WSValidateDataDependOtherDataAndIsDepended];
                            }
                        }

                    }
                }
            }
        }else{
            BOOL bfind = NO;
            for (int i = 0; i < [self.currentFuncs.paramArray count] && !bfind; i++) {
                WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:i];
                if (param.iDependon != nil && [param.iDependon length] > 0 /*&& [param.iDependon isEqualToString:aParam.col]*/) {
                    
                    NSArray *array = [param.iDependon componentsSeparatedByString:@"|"];
                    for (NSString *dependoncol in array) {
                        if ([dependoncol isEqualToString:aParam.col]) {
                            NSString *prefix = [NSString stringWithFormat:@"%@-%@", self.currentFuncs.fc, dependoncol/*param.iDependon*/];
                            [aProtocal setNotificationPrefix:prefix andRow:(unsigned int)aRow andColumn:(unsigned int)aColumn andDataType:WSValidateDataIsDepended];
                            bfind = YES;
                            //                            NSLog(@"prefix2 = %@-%d-%d", prefix, aRow, aColumn);
                        }
                    }
                }
            }
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    WSHTextField *textFieldView =(WSHTextField *)textField;
    [textFieldView resignFirstResponder];
    
    for (int i = textFieldView.iRow; i< self.datas.count; i++) {
        NSMutableArray *textView = [self.datas objectAtIndex:i];
        int iColumn = textFieldView.iColumn;
        if (iColumn < textView.count && iColumn > 0 ) {
            for (int j = iColumn ; j < textView.count; j++) {
                if (j < textView.count -1 ) {
                    WSHTextField *textFieldOpt = [[self.datas objectAtIndex:i] objectAtIndex:j +1];
                    BOOL isTextField = [textFieldOpt isKindOfClass:[WSHTextField class]];
                    if (isTextField && textFieldOpt.enabled && !textFieldOpt.isHidden) {
                        [textFieldOpt becomeFirstResponder];
                        return NO ;
                    }
                }
                else if (i < self.datas.count-1 && j == textView.count -1){
                    WSHTextField *textFieldOpt = [[self.datas objectAtIndex:i+1] objectAtIndex:1];
                    BOOL isTextField = [textFieldOpt isKindOfClass:[WSHTextField class]];
                    if (isTextField && textFieldOpt.enabled && !textFieldOpt.isHidden) {
                        [textFieldOpt becomeFirstResponder];
                        return NO ;
                    }
                }
            }
            
        } else {
            //             MMSH-3587
            //             SFA玛氏中国MWC- 【IOS:拜访】产品表格如价格，产品等不能用键盘点击下一项输入
            WSHTextField *textFieldOpt = [[self.datas objectAtIndex:i] objectAtIndex:1];
            BOOL isTextField = [textFieldOpt isKindOfClass:[WSHTextField class]];
            if (isTextField && textFieldOpt.enabled && !textFieldOpt.isHidden) {
                [textFieldOpt becomeFirstResponder];
                return NO ;
            }
        }
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [super textFieldDidBeginEditing:textField];
    //    self.m_CurrentInputView = textField;
    BOOL isField = [textField isKindOfClass:[WSHTextField class]];
    if (isField) {
        WSHTextField *field = (WSHTextField*)textField;
        if (field.m_type != nil && [field.m_type isEqualToString:COL_TYPNUM]) {
            self.m_CurrentInputView = textField;
            return;
        }
    }
    
    //       if ([textField isKindOfClass:[WSHTextField class]] ])
    //    {
    //        self.isModifyData = YES;
    //        WSHTextField *field = (WSHTextField*)textField;
    //        if (field.m_isGride) {
    //            if (self.m_CurrentInputView && !CGRectIsEmpty(dataGridComponentRect)) {
    //                CGRect vcRect = self.view.frame;
    //
    //                CGFloat originY = 0;
    //                if ([self respondsToSelector:@selector(originalViewYPosition)]) {
    //                    id result = [self performSelector:@selector(originalViewYPosition)];
    //                    if ([result isKindOfClass:[NSNumber class]]) {
    //                        originY = [result floatValue];
    //                    }
    //                }
    //                vcRect.origin.y = originY;
    //                [UIView animateWithDuration:0.1 animations:^{
    //                    self.view.frame = vcRect;
    //                }];
    //
    //
    //                DataGridComponent *compView = nil;
    //                for (UIView *view in [self.contentScrollView subviews]) {
    //                    if ([view isKindOfClass:[DataGridComponent class]]) {
    //                        compView = (DataGridComponent *)view;
    //                        break;
    //                    }
    //                }
    //                [compView reDrawGridViewWithY: CGRectGetMinY(dataGridComponentRect)];
    //                [compView redrawGridViewWithHeightForKeyboardShow: CGRectGetHeight(dataGridComponentRect)];
    //            }
    //
    //             [textField resignFirstResponder];
    //            WSGridTextInputViewController *vc = [[WSGridTextInputViewController alloc] init];
    //            vc.maxWordCount = [field.m_max integerValue];
    //            vc.currentTextField = textField;
    //            vc.currentTextField.keyboardType =  UIKeyboardTypeDefault;
    //            vc.delegate = self;
    //            [self presentViewController:vc animated:YES completion:nil];
    //
    //        }
    //    }
    self.m_CurrentInputView = textField;
}
-(UIView *)WSHTextField:(WSHTextField *)textField viewForKeyboardUserInfo:(NSDictionary *)userInfo
{
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect = [aValue CGRectValue];
    aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endRect = [aValue CGRectValue];
    CGFloat moveFloat = CGRectGetMinY(endRect) - CGRectGetMinY(beginRect);
    
    if (moveFloat == 0) {
        return self.contentScrollView;
    }
    
    for(UIView* view in self.contentScrollView.subviews)
    {
        if([view isKindOfClass:[DataGridComponent class]])
        {
            CGRect rect = view.frame;
            if (moveFloat < 0) {
                dataGridComponentRect = rect;
                
                WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
                UIViewController *rootViewController = delegate.window.rootViewController;
                CGRect rectInRootVC = [self.contentScrollView convertRect:self.contentScrollView.frame toView:rootViewController.view];
                moreHeight = self.view.bounds.size.width - CGRectGetMaxY(rectInRootVC) ;
            }
            
            CGFloat spareFloat = CGRectGetHeight(self.contentScrollView.frame) - CGRectGetHeight(dataGridComponentRect) - CGRectGetMinY(dataGridComponentRect);
            if (moveFloat > 0) {
                moveFloat -= (spareFloat + moreHeight);
            }else {
                moveFloat += (spareFloat + moreHeight);
            }
            rect.size.height += moveFloat;
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 view.frame = rect;
                             } completion:^(BOOL finished) {
                                 view.frame = rect;
                             }];
            
            return view;
        }
    }
    
    return nil;
}
- (void)gridTextInputFinish:(WSGridTextInputViewController *)gridTextInput {
    if (gridTextInput.isValueChange) {
        _isValueChange = YES;
    }
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAIN_KEYBORE_HEIGHT_NOTIFICTION_NAME object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//}

- (BOOL)isValueChange {
    if ([super respondsToSelector:@selector(isValueChange)]) {
        BOOL superValueChange = [super isValueChange];
        if (superValueChange) return YES;
    }
    
    if (_isValueChange) return _isValueChange;
    for (UIView *view in self.contentScrollView.subviews) {
        if ([view respondsToSelector:@selector(isValueChange)]) {
            if ([view performSelector:@selector(isValueChange)]) {
                self.isValueChange = YES;
                return _isValueChange;
            }
        }
    }
    return NO;
}

/**
 *  重绘产品表格，目前只支持self.contentScrollView视图上只有一个表格类型视图的业务逻辑。
 *
 *  @param newHeight <#newHeight description#>
 */
- (void)reDrawGrideWithHeight:(CGFloat) newHeight
{
    
    DataGridComponent *compView = self.dataGridView;

    if (compView  && ![self isPrepareShowOptView]) {
        
        //调整后的表格可视区域的高度
        CGFloat adjustHeight = newHeight - 30;
        
        //重新计算y_point坐标
        
//        self.y_point = self.y_point - compView.frame.size.height;
        self.y_point = compView.frame.origin.y;
        
        // 根据显示的数据的不同情况 判断是否应该显示提示 如果显示 判断应该提示什么内容
        UILabel *notice_label = nil;
        // 提示向左滑动
        BOOL should_notice_swap_left = NO;
        // 提示向上滑动
        BOOL should_notice_swap_up = NO;
        NSString *infoToNotice = @"";
        // 判断提示的信息
        if ([compView.dataSource.columnWidth count]) {
            // 列数大于1 对其宽度的判断
            float width = compView.contentWidth + [[compView.dataSource.columnWidth objectAtIndex:0] floatValue];
            if (width > self.view.width)
            {
                should_notice_swap_left = YES;
            }
        }
        
        
        CGFloat cacheAdjuestHeight = adjustHeight;
        cacheAdjuestHeight -= compView.headerHeight;
        for (NSInteger i = 0; i < self.m_dataSources.count; i++) {
            cacheAdjuestHeight -= [[compView.cellHeightDic objectForKey:[NSNumber numberWithInteger:i]] floatValue];
            if (cacheAdjuestHeight < 0) {
                should_notice_swap_up = YES;
                break;
            }
        }
        
        
        if (should_notice_swap_up)
        {
            // 提示向上滑动
            infoToNotice = NSLocalizedString(@"more_content_scroll_top", nil);
            if (should_notice_swap_left) {
                // 提示向上和向左滑动
                infoToNotice = NSLocalizedString(@"more_content_scroll_top_left", nil);
            }
        }
        else if(should_notice_swap_left)
        {
            // 提示向左滑动
            infoToNotice = NSLocalizedString(@"more_content_scroll_left", nil);
        }
        
        
        if (should_notice_swap_left || should_notice_swap_up) {
            
            // SFA-4388 显示不协调（调整向左滑动提示不显示的问题）
            if (adjustHeight > compView.height) {
                self.y_point += compView.height + 30;
                if (should_notice_swap_left || should_notice_swap_up){
                    self.y_point -= 30;
                    UIView *noticView = [self.contentScrollView viewWithTag:NoticeLabelTag];
                    
                    if (noticView) {
                        
                        [noticView removeFromSuperview];
                    }
                    notice_label = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, self.y_point, self.view.frame.size.width - MAIN_PADDING * 2, 30)];
                    notice_label.backgroundColor = [UIColor clearColor];
                    notice_label.textColor = [UIColor redColor];
                    UIFont *font = [UIFont systemFontOfSize:13];
                    notice_label.font = font;
                    notice_label.text = infoToNotice;
                    notice_label.textAlignment = NSTextAlignmentCenter;
                    notice_label.tag = NoticeLabelTag;
                    [notice_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                    [self.contentScrollView addSubview:notice_label];
                    self.y_point += 30;
                }
                
                return;
            }else {
                UIView *noticView = [self.contentScrollView viewWithTag:NoticeLabelTag];
                
                if (noticView) {
                    
                    [noticView removeFromSuperview];
                }
            }
            
            
            self.y_point += adjustHeight;
            
            notice_label = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_PADDING, self.y_point, self.view.frame.size.width - MAIN_PADDING * 2, 30)];
            notice_label.backgroundColor = [UIColor clearColor];
            notice_label.textColor = [UIColor redColor];
            UIFont *font = [UIFont systemFontOfSize:13];
            notice_label.font = font;
            notice_label.text = infoToNotice;
            notice_label.textAlignment = NSTextAlignmentCenter;
            notice_label.tag = NoticeLabelTag;
            [notice_label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [self.contentScrollView addSubview:notice_label];
            self.y_point += 30;
        }else{
            
            adjustHeight += 30;
            self.y_point += adjustHeight;
            
            if (adjustHeight > compView.height) {
                return;
            }else {
                UIView *noticView = [self.contentScrollView viewWithTag:NoticeLabelTag];
                
                if (noticView) {
                    
                    [noticView removeFromSuperview];
                }
            }
        }
        
        [compView reDrawGridViewWithHeight:adjustHeight];
    }
    
    
    dataGridComponentRect = compView.frame;
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    
}

- (void) recount
{
    
    //文本回显（公式计算）
    if(self.expressionDictionary
       && [self.expressionDictionary count] > 0) {
        
        NSArray * allKeys = [self.expressionDictionary allKeys];
        
        for (NSString *tempkey in  allKeys) {
            
            //汇总公式（前提是不会出现相同的公式内容）
            if ([tempkey rangeOfString:@"sum"].length > 0) {
                id temp = [self.expressionDictionary objectForKey:tempkey];
                if ([temp isKindOfClass:[WSHTextField class]]) {
                    //总和
                    WSHTextField *expressionText = (WSHTextField *)temp;
                    expressionText.text = @"0";
                    
                    BOOL isFloating = NO;
                    if (expressionText.m_max
                        && [expressionText.m_max rangeOfString:@"."].length > 0) {
                        
                        isFloating = YES;
                    }
                    
                    for (NSArray * rowArray in self.datas) {
                        for (id objectTemp  in rowArray) {
                            if ([objectTemp isKindOfClass:[WSHTextField class]]
                                && [[NSString stringWithFormat:@"%@@sum",((WSHTextField *)objectTemp).m_col] isEqualToString:tempkey]) {
                                WSHTextField *mWSHTextField = (WSHTextField *)objectTemp;
                                if (isFloating) {
                                    NSString *formatStirng = nil;
                                    if(expressionText.m_pcs
                                       && [expressionText.m_pcs length] > 0
                                       && [expressionText.m_pcs integerValue] > 0){
                                        
                                        formatStirng = [NSString stringWithFormat:@"%%.%ldf" , (long)[expressionText.m_pcs integerValue]];
                                    }
                                    if (formatStirng) {
                                        expressionText.text = [NSString stringWithFormat:formatStirng,([[expressionText getTextValue] floatValue] +  [[mWSHTextField getTextValue] floatValue])];
                                    }else{
                                        expressionText.text = [NSString stringWithFormat:@"%f",([[expressionText getTextValue] floatValue] +  [[mWSHTextField getTextValue] floatValue])];
                                    }
                                    
                                }else{
                                    
                                    expressionText.text = [NSString stringWithFormat:@"%lli",([[expressionText getTextValue] longLongValue] +  [[mWSHTextField getTextValue] longLongValue])];
                                }
                                break;
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
}

/**
 *  WSHTextField 文本内容改变监听方法
 *
 *  @param sender <#sender description#>
 */
- (void) textFieldTextDidChange:(id)sender
{
    
    if (sender && [sender isKindOfClass:[NSNotification class]]) {
        
        NSNotification *notification = (NSNotification *)sender;
        
        if (notification.object && [notification.object isKindOfClass:[WSHTextField class]]) {
            
            WSHTextField *tempTextField = (WSHTextField *)notification.object;
            
            //公式运算
            if([self.formulaDictionary count] > 0){
                
                NSArray *tfArray = [self.formulaDictionary allValues];
                if ([tfArray containsObject:tempTextField]) {
                    NSArray *keysArray = [self.formulaDictionary allKeys];
                    NSString *col = [[self.formulaDictionary allKeysForObject:tempTextField] firstObject];
                    if (col && [col length] > 0) {
                        for (NSString *item in keysArray)
                        {
                            if (([item rangeOfString:@"value"].length > 0)&&([item rangeOfString:col].length > 0))
                            {
                                [self updateValueInTextFiled:[self.formulaDictionary objectForKey:item]];
                            }
                        }
                    }
                }
            }
            
            [self recount];
        }
    }
}

#pragma mark -


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    if([self.currentFuncs.unredo integerValue] < 1 && self.currentStore.inReadonlyMode != YES){
        [super addToolBar];
    }
    
    if (self.currentFuncs.readonly == 1) {
        [super uploadVisitAction];
    }
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    
    if (self.abnormalReasonDict && [self.abnormalReasonDict count] > 0) {
        NSArray * keys  = [self.abnormalReasonDict allKeys];
        for (NSString *stringKey in keys) {
            NSMutableDictionary *acvtObj = [self.abnormalReasonDict objectForKey:stringKey];
            NSInteger index = [stringKey integerValue];
            if (self.resonButtons
                && index < [self.resonButtons count]) {
                
                WSAcvtButtonForTB * button = [self.resonButtons objectAtIndex:index];
                
                if (acvtObj) {
                    
                    [button setSelected:YES];
                }else{
                    
                    [button setSelected:NO];
                }
            }
            
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstLoadView) {
        if (INTERFACE_IS_PHONE) {   // ipad 暂定不需要添加storenamelabel
            [self loadStoreNameLabel];
        }
        [self loadGridViewSearchBar];
        [self initDataSource];
        [self setGrideViewData];
        [self createDataGridView];
        [self resetRowViewsValue];
        [self addFuncsOtherBeanView];
        [self addOptView];
        
        [self recount];
    }else{
        
    }
    
    // 第一次载入表格页面也要支持删除操作，故需要将m_addedDataSources做赋值操作
    [self insertProdDataWithIsAlterDB:NO];
    [_firstGridSearchView redisPlayWith:self.m_addedDataSources];
    
}

- (void) addMoreProductToGrideView{
    
    
}

- (void)insertProdDataWithIsAlterDB:(BOOL)isAlterDB {
    
}

- (NSArray *)getProdsWithBrandId:(WSFuncsBean *)funcs
{
    
    NSMutableArray *dictSeries = [NSMutableArray array];
    if (funcs.filter) {
        NSArray *filters = [funcs.filter componentsSeparatedByString:@","];
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        [filters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *partFilter = (NSString *)obj;
            
            NSArray *filterDicts = [service queryDictsWithParentId:partFilter];
            
            [filterDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSDictBean *dictBean = (WSDictBean *)obj;
                [dictSeries addObject:dictBean.Id];
            }];
        }];
    }


    WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
    __block NSMutableArray *selectedSerieProds = [NSMutableArray array];
    if ([dictSeries count] > 0) {
        if (prodBeanArray.prodArray) {
            [prodBeanArray.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSProdBean *prodBean = (WSProdBean *)obj;
                if ( prodBean.pTyp && [dictSeries containsObject:prodBean.pTyp]) {
                    [selectedSerieProds addObject:prodBean];
                }
            }];
        }
    }
    return selectedSerieProds;
}

- (void)reLayoutBaseGridView
{
    [self initDataSource];
    [self setGrideViewData];
    [self createDataGridView];
    [self resetRowViewsValue];
    [self addFuncsOtherBeanView];
    [self addOptView];
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
}

- (void)resetRowViewsValue
{
    for (NSArray *rowViewsArray in self.datas) {
        for (UIView *view in rowViewsArray) {
            if ([view isKindOfClass:[WSCheckBox class]]) {
                WSCheckBox *checkBox = (WSCheckBox *)view;
                if (checkBox.selected) {
                    [checkBox setSelected:YES];
                }
            }else if ([view isKindOfClass:[WSHTextField class]]) {
                WSHTextField *textField = (WSHTextField *)view;
                if (textField.text.length > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
                }
            }
        }
    }
}

// for妮维雅
#pragma mark WSGridSearchViewDelegate Methods


//展开下拉列表前
- (void)willSelectedgridSearchView:(WSGridSearchView *)gridSearchView  heightChange:(CGFloat)changedHeight
{
    for (UIView *view in self.contentScrollView.subviews) {
        if (![view isKindOfClass:[WSGridSearchView class]] && ![view isEqual:self.storeNameLabel]) {
            [view removeFromSuperview];
        } else if ([view isKindOfClass:[WSGridSearchView class]]) {
            [view setFrame:CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, changedHeight)];
            self.y_point = self.storeNameLabel.bottom + CGRectGetHeight(view.frame);
        }
    }
    if (changedHeight > 44) {
        [self insertProdDataWithIsAlterDB:NO];
    }
    [gridSearchView redisPlayWith:self.m_addedDataSources];
}
//显示所有已填写的产品
- (void)selectedFilledProdsGridSearchView:(WSGridSearchView *)gridSearchView  heightChange:(CGFloat)changedHeight
{
    for (UIView *view in self.contentScrollView.subviews) {
        if (![view isKindOfClass:[WSGridSearchView class]] && ![view isEqual:self.storeNameLabel]) {
            [view removeFromSuperview];
        } else if ([view isKindOfClass:[WSGridSearchView class]]) {
            [view setFrame:CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, changedHeight)];
            self.y_point = self.storeNameLabel.bottom + CGRectGetHeight(view.frame);
        }
    }
    
    _isAllProducts = YES;

    self.showAddedProds = YES;
    [self.m_dataSources removeAllObjects];
    [self.datas removeAllObjects];
    //[self loadRedisDataBaseDatas];
    
    
    if (gridSearchView.selectedIndex == 1) {
        
       
        if ([self.m_addedDataSources count] > 0) {
            [self.m_dataSources addObjectsFromArray:self.m_addedDataSources];
        }
        
//        else {
//            if ([gridSearchView.uploadedEditedProds count] > 0) {
//                self.m_dataSources  = gridSearchView.uploadedEditedProds;
//
//            }
//        }
        [self reLayoutButtonAndGridViewWithIsAllProducts:_isAllProducts];
        
    }else{
        
        [self reLayoutBaseGridView];
    }
    
}
//选择系列
- (void)gridSearchView:(WSGridSearchView *)gridSearchView selectProds:(NSArray *)prods atIndex:(NSInteger)selecIndex  heightChange:(CGFloat)changedHeight {
    
    for (UIView *view in self.contentScrollView.subviews) {
        if (![view isKindOfClass:[WSGridSearchView class]] && ![view isEqual:self.storeNameLabel]) {
            [view removeFromSuperview];
        } else if ([view isKindOfClass:[WSGridSearchView class]]) {
            [view setFrame:CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, changedHeight)];
            self.y_point = self.storeNameLabel.bottom + CGRectGetHeight(view.frame);
        }
    }
    
    _isAllProducts = NO;

    if (changedHeight > 44) {
        return;
    }
    if(selecIndex == 0){
        self.showAddedProds = NO;
        [self.m_dataSources removeAllObjects];
         self.m_dataSources = nil;
    }else {
        self.showAddedProds = NO;
        [self.m_dataSources removeAllObjects];
        [self.m_dataSources addObjectsFromArray:prods];
    }
    [self.datas removeAllObjects];
    //[self loadRedisDataBaseDatas];
    
    /*内存中去除删除掉的产品回显*/
    NSMutableArray *databaseDataMArray = [[NSMutableArray alloc] init];
    for (WSProductObject *productObject in _m_DataBaseDatas) {
        if (![self.deletedProdIds containsObject:productObject.prod_id]) {
            [databaseDataMArray addObject:productObject];
        }
    }
    _m_DataBaseDatas = databaseDataMArray;
    
    [self reLayoutButtonAndGridViewWithIsAllProducts:_isAllProducts];

}

#pragma mark WSSerieLinkDelegate Methods

- (void)serieLinkView:(WSSerieLinkView *)serieLinkView didSelectRowAtBrandIndex:(NSInteger)brandIndex andSerieIndex:(NSInteger)serieIndex selectedProds:(NSArray *)prods changedHeight:(CGFloat)changedHeight {
    for (UIView *view in self.contentScrollView.subviews) {
        if (![view isKindOfClass:[WSSerieLinkView class]] && ![view isEqual:self.storeNameLabel]) {
            [view removeFromSuperview];
        } else if ([view isKindOfClass:[WSSerieLinkView class]]) {
            [view setFrame:CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, changedHeight)];
            self.y_point =self.storeNameLabel.bottom + CGRectGetHeight(view.frame);
        }
    }
    if (changedHeight > 44) {
        return;
    }
       
    if (brandIndex == 0) {
        self.showAddedProds = YES;
        [self.m_dataSources removeAllObjects];
        self.m_dataSources = nil;
    } else {
        self.showAddedProds = NO;
        [self.m_dataSources removeAllObjects];
        [self.m_dataSources addObjectsFromArray:prods];
    }
    [self.datas removeAllObjects];
    //[self loadRedisDataBaseDatas];
    /*内存中去除删除掉的产品回显*/
    NSMutableArray *databaseDataMArray = [[NSMutableArray alloc] init];
    for (WSProductObject *productObject in _m_DataBaseDatas) {
        if (![self.deletedProdIds containsObject:productObject.prod_id]) {
            [databaseDataMArray addObject:productObject];
        }
    }
    _m_DataBaseDatas = databaseDataMArray;
    if (brandIndex == 0) {
        [self reLayoutButtonAndGridViewWithIsAllProducts:_isAllProducts];
    }else{
         [self reLayoutBaseGridView];
       
    }
}


- (void)willShowserieLinkView:(WSSerieLinkView *)serieLinkView didSelectRowAtBrandIndex:(NSInteger)brandIndex andSerieIndex:(NSInteger)serieIndex changedHeight:(CGFloat)changedHeight {
    for (UIView *view in self.contentScrollView.subviews) {
        if (![view isKindOfClass:[WSSerieLinkView class]] && ![view isEqual:self.storeNameLabel]) {
            [view removeFromSuperview];
        } else if ([view isKindOfClass:[WSSerieLinkView class]]) {
            [view setFrame:CGRectMake(view.origin.x, view.origin.y, view.frame.size.width, changedHeight)];
            self.y_point = self.storeNameLabel.bottom + CGRectGetHeight(view.frame);
        }
    }
    if (changedHeight > 44) {
        [self insertProdDataWithIsAlterDB:NO];
    }
    [serieLinkView redisplayWith:self.m_addedDataSources];
}

#pragma mark - validate data

- (BOOL)validateData
{
    for (NSArray *arrayRow in self.datas) {
        for (id tempUI in arrayRow) {
            
            if ([tempUI conformsToProtocol:@protocol(WSValidateData)]) {
                if ([tempUI respondsToSelector:@selector(textCheck)]) {
                    if (![tempUI textCheck]) {
                        return NO;
                    }
                }
            }
        }
    }
    
    return YES;
}

/*验证表格必填（表格需要填写值（至少一个元素有值））*/
- (BOOL)isValidateGridRequried {
    BOOL isPassed = NO;
     // WRIGLEY-1829 配置非空值上传
    BOOL isRequired = (self.model.currentFuncs.nullvalue == 0) ? YES : NO;
    if (!isRequired) {
        return YES;
    }
  
     // WRIGLEY-1829 与 Android 一致，通过 nullvalue 来判断是否必填，required 只控制是否必须要上传
//    NSString *requried = self.currentFuncs.required;
//    if ([requried isKindOfClass:[NSString class]] && [requried isEqualToString:@"R"]) {
//        isRequired = YES;
//    }
    
    if (isRequired) {
        NSInteger rows = [self.datas count];
        NSInteger columns = [self.currentFuncs.paramArray count];
        for (NSInteger i = 0; i < rows; i++)
        {
            NSArray *subdatas = [self.datas objectAtIndex:i];
            if (![subdatas isKindOfClass:[NSArray class]]) {
                break;
            }
            for (int j = 0; j < columns; j++)
            {
                id view = [subdatas objectAtIndex:j+1];
                /*和安卓保持一致,WSCheckBox不选中时 其默认为值0（不进行检测）*/
                if (view != nil && [view respondsToSelector:@selector(entityIsEnable)]){
                    if ([view entityIsEnable]) {
                        if ([view respondsToSelector:@selector(isValueLegal)]){
                            if ([view isValueLegal]) {
                                isPassed = YES;
                            }
                        }
                    }
                }
            }
        }
    }else {
        isPassed = YES;
    }
    
    if (!isPassed) {
        NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"order_confirm_uninputvalue_label", nil)];
        WSMessageObject  *messageobject =[[WSMessageObject alloc] init];
        [messageobject setMessageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
        [messageobject setDisplayMessage:message];
        [[WSMessageCenter shareInstance] showMessageView:messageobject];
    }
    return isPassed;
}

/*验证列必填*/
- (BOOL)checkIfRequiredFilled
{
    NSInteger iMax = [self.datas count];
    NSInteger jMax = [self.currentFuncs.paramArray count];
    
    NSInteger firstNeedFilledRowIndex = -1;

//    BOOL bFind = NO;
//    for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
//        if (param.isReq) {
//            if ([@"1" isEqualToString:param.isReq]) {
//                bFind = YES;
//                break;
//            }
//        }
//    }
//
//    if (!bFind) return YES;
    //  是否必填 应该判断的时isReq字段     - Nemo
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    for (int i = 0; i < iMax; i++)
    {
        NSArray *subdatas = [self.datas objectAtIndex:i];
        if (![subdatas isKindOfClass:[NSArray class]]) {
            break;
        }
        
        for (int j = 0; j < jMax; j++)
        {
            WSFuncsBean_Param* param = (WSFuncsBean_Param *)[self.currentFuncs.paramArray objectAtIndex:j];
//            if (!param.isReq) {
//                break;
//            }
//            if (![param.isReq isKindOfClass:[NSString class]]) {
//                break;
//            }
            if ([param.isReq isEqualToString:@"1"] || param.iDependon.length > 0)
            {
                // ui元素
                id ui = [subdatas objectAtIndex:j+1];
                
                BOOL needCheck = YES;
                if ([ui respondsToSelector:@selector(iDataType)] && [ui respondsToSelector:@selector(entityIsEnable)]) {
                    if ([ui iDataType] == WSValidateDataDependOtherData && ![ui entityIsEnable]) {
                        needCheck = NO;
                    }else if ([ui iDataType] == WSValidateDataIsDepended && ![param.isReq isEqualToString:@"1"]){
                        needCheck = NO;
                    }
                }
                
                if (needCheck) {
                    // 判断是否填写
                    BOOL isBlank = NO;
                    
                    if ([ui respondsToSelector:@selector(isValueLegal)])
                    {
                        if (![ui isValueLegal]) {
                            isBlank = YES;
                        }
                    }
                    if ([ui isKindOfClass:[WSAcvtButtonForTB class]])
                    {
                        isBlank = ![ui hasBeenFilled];
                    }
                    
                    
                    if (isBlank) {
                        if (![dic objectForKey:param.col])
                        {
                            if (param.name) {
                                [dic  setObject:param.name forKey:param.col];
                            }
                            if (firstNeedFilledRowIndex < 0) {
                                firstNeedFilledRowIndex = i;
                            }

                        }
                    }
                }
                
            }
        }
    }
    
    NSArray *items = [dic allValues];
    if (items && [items count] > 0)
    {
        NSMutableString *strinfo = [[NSMutableString alloc] initWithCapacity:4];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *name = (NSString*)obj;
            if (idx == 0) {
                [strinfo appendString:name];
            }else{
                [strinfo appendString:@","];
                [strinfo appendString:name];
            }
        }];
        
        NSString *rowName = @"";
        
        if (self.m_dataSources.count > 0 && self.m_dataSources.count == iMax) {
            id data = [self.m_dataSources objectAtIndex:firstNeedFilledRowIndex];
            if ([data isKindOfClass:[WSProdBean class]]) {
                rowName = ((WSProdBean *)data).name;
            }else if ([data isKindOfClass:[WSDictBean class]]){
                rowName = ((WSDictBean *)data).name;
            }
        }
        NSString *strinput = NSLocalizedString(@"not_filled", nil);
        NSString *title = [NSString stringWithFormat:@"%@ ", rowName];
        title = [title stringByAppendingString:[NSString stringWithFormat:strinput,strinfo]];
        //        NSString *title = [NSString stringWithFormat:strinput,strinfo];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        return NO;
    }
    return YES;
}



@end
