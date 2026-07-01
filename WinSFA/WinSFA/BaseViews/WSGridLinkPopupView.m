
//
//  WSGridLinkPopupView.m
//  WinSFA
//
//  Created by heju on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSGridLinkPopupView.h"
#import "WSProdBeanArray.h"

#import "WSBaseProductDBService.h"
#import "WSBaseDictsDBService.h"

#define WSRect(x,y,w,h) CGRectMake(x, y, w,h)

#define K_TABLE_LEFT_MARGIN 20
#define K_TABLE_RIGHT_MARGIN 20

#define K_TABLE_SECTION 1
#define K_TABLE_ROW_HEIGHT 44

#define K_BRAND_CELL_BG_COLOR [UIColor colorWithRed:208.0f/255 green:208.0f/255 blue:208.0f/255 alpha:0.6]

@interface WSGridLinkPopupView() {
}

@property (nonatomic,strong)NSString *superGridMd5;
@property (nonatomic,strong)NSString *selectedBrandName;
@property (nonatomic,strong)NSString *storeId;
@property (nonatomic,strong)NSArray *params;
@property (nonatomic,copy)NSString *appendprop;
@end


@implementation WSGridLinkPopupView

/*按品牌选择的产品 也要走分销规则*/
- (id)initWithFrame:(CGRect)frame
            storeId:(NSString *)storeId
             params:(NSArray *)params
              brandFilter:(NSString *)brandFilter
                md5:(NSString *)superGridMd5
     brandSerieType:(WSBrandSerieType)brandSerieType
              prods:(NSArray *)prods
         appendprop:(NSString *)appendprop {
    self = [self initWithFrame:frame storeId:storeId brandFilter:brandFilter md5:superGridMd5 prods:prods isShowSeries:NO appendprop:appendprop];
    if (self) {
        self.params = params;
        self.brandSerieType = brandSerieType;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
        brandFilter:(NSString *)brandFilter
                md5:(NSString *)superGridMd5
              prods:(NSArray *)prods
         appendprop:(NSString *)appendprop {
    return [self initWithFrame:frame storeId:nil brandFilter:brandFilter md5:superGridMd5 prods:prods isShowSeries:YES appendprop:appendprop];
}


- (id)initWithFrame:(CGRect)frame
            storeId:(NSString *)storeId
        brandFilter:(NSString *)brandFilter
                md5:(NSString *)superGridMd5
              prods:(NSArray *)prods
        isShowSeries:(BOOL) isShowSeries
         appendprop:(NSString *)appendprop  {
    self = [super  initWithFrame:frame];
    if (self) {
        // to do something
        _selectedBrandName = [[NSString alloc]init];
        self.backgroundColor = POP_WINDOW_BG_COLOR;
        self.storeId = storeId;
        self.superGridMd5 = superGridMd5;
        self.appendprop = appendprop;
        
        // brandIds
        self.brandIdsString = brandFilter;
        [self initDataSource];
        [self initBrandDatasWith:brandFilter];
        
        CGFloat tableWidth = (frame.size.width - K_TABLE_LEFT_MARGIN - K_TABLE_RIGHT_MARGIN);
        if (isShowSeries) {
            tableWidth = tableWidth / 2;
        }
        CGFloat tableHeight = self.brands.count * K_TABLE_ROW_HEIGHT;
        
        CGFloat popViewHeight = tableHeight < POP_VIEW_MAX_HEIGHT ? tableHeight : POP_VIEW_MAX_HEIGHT;
        CGFloat popViewPaddingY = (self.height - popViewHeight) / 2;

        // 品牌列表
        _brandTableView = [[UITableView alloc] initWithFrame:WSRect(K_TABLE_LEFT_MARGIN, popViewPaddingY, tableWidth, popViewHeight)];
        self.brandTableView.tableFooterView = [[UIView alloc]init];
        self.brandTableView.delegate = self;
        self.brandTableView.dataSource = self;
        self.brandTableView.backgroundColor = [UIColor whiteColor];
        self.brandTableView.alpha = 1.0f;
        [self addSubview:self.brandTableView];
        
        // 系列列表
        if (isShowSeries) {
            _serieTableView = [[UITableView alloc] initWithFrame:WSRect(K_TABLE_LEFT_MARGIN + tableWidth, popViewPaddingY, tableWidth, popViewHeight)];
            self.serieTableView.tableFooterView = [[UIView alloc]init];
            self.serieTableView.delegate = self;
            self.serieTableView.dataSource = self;
            self.serieTableView.backgroundColor = [UIColor whiteColor];
            self.serieTableView.alpha = 1.0f;
            [self addSubview:self.serieTableView];
        }
        [self dispalay:prods];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
        brandFilter:(NSString *)brandFilter
                md5:(NSString *)superGridMd5
              prods:(NSArray *)prods
             params:(NSArray *)params
         appendprop:(NSString *)appendprop {
    self = [super  initWithFrame:frame];
    if (self) {
        // to do something
        self.params = params;
        self = [self initWithFrame:frame brandFilter:brandFilter md5:superGridMd5 prods:prods appendprop:appendprop];
    }
    return self;
}

- (void)dispalay:(NSArray *)prods {
    
    
    if ([prods count] > 0) {
        _selectedBrandIndex = 0;
    }
    [self redisplayWith:prods];
}


- (NSMutableArray *)getInsertedProdsFromeDb {
    __block NSMutableArray *insertedProducts = [NSMutableArray array];
    NSArray *names =  @[@"IDX"];
    NSArray *values = [NSArray arrayWithObjects:self.superGridMd5, nil];
    if ([names count] != [values count]) {
        return nil;
    }
    NSArray *productObjects = [[WSProductTable sharedTable] queryWithNames:names ArgumentsValue:values];
    [self.allBrandProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSProdBean *tmpProd = (WSProdBean *)obj;
        [productObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProductObject *producObject = (WSProductObject *)obj;
            if (tmpProd.Id && producObject.prod_id && [tmpProd.Id isEqualToString:producObject.prod_id]) {
                [insertedProducts addObject:tmpProd];
            }
        }];
    }];
    return insertedProducts;
}

// 直接用竞品id过滤产品的serie字段
- (void)initAllBrandProds {
    self.selectedBrandRow = NO;
    self.selectedSerieRow = NO;
    _selectedSerieIndex = -1;
    _selectedBrandIndex = -1;
    _uploadedEditedProds = [[NSMutableArray alloc] init];
    _editedBrandProdsDictionary = [[NSMutableDictionary alloc] init];
    _editedSerieProdsDicionary = [[NSMutableDictionary alloc] init];
    _allEditedProds = [[NSMutableArray alloc] init];
    _brands = [[NSMutableArray alloc] init];
    _allBrandProds = [[NSMutableArray alloc] init];
    _trimmingDataSource = [[NSMutableDictionary alloc] init];
    NSArray *brandsId = [self.brandIdsString componentsSeparatedByString:@","];
    
    NSArray *prodArray = [self queryProdsByStoreId:self.storeId params:self.params brandId:nil];
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    for (NSInteger i = 0; i < [brandsId  count]; i++) {
        // 品牌的字典项
        NSString *brandId = [brandsId objectAtIndex:i];
        __block NSMutableDictionary *serieDictionary = [NSMutableDictionary dictionary];
        
        WSDictBean *dictBean = [service queryDictWithID:brandId];
        if (dictBean) {
            // 系列的dictBean
            __block NSMutableArray *prodsId = [NSMutableArray array];
            for (NSInteger i = 0; i < [prodArray count]; i++) {
                WSProdBean *prodBean = (WSProdBean *)[prodArray objectAtIndex:i];
                if (dictBean.Id && prodBean.series && [dictBean.Id isEqualToString:prodBean.series]) {
                    [prodsId addObject:prodBean.Id];
                    [self.allBrandProds addObject:prodBean];
                }
            }
            
            [serieDictionary setObject:prodsId forKey:dictBean.Id];
        }
        
        [self.trimmingDataSource  setObject:serieDictionary forKey:brandId];
    }
}

/*直接通过品牌找到其下的产品*/
- (NSMutableArray *)getBrandProdsWith:(NSString *)brandId {
    
    __block NSMutableArray *selectedSerieProds = [NSMutableArray array];
    NSArray *prodArray = [self queryProdsByStoreId:self.storeId params:self.params brandId:nil];
    if (prodArray) {
        [prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProdBean *prodBean = (WSProdBean *)obj;
            if (brandId && prodBean.series && [brandId isEqualToString:prodBean.series]) {
                [selectedSerieProds addObject:prodBean];
            }
        }];
    }
    return selectedSerieProds;
}

/*旧的通过品牌 找 系列  再通过系列 找产品逻辑*/
-(void)initDataSource {
    self.selectedBrandRow = NO;
    self.selectedSerieRow = NO;
    _selectedSerieIndex = -1;
    _selectedBrandIndex = -1;
    _uploadedEditedProds = [[NSMutableArray alloc] init];
    _editedBrandProdsDictionary = [[NSMutableDictionary alloc] init];
    _editedSerieProdsDicionary = [[NSMutableDictionary alloc] init];
    _allEditedProds = [[NSMutableArray alloc] init];
    _brands = [[NSMutableArray alloc] init];
    _allBrandProds = [[NSMutableArray alloc] init];
    _trimmingDataSource = [[NSMutableDictionary alloc] init];
    NSArray *brandsId = [self.brandIdsString componentsSeparatedByString:@","];
    
    NSArray *prodArray = [self queryProdsByStoreId:self.storeId params:self.params brandId:nil];
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    for (NSInteger i = 0; i < [brandsId  count]; i++) {
        // 品牌的字典项
        NSString *brandId = [brandsId objectAtIndex:i];
        NSArray *filterArray = [service queryDictsWithParentId:brandId];
        
        __block NSMutableDictionary *serieDictionary = [NSMutableDictionary dictionary];
        
        [filterArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSDictBean *dictBean = (WSDictBean *)obj;

            // 系列的dictBean
            __block NSMutableArray *prodsId = [NSMutableArray array];
            for (NSInteger i = 0; i < [prodArray count]; i++) {
                WSProdBean *prodBean = (WSProdBean *)[prodArray objectAtIndex:i];
                if (dictBean.Id && prodBean.pTyp && [dictBean.Id isEqualToString:prodBean.pTyp]) {
                    [prodsId addObject:prodBean.Id];
                    [self.allBrandProds addObject:prodBean];
                }
            }
            
            [serieDictionary setObject:prodsId forKey:dictBean.Id];
            
            
            
        }];
        
        [self.trimmingDataSource  setObject:serieDictionary forKey:brandId];
    }
    
}

// 品牌集合
- (void)initBrandDatasWith:(NSString *)brandIdsString {
    if (_brands == nil) {
        _brands = [[NSMutableArray alloc] init];
    } else {
        [self.brands removeAllObjects];
    }
    if (brandIdsString) {
        // brandIdFilter:(90654,90655)
        NSArray *brandsId = [brandIdsString componentsSeparatedByString:@","];
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        for (NSInteger i = 0; i < [brandsId count]; i++) {
        
            NSString *currentBrandId = [brandsId objectAtIndex:i];
            // winSFA MSTD-4359  如果 currentBrandId 只有一个，则直接查询pid 为 currentBrandId 的品牌，与安卓逻辑一致
            if (brandsId.count == 1) {
                // MSTD-7407
                if ([self.storeId length] > 0) {
                    [self.brands addObjectsFromArray:[service queryDictsWithParentId:currentBrandId andDrid:self.storeId]];
                } else {
                    [self.brands addObjectsFromArray:[service queryDictWithPid:currentBrandId ]];
                }
            }else{
                WSDictBean *dictBean = [service queryDictWithID:currentBrandId];
                if (dictBean) {
                    [self.brands addObject:dictBean];
                }
            }
            
        }
        // 品牌列表第一行 显示所有已选择的产品
        NSArray *names = [NSArray arrayWithObjects:NSLocalizedString(@"all_selected_product", nil),@"-1", nil];
        NSArray *keys = [NSArray arrayWithObjects:@"name",@"id",nil];
        NSMutableDictionary *selectedProdsDictionary = [NSMutableDictionary dictionaryWithObjects:names forKeys:keys];
        WSDictBean *selectedProdsDictBean = [[WSDictBean alloc] initWithObject:selectedProdsDictionary];
        [self.brands insertObject:selectedProdsDictBean atIndex:0];
        
    } else {
        NSLog(@"no filter");
    }
    
}

// 某一品牌系列集合
- (NSMutableArray *)getSerieDataSourceWith:(WSDictBean *)brand {
    __block NSMutableArray *tmpSeries = [NSMutableArray array];

    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    [tmpSeries addObjectsFromArray:[service queryDictsWithParentId:brand.Id]];
    
    return tmpSeries;
}

//某一系列产品集合
- (NSMutableArray *)getProdsWith:(WSDictBean *)serieDictBean {
    __block NSMutableArray *selectedSerieProds = [NSMutableArray array];
    NSArray *prodArray = [self queryProdsByStoreId:self.storeId params:self.params brandId:nil];
    if (prodArray) {
        [prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProdBean *prodBean = (WSProdBean *)obj;
            if (serieDictBean.Id && prodBean.pTyp && [serieDictBean.Id isEqualToString:prodBean.pTyp]) {
                [selectedSerieProds addObject:prodBean];
            }
        }];
    }
    return selectedSerieProds;
}

- (void)redisplayWith:(NSArray *)editedProds {
 
    [self.allEditedProds removeAllObjects];
    [self.editedBrandProdsDictionary removeAllObjects];
    [self.editedSerieProdsDicionary removeAllObjects];
    [self.allEditedProds addObjectsFromArray:editedProds];
    if (self.brandSerieType == WSBrandType) {
        [self reloadBrandTableWith:editedProds];
    } else {
        [self reloadBrandTableWith:editedProds];
        [self reloadSerieTableWith:editedProds];
    }
    
    
}

- (void)reloadBrandTableWith:(NSArray *)editedProds {
    // 重新加载品牌列表
    
    [self.trimmingDataSource enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *serieDictionray = (NSMutableDictionary *)obj;
        NSMutableArray *addedBrandProds = [NSMutableArray array];
        NSMutableArray *brandAllProds = [NSMutableArray array];
        [serieDictionray enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableArray *prodsId = (NSMutableArray *)obj;
            [brandAllProds addObjectsFromArray:prodsId];
            [editedProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSProdBean *currentAddedProd = (WSProdBean *)obj;
                if ([prodsId containsObject:currentAddedProd.Id]) {
                    [addedBrandProds addObject:currentAddedProd];
                }
            }];
            
        }];
        if ([addedBrandProds count] > 0) {
            NSString *brandPartName = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[addedBrandProds count],(unsigned long)[brandAllProds count]];
            [self.editedBrandProdsDictionary setObject:brandPartName forKey:key];
        }
    }];
    NSString *brandPartName = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[editedProds count],(unsigned long)[self.allBrandProds count]];
    [self.editedBrandProdsDictionary setObject:brandPartName forKey:@"-1"];
    [self.brandTableView reloadData];
}

- (void)reloadSerieTableWith:(NSArray *)editedProds {
    [self.series enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block NSMutableArray *currentSerieAddedProds = [NSMutableArray array];
        WSDictBean *serieDictBean = (WSDictBean *)obj;
        [editedProds enumerateObjectsUsingBlock:^(id prodObj, NSUInteger prodIdx, BOOL *stop) {
            WSProdBean *prodBean = (WSProdBean *)prodObj;
            if ([prodBean.pTyp isEqualToString:serieDictBean.Id] ) {
                // 已添加的属于当前系列的产品
                [currentSerieAddedProds addObject:prodBean];
            }
        }];
        // 当前系列的所有产品
        NSMutableArray *serieAllProds = [self getProdsWith:serieDictBean];
        if (currentSerieAddedProds
            && [currentSerieAddedProds count] > 0
            && [serieAllProds count] > 0) {
            WSDictBean *serieDictBean = [self.series objectAtIndex:idx];
            NSString *appendingPart = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[currentSerieAddedProds count],(unsigned long)[serieAllProds count]];
            if (serieDictBean.Id) {
                [self.editedSerieProdsDicionary setObject:appendingPart forKey:[NSString stringNotNilWithValue:serieDictBean.Id]];
            } else {
                LogError(@"serieDictBean.Id 不存在");
            }
        }
    }];

    [self.serieTableView reloadData];
}

- (NSArray *)queryProdsByStoreId:(NSString *)storeId params:(NSArray *)params brandId:(NSString *)brandId {
    
    WSBaseProductDBService *baseProductDBService = [[WSBaseProductDBService alloc] init];
    return [baseProductDBService queryBrandSortProductsWithStoreId:storeId brand:brandId params:params appendprop:self.appendprop];
}



#pragma mark UITableViewDelegate/UITableViewDataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return K_TABLE_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if (tableView == self.brandTableView) {
        rowCount = [self.brands count];
    } else if (tableView == self.serieTableView) {
        rowCount = [self.series count];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (self.brandSerieType == WSBrandType) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width,cell.frame.size.height)];
        if (self.selectedBrandIndex != -1 && self.selectedBrandIndex == indexPath.row && self.selectedBrandRow) {
            backgroundView.backgroundColor = [UIColor whiteColor];
        } else {
            backgroundView.backgroundColor = K_BRAND_CELL_BG_COLOR;
        }
        cell.backgroundView = backgroundView;
        
        WSDictBean *brandBean = [self.brands objectAtIndex:indexPath.row];
        NSString *text = brandBean.name;
        NSString *appending = [self.editedBrandProdsDictionary objectForKey:brandBean.Id];
        if (appending) {
            text = [text stringByAppendingString:appending];
        }
        cell.textLabel.text = text;

    } else {
        if (tableView == self.brandTableView) {
            UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width,cell.frame.size.height)];
            if (self.selectedBrandIndex != -1 && self.selectedBrandIndex == indexPath.row && self.selectedBrandRow) {
                backgroundView.backgroundColor = [UIColor whiteColor];
            } else {
                backgroundView.backgroundColor = K_BRAND_CELL_BG_COLOR;
            }
            cell.backgroundView = backgroundView;
            
            WSDictBean *brandBean = [self.brands objectAtIndex:indexPath.row];
            NSString *text = brandBean.name;
            NSString *appending = [self.editedBrandProdsDictionary objectForKey:brandBean.Id];
            if (appending) {
                text = [text stringByAppendingString:appending];
            }
            cell.textLabel.text = text;
            
        } else if (tableView == self.serieTableView) {
            if (self.selectedSerieIndex != -1 && self.selectedSerieIndex == indexPath.row && self.selectedSerieRow) {
                cell.textLabel.textColor = [UIColor orangeColor];
            }
            WSDictBean *serieBean = [self.series objectAtIndex:indexPath.row];
            NSString *text = serieBean.name;
            NSString *appending = [self.editedSerieProdsDicionary objectForKey:serieBean.Id];
            if (appending) {
                text = [text stringByAppendingString:appending];
            }
            cell.textLabel.text = text;
        }
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.brandSerieType == WSBrandType) {
        self.selectedBrandName = @"";
        self.selectedBrandRow = YES;
        self.selectedSerieRow = NO;
        self.selectedBrandIndex  = indexPath.row;
        
        WSDictBean *brand = [self.brands objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            // 加载已添加的产品
            self.selectedBrandName = [NSString stringWithFormat:@"(%@)",brand.name];
            if ([_delegate respondsToSelector:@selector(gridLinkPopupView:didSelectedAllEditedProds: andBrandSerieName:)]) {
                [_delegate gridLinkPopupView:self didSelectedAllEditedProds:YES andBrandSerieName:self.selectedBrandName];
            }
            
        } else if (indexPath.row != 0) {
            
            WSDictBean *brand = [self.brands objectAtIndex:indexPath.row];
            
            /*
            NSMutableArray *currentBrandProds = [self getBrandProdsWith:brand.Id];
             */
            
            NSMutableArray *currentBrandProds  = [NSMutableArray arrayWithArray: [self queryProdsByStoreId:self.storeId params:self.params brandId:brand.Id]]; 
            
            NSString *brandAndSerieName = [NSString stringWithFormat:@"(%@)",brand.name];
            if ([_delegate respondsToSelector:@selector(gridLinkPopupView:didSelecteBrandRowAtIndex:serieIndex:prods: andBrandSerieName:)]) {
                [_delegate gridLinkPopupView:self didSelecteBrandRowAtIndex:indexPath.row serieIndex:-1 prods:currentBrandProds andBrandSerieName:brandAndSerieName];
                // 此视图从window上消失
            }
        }
        
        [self.brandTableView reloadData];
        
    } else {
        if (tableView == self.brandTableView) {
            self.selectedBrandName = @"";
            self.selectedBrandRow = YES;
            self.selectedSerieRow = NO;
            self.selectedBrandIndex  = indexPath.row;
            
            WSDictBean *brand = [self.brands objectAtIndex:indexPath.row];
            if (indexPath.row == 0) {
                // 加载已添加的产品
                self.selectedBrandName = [NSString stringWithFormat:@"(%@)",brand.name];
                if ([_delegate respondsToSelector:@selector(gridLinkPopupView:didSelectedAllEditedProds: andBrandSerieName:)]) {
                    [_delegate gridLinkPopupView:self didSelectedAllEditedProds:YES andBrandSerieName:self.selectedBrandName];
                }
                
            } else if (indexPath.row != 0) {
                WSDictBean *brand = [self.brands objectAtIndex:indexPath.row];
                self.series = [self getSerieDataSourceWith:brand];
                [self.serieTableView reloadData];
                if ([self.allEditedProds count] > 0) {
                    [self reloadSerieTableWith:self.allEditedProds];
                }
                self.selectedBrandName = [NSString stringWithFormat:@"%@",brand.name];
            }
            
            [self.brandTableView reloadData];
        } else if (tableView == self.serieTableView) {
            self.selectedSerieRow = YES;
            self.selectedSerieIndex  = indexPath.row;
            WSDictBean *serieDictBean = [self.series objectAtIndex:indexPath.row];
            NSArray *serieProds = [self getProdsWith:serieDictBean];
            NSString *brandAndSerieName = [NSString stringWithFormat:@"(%@/%@)",self.selectedBrandName,serieDictBean.name];
            if ([_delegate respondsToSelector:@selector(gridLinkPopupView:didSelecteBrandRowAtIndex:serieIndex:prods: andBrandSerieName:)]) {
                
                [_delegate gridLinkPopupView:self didSelecteBrandRowAtIndex:self.selectedBrandIndex serieIndex:self.selectedSerieIndex prods:serieProds andBrandSerieName:brandAndSerieName];
                // 此视图从window上消失
            }
            
            [self.serieTableView reloadData];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return K_TABLE_ROW_HEIGHT;
}

- (void)scrollToRowSelectIndexPath:(NSIndexPath *)indexPath{
    
    [self.brandTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self doSelectBrandAtIndexPath:indexPath];
    
}

- (void)doSelectBrandAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedBrandName = @"";
    self.selectedBrandRow = YES;
    self.selectedSerieRow = NO;
    self.selectedBrandIndex  = indexPath.row;
    
    WSDictBean *brand = [self.brands objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        // 加载已添加的产品
        self.selectedBrandName = [NSString stringWithFormat:@"(%@)",brand.name];
        if ([_delegate respondsToSelector:@selector(gridLinkPopupView:didSelectedAllEditedProds: andBrandSerieName:)]) {
            [_delegate gridLinkPopupView:self didSelectedAllEditedProds:YES andBrandSerieName:self.selectedBrandName];
        }
        
    } else if (indexPath.row != 0) {
        WSDictBean *brand = [self.brands objectAtIndex:indexPath.row];
        self.series = [self getSerieDataSourceWith:brand];
        [self.serieTableView reloadData];
        if ([self.allEditedProds count] > 0) {
            [self reloadSerieTableWith:self.allEditedProds];
        }
        self.selectedBrandName = [NSString stringWithFormat:@"%@",brand.name];
    }
    
    [self.brandTableView reloadData];

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
