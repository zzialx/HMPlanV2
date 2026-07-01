//
//  WSSerieLinkView.m
//  WinSFA
//
//  Created by heju on 15/2/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSerieLinkView.h"
#import "WSBaseDictsDBService.h"

#define K_TABLEVIEW_SECTION 1
#define K_TABLEVEIW_ROW_HEIGTH 44
#define K_SERIELINKVIEW_INIT_HEIGGT 44
#define K_TABLEVIEW_ROW_MAX 6
#define K_LAUNCH_BUTTON_HEIGHT 6
#define K_LAUNCH_BUTTON_WIDHT 12
#define K_LAUCH_BUTTON_RIGHT_MARGIN 20
#define K_BRAND_TABLE_LEFT_MARGIN 0
#define K_SERIE_TABLE_RIGHT_MARGIN 0
#define K_BRAN_SERIE_TABLES_SPACE 0
#define K_CONTENT_BACKGROUND_VIEW_BORDER_WIDTH 4.0f
#define K_CONTENT_BACKGROUND_VIEW_CORNERRADIUS 1.0f
#define K_CONTENT_BACKGROUND_VIEW_LEFT_MARGIN 1

#define K_SELECTED_COLOR [UIColor colorWithRed:208.0f/255 green:208.0f/255 blue:208.0f/255 alpha:0.6]


@interface WSSerieLinkView ()<UIGestureRecognizerDelegate,WSSerieLinkHeadViewDelegate>

@property (nonatomic,strong) WSSerieLinkHeadView *headView;
@property (nonatomic,strong) UIView *contentBackgroundView;
@property (nonatomic,strong) NSString *superProdGridMd5;
@property (nonatomic,strong) __block NSMutableArray *uploadedEditedProds; // 已编辑且上传的产品，用于再次进入此页面的回显
@end


@implementation WSSerieLinkView

// (0,0,width,44)
- (id)initWithFrame:(CGRect)frame  brandFilter:(NSString *)brandFilter superProdGridMd5:(NSString *)md5{
    self = [super initWithFrame:frame];
    if (self) {
        self.superProdGridMd5 = md5;
        self.brandFilter = brandFilter;
        self.backgroundColor = [UIColor whiteColor];
        [self initAllBrandData];
        //[self getUploadedProdsDataFromDb];

        _headView = [[WSSerieLinkHeadView alloc]initWithFrame:self.bounds];
        self.headView.delegate = self;
        [self addSubview:self.headView];
        
        _contentBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(K_CONTENT_BACKGROUND_VIEW_LEFT_MARGIN, K_SERIELINKVIEW_INIT_HEIGGT, frame.size.width - 2*K_CONTENT_BACKGROUND_VIEW_LEFT_MARGIN, 0)];
        self.contentBackgroundView.layer.cornerRadius = K_CONTENT_BACKGROUND_VIEW_BORDER_WIDTH;
        self.contentBackgroundView.layer.borderColor = [K_SELECTED_COLOR CGColor];
        self.contentBackgroundView.layer.borderWidth = K_CONTENT_BACKGROUND_VIEW_CORNERRADIUS;
        [self addSubview:self.contentBackgroundView];

        
        CGFloat contentBgWidth = CGRectGetWidth(self.contentBackgroundView.frame);
        _brandTableView = [[UITableView alloc]initWithFrame:CGRectMake(K_BRAND_TABLE_LEFT_MARGIN, 0, contentBgWidth/2 - K_BRAND_TABLE_LEFT_MARGIN - K_BRAN_SERIE_TABLES_SPACE/2, 0)];
        self.brandTableView.delegate = self;
        self.brandTableView.dataSource = self;
        
        
        self.brandTableView.tableFooterView = [[UIView alloc] init];
        [self.contentBackgroundView addSubview:self.brandTableView];
        
        _serieTableView = [[UITableView alloc]initWithFrame:CGRectMake(contentBgWidth/2 + K_BRAN_SERIE_TABLES_SPACE/2, 0, contentBgWidth/2 - K_SERIE_TABLE_RIGHT_MARGIN - K_BRAN_SERIE_TABLES_SPACE/2, 0)];
        self.serieTableView.delegate = self;
        self.serieTableView.dataSource = self;
        self.serieTableView.tableFooterView = [[UIView alloc] init];
        [self.contentBackgroundView addSubview:self.serieTableView];
        if ([self.uploadedEditedProds count] > 0) {
            [self redisplayWithUploadedEditedProds:self.uploadedEditedProds];
        }
        self.selectedBrandIndex = 0;
    }
    return self;
}

- (void)getUploadedProdsDataFromDb {
    _uploadedEditedProds = [[NSMutableArray alloc] init];
    NSArray *names =  @[@"idx"];
    NSArray *values = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:self.superProdGridMd5], nil];
    NSArray *productObjects =  [[WSProductTable sharedTable] queryWithNames:names ArgumentsValue:values];
    [self.allBrandProds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSProdBean *tmpProd = (WSProdBean *)obj;
        [productObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProductObject *producObject = (WSProductObject *)obj;
            if (tmpProd.Id && producObject.prod_id && [tmpProd.Id isEqualToString:producObject.prod_id]) {
                [self.uploadedEditedProds addObject:tmpProd];
            }
        }];
    }];

}


- (NSString *)filterRepeatString:(NSString *)string {
    NSArray *serieNameArray = [NSArray array];
    if ([string rangeOfString:@"("].location != NSNotFound) {
        serieNameArray = [string componentsSeparatedByString:@"("];
    }
    if ([serieNameArray count] > 0) {
        return [serieNameArray firstObject];
    }
    return string;
}

// 初始化所有品牌数据 并归类
- (void)initAllBrandData {
    _contentViewHidden = YES;
    self.selectedBrandRow = NO;
    self.selectedSerieRow = NO;
    self.allBrandProds = [NSMutableArray array];
    if (self.dataSourceDictionary == nil) {
        _dataSourceDictionary = [NSMutableDictionary dictionary];
    }
    NSArray *brandsId = [self.brandFilter componentsSeparatedByString:@","];
    
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    for (NSInteger i = 0; i < [brandsId  count]; i++) {
        // 品牌的字典项
        NSString *brandId = [brandsId objectAtIndex:i];
        __block NSMutableDictionary *serieDictionary = [NSMutableDictionary dictionary];
        
        NSArray *filterDicts = [service queryDictsWithParentId:brandId];
        
        [filterDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSDictBean *dictBean = (WSDictBean *)obj;
            // 系列的dictBean
            __block NSMutableArray *prodsId = [NSMutableArray array];
            WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
            for (NSInteger i = 0; i < [prodBeanArray.prodArray count]; i++) {
                WSProdBean *prodBean = (WSProdBean *)[prodBeanArray.prodArray objectAtIndex:i];
                if (dictBean.Id && prodBean.pTyp && [dictBean.Id isEqualToString:prodBean.series]) {
                    [prodsId addObject:prodBean.Id];
                    [self.allBrandProds addObject:prodBean];
                }
            }
            
            [serieDictionary setObject:prodsId forKey:dictBean.Id];
            
        }];
        
        [self.dataSourceDictionary setObject:serieDictionary forKey:brandId];
    }
}


// 获取系列的产品
- (NSMutableArray *)getProdsWith:(WSDictBean *)serieDictBean {
    __block NSMutableArray *selectedSerieProds = [NSMutableArray array];
    WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
    if (prodBeanArray.prodArray) {
        [prodBeanArray.prodArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSProdBean *prodBean = (WSProdBean *)obj;
            if (serieDictBean.Id && prodBean.pTyp && ([serieDictBean.Id isEqualToString:prodBean.series])) {
                [selectedSerieProds addObject:prodBean];
            }
        }];
    }
    return selectedSerieProds;
}

// 获取系列集合
- (NSMutableArray *)getSeriesAndNamesWith:(WSDictBean *)brandDictBean {
    _showSeriesName = [[NSMutableArray alloc] init];
    __block NSMutableArray *tmpSeries = [NSMutableArray array];

    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    
    NSArray *filterDicts = [service queryDictsWithParentId:brandDictBean.Id];
    
    [filterDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSDictBean *dictBean = (WSDictBean *)obj;
        if (brandDictBean.Id && dictBean.p && [brandDictBean.Id isEqualToString:dictBean.p]) {
            [tmpSeries addObject:dictBean];
            [self.showSeriesName addObject:dictBean.name];
        }
    }];
    return tmpSeries;
}



// 获取品牌集合
- (NSMutableArray *)getProdBrandsAndNamesWith:(NSString  *)brandIdFilter {
    __block NSMutableArray * tmpProdBrands = [[NSMutableArray alloc] init];
    if (_prodBrandsNameAndId == nil) {
        _prodBrandsNameAndId = [NSMutableArray array];
    }
    if (brandIdFilter) {
        // brandIdFilter:(90654,90655)
        _prodBrands = [NSMutableArray array];
        NSArray *brandsId = [brandIdFilter componentsSeparatedByString:@","];
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        for (NSInteger i = 0; i < [brandsId count]; i++) {
            NSString *currentBrandId = [brandsId objectAtIndex:i];
            
            WSDictBean *dictBean = [service queryDictWithID:currentBrandId];
            
            if (dictBean) {
                [tmpProdBrands addObject:dictBean];
                NSMutableArray *prodBrandArray = [NSMutableArray arrayWithObjects:dictBean.Id,dictBean.name, nil];
                [self.prodBrandsNameAndId addObject:prodBrandArray];
            }
            
        }
    } else {
        NSLog(@"no filter");
    }
    return tmpProdBrands;
}

// 重新加载系列表的数据
- (void)reloadSerieDataWith:(NSMutableArray *)addedProds {
    [self.showSeries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block NSMutableArray *currentSerieAddedProds = [NSMutableArray array];
        WSDictBean *serieDictBean = (WSDictBean *)obj;
        [addedProds enumerateObjectsUsingBlock:^(id prodObj, NSUInteger prodIdx, BOOL *stop) {
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
            NSString *currentSerieName = [self.showSeriesName objectAtIndex:idx];
            currentSerieName = [self filterRepeatString:currentSerieName];
            
            NSString *appendingPart = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[currentSerieAddedProds count],(unsigned long)[serieAllProds count]];
            currentSerieName = [currentSerieName stringByAppendingString:appendingPart];
            [self.showSeriesName replaceObjectAtIndex:idx withObject:currentSerieName];
        }
    }];
}

- (void)redisplayWithUploadedEditedProds:(NSMutableArray *)uploadedEditingProds  {
    if ([uploadedEditingProds count] > 0) {
        self.prodBrands = [self getProdBrandsAndNamesWith:self.brandFilter];
//        NSString *hasBeenAdded = NSLocalizedString(@"所有产品", nil);
        NSString *hasBeenAdded = NSLocalizedString(@"all_selected_product", nil);
        NSMutableArray *prodBrand = [NSMutableArray arrayWithObjects:@"-1",hasBeenAdded, nil];
        [self.prodBrandsNameAndId insertObject:prodBrand atIndex:0];
        [self brandTableReloadDataWithProds:uploadedEditingProds];
    }
}

// 重新展现视图
- (void)redisplayWith:(NSMutableArray *)addedProds {
    
    if (addedProds && [addedProds count] > 0) {
        if (self.allAddedProds == nil   ) {
            _allAddedProds = [[NSMutableArray alloc] init];
        } else {
            [self.allAddedProds removeAllObjects];
        }
        [self.allAddedProds addObjectsFromArray:addedProds];
        // 重新加载系列列表
        [self reloadSerieDataWith:addedProds];
        [self.serieTableView reloadData];
        
        // 重新加载品牌列表
        
        [self brandTableReloadDataWithProds:addedProds];
        
    }
}


- (void)brandTableReloadDataWithProds:(NSArray *)prods {
    _addedProdBrandDictianry = [NSMutableDictionary dictionary];
    [self.dataSourceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *serieDictionray = (NSMutableDictionary *)obj;
        NSMutableArray *addedBrandProds = [NSMutableArray array];
        NSMutableArray *brandAllProds = [NSMutableArray array];
        [serieDictionray enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableArray *prodsId = (NSMutableArray *)obj;
            [brandAllProds addObjectsFromArray:prodsId];
            [prods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WSProdBean *currentAddedProd = (WSProdBean *)obj;
                if ([prodsId containsObject:currentAddedProd.Id]) {
                    [addedBrandProds addObject:currentAddedProd];
                }
            }];
            
        }];
        if ([addedBrandProds count] > 0) {
            NSString *brandPartName = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[addedBrandProds count],(unsigned long)[brandAllProds count]];
            [self.addedProdBrandDictianry setObject:brandPartName forKey:key];
        }
    }];
//    NSString *hasBeenAdded = NSLocalizedString(@"所有产品", nil);
    NSString *hasBeenAdded = NSLocalizedString(@"all_selected_product", nil);
    NSString *brandPartName = [NSString stringWithFormat:@"(%lu/%lu)",(unsigned long)[prods count],(unsigned long)[self.allBrandProds count]];
    hasBeenAdded = [hasBeenAdded stringByAppendingString:brandPartName];
    NSMutableArray *prodBrand = [NSMutableArray arrayWithObjects:@"-1",hasBeenAdded, nil];
    [self.prodBrandsNameAndId replaceObjectAtIndex:0 withObject:prodBrand];
    [self.brandTableView reloadData];

}

#pragma mark UITableViewDelegate/UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return K_TABLEVIEW_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if (tableView == self.brandTableView) {
        rowCount = [self.prodBrandsNameAndId count];
    }else if (tableView == self.serieTableView) {
        rowCount = [self.showSeries count];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (tableView == self.brandTableView) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width,cell.frame.size.height)];
        backgroundView.backgroundColor = K_SELECTED_COLOR;
        cell.backgroundView = backgroundView;
        NSMutableArray *prod = [self.prodBrandsNameAndId objectAtIndex:indexPath.row];
        NSString *appending = [self.addedProdBrandDictianry objectForKey:[prod firstObject]];
        if (appending) {
            cell.textLabel.text =[NSString stringWithFormat:@"%@%@",[prod lastObject],appending];
        } else {
            cell.textLabel.text =[NSString stringWithFormat:@"%@",[prod lastObject] ];
        }
        if (self.selectedBrandIndex == indexPath.row  &&  self.selectedBrandRow) {
            backgroundView.backgroundColor = [UIColor whiteColor];
            cell.backgroundView = backgroundView;
        }
        
    } else if (tableView == self.serieTableView) {
        cell.textLabel.text = [self.showSeriesName objectAtIndex:indexPath.row];
        if (self.selectedCategoryIndex == indexPath.row && self.selectedSerieRow) {
            cell.textLabel.textColor = MAIN_TINT_COLOT;
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame = self.frame;
    if (tableView == self.brandTableView) {
        self.selectedBrandRow = YES;
        if (!(self.selectedBrandIndex == indexPath.row)) {
            self.selectedSerieRow = NO;
        }
        
        [self doSelectBrandAtIndexPath:indexPath];
        
    } else if (tableView == self.serieTableView) {
        self.selectedSerieRow = YES;
        self.selectedCategoryIndex = indexPath.row;
        WSDictBean *selectDictBean = [self.showSeries objectAtIndex:indexPath.row];
        self.m_selectedSerieProds = [self getProdsWith:selectDictBean];
        NSString *selectedSerieName = selectDictBean.name;
        NSMutableArray *branIdAndName = [self.prodBrandsNameAndId objectAtIndex:self.selectedBrandIndex];
        NSString *selectedBrandName = [branIdAndName lastObject];
        NSString *titleText = [NSString stringWithFormat:@"%@/%@",selectedBrandName,selectedSerieName];
        
        self.headView.superViewDisplay = NO;
        [self.headView changeMarkImageViewDown];
        [self.headView changeSelectedNormal];
        [self.headView changeHeadLableText:titleText];
        self.contentBackgroundView.hidden = YES;
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y,frame.size.width,K_SERIELINKVIEW_INIT_HEIGGT)];
        if ([_delegate respondsToSelector:@selector(serieLinkView:didSelectRowAtBrandIndex:andSerieIndex:selectedProds:changedHeight:)]) {
            [_delegate serieLinkView:self didSelectRowAtBrandIndex:self.selectedBrandIndex andSerieIndex:self.selectedCategoryIndex selectedProds:self.m_selectedSerieProds changedHeight:K_SERIELINKVIEW_INIT_HEIGGT];
        }
        // 刷新选中状态
        [self.serieTableView reloadData];
        _contentViewHidden = YES;
    }
}



- (void)serieLinkHeadView:(WSSerieLinkHeadView *)serieLinkHeadView superViewWillDisplay:(BOOL)dispaly {
    _contentViewHidden = dispaly;
    CGFloat serieLinkViewHeight = self.frame.size.height;
    if (_contentViewHidden) {
        if ((_prodBrands == nil ||[self.prodBrands count] == 0 ) && [self.uploadedEditedProds count] == 0) {
            self.prodBrands = [self getProdBrandsAndNamesWith:self.brandFilter];
            // 左侧列表cell展示出所有产品选项
//            NSString *hasBeenAdded = NSLocalizedString(@"所有产品", nil);
            NSString *hasBeenAdded = NSLocalizedString(@"all_selected_product", nil);
            NSMutableArray *prodBrand = [NSMutableArray arrayWithObjects:@"-1",hasBeenAdded, nil];
            [self.prodBrandsNameAndId insertObject:prodBrand atIndex:0];
            
        }
        serieLinkViewHeight = [self.prodBrandsNameAndId count] *K_TABLEVEIW_ROW_HEIGTH + K_SERIELINKVIEW_INIT_HEIGGT;
        CGRect rect = [[UIScreen mainScreen] bounds];
        serieLinkViewHeight = rect.size.height - 64 - 44;
        CGRect contentBackgroundViewFrame = self.contentBackgroundView.frame;
        [self.contentBackgroundView setFrame:CGRectMake(contentBackgroundViewFrame.origin.x, contentBackgroundViewFrame.origin.y, contentBackgroundViewFrame.size.width,serieLinkViewHeight - K_TABLEVEIW_ROW_HEIGTH)];
        
        
        self.contentBackgroundView.hidden = NO;
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, serieLinkViewHeight)];
        
        CGRect brandTableFrame = self.brandTableView.frame;
        CGRect serieTableFrame = self.serieTableView.frame;
        [self.brandTableView setFrame:CGRectMake(brandTableFrame.origin.x, brandTableFrame.origin.y, brandTableFrame.size.width, serieLinkViewHeight - K_TABLEVEIW_ROW_HEIGTH)];
        [self.serieTableView setFrame:CGRectMake(serieTableFrame.origin.x, serieTableFrame.origin.y, serieTableFrame.size.width, serieLinkViewHeight - K_TABLEVEIW_ROW_HEIGTH)];
        [self.brandTableView reloadData];
        if (self.selectedBrandIndex == 0) {
            [self.showSeries removeAllObjects];
            [self.serieTableView reloadData];
        }
        //即将展开
        if ([_delegate respondsToSelector:@selector(willShowserieLinkView:didSelectRowAtBrandIndex:andSerieIndex:changedHeight:)]) {
            [_delegate willShowserieLinkView:self didSelectRowAtBrandIndex:self.selectedBrandIndex andSerieIndex:self.selectedCategoryIndex changedHeight:serieLinkViewHeight];
            
        }
        
    } else {

        serieLinkViewHeight = K_TABLEVEIW_ROW_HEIGTH;
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, serieLinkViewHeight)];
        self.contentBackgroundView.hidden = YES;
        if ([_delegate respondsToSelector:@selector(serieLinkView:didSelectRowAtBrandIndex:andSerieIndex:selectedProds:changedHeight:)]) {
            [_delegate serieLinkView:self didSelectRowAtBrandIndex:self.selectedBrandIndex andSerieIndex:self.selectedCategoryIndex selectedProds:self.m_selectedSerieProds changedHeight:K_SERIELINKVIEW_INIT_HEIGGT];
        }
    }
    _contentViewHidden = !_contentViewHidden;
    
}

- (void)scrollToRowSelectIndexPath:(NSIndexPath *)indexPath{
    
    [self.brandTableView deselectRowAtIndexPath:indexPath animated:NO];

    [self doSelectBrandAtIndexPath:indexPath];
    
}

- (void)doSelectBrandAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = self.frame;
    self.selectedBrandIndex = indexPath.row;
    // indexPath.row == 0为 已添加所有产品的选项
    if (indexPath.row == 0) {
        NSArray *brandNameAndId = [self.prodBrandsNameAndId objectAtIndex:indexPath.row];
        [self.headView changeHeadLableText:[brandNameAndId lastObject]];
        self.contentBackgroundView.hidden = YES;
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y,frame.size.width,K_SERIELINKVIEW_INIT_HEIGGT)];
        if ([_delegate respondsToSelector:@selector(serieLinkView:didSelectRowAtBrandIndex:andSerieIndex:selectedProds:changedHeight:)]) {
            [_delegate serieLinkView:self didSelectRowAtBrandIndex:indexPath.row andSerieIndex:self.selectedBrandIndex selectedProds:nil changedHeight:K_SERIELINKVIEW_INIT_HEIGGT];
        }
        
    } else {
        WSDictBean *selectDictBean = [self.prodBrands objectAtIndex:indexPath.row - 1];
        self.showSeries = [self getSeriesAndNamesWith:selectDictBean];
        if ([self.allAddedProds count] > 0 || [self.uploadedEditedProds count] > 0) {
            [self reloadSerieDataWith:self.allAddedProds];
        }
        [self.serieTableView reloadData];
    }
    // 用于刷新选中状态
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
