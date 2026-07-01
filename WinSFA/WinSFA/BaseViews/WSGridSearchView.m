//
//  WSGridSearchTableView.m
//  WinSFA
//
//  Created by heju on 15/2/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//


#define K_SERIES_SEARCHBAR_HEIGTH 44.0f
#define K_SERIES_BUTTON_HEIGHT 35.0f
#define K_ADDED_BUTTON_HEGITH  35.0f
#define K_TABLEVIEW_ROW_HEIGHT 44.0f
#define K_TABLEVIEW_COMMON_ROW_HEIGHT 35.0f
#define K_TABLEVIEW_MAXROW_COUNT 10
#define K_LAUNCH_BUTTON_HEIGHT 6
#define K_LAUNCH_BUTTON_WIDHT 12
#define K_LAUCH_BUTTON_RIGHT_MARGIN 20



#import "WSGridSearchView.h"

#import "WSProdBeanArray.h"

#import "WSProductTable.h"

#import "WSBaseDictsDBService.h"

 
@interface WSGridSearchView ()
{
}

@property (nonatomic, strong)WSFuncsBean *currentFuncs;
@property (nonatomic, strong)UITableView *seriesTableView;
@property (nonatomic, strong)NSMutableArray *seriesIdAndNameArrays;     // 包含所有系列的（id,name）数组
@property (nonatomic, strong)NSMutableDictionary *dataSourceDictionary; // 所有系列和产品关系字典（serieId  和 prodId绑定）
@property (nonatomic, strong)NSMutableDictionary *addedProdDictionary;  // 已添加的系列和产品关系字典（serieId  和 prodId绑定）


@property (nonatomic, strong)NSString *superProdGridMd5;
@property (nonatomic, strong)UIImageView *triangleImageView;
@property (nonatomic, assign)BOOL triangledDown;



@end


@implementation WSGridSearchView

- (id)initWithFrame:(CGRect)frame funcs:(WSFuncsBean *)funcs md5:(NSString *)superGridMd5{
    self = [super initWithFrame:frame];
    if (self) {
        //add Table
        _triangledDown = YES;
        self.superProdGridMd5 = superGridMd5;
        self.currentFuncs = funcs;
        [self initDataSourceWith:funcs];
        
        /*
        [self getUploadedProdsDataFromDb];
         */
        self.seriesTableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        self.seriesTableView.backgroundColor = [UIColor whiteColor];
        self.seriesTableView.delegate=self;
        self.seriesTableView.dataSource=self;
        self.selectedIndex = 1;
        [self  addSubview:self.seriesTableView];
    }
    return self;
}

// 初始化系列数据
- (void)initDataSourceWith:(WSFuncsBean *)funcs {
    // 对系列及其产品归类
    self.addedProdDictionary = [[NSMutableDictionary alloc] init];
    self.seriesIdAndNameArrays = [[NSMutableArray alloc] init];
    NSArray *selectSerieRowArray = [NSArray arrayWithObjects:@"-2",NSLocalizedString(@"select_series", nil) ,nil];
    [self.seriesIdAndNameArrays insertObject:selectSerieRowArray atIndex:0];
    if (funcs.filter) {
        NSArray *filters = [funcs.filter componentsSeparatedByString:@","];
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        self.dataSourceDictionary = [[NSMutableDictionary alloc] init];
        self.allSeriesProds = [[NSMutableArray alloc] init];
        [filters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *partFilter = (NSString *)obj;
            
            NSArray *filterDicts = [[NSArray alloc] init];
            if (_drid) {
                filterDicts = [service queryDictsWithParentId:partFilter andDrid:_drid];
            }else
                filterDicts = [service queryDictsWithParentId:partFilter];
            
            [filterDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               
                WSDictBean *dictBean = (WSDictBean *)obj;
                NSString *dictId = dictBean.Id;

                NSMutableArray *currentSerieProdIds = [NSMutableArray array];
                WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
                [prodBeanArray.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSProdBean *prodBean = (WSProdBean *)obj;
                    if (/*(prodBean.pTyp && dictId && [dictId isEqualToString:prodBean.pTyp]) ||*/
                        (prodBean.series && dictId && [dictId isEqualToString:prodBean.series])) {
                        [currentSerieProdIds addObject:prodBean.Id];
                        [self.allSeriesProds addObject:prodBean];
                    }
                }];
                [self.dataSourceDictionary setObject:currentSerieProdIds forKey:[NSString stringNotNilWithValue:dictBean.Id]];
            }];
            
        }];
    }
}


- (void)getUploadedProdsDataFromDb {
    _uploadedEditedProds = [[NSMutableArray alloc] init];
    NSArray *names =  @[@"idx"];
    NSArray *values = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:self.superProdGridMd5], nil];
    NSArray *productObjects =  [[WSProductTable sharedTable] queryWithNames:names ArgumentsValue:values];
    [self.allSeriesProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSProdBean *tmpProd = (WSProdBean *)obj;
        [productObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProductObject *producObject = (WSProductObject *)obj;
            if (tmpProd.Id && producObject.prod_id && [tmpProd.Id isEqualToString:producObject.prod_id]) {
                [self.uploadedEditedProds addObject:tmpProd];
            }
        }];
    }];
    
}

// 获取所有系列的name 和id
- (NSMutableArray *)getAllserieIdAndNamesWith:(WSFuncsBean *)funcs {
    __block NSMutableArray *dictSeries = [NSMutableArray array];
    __block NSMutableArray *seriesNameAndIds = [NSMutableArray array];
    if (funcs.filter) {
        NSArray *filters = [funcs.filter componentsSeparatedByString:@","];
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        [filters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *partFilter = (NSString *)obj;
            
            NSArray *filterDicts = [[NSArray alloc] init];
            if (_drid) {
                filterDicts = [service queryDictsWithParentId:partFilter andDrid:_drid];
            }else
                filterDicts = [service queryDictsWithParentId:partFilter];
            
            [filterDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSDictBean *dictBean = (WSDictBean *)obj;
                    
                NSString *serieId = dictBean.Id;
                NSString *serieName = dictBean.name;
                NSArray *serieNameId = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:serieId],[NSString stringNotNilWithValue:serieName], nil];
                [dictSeries addObject:dictBean];
                [seriesNameAndIds addObject:serieNameId];
            }];
        }];
    }
    if ([seriesNameAndIds count] > 0) {
//        NSArray *addedProdRowArray = [NSArray arrayWithObjects:@"-1",NSLocalizedString(@"所有产品", nil), nil];
        NSArray *addedProdRowArray = [NSArray arrayWithObjects:@"-1",NSLocalizedString(@"all_selected_product", nil), nil];
        [self.seriesIdAndNameArrays insertObject:addedProdRowArray atIndex:1];
        [self.seriesIdAndNameArrays addObjectsFromArray:seriesNameAndIds];
    }
    return self.seriesIdAndNameArrays;
}

// 重新加载视图
- (void)redisPlayWith:(NSMutableArray *)allAddedProds {
    if (allAddedProds) {
        [self trimmingProdsDataWith:allAddedProds];
        [self.seriesTableView reloadData];
    }
}

- (void)trimmingProdsDataWith:(NSMutableArray *)uploadedProds {
    [self.dataSourceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *serieId = (NSString *)key;
        NSMutableArray *serieProdsId = (NSMutableArray *)obj;
        NSMutableArray *addedProdsOfSerie = [NSMutableArray array];
        [uploadedProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProdBean *prodBean = (WSProdBean *)obj;
            if ([serieProdsId containsObject:prodBean.Id]) {
                [addedProdsOfSerie addObject:prodBean];
            }
            
        }];
        //  统计该系列已添加的产品
        if ([addedProdsOfSerie count] > 0) {
            NSString *statistics = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[addedProdsOfSerie count],(unsigned long)[serieProdsId count]];
            [self.addedProdDictionary setObject:statistics forKey:serieId];
        }
    }];
    if ( [uploadedProds count] > 0) {
        NSString * addedProds = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[uploadedProds count],(unsigned long)[self.allSeriesProds count]];
        [self.addedProdDictionary setObject:addedProds forKey:@"-1"];
    }
}

#pragma mark  UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.seriesIdAndNameArrays count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
  
    if ([self.seriesIdAndNameArrays count] > 0) {
        if (indexPath.row == 0 ) {
            if (_triangleImageView) {
                [_triangleImageView removeFromSuperview];
            }
            _triangleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - K_LAUNCH_BUTTON_WIDHT - K_LAUCH_BUTTON_RIGHT_MARGIN,(K_TABLEVIEW_ROW_HEIGHT - K_LAUNCH_BUTTON_HEIGHT)/2, K_LAUNCH_BUTTON_WIDHT, K_LAUNCH_BUTTON_HEIGHT)];
            [cell.contentView addSubview:self.triangleImageView];
            if (self.triangledDown) {
                [self.triangleImageView setImage:[UIImage imageForName:@"triangle_down.png"]];
            } else {
                [self.triangleImageView setImage:[UIImage imageForName:@"triangle_up.png"]];
            }
            
        }else{
            for (UIView * view in cell.contentView.subviews) {
                if (view == _triangleImageView) {
                    view.hidden = YES;
                    break;
                }
            }
        }
        NSArray *dictSerieIdAndNames = [self.seriesIdAndNameArrays objectAtIndex:indexPath.row];
        NSString *serieName = [dictSerieIdAndNames lastObject];
        NSString *appending = [self.addedProdDictionary objectForKey:[dictSerieIdAndNames firstObject]];
        if (appending && [appending  length] > 0) {
            serieName = [serieName stringByAppendingString:appending];
        }
        cell.textLabel.text = serieName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CGFloat changedHeight = K_TABLEVIEW_ROW_HEIGHT;
    if (indexPath.row ==0 || indexPath.row == 1) {
        self.triangledDown = !self.triangledDown;
        if (indexPath.row == 0) {
            if ([self.seriesIdAndNameArrays count]==1) {
                [self getAllserieIdAndNamesWith:self.currentFuncs];
                /*
                if ([self.uploadedEditedProds count] > 0) {
                    [self trimmingProdsDataWith:self.uploadedEditedProds];
                }
                 */
                
            } else {
                [self.seriesIdAndNameArrays removeAllObjects];
                NSArray *selectSerie = [NSArray arrayWithObjects:@"-2",NSLocalizedString(@"select_series", nil), nil];
                [self.seriesIdAndNameArrays insertObject:selectSerie atIndex:0];
            }
            changedHeight = K_TABLEVIEW_ROW_HEIGHT + ([self.seriesIdAndNameArrays count] -1)*K_TABLEVIEW_COMMON_ROW_HEIGHT;
            if (changedHeight >= K_TABLEVIEW_ROW_HEIGHT * K_TABLEVIEW_MAXROW_COUNT) {
                changedHeight = K_TABLEVIEW_ROW_HEIGHT * K_TABLEVIEW_MAXROW_COUNT;
            }
        } else if (indexPath.row == 1) {
            [self.seriesIdAndNameArrays removeAllObjects];
            NSArray *selectedSerieNameAndId = [NSArray arrayWithObjects:@"-1",NSLocalizedString(@"all_selected_products", nil), nil];
            [self.seriesIdAndNameArrays insertObject:selectedSerieNameAndId atIndex:0];
        }
        [self.seriesTableView setFrame:CGRectMake(self.seriesTableView.origin.x, self.seriesTableView.origin.y, self.seriesTableView.frame.size.width, changedHeight)];
        [self.seriesTableView reloadData];
        if (indexPath.row == 0) {
            if ([_delegate respondsToSelector:@selector(willSelectedgridSearchView:heightChange:)]) {
                [_delegate willSelectedgridSearchView:self heightChange:changedHeight];
            }
        }else{
            self.selectedIndex = indexPath.row;
            if ([_delegate respondsToSelector:@selector(selectedFilledProdsGridSearchView:heightChange:)]) {
                [_delegate selectedFilledProdsGridSearchView:self heightChange:changedHeight];
            }
        }
    }  else {
        self.triangledDown = YES;
        NSArray *selectedSerieIdAndNames =  [self.seriesIdAndNameArrays objectAtIndex:indexPath.row];
        NSString *seletedSerieId = [selectedSerieIdAndNames firstObject];
        NSString *seletedSerieName = [selectedSerieIdAndNames lastObject];
        WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
        NSString *showSelectedSeriesName =  [NSString stringWithFormat:@"%@   %@",NSLocalizedString(@"series_lable", nil),seletedSerieName];
        __block NSMutableArray *selectedSerieProds = [NSMutableArray array];
        if (prodBeanArray.prodArray) {
            [prodBeanArray.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSProdBean *prodBean = (WSProdBean *)obj;
                if ((seletedSerieId && prodBean.pTyp && [seletedSerieId isEqualToString:prodBean.pTyp]) ||
                    (seletedSerieId && prodBean.series && [seletedSerieId isEqualToString:prodBean.series])) {
                    [selectedSerieProds addObject:prodBean];
                }
            }];
        }
        if ([selectedSerieProds count] > 0) {
            self.selectedIndex = indexPath.row;
            [self.seriesTableView setFrame:CGRectMake(self.seriesTableView.origin.x, self.seriesTableView.origin.y, self.seriesTableView.frame.size.width, K_TABLEVIEW_ROW_HEIGHT)];
            
            
            //
            [self.seriesIdAndNameArrays removeAllObjects];
            NSArray *changedSerieIdAndName= [NSArray arrayWithObjects:seletedSerieId , showSelectedSeriesName,nil];
            [self.seriesIdAndNameArrays insertObject:changedSerieIdAndName atIndex:0];
            [self.seriesTableView reloadData];
            if ([_delegate respondsToSelector:@selector(gridSearchView:selectProds:atIndex:heightChange:)]) {
                [_delegate gridSearchView:self selectProds:selectedSerieProds atIndex:self.selectedIndex heightChange:K_TABLEVIEW_ROW_HEIGHT];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = K_TABLEVIEW_ROW_HEIGHT;
    if (indexPath.row != 0) {
        rowHeight = K_TABLEVIEW_COMMON_ROW_HEIGHT;
    }
    return rowHeight;
}
- (void)scrollToRowSelectIndexPath:(NSIndexPath *)indexPath{
    
    [self.seriesTableView deselectRowAtIndexPath:indexPath animated:NO];
    CGFloat changedHeight = K_TABLEVIEW_ROW_HEIGHT;
    self.selectedIndex = indexPath.row;
    [self.seriesIdAndNameArrays removeAllObjects];
//    NSArray *selectedSerieNameAndId = [NSArray arrayWithObjects:@"-1",NSLocalizedString(@"系列:      所有产品", nil), nil];
    NSArray *selectedSerieNameAndId = [NSArray arrayWithObjects:@"-1",NSLocalizedString(@"all_selected_products", nil), nil];
    [self.seriesIdAndNameArrays insertObject:selectedSerieNameAndId atIndex:0];
    [self.seriesTableView setFrame:CGRectMake(self.seriesTableView.origin.x, self.seriesTableView.origin.y, self.seriesTableView.frame.size.width, changedHeight)];
    if (indexPath.row == 0) {
        if ([_delegate respondsToSelector:@selector(willSelectedgridSearchView:heightChange:)]) {
            [_delegate willSelectedgridSearchView:self heightChange:changedHeight];
        }
    }else{
        self.selectedIndex = indexPath.row;
        if ([_delegate respondsToSelector:@selector(selectedFilledProdsGridSearchView:heightChange:)]) {
            [_delegate selectedFilledProdsGridSearchView:self heightChange:changedHeight];
        }
    }

    [self.seriesTableView reloadData];


}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
