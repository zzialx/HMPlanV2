//
//  WSTAAcvtDataGridComponentDataSource.m
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSTAAcvtDataGridComponentDataSource.h"
#import "WSDataSourceManager.h"
#import "WSFuncsBeanArray.h"
#import "WCURLUILabel.h"
#import "WSDatePickerLabel.h"
#import "WSCurrentTime.h"
#import "WSAppData.h"
#import "WSRadioButton.h"
#import "WSCheckBox.h"
#import "WSNRLabel.h"
#import "WSAddAcvtTable.h"
#import "WSMappingObject.h"
#import "WSStoreAcvtDisBean.h"
#import "WSStoreAcvtDisArray.h"
#import "WSAddNewAcvtModel.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAcvtQstDisItem.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "GetMD5byStr.h"

@implementation WSTAAcvtDataGridComponentDataSource

- (id)initWith:(NSObject <I_W_BuildInfo> *)currentBuildInfo {
    if (self = [super init]) {
        
        
        WSAddNewAcvtModel *model = (WSAddNewAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        _acvtModel = model;
        _currentFunc = model.currentFuncs;
        _currentBuildInfo = currentBuildInfo;
        self.dataSource = [self getTADataSource];
        self.nativeGridViewValuesMapping = [self getNatieGridViewValuesMapping];
        self.titles = [self getTATitlesWithRelationAcvtBean:nil];
        self.columnWidth = [self getColumnsWidth];
        self.currentTableItem = [self generateTableItem];
        self.data = [self  grideViewData];
    }
    return self;
}

-(id)initWith:(NSObject<I_W_BuildInfo> *)currentBuildInfo withNowRequestData:(NSObject *)tmpData andRequestNodeName:(NSString *)nodeName{
    if (self = [super init]) {
        
        NSDictionary  *dict = (NSDictionary *)tmpData;
        NSArray * array1 = [dict objectForKey:nodeName];
        NSDictionary * dict1 = [array1 firstObject];
        NSMutableArray * arrays = [[NSMutableArray alloc]initWithArray:[dict1 objectForKey:[NSString stringWithFormat:@"%@%@",@"acvt:",nodeName]]];
        NSMutableArray * arrayBeanArray = [[NSMutableArray alloc]init];
        WSAcvtBean * currentAcvtBean = [[WSAcvtBean alloc]init];
        WSAddNewAcvtModel *model = (WSAddNewAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        _acvtModel = model;
        _currentFunc = model.currentFuncs;
        
        for (int i = 0 ; i < arrays.count; i ++) {
            WSAcvtBean * AcvtBean = [[WSAcvtBean alloc]initWithObject:arrays[i]];
            [arrayBeanArray addObject:AcvtBean];
        }
        WSAcvtBean_qst * serverAcvtBean = nil;
        for (WSAcvtBean * acvtBean in arrayBeanArray) {
            if ([acvtBean.acvtCode isEqualToString:[(WSAcvtBean_qst*)currentBuildInfo filter]]) {
                currentAcvtBean = acvtBean;
            }
            if ([acvtBean.acvtId isEqualToString:model.currentAcvtBean.acvtId]) {
                for (WSAcvtBean_qst * acvtBean_qst in acvtBean.qsts) {
                    if ([acvtBean_qst.acvtQstId isEqualToString:[(WSAcvtBean_qst*)currentBuildInfo acvtQstId]]) {
                        serverAcvtBean = acvtBean_qst;
                    }
                }
            }
        }
        
        self.acvtDisArray = [[WSStoreAcvtDisArray alloc]initWithObject:dict1 andKey:[NSString stringWithFormat:@"%@%@",@"acvtdis:",nodeName]/*@"acvtdis:storeAcvtDisByMonth"*/];
        _currentBuildInfo = currentBuildInfo;
        if (serverAcvtBean != nil) {
            self.dataSource = [self getTAServerDataSourc:serverAcvtBean];
        }else{
            self.dataSource = [self getTADataSource];
        }
        self.nativeGridViewValuesMapping = [self getNatieGridViewValuesMapping];
        self.titles = [self getTATitlesWithRelationAcvtBean:currentAcvtBean];
        self.columnWidth = [self getColumnsWidth];
        self.currentTableItem = [self generateTableItem];
        self.data = [self  grideViewData];
        
    }
    return self;
}

- (WSTableItem *)generateTableItem {
    return [[WSTableItem alloc] initWithFuncsBean:_currentFunc param:self.columnParams];
}

- (NSMutableArray *)getTATitlesWithRelationAcvtBean:(WSAcvtBean *)currentAcvtBean{
    if (currentAcvtBean == nil) {
        NSString *filter = [(WSAcvtBean_qst*)_currentBuildInfo filter];
        WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
        _relationAcvtBean = [service queryAcvtByFilter:nil acvtCode:filter];
    }else{
        
        _relationAcvtBean = currentAcvtBean;
    }
    
    __block NSMutableArray *titltes = [NSMutableArray array];
    
    NSString *firstColumnTitle  = NSLocalizedString(@"default_left_attach_header_label", nil);
    if ([_currentBuildInfo isKindOfClass:[WSAcvtBean_qst class]]) {
        firstColumnTitle = [(WSAcvtBean_qst *)_currentBuildInfo qstName];
        if (firstColumnTitle == nil) {
            firstColumnTitle = @"";
        }
    }
    [titltes addObject: firstColumnTitle];
    if (_relationAcvtBean) {
        self.qstsForColumn = _relationAcvtBean.qsts;
        [_relationAcvtBean.qsts enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *stop) {
            WSAcvtBean_qst *currentQst = (WSAcvtBean_qst *)obj;
            [titltes addObject:[NSString stringNotNilWithValue:currentQst.qstName]];
        }];
    }
    return titltes;
}


- (NSMutableArray *)getColumnsWidth {
    
    NSMutableArray *allColumnwidths = [NSMutableArray array];
    
    self.columnParams  = [self generateParmas];
    
    NSString *firstColumnWidth = nil;
    
    if ([self.columnParams count] > 0) {
        if (!firstColumnWidth || firstColumnWidth.integerValue <= 0) {
            firstColumnWidth = ((self.currentFunc.fCharNum > 0) ? [NSString stringWithFormat:@"%d", self.currentFunc.fCharNum * UINIT_WIDTH_OTHER] : [NSString stringWithFormat:@"%d", self.currentFunc.wfcol]);
        }
        if (firstColumnWidth.integerValue <=0) {
            firstColumnWidth = DEFAULT_COLUM_WIDTH;
        }
        [allColumnwidths addObject:firstColumnWidth];
        
        
        /*其他列宽*/
        for( NSInteger i = 0; i < [self.columnParams count] ; i++)
        {
            
            NSInteger unitValue = UNIT_WIDTH_DEFAULT ;
            
            WSFuncsBean_Param *funcsBean_Param  = [self.columnParams objectAtIndex:i];
            
            if (funcsBean_Param.charNum.integerValue > 0)
            {
                if ([funcsBean_Param.tpy isEqualToString:@"N"]   ||
                    [funcsBean_Param.tpy isEqualToString:@"C"]   ||
                    [funcsBean_Param.tpy isEqualToString:@"CHT"] ||
                    [funcsBean_Param.tpy isEqualToString:@"R"]   ||
                    [funcsBean_Param.tpy isEqualToString:@"D"]   ||
                    [funcsBean_Param.tpy isEqualToString:@"P"]   ||
                    [funcsBean_Param.tpy isEqualToString:@"DT"]  ||
                    [funcsBean_Param.tpy isEqualToString:@"SD"]  ||
                    [funcsBean_Param.tpy isEqualToString:COL_TYPCHECKBOXALL]
                    )
                {// 数字 标点 按钮 中文  单位字符的宽度
                    unitValue = UINIT_WIDTH_OTHER;
                }
                else if ([funcsBean_Param.tpy isEqualToString:@"T"])
                {// 字母 单位字符的宽度
                    unitValue = UINIT_WIDTH_T;
                }
                else if ([funcsBean_Param.tpy isEqualToString:@"B"])
                {// 按钮  待测试
                    unitValue = UINIT_WIDTH_B;
                }
                
                if ([funcsBean_Param.tpy isEqualToString:COL_TYPCHECKBOXALL])
                {
                    //表头包含checkBox的列宽需要特殊处理 (多选项控件UI占2字节宽度（多选项图片）, 其他则是文字显示宽度) 如有改变则调整
                    [allColumnwidths addObject:[NSString stringWithFormat:@"%ld_%ld",  (long)(funcsBean_Param.charNum.integerValue - 2) * unitValue ,2 *  (long)unitValue]];
                }else if ([funcsBean_Param.tpy isEqualToString:COL_TYPCHECKBOX]){
                    /*
                     为不影响标准表格列宽度 暂时做此修改.
                     */
                    NSInteger tmpUnitValue = unitValue;
                    if (INTERFACE_IS_PAD) {
                        tmpUnitValue = unitValue/2;
                    }
                    [allColumnwidths addObject:[NSString stringWithFormat:@"%ld", (long)funcsBean_Param.charNum.integerValue * tmpUnitValue]];
                }else{
                    
                    [allColumnwidths addObject:[NSString stringWithFormat:@"%ld", (long)funcsBean_Param.charNum.integerValue * unitValue]];
                }
            }
            else if(funcsBean_Param.wcol > 0)
            {
                if ([funcsBean_Param.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                    
                    [allColumnwidths addObject:[NSString stringWithFormat:@"%ld_%ld", (long)funcsBean_Param.wcol, (long)funcsBean_Param.wcol]];
                }else{
                    
                    [allColumnwidths addObject:[NSString stringWithFormat:@"%ld", (long)funcsBean_Param.wcol]];
                }
                
            }
            else
            {
                if ([funcsBean_Param.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
                    
                    [allColumnwidths addObject:[NSString stringWithFormat:@"%@_%@", firstColumnWidth,firstColumnWidth]];
                }else{
                    
                    [allColumnwidths addObject:firstColumnWidth];
                }
                
            }
        }
    }
    
    return allColumnwidths;
}

- (NSMutableArray *)getTADataSource {
    return [NSMutableArray arrayWithArray:[(WSAcvtBean_qst *)_currentBuildInfo opt]] ;
}

-(NSMutableArray *)getTAServerDataSourc:(WSAcvtBean_qst *)acvtBean_qst{
    return [NSMutableArray arrayWithArray:[acvtBean_qst opt]];
}


- (NSMutableArray *)generateParmas {
    NSMutableArray *params = [NSMutableArray array];
    for (NSInteger i = 0; i < [self.qstsForColumn count]; i++) {
        WSAcvtBean_qst *qst = [self.qstsForColumn objectAtIndex:i];
        WSFuncsBean_Param *param = [[WSFuncsBean_Param alloc] initFuncsParamWithAcvtQstBean:qst];
        [params addObject:param];
    }
    return params;
}

- (NSMutableArray *)grideViewData {
    if ([self.columnParams count] < 1) {
        return nil;
    }
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSInteger startInterer = 0;
    
    for (NSInteger i = startInterer; i < [self.dataSource count]; i++) {
        
        NSMutableArray *currentRowView = [[NSMutableArray alloc] initWithCapacity:[self.columnWidths count]];
        
        UIView *firstColView = [self firstColumnDataWithIndex:i];
        
        [currentRowView addObject:firstColView];
        
        int j = 0; // 列
        for (WSFuncsBean_Param *param in self.columnParams) {
            
            UIView *view = [self viewFromParam:param atRowIndex:i atColumn:j];
            
            j++;
            
            [currentRowView addObject:view];
        }
        [datas addObject:currentRowView];
        
    }
    
    // 启动依赖关系
    for (int n = 0; n < [datas count]; n++) {
        NSArray *viewArray = [datas objectAtIndex:n];
        for (int m = 0; m < [viewArray count]; m++) {
            id obj = [viewArray objectAtIndex:m];
            if (obj != nil && [obj respondsToSelector:@selector(startObservingEntity)]) {
                [obj startObservingEntity];
            }
        }
    }
    return datas;
}


- (UILabel *)firstColumnDataWithIndex:(NSInteger)aIndex {
    
    CGFloat firstColumnWidth= [[self.columnWidths firstObject] floatValue];
    
    WCURLUILabel* firstColumnLabel = [[WCURLUILabel alloc] initWithFrame:CGRectMake(0, 0, firstColumnWidth, DATAGRID_CELL_HEIGHT_DEFAULT)];
    
    firstColumnLabel.numberOfLines = 0;
    
    firstColumnLabel.font = [UIFont systemFontOfSize:DATAGRID_TITLE_FONTSIZE];
    
    firstColumnLabel.textAlignment = NSTextAlignmentCenter;
    
    WSAcvtBean_qst_opt *opt = [self.dataSource objectAtIndex:aIndex];
    
    
    firstColumnLabel.text =  opt.optName;
    
    
    return firstColumnLabel;
}




// NSMutableArray *formulaStringArray = [NSMutableArray arrayWithCapacity:1];
- (UIView *)viewFromParam:(WSFuncsBean_Param *)aParam atRowIndex:(NSInteger)aIndex atColumn:(NSInteger)aColumn {
    
    if (![aParam.tpy isKindOfClass:[NSString class]]) {
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        NSString *tipString = NSLocalizedString(@"config_error", nil);
        tip.textAlignment = NSTextAlignmentCenter;
        tip.textColor = [UIColor redColor];
        tip.text = tipString;
        return tip;
    }
    
    if ([aParam.tpy isEqualToString:COL_TYPNUM]
        || [aParam.tpy isEqualToString:COL_TYPTEXT]
        || [aParam.tpy isEqualToString:COL_TYPCHT]
        || [aParam.tpy isEqualToString:COL_TYPCHTS]
        || [aParam.tpy isEqualToString:COL_TYPL]) {
        WSHTextField *textfield = [[WSHTextField alloc] initWithFrame:CGRectMake(3, 3, aParam.wcol, 24) Param:aParam isAcvtGrid:YES];
        
        
        textfield.iRow = (int)aIndex;
        textfield.iColumn = (int)aColumn;
//        textfield.currentFuncs=self.currentFunc;
        textfield.m_col = aParam.col;
        id bean = [_dataSource objectAtIndex:aIndex];
        if ([bean isKindOfClass:[WSProdBean class]]) {
            WSProdBean* aProd = (WSProdBean*)bean;
            textfield.prodName = aProd.prodName;
        }else if ([bean isKindOfClass:[WSDictBean class]]){
            WSDictBean* aDict = (WSDictBean*)bean;
            textfield.prodName = aDict.name;
        } else if ([bean isKindOfClass:[WSFuncsBean_opt class]]) {
            WSFuncsBean_opt *opt = (WSFuncsBean_opt *)bean;
            textfield.prodName = opt.name;
        }
        textfield.iColumnName = aParam.name;
        [self setDependedInfoWith:textfield withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
        if(aParam.readonly == 1) {
            textfield.userInteractionEnabled = NO;
            textfield.textColor = [UIColor grayColor];
        }
        
        textfield.borderStyle = UITextBorderStyleNone;
        textfield.delegate = self;
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        if(aParam.idefault){
            textfield.text = aParam.idefault;
        }
    
        
        if ([aParam.tpy isEqualToString:COL_TYPNUM] ) {
            if (aParam.pcs && [aParam.pcs length] > 0 && [textfield.text length] > 0 ) {
                CGFloat  contentFloat = [textfield.text floatValue];
                NSString *contentString = [NSString stringWithFormat:@"%lf",contentFloat];
                NSArray *contenArray = [contentString componentsSeparatedByString:@"."];
                NSString *headPart = [contenArray firstObject];
                NSString *endPart = [contenArray lastObject];
                if ([aParam.pcs integerValue] < [endPart length]) {
                    endPart = [endPart substringToIndex:[aParam.pcs integerValue]];
                }
                if (endPart && [endPart length] > 0) {
                    textfield.text = [NSString stringWithFormat:@"%@.%@",headPart,endPart];
                } else {
                    textfield.text = headPart;
                }
            }
        }
        
        /*若相关为题的ds为rowid则其值为当前行WSAcvtBean_qst_opt的id*/
        if ([aParam.mappingAcvtQstDs isEqualToString:@"rowid"]) {
            textfield.text = [(WSAcvtBean_qst_opt*)[self.dataSource objectAtIndex:aIndex] optId];
        }
        
        NSString * redisValue = nil;
        if ([self nativeRedis]) {
            NSString *nativeRedisVale = [self getNativeRedisValueWith:aParam data:[self.dataSource objectAtIndex:aIndex]];
            if ([nativeRedisVale length] > 0) {
                redisValue = nativeRedisVale;
            }
        }
        
        if ([self serverRedisWith:aParam] && [aParam.isHidden isEqualToString:@"0"]) {
            NSString *serverRedisValue = [self getServerRedisValueWith:aParam data:[self.dataSource objectAtIndex:aIndex]];
            if ([serverRedisValue length] > 0) {
                redisValue = serverRedisValue;
            }
        }
        if ([redisValue length] > 0) {
             textfield.text = redisValue;
        }
        return textfield ;
    } else if ([aParam.tpy isEqualToString:COL_TYPPHOTO]) {
        PhotoTypeButton *button = [[PhotoTypeButton alloc] init];
        button.iRow = (int)aIndex;
        button.iColumn = (int)aColumn;
        button.customDelegate = self;
        NSString *currentQstMc = [(WSAcvtBean_qst *)_currentBuildInfo mc];
        NSString* mImageIdx=[NSString stringWithFormat:@"%@_%@",currentQstMc,[self getGridMd5]];
        NSString* cellKey=[NSString stringWithFormat:@"%ld_%@", (long)aIndex, aParam.col];
        button.imageMD5 = [Md5Manager getMd5ByEmpId:nil
                                            sotreId:nil
                                            bizDate:nil
                                           funcCode:nil
                                             acvtId:mImageIdx
                                               memo:cellKey];
        // 判断是否需要回显数据
        if ([self   nativeRedis]) {
            
        }
        return button;
    } else if ([aParam.tpy isEqualToString:COL_TYPDATE]) {
        WSDatePickerLabel *view = [[WSDatePickerLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100) param:aParam];
        view.iRow = (int)aIndex;
        view.iColumn = (int)aColumn;
        [self setDependedInfoWith:view withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
        
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1].CGColor;
        view.layer.cornerRadius = 5.0;
        view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
        if ([self serverRedisWith:aParam]) {
        
        }
        
        if ([self nativeRedis]) {
            
        }
        return view;
    } else if ([aParam.tpy isEqualToString:COL_TYPR]) {
        
        WSRadioButton *radioButton = [self setGrideViewDataKindOfRadioButton:aParam Data:[_dataSource objectAtIndex:aIndex]];
        if (aParam.idefault && [aParam.idefault isEqualToString:@"1"]) {
            [radioButton setSelected:YES];
        }
        [self setStateOfCurrentButton:radioButton withParam:aParam atRow:aIndex andColumn:aColumn];
        if(radioButton != nil) {
            radioButton.iRow = (int)aIndex;
            radioButton.iColumn = (int)aColumn;
            [self setDependedInfoWith: radioButton withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
            radioButton.iRow = (int)aIndex;
            return  radioButton;
        }
    } else if ([aParam.tpy isEqualToString:COL_TYPCHECKBOX]) {
        UIButton* l_button = [self setGrideViewDataKindOfCheckBox:aParam Data:[_dataSource objectAtIndex:aIndex]];
        
        [self setStateOfCurrentButton:l_button withParam:aParam atRow:aIndex andColumn:aColumn];
        
        if(l_button != nil) {
            if ([l_button isKindOfClass:[WSCheckBox class]]) {
                WSCheckBox *tempCheck = (WSCheckBox *)l_button;
                tempCheck.iRow = (int)aIndex;
                tempCheck.iColumn = (int)aColumn;
                tempCheck.tpy = COL_TYPCHECKBOX;
                [self setDependedInfoWith:tempCheck withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
                return  l_button;
            }
        }
        
    }else if ([aParam.tpy isEqualToString:COL_TYPCHECKBOXALL]) {
        
        WSCheckBox *checkBoxBtn = (WSCheckBox *)[self setGrideViewDataKindOfCheckBox:aParam Data:[_dataSource objectAtIndex:aIndex]];
        if (checkBoxBtn != nil) {
            [self setStateOfCurrentButton:checkBoxBtn withParam:aParam atRow:aIndex andColumn:aColumn];
            [self setDependedInfoWith: checkBoxBtn withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
            checkBoxBtn.iRow = (int)aIndex;
            checkBoxBtn.iColumn = (int)aColumn; //列值计算同表头一致。
            checkBoxBtn.tpy = COL_TYPCHECKBOXALL;
            
            return checkBoxBtn;
        }
    }else if ([aParam.tpy isEqualToString:COL_TYPLNR]) {
        
        WSNRLabel * label = [[WSNRLabel alloc] initWithFrame:CGRectMake(0, 0, aParam.wcol, 29)];
        
        label.font = [UIFont systemFontOfSize:UI_Font];
        label.textColor = [UIColor blackColor];
        label.iRow = aIndex;
        label.iColumn = aColumn;
//        label.currentFuncs=self.currentFunc;
        label.m_col = aParam.col;
        NSString * redisValue = nil;
        if ([self nativeRedis]) {
            NSString *nativeRedisVale = [self getNativeRedisValueWith:aParam data:[self.dataSource objectAtIndex:aIndex]];
            if ([nativeRedisVale length] > 0) {
                redisValue = nativeRedisVale;
            }
        }
        
        if ([self serverRedisWith:aParam]) {
            NSString *serverRedisValue = [self getServerRedisValueWith:aParam data:[self.dataSource objectAtIndex:aIndex]];
            if ([serverRedisValue length] > 0) {
                redisValue = serverRedisValue;
            }
        }
        label.text = redisValue;
        
        return label;
    }
    else if ([aParam.tpy isEqualToString:COL_TYPDT]){
        
        WSSelectListView *list = [self setGrideViewDataKindofSelectList:aParam Data:[self.dataSource objectAtIndex:aIndex]];
        list.selectListDelegate = self;
        if (list!= nil) {
            list.iRow = (int)aIndex;
            list.iColumn = (int)aColumn;
            [self setDependedInfoWith:list withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
            
        }
        return list;
    }
    else if ([aParam.tpy isEqualToString:COL_TYPTIME]){
        
        WSDatePickerLabel *view = [[WSDatePickerLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100) param:aParam];
        view.datePickerLaberMode = WSDatePickerLabelModeTime;
        view.iRow = (int)aIndex;
        view.iColumn = (int)aColumn;
        view.textAlignment = NSTextAlignmentCenter;
        [self setDependedInfoWith:view withParam:aParam withRow:(int)aIndex andColumn:(int)aColumn];
        if ([[UIDevice currentDevice] systemVersionByFloat] < 8.000000) {
            view.layer.borderWidth = 1.0;
            view.layer.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1].CGColor;
            view.layer.cornerRadius = 5.0;
            view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        }
        
        if ([self serverRedisWith:aParam]) {
            
        }
        if ([self nativeRedis]) {
            
        }
        return view;
        
    }
    
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.text = @"text";
    return view;
}

-(WSRadioButton*)setGrideViewDataKindOfRadioButton:(WSFuncsBean_Param*)aParam
                                              Data:(id)aData;
{
    if([aParam.tpy isEqualToString:COL_TYPR])
    {
        WSRadioButton *radioButton = [WSRadioButton buttonWithType:UIButtonTypeCustom];
        
        radioButton.frame = CGRectMake(0, 0, 0, 0);
        [radioButton addTarget:self action:@selector(radioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [radioButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"] forState:UIControlStateSelected];
        [radioButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"] forState:UIControlStateHighlighted];
        [radioButton setImage:[UIImage scaledImageForName:@"selected_no_radio" ofType:@"png"] forState:UIControlStateNormal];
        if (aParam.readonly == 1) {
            radioButton.userInteractionEnabled = NO;
        }
        return radioButton;
    }
    
    return nil;
}


-(UIButton*)setGrideViewDataKindOfCheckBox:(WSFuncsBean_Param*)aParam
                                      Data:(id)aData;
{
    if ([aParam.tpy isEqualToString:COL_TYPCHECKBOX]
        || [aParam.tpy isEqualToString:COL_TYPCHECKBOXALL])
    {
        WSCheckBox *checkButton = [WSCheckBox buttonWithType:UIButtonTypeCustom];
        
        checkButton.frame = CGRectMake(0, 0, 0, 0);
        [checkButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
        [checkButton setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
//        [checkButton setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
        [checkButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        if (aParam.readonly == 1) {
            checkButton.userInteractionEnabled = NO;
            [checkButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
            [checkButton setImage:[UIImage imageNamed:@"icn_check_2"] forState:UIControlStateSelected];
        }
        return checkButton;
    }
    
    return nil;
}

//create WSSelectListView
- (WSSelectListView *)setGrideViewDataKindofSelectList:(WSFuncsBean_Param *)aParam Data:(id)aData

{
    if ([aParam.tpy isEqualToString:COL_TYPDT] || [aParam.tpy isEqualToString:COL_TYPSD]) {
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSArray* filterArray = [service queryDictsForAcvtGridWithFilter:aParam.filter];
        NSMutableArray *nameList = [NSMutableArray arrayWithArray:[filterArray valueForKeyPath:@"@distinctUnionOfObjects.name"]];
        /*
        NSMutableArray *nameList = [[NSMutableArray alloc] init];
        for (WSDictBean *db in filterArray)
        {
            //过滤可选项
            [nameList addObject:db.name];
        }
        */
        
        NSInteger width=100;
        
        if ([aParam.charNum intValue] > 0){
            
            width = [aParam.charNum intValue] * UINIT_WIDTH_OTHER ;
            
        }else if(aParam.wcol>0){
            
            width = aParam.wcol;
            
        }
        
        //selectMode 选择方式（单选，多选）
        WSSelectListViewSelectMode selectMode = WSSelectListViewSelectModeSingleSelection;
        
        if ([aParam.tpy isEqualToString:COL_TYPDT]){
            selectMode = WSSelectListViewSelectModeSingleSelection;
            //加入一个空白选项，用于单选取消选择
            [nameList insertObject:@"" atIndex:0];
        }
        
        else if ([aParam.tpy isEqualToString:COL_TYPSD])
            
        {
            selectMode = WSSelectListViewSelectModeMultipleChoice;
            
        }
        
        WSSelectListView *list = [[WSSelectListView alloc] initWithFrame:CGRectMake(0, 0, width, 36) style:UITableViewStylePlain selectMode:selectMode];
        list.content = nameList;
        list.layer.cornerRadius = 5.0f;
        
        if ([aParam.tpy isEqualToString:COL_TYPDT]) {
            NSString *selectItem = nil; //选择项
            
            if ([self nativeRedis]) { //本地回显
                if ([aData isKindOfClass:[WSAcvtBean_qst_opt class]]) {
//                    NSString *tmpSelectItem = [self getNativeRedisValueWith:aParam data:(WSAcvtBean_qst_opt *)aData];
//                    if ([tmpSelectItem length] > 0) {
//                        selectItem = tmpSelectItem;
//                    }
                    
                    // SFA-6274 之前是按name匹配，现在与服务器回显统一逻辑，根据上传的id取name的值
                    NSString *selectId = [self getNativeRedisValueWith:aParam data:(WSAcvtBean_qst_opt *)aData];
                    for (WSDictBean *dictBean in filterArray)
                    {
                        if (dictBean.Id && selectId && [dictBean.Id isEqualToString:selectId]) {
                            selectItem = dictBean.name;
                        }
                    }

                }
            }
             
        
            
            if (selectItem == nil) {
                if ([self serverRedisWith:aParam]) {
                     if ([aData isKindOfClass:[WSAcvtBean_qst_opt class]]) {
                         NSString *selectId = [self getServerRedisValueWith:aParam data:aData];
                         for (WSDictBean *dictBean in filterArray)
                         {
                             if (dictBean.Id && selectId && [dictBean.Id isEqualToString:selectId]) {
                                 selectItem = dictBean.name;
                             }
                         }
                     }
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
                        
                        list.selectedIndex = index ;
                        
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


// 按钮是否选中的回显
- (void)setStateOfCurrentButton:(UIButton *)button withParam:(WSFuncsBean_Param *)aParam atRow:(NSInteger)rowIndex andColumn:(NSInteger)columnIndex {
    
    // 区分是否只读 aParam.readonly == 1  只读 设施button 不可点击
    BOOL redisValue = NO;
    
    if ([self serverRedisWith:aParam]) {
        BOOL serverRedisValue = [self getRequestForNowRedisValueWith:aParam data:[self.dataSource objectAtIndex:rowIndex]];
        if (serverRedisValue) {
            redisValue = serverRedisValue;
        }
    }
    
    if ([self nativeRedis]) {
        NSString *nativeRedis = [self getNativeRedisValueWith:aParam data:[self.dataSource objectAtIndex:rowIndex]];
        if ( [nativeRedis isKindOfClass:[NSString class]] && [nativeRedis isEqualToString:@"1"]) {
            redisValue = YES;
        }
    }
    
    
    if (redisValue) {
        button.selected = redisValue;

    }
}


#pragma mark - private function
- (void)setDependedInfoWith:(id<WSValidateData>)aProtocal withParam:(WSFuncsBean_Param *)aParam withRow:(unsigned int)aRow andColumn:(unsigned int)aColumn
{
    if (aProtocal != nil && [aProtocal respondsToSelector:@selector(setNotificationPrefix:andRow:andColumn:andDataType:)]) {
        if (aParam.iDependon != nil && [aParam.iDependon length] > 0) {
            for (int i = 0; i < [self.columnParams count]; i++) {
                @autoreleasepool {
                    WSFuncsBean_Param *param = [self.columnParams objectAtIndex:i];
                    if (param.col != nil && [param.col isEqualToString:aParam.iDependon]) {
                        NSString *prefix = [NSString stringWithFormat:@"%@-%@", [(WSAcvtBean_qst *)_currentBuildInfo mc], aParam.iDependon];
                        [aProtocal setNotificationPrefix:prefix andRow:aRow andColumn:i andDataType:WSValidateDataDependOtherData];
                    }
                }
            }
        }else{
            BOOL bfind = NO;
            for (int i = 0; i < [self.columnParams count] && !bfind; i++) {
                WSFuncsBean_Param *param = [self.columnParams objectAtIndex:i];
                if (param.iDependon != nil && [param.iDependon length] > 0 && [param.iDependon isEqualToString:aParam.col]) {
                    NSString *prefix = [NSString stringWithFormat:@"%@-%@", [(WSAcvtBean_qst *)_currentBuildInfo mc], param.iDependon];
                    [aProtocal setNotificationPrefix:prefix andRow:aRow andColumn:aColumn andDataType:WSValidateDataIsDepended];
                    bfind = YES;
                }
            }
        }
    }
}


- (NSMutableDictionary *)getNatieGridViewValuesMapping {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSMutableArray *gridMD5s = [NSMutableArray array];
    for (NSObject<I_W_OptionDataItem> *option  in self.dataSource) {
        NSString *optId = [option getDataItemID];
        NSString *rowMD5 = [NSString md5:[NSString stringWithFormat:@"%@%@",[self getGridMd5],optId]];
        [gridMD5s addObject:rowMD5];
    }
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *acvtQstDisItems = [service queryAcvtQstDatasByGenIds:gridMD5s];
    
    /*以(WSAcvtQstDisItem的genid+acvtQstId 作为key, acvtanswer作为value*/
    for (WSAcvtQstDisItem *item in acvtQstDisItems) {
        NSString *viewValue = item.acvtanswer;
        if (viewValue) {
            NSString *key = [NSString stringWithFormat:@"%@_%@",item.genId,item.acvtQstId];
            [dictionary setObject:viewValue forKey:key];
        }
    }
    return dictionary;
}

/*本地回显*/
- (NSString *)getNativeRedisValueWith:(WSFuncsBean_Param *)param data:(WSAcvtBean_qst_opt *)opt {
    
    /*  
     NSArray *rowDatas = [[WSAddAcvtTable sharedTable] queryWithNames:@[@"md5"] ArgumentsValue:@[rowMd5]];
     WSAddAcvtObject *acvtObject = [rowDatas firstObject];
     NSDictionary *acvt_qsts_Dic = [acvtObject.acvt_datas objectFromJSONString];
     NSString *qstValue = [acvt_qsts_Dic objectForKey:param.mappingAcvtQstId];
     if ([qstValue length] > 0) {
       return qstValue;
     }
     */
    
    /*
     WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
     NSArray *datas = [service queryAcvtQstDatasByGenId:rowMd5];
     for (WSAcvtQstDisItem *item in datas) {
       if ([item.acvtQstId isEqualToString:param.mappingAcvtQstId]) {
         return item.acvtanswer;
       }
     }
     */
     
    
    NSString *rowMd5 = [NSString md5:[NSString stringWithFormat:@"%@%@",[self getGridMd5],opt.optId]];
    NSString *key = [NSString stringWithFormat:@"%@_%@",rowMd5,param.mappingAcvtQstId];
    return [self.nativeGridViewValuesMapping valueForKey:key];
    

    return nil;
}

- (NSString *)getServerRedisValueWith:(WSFuncsBean_Param *)param data:(WSAcvtBean_qst_opt *)opt {
    
    if (self.acvtModel.isNewAddAcvt) {
        return nil;
    }else{
        NSString *acvtQstId = [(WSAcvtBean_qst *)_currentBuildInfo acvtQstId];
        
        NSArray *rowValues = [self.acvtModel getTAServerRedisValueForStoreByQstId:acvtQstId];
        
        __block NSString *rowValue = nil;
        
        __block NSString *row_genId = nil;
        
        __block NSString *row_optId_relationQstId = nil;
        
        [rowValues enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
            NSString *qstValue = (NSString *)obj;
            if ([qstValue rangeOfString:opt.optId].location != NSNotFound) {
                
                rowValue = qstValue;
                
                NSArray *array = [qstValue componentsSeparatedByString:@"@"];
                
                row_genId = [array firstObject];
                
                if ([array count] >= 2) {
                    
                    row_optId_relationQstId = [array lastObject];
                }
            }
        }];
//        NSArray *names = @[@"gen_id",@"sid",@"acvtId",@"acvtQstId"];
//        NSArray *values = @[row_genId,self.acvtModel.currentStore.Id,self.relationAcvtBean.acvtId,param.mappingAcvtQstId];
        
        NSMutableArray *names = [NSMutableArray arrayWithObjects:@"gen_id",@"sid",@"acvtId",@"acvtQstId", nil];
        NSMutableArray *values = [NSMutableArray arrayWithObjects:row_genId,self.acvtModel.currentStore.Id,self.relationAcvtBean.acvtId,param.mappingAcvtQstId, nil];
        
        if (self.acvtModel.currentNewStore.Id && self.acvtModel.currentNewStore.Id.length > 0){
            [names addObject:@"newStoreId"];
            [values addObject:self.acvtModel.currentNewStore.Id];
        }
        
        NSArray *results = [[WSBaseStoreAcvtDisTable sharedTable] queryColValues:@"acvt_qst_answer" withName:names ArgumentsValue:values isDistinct:YES];
        return [results firstObject];
    }
        
    
    
    /*
    NSArray *storeAcvtdisArray = self.acvtModel.currentStore.acvtDisArray;
    
    __block NSString *redisValue = nil;
    
    
    
    [storeAcvtdisArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        
        WSStoreAcvtDisBean *storeAcvtdisBean = (WSStoreAcvtDisBean *)obj;
        
        if ([storeAcvtdisBean.m_p count] >= 4) {
            
            NSString *storeId = [storeAcvtdisBean.m_p objectAtIndex:0];
            
            NSString *acvtId = [storeAcvtdisBean.m_p objectAtIndex:1];
            
            NSString *acvtQstId = [storeAcvtdisBean.m_p objectAtIndex:2];
            
            NSString *acvtQstValue = [storeAcvtdisBean.m_p objectAtIndex:3];
            
            if (row_genId && storeAcvtdisBean.gen_id && [row_genId isEqualToString:storeAcvtdisBean.gen_id]) {
                if ([storeId isEqualToString:self.acvtModel.currentStore.Id]
                    && [acvtId isEqualToString:self.relationAcvtBean.acvtId]
                    && [acvtQstId isEqualToString:param.mappingAcvtQstId]) {
                    redisValue = acvtQstValue;
                }
            }
        }
        
    }];
    
    return redisValue;
     */
}

- (BOOL)getRequestForNowRedisValueWith:(WSFuncsBean_Param *)param data:(WSAcvtBean_qst_opt *)opt {
    // 这里需要得到-------acvtdis的回显
    NSMutableArray *rowValues = [[NSMutableArray alloc]init];;
    for (WSStoreAcvtDisBean *bean in self.acvtDisArray.storeAcvtDisArray) {
        if (bean.m_p.count >2 && [_acvtModel.currentAcvtBean.acvtId isEqualToString:[bean.m_p objectAtIndex:0]]) {
            
            [rowValues addObject:[bean.m_p objectAtIndex:2]];
        }
    }
    __block NSString *rowValue = nil;
    
    __block NSString *row_genId = nil;
    
    __block NSString *row_optId_relationQstId = nil;
    
    [rowValues enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        NSString *qstValue = (NSString *)obj;
        if ([qstValue rangeOfString:opt.optId].location != NSNotFound) {
            
            rowValue = qstValue;
            
            NSArray *array = [qstValue componentsSeparatedByString:@"@"];
            
            row_genId = [array firstObject];
            
            if ([array count] >= 2) {
                
                row_optId_relationQstId = [array lastObject];
            }
        }
    }];
    
    NSArray *storeAcvtdisArray = self.acvtDisArray.storeAcvtDisArray;
    
    __block BOOL redisValue = NO;
    
    [storeAcvtdisArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
        
        WSStoreAcvtDisBean *storeAcvtdisBean = (WSStoreAcvtDisBean *)obj;
        
        if ([storeAcvtdisBean.m_p count] >=3) {
            
            // NSString *storeId = [storeAcvtdisBean.m_p objectAtIndex:0];
            
            NSString *acvtId = [storeAcvtdisBean.m_p objectAtIndex:0];
            
            NSString *acvtQstId = [storeAcvtdisBean.m_p objectAtIndex:1];
            
            NSString *acvtQstValue = [storeAcvtdisBean.m_p objectAtIndex:2                                          ];
            
            if (row_genId && storeAcvtdisBean.gen_id && [row_genId isEqualToString:storeAcvtdisBean.gen_id]) {
                if (/*[storeId isEqualToString:self.acvtModel.currentStore.Id]
                     && */[acvtId isEqualToString:self.relationAcvtBean.acvtId]
                    && [acvtQstId isEqualToString:param.mappingAcvtQstId]) {
                    redisValue = [acvtQstValue boolValue];
                }
            }
        }
        
    }];
    
    return redisValue;
    
}
#pragma  mark ZJPSelectListDelegate Methods
- (void)selectListChange:(WSSelectListView *)aSelectListView {
    
    if ([self.taDataSourceDelegate respondsToSelector:@selector(taAcvtDataGridComponetDataSource:valueChange:)]) {
        [self.taDataSourceDelegate taAcvtDataGridComponetDataSource:self valueChange:aSelectListView];
    }
    
}



- (BOOL)serverRedisWith:(WSFuncsBean_Param *)param {
    BOOL serverRedis = YES;
    if (!param.redis
        || (param.redis && [param.redis isEqualToString:@"0"])
        || (param.redis && [param.redis length] < 1)) {
        serverRedis = NO;
    }
    return serverRedis;
}

// 表格数据是否回显
- (BOOL)nativeRedis {
    BOOL redis = YES;
    NSString *dateType = self.currentFunc.dateTyp;
    if (dateType && [dateType isEqualToString:@"E"] ) {
        redis = NO;
    } else if (dateType && [dateType isEqualToString:@"D"]){
        // 当天回显
        redis = YES;
    }else {
        redis = YES;
    }
    return redis;
}


- (NSString *)getGridMd5 {
    
    if (!self.acvtModel.md5  || [self.acvtModel.md5 length] < 1) {
        self.acvtModel.md5 = [self createGridMD5];
    }
    
    return self.acvtModel.md5;
}

- (NSString *) createGridMD5
{
    
    NSString *newMD5 = @"";
    WSStoreBean *currentStore = self.acvtModel.currentStore;
    NSString *storeid = currentStore.Id;
    if ([currentStore isKindOfClass:[WSStoreBean class]]) {
        if (currentStore.iStoreIdentify != nil) {
            storeid = currentStore.iStoreIdentify;
        }
    }
    
    NSString* l_dateStr = [WSCurrentTime getDateTime];
    
    NSString *acvtQstId = [(WSAcvtBean_qst *)_currentBuildInfo acvtQstId];
    newMD5 = [NSString md5:[NSString
                            stringWithFormat:@"%@%@%@%@%@%@%@",
                            [WSAppData getObjectbyKey:APPDATA_EMPID],
                            (storeid == nil) ? @"-1" : storeid,
                            [WSAppData getObjectbyKey:APPDATA_BIZDATE],
                            self.acvtModel.currentFuncs.fc,
                            l_dateStr,
                            self.acvtModel.currentAcvtBean.acvtId,
                            acvtQstId
                            ]];
    
    return newMD5;
    
}

-(NSString*)getMD5Time
{
    NSString* l_dateStr;
    const char* l_MD5Type = [self.currentFunc.dateTyp UTF8String];
    if(l_MD5Type == NULL)
    {
        l_dateStr = [WSCurrentTime getDateString];
        return l_dateStr;
    }
    switch (*l_MD5Type)
    {
        case 'Y':
        {
            l_dateStr = [WSCurrentTime getYearString];
        }
            break;
        case 'M':
        {
            l_dateStr = [WSCurrentTime getMonthString];
            
        }
            break;
        case 'W':
        {
            l_dateStr = [WSCurrentTime getWeekString];
            
        }
            break;
        case 'E':
        {
            l_dateStr = [WSCurrentTime getTimeString];
        }
            break;
        case 'L': //永远覆盖前一条
        {
            l_dateStr = @"L";
            break;
        }
        case 'D': {
            l_dateStr = [WSCurrentTime getDateString];
        }
            break;
        default:
        {
            l_dateStr = [WSCurrentTime getDateTime];
        }
            break;
    }
    
    return l_dateStr;
}


-(void)checkBoxPressed:(UIButton *)sender{
    UIButton * btn = (UIButton * )sender;
    btn.selected = !btn.selected;
}

@end
