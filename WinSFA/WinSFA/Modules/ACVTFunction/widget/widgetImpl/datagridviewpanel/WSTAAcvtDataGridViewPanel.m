//
//  WSTAAcvtDataGridViewPanel.m
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSTAAcvtDataGridViewPanel.h"

#import "WSTAAcvtDataGridViewDataSouce.h"

#import "WSDataSourceManager.h"

#import "WSSelectListView.h"
#import "WSGridWidget.h"
#import "WSCheckBox.h"
#import "GetMD5byStr.h"
#import "WSBaseDictsDBService.h"

#define TA_HEAD_Y_OFFSET (INTERFACE_IS_PHONE ? 6 : 10)

@implementation WSTAAcvtDataGridViewPanel



- (void)buildDisplayContent {
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    BOOL firstLoadIsExtended = [model firstLoadIsExtended:xbuildInfo];

    WSTAAcvtDataGridComponentDataSource *dataSource = (WSTAAcvtDataGridComponentDataSource *)[xdataSource getDataSourceFor:xbuildInfo];
    
    dataSource.taDataSourceDelegate = self;
    
    float height = 0;
    
    if ([dataSource.data count] > 0) {
        
        height = DATAGRID_CELL_HEIGHT_DEFAULT * ([dataSource.data count] + 1) + 10;
        
    }else{
        // 需要判断是否需要添加品牌系列然后选择height的高度O
        if (dataSource.needSelect) {
            height = DATAGRID_CELL_HEIGHT_DEFAULT + 44 - TA_HEAD_Y_OFFSET;
        } else {
            height = DATAGRID_CELL_HEIGHT_DEFAULT - TA_HEAD_Y_OFFSET;
        }
    }

    
    
    self.dataGridView = [[DataGridComponent alloc] initWithFrame: CGRectMake(0, 0, self.bounds.size.width, height) data:dataSource];
    
    self.dataGridView.backgroundColor = [UIColor lightGrayColor];
    
    //表格第一次绘图是展开形式，则不允许闭合 firstLoadedIsExtended = yes；存在多个TB表格时，第一次绘图是闭合形式 firstLoadedIsExtended = no；
    if (firstLoadIsExtended) {
        self.dataGridView.isAllowedExtend = NO;
    }else{
        self.dataGridView.isAllowedExtend = YES;
    }
    self.dataGridView.isExtendedView = firstLoadIsExtended;
    
    self.dataGridView.tag = [[xbuildInfo getAcvtQstId] integerValue];
    // 将表头控件视图句柄交给表头数据源
    
    self.dataGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:self.dataGridView];

    [self setReadonly:[xbuildInfo getReadOnly]];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
    
    
}



- (void)layoutSubviews {
    
    self.dataGridView.frame = CGRectMake(self.dataGridView.frame.origin.x, self.dataGridView.frame.origin.y, self.dataGridView.frame.size.width, self.dataGridView.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.dataGridView.frame.size.height);
}

- (NSObject *)getResultDirectly {
    NSMutableArray *allRows = [NSMutableArray array];
    WSTAAcvtDataGridComponentDataSource *taComponentDataSource = (WSTAAcvtDataGridComponentDataSource *)self.dataGridView.dataSource;
    for (NSInteger i = 0 ; i < [taComponentDataSource.dataSource count]; i++) {
        NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
        WSAcvtBean_qst_opt *opt = [taComponentDataSource.dataSource objectAtIndex:i];
        NSMutableArray *rowViews = [taComponentDataSource.data objectAtIndex:i];
        for (NSInteger j = 0; j < [taComponentDataSource.columnParams count]; j++) {
            WSFuncsBean_Param *param = [taComponentDataSource.columnParams objectAtIndex:j];
           
            WSGridWidget *gridWidget = [rowViews objectAtIndex:j + 1];
            UIView *view = [gridWidget getView];
            
            if ([view isKindOfClass:[WSSelectListView class]]){
                
                WSSelectListView *selectlist = (WSSelectListView *)view;
                if (selectlist.selectedIndex != -1) {
                    NSString *selectedContent = [selectlist currentSelectedContent];
                    NSString *selectedId = [self  getDictIdWith:selectedContent param:param];
                    [rowDictionary setObject:[NSString stringNotNilWithValue:selectedId] forKey:[NSString stringWithFormat:@"%@%@",param.tpy,param.mappingAcvtQstId]];
                    
                } else {
                    [rowDictionary setObject:@"" forKey:[NSString stringWithFormat:@"%@%@",param.tpy,param.mappingAcvtQstId]];
                }
            } else {
                NSString *value = [gridWidget getValue];
                [rowDictionary setObject:[NSString stringNotNilWithValue:value] forKey:[NSString stringWithFormat:@"%@%@",param.tpy,param.mappingAcvtQstId]];
            }
        }
        NSString *rowMd5 = [NSString md5:[NSString stringWithFormat:@"%@%@",[taComponentDataSource getGridMd5],opt.optId]];
        [rowDictionary setObject:[NSString stringNotNilWithValue:rowMd5] forKey:@"id"];
        [allRows addObject:rowDictionary];
    }
    return /*[allRows JSONString]*/ allRows;
}


- (NSString *)getDictIdWith:(NSString *)dictName param:(WSFuncsBean_Param *)param{
    if ([param.tpy isEqualToString:COL_TYPDT] || [param.tpy isEqualToString:COL_TYPSD]){
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSArray* filterArray = [service queryDictsForAcvtGridWithFilter:param.filter];
        
        for (WSDictBean *db in filterArray)
        {
            if ([dictName isEqualToString:db.name]) {
                return db.Id;
            }
        }
    }
    return nil;
}


- (DataGridComponentDataSource *)getAcvtTAQstDataSource {
    if (self.dataGridView) {
        return self.dataGridView.dataSource;
    }
    return nil;
}


- (NSString *)acvtDataGridTAQstId {
    return [xbuildInfo getAcvtQstId];
}

// 节点请求刷新表格数据
-(void)reloadCurrentWidgetWithValue:(NSObject *)value andRequestNodeName:(NSString *)nodeName{
    CGFloat topGap = 10.0f;
    
    [self.dataGridView removeFromSuperview];
    WSTAAcvtDataGridComponentDataSource *dataSource = [[WSTAAcvtDataGridComponentDataSource alloc]initWith:xbuildInfo withNowRequestData:value andRequestNodeName:nodeName];
    
    dataSource.taDataSourceDelegate = self;
    
    float height = 0;
    
    if ([dataSource.data count] > 0) {
        
       // SFA-1668 SFA 史克医院--医院拜访计划设置--医院显示不全，不能下拉查看
        height = DATAGRID_CELL_HEIGHT_DEFAULT * ([dataSource.data count] + 1) + 10+10;
        
    }else{
        // 需要判断是否需要添加品牌系列然后选择height的高度O
        if (dataSource.needSelect) {
            height = DATAGRID_CELL_HEIGHT_DEFAULT + 44;
        } else {
            height = DATAGRID_CELL_HEIGHT_DEFAULT;
        }
    }
    self.dataGridView = [[DataGridComponent alloc] initWithFrame: CGRectMake(0, topGap, self.bounds.size.width, height) data:dataSource];
    
    self.dataGridView.backgroundColor = [UIColor grayColor];
    
    self.dataGridView.tag = [[xbuildInfo getAcvtQstId] integerValue];
    // 将表头控件视图句柄交给表头数据源
    
    self.dataGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:self.dataGridView];
    
    [self setReadonly:[xbuildInfo getReadOnly]];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height);
    
}


#pragma WSTAAcvtDataGridComponetDataSource Methods 

- (void)taAcvtDataGridComponetDataSource:(WSTAAcvtDataGridComponentDataSource *)taDataSource valueChange:(NSObject *)object {
    if ([self.delegate respondsToSelector:@selector(widget:valueChanged:)]) {
        [self.delegate widget:self valueChanged:YES];
    }
}


@end
