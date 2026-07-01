//
//  WSRecipeController.m
//  WinSFA
//
//  Created by huzepei on 16/8/1.
//  Copyright © 2016年 WinChannel. All rights reserved.

#import "WSRecipeController.h"
#import "WSRichMediaOptionBar.h"
#import "PureLayout.h"
#import "WSRichMediaItemCell.h"
#import "UIView+Extension.h"
#import "WSBaseDictsTable.h"
#import "WSRichMediaTable.h"
#import "WSRichModel.h"
#import "WSRichItemModel.h"
#import "WSShowRichMediaItemCell.h"
#import "WSRichMediaTemplateTable.h"
#define Categary @"Categary"
#define Product @"Product"
#define richMediaAddItem @"richMediaAddItem"
#define BarHeight 40
#define PaddingToRight 15
#define BarCount (_richModelFilterArr.count - 1)
//#define BarCount 3
#define BarWidthPaddingToRight (135)
#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define isKindOfString [_richModelFilterArr[0] isKindOfClass:[NSString class]]


//#define k_UISCREN_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : self.view.frame.size.height)
//#define k_UISCREN_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : self.view.frame.size.width)
#define k_UISCREN_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 1024)
#define k_UISCREN_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 768)

@interface WSRecipeController ()<UICollectionViewDataSource, UICollectionViewDelegate,WSRichMediaOptionBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *barShrinkView;
@property (nonatomic,strong) UIView *BarView;
//shrink
@property (nonatomic,strong)UIView *shrinkView;
@property (nonatomic,strong)UIButton *shrinkBtn;
@property (nonatomic,strong) UICollectionView * contentView;
//model  显示bar选项数组
@property (nonatomic,strong)NSMutableArray * richModelFilterArr;
//当前只有一行Bar,记录Bar上面点击Item时,回传的ID
@property (nonatomic,strong) NSMutableArray * richKindStringIDs;
// 数据源- 变化很大
@property (nonatomic,strong) NSMutableArray * richItemModelArr;
// 所有的items,固定不变
@property (nonatomic,strong) NSMutableArray * allItems;
//前缀数组
@property (nonatomic,strong) NSMutableArray * prefixArray;

@property(nonatomic,copy) NSString * currentSelectIdString;

@property(nonatomic,strong ) UIButton *shrinkCategary;

@property(nonatomic,strong ) UIButton *shrinkProduct;

@property(nonatomic,strong )UIButton * bgButton;

@property(nonatomic,strong)UIWindow  *window;

@property(nonatomic,strong)UITableView   *dropTableView;

@property(nonatomic,strong)NSArray   *dropTableViewDatasource;

@property(nonatomic,copy) NSString * prodFilterCondition;// 筛选的条件

@property(nonatomic,strong) WSFilterItem * selectItem; // 产品品类，产品
@property(nonatomic,copy) NSString * tableViewType; // tableview 的类型-产品品类，产品

@property(nonatomic,strong) NSArray * unSelectProdArray; // 取消 品类，产品 收索之前的数据
@end

@implementation WSRecipeController

#pragma - view cycle

- (void)viewDidLoad {
    
    [self loadData];
    [self initViews];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviceDemoDelete:) name:@"deleteDemoList" object:nil];
    
    [super viewDidLoad];
}

-(void)initViews
{
    if (_richModelFilterArr.count == 0) return;
    
     ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    
    _BarView = [[UIView alloc] init];
    _BarView.layer.cornerRadius = 10.0;
    _BarView.layer.masksToBounds = YES;
    _BarView.clipsToBounds = YES;
    [self.view addSubview:_BarView];
    
    if (isKindOfString) {
        
        [_BarView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [_BarView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [_BarView autoSetDimensionsToSize:CGSizeMake(self.view.width - 15, BarHeight)];
        
        WSRichMediaOptionBar *moBar =  [[WSRichMediaOptionBar alloc] init];
        moBar.delagate = self;
        moBar.kindStringIDs = _richKindStringIDs;
        moBar.dataArray = _richModelFilterArr;
        [_BarView addSubview:moBar];
        
        [moBar autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [moBar autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [moBar autoSetDimensionsToSize:CGSizeMake(k_UISCREN_Width - BarWidthPaddingToRight - 20, BarHeight)];
        
//        [moBar autoPinEdgesToSuperviewEdges];
        
//        [self.contentView setFrame:CGRectMake(0, BarHeight, k_UISCREN_Width - BarWidthPaddingToRight, self.view.height - BarHeight)];
        
        [self.contentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_BarView withOffset:10.0];
        [self.contentView autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeTop];
        
    }else{
        
        _BarView.frame = CGRectMake(0, 0, k_UISCREN_Width - 15, BarCount * BarHeight);
        for (int i = 0; i < BarCount; i++) {
            
            //数据乱套了,richModel里面可能是String...
            WSRichModel *richModel = _richModelFilterArr[i];
            if ([richModel isKindOfClass:[NSString class]]) {
                break;
            }
            WSRichMediaOptionBar *moBar =  [[WSRichMediaOptionBar alloc] init];
            
            moBar.delagate = self;
            
            moBar.groupHeaderName = richModel.name;
            moBar.groupHeaderID = richModel._id;
            moBar.dataArray = richModel.filterItems;
            [_BarView addSubview:moBar];
            
            if (_isNotEdit) {
                moBar.frame = CGRectMake(0, i * BarHeight, k_UISCREN_Width, BarHeight);
            }else{
                moBar.frame = CGRectMake(0, i * BarHeight, k_UISCREN_Width - BarWidthPaddingToRight - 20, BarHeight);
            }
        }
        
        NSLog(@"k_UISCREN_Width %d   k_UISCREN_Width %d",k_UISCREN_Width,k_UISCREN_Width);
        
        [self setUpShrinkView];
        
        [self.contentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_shrinkView withOffset:10.0];
        [self.contentView autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeTop];
    }
}

-(void)reviceDemoDelete:(NSNotification*)notification
{
    NSArray *arr = [notification object];
    _addedArr = [arr mutableCopy];
}

-(void)setUpShrinkView
{
    _shrinkView = [[UIView alloc] init];
//    _shrinkView.backgroundColor = WSColor(247, 248, 247);
     _shrinkView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_shrinkView];
    
    if (isKindOfString) {
        _shrinkView.frame = CGRectMake(0, BarHeight, k_UISCREN_Width - BarWidthPaddingToRight - 15, BarHeight);
    }else{
        
        if (_isNotEdit) {
            
            _shrinkView.frame = CGRectMake(0, BarCount * BarHeight, k_UISCREN_Width, BarHeight);
            
        }else{
            
            _shrinkView.frame = CGRectMake(0, BarCount * BarHeight, k_UISCREN_Width - BarWidthPaddingToRight -20, BarHeight);
        }
    }
    
    UIButton *shrinkTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    [shrinkTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shrinkTitle.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [shrinkTitle setTitle:@"产品" forState:UIControlStateNormal];
    [shrinkTitle setTitleColor:WSColor(237, 90, 43) forState:UIControlStateSelected];
    [shrinkTitle setTitleColor:WSColor(127, 127, 127) forState:UIControlStateNormal];
    [_shrinkView addSubview:shrinkTitle];
    ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    [shrinkTitle autoSetDimension:ALDimensionWidth toSize:90];
    [shrinkTitle autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeRight];
    
    UIButton *shrinkCategary = [[UIButton alloc] init];
    [shrinkCategary setTitle:@"请选择类别" forState:UIControlStateNormal];
    [shrinkCategary setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    shrinkCategary.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [shrinkCategary addTarget:self action:@selector(selectCategary:) forControlEvents:UIControlEventTouchUpInside];
    self.shrinkCategary = shrinkCategary;
//    shrinkCategary.text = @"请选择类别";
//    shrinkCategary.font = [UIFont systemFontOfSize:16.0];
//    shrinkCategary.textColor = WSColor(127, 127, 127);
    [_shrinkView addSubview:shrinkCategary];
    [shrinkCategary autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:shrinkTitle withOffset:20];
    [shrinkCategary autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_shrinkView];
    [shrinkCategary autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [shrinkCategary autoSetDimension:ALDimensionWidth toSize:90 relation:NSLayoutRelationGreaterThanOrEqual];
    
    UIButton *shrinkProduct = [[UIButton alloc] init];
    [shrinkProduct setTitle:@"pls_select_product" forState:UIControlStateNormal];
    [shrinkProduct setTitleColor:WSColor(185, 185, 185) forState:UIControlStateNormal];
    shrinkProduct.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [shrinkProduct addTarget:self action:@selector(selectProduct:) forControlEvents:UIControlEventTouchUpInside];
    shrinkProduct.enabled = NO;
    self.shrinkProduct = shrinkProduct;
//    shrinkProduct.text = @"pls_select_product";
//    shrinkProduct.font = [UIFont systemFontOfSize:16.0];
//    shrinkProduct.textColor = WSColor(127, 127, 127);
    [_shrinkView addSubview:shrinkProduct];
    [shrinkProduct autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:shrinkCategary withOffset:20];
    [shrinkProduct autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_shrinkView];
    [shrinkProduct autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [shrinkProduct autoSetDimension:ALDimensionWidth toSize:90 relation:NSLayoutRelationGreaterThanOrEqual];
    
    _shrinkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shrinkBtn setImage:[UIImage imageNamed:@"rich_arrow"] forState:UIControlStateNormal];
    [_shrinkBtn addTarget:self action:@selector(shrink:) forControlEvents:UIControlEventTouchUpInside];
    [_shrinkBtn setAdjustsImageWhenHighlighted:NO];
    [_shrinkView addSubview:_shrinkBtn];
    [_shrinkBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_shrinkBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_shrinkView withOffset:-20];
    
    
    UIWindow  *window = [UIApplication sharedApplication].keyWindow;
    self.window = window;
    self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgButton addTarget:self action:@selector(removebgButton) forControlEvents:UIControlEventTouchUpInside];
//    self.bgButton.backgroundColor = [UIColor redColor];
    [window addSubview:self.bgButton];
    self.bgButton.alpha = 0;
    [self.bgButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.dropTableView = [[UITableView alloc]init];
    self.dropTableView.layer.cornerRadius = 8;
    self.dropTableView.layer.borderColor = MAIN_TINT_COLOT.CGColor;
    self.dropTableView.layer.borderWidth = 0.6;
    self.dropTableView.delegate = self;
    self.dropTableView.dataSource = self;
 
    
}

-(void)selectCategary:(UIButton *)sender{
    self.bgButton.alpha = 1;
    [self.window addSubview:self.dropTableView];
    CGRect rect = [self.shrinkCategary convertRect:self.shrinkCategary.bounds toView:self.window];
  
    WSRichModel * proModel = [_richModelFilterArr lastObject]
    ;
    self.prodFilterCondition = proModel._id;
    self.dropTableViewDatasource = proModel.filterItems;
    float height = 0;
    if (self.dropTableViewDatasource.count > 6) {
        height = 7 * 44 ;
    }else{
        height = (self.dropTableViewDatasource.count + 1) * 44;
    }
    
    self.dropTableView.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width * 2, height);
    self.tableViewType = Categary;
    [self.dropTableView reloadData];
    NSLog(@"请选择类别");
}

-(void)selectProduct:(UIButton *)sender{
    self.bgButton.alpha = 1;
    [self.window addSubview:self.dropTableView];
    CGRect rect = [self.shrinkProduct convertRect:self.shrinkProduct.bounds toView:self.window];
    
    NSString * spl = [NSString stringWithFormat:@"select * from base_dicts where pid = '%@'",self.selectItem._id];
    if ([self.tableViewType isEqualToString:Categary]) {
        self.dropTableViewDatasource = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:spl andClassName:@"WSFilterItem"];
    }
    float height = 0;
    if (self.dropTableViewDatasource.count > 6) {
        height = 7 * 44 ;
    }else{
        height = (self.dropTableViewDatasource.count + 1) * 44;
    }
    self.dropTableView.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width * 2, height);
    self.tableViewType = Product;
    [self.dropTableView reloadData];

    NSLog(@"pls_select_product");
}

-(void)removebgButton{
    self.bgButton.alpha = 0;
    [self.dropTableView removeFromSuperview];

}

#pragma mark - 加载数据
-(void)loadData
{
    _richModelFilterArr = [NSMutableArray array];
    _richKindStringIDs = [NSMutableArray array];
    _prefixArray = [NSMutableArray array];
    _addedArr = [NSMutableArray array];

    
//    NSString *sql = [NSString stringWithFormat:@"SELECT dict2._id,dict2.name,dict2.pid  FROM base_dicts AS dict1, base_dicts AS dict2 WHERE dict1.typ ='fumeiti_label' AND dict1.name = '%@' AND dict1.levelCode = 1 AND dict1._id = dict2.pid;",_vcName];
//    NSMutableArray * arr = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichModel"];
    
    
    NSString *sql = [NSString stringWithFormat:@"SELECT dict2._id,dict2.name,dict2.pid  FROM base_dicts AS dict1, base_dicts AS dict2 WHERE dict1.typ ='fumeiti_label' AND dict1.name = '%@' AND dict1.levelCode = 1 AND dict1._id = dict2.pid ORDER BY dict2.SEQ;",_vcName];
    NSMutableArray * arr = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSRichModel"];
    
    NSString *proStr = @"";
    for (WSRichModel * rm in arr) {
        if ([rm.name isEqualToString:@"产品"]) {
            proStr = [NSString stringWithFormat:@"%@:000",rm._id];
            continue;
        }
        NSString *rm_id = [NSString stringWithFormat:@"%@:000",rm._id];
        [_prefixArray addObject:rm_id];
    }
    if (![proStr isEqualToString:@""]) {
        [_prefixArray addObject:proStr];
    }
    
    NSLog(@"prefixArray%@",_prefixArray);
    
    WSRichModel *proRichModel;
    for (int i = 0; i<arr.count; i++) {
        WSRichModel *richModel = arr[i];
    
         NSString *sql2 = [NSString stringWithFormat:@"SELECT dict2._id,dict2.name,dict2.pid, dict2.SEQ FROM base_dicts AS dict1, base_dicts AS dict2 WHERE dict1._id = '%@' AND dict1.typ = 'fumeiti_label' AND dict1.levelCode = 2 AND dict1._id = dict2.pid ORDER BY dict2.SEQ;",richModel._id];
        NSMutableArray * tempArr = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql2 andClassName:@"WSFilterItem"];
        
        if (tempArr.count == 0) {
            [_richModelFilterArr addObject:richModel.name];
            [_richKindStringIDs addObject:richModel._id];
            
        }else{
            
            if ([richModel.name isEqualToString:@"产品"]) {
                proRichModel = richModel;
                proRichModel.filterItems = tempArr;
                continue;
            }
            
            richModel.filterItems = tempArr;
            [_richModelFilterArr addObject:richModel];
        }
    }
    
    if (proRichModel) {
        [_richModelFilterArr addObject:proRichModel];
    }
    
    
    //所有数据
    NSString *sql2 = [NSString stringWithFormat:@"SELECT spe.ID, spe.speid, spe.cod,spe.name ,spe.typ, spe.memo, spe.img_url, spe.h5_url, spe.levelCode, spe.h5_add, spe.img_add , spe.share_url , spe.isread ,spe.type_,spe.fenleiId FROM  base_dicts AS dict, spe_richMedia AS spe WHERE dict.name = '%@' AND  dict.typ = 'fumeiti_label' AND dict._id = spe.typ AND spe.type_ = '1' ORDER BY spe.seq;",_vcName];

    
    
    _richItemModelArr = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql2 andClassName:@"WSRichItemModel"];
    
    _allItems = [_richItemModelArr copy];
}

#pragma mark - event
-(void)shrink:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [UIView animateWithDuration:0.3 animations:^{
             _shrinkBtn.transform = CGAffineTransformMakeRotation(M_PI);
            
            if (!isKindOfString) {
                _BarView.height = 0;
                _shrinkView.y = 0;
                self.contentView.y = BarHeight;
            }
            
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _shrinkBtn.transform = CGAffineTransformMakeRotation(0);
            if (isKindOfString) {
                _BarView.height = BarHeight;
                _shrinkView.y = BarHeight;
                self.contentView.y = 2 * BarHeight;
            }else{
                _BarView.height = BarCount * BarHeight;
                _shrinkView.y = BarCount * BarHeight;
                self.contentView.y = (BarCount + 1) * BarHeight;
            }
            
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -setter getter
-(void)setVcName:(NSString *)vcName
{
    _vcName = vcName;
    self.filterName = vcName;
}

-(UICollectionView *)contentView
{
    if (!_contentView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        if (self.isNotEdit) {
            layout.minimumLineSpacing = 10;
            layout.minimumInteritemSpacing = 10;

        }else{
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
        }
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentView.showsHorizontalScrollIndicator = NO;
        if (self.isNotEdit) {
            _contentView.backgroundColor = WSColor(246,246,246);

        }else{
            _contentView.backgroundColor = [UIColor whiteColor];

        }
        _contentView.dataSource = self;
        _contentView.delegate = self;
        [self.view addSubview:_contentView];
        if (self.isNotEdit) {
            [_contentView registerClass:[WSShowRichMediaItemCell class] forCellWithReuseIdentifier:@"WSRichMediaItemCell"];
        }else{
            [_contentView registerNib:[UINib nibWithNibName:@"WSRichMediaItemCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([WSRichMediaItemCell class])];
        }
        
    }
    return _contentView;
}
#pragma moBarDelagate
- (void)WSRichMediaOptionBarClickWithStringID:(NSString *)str
{
    self.currentSelectIdString  = str;
    if (isKindOfString) {
        NSMutableArray *itemArray = [NSMutableArray array];
        
        if ([str isEqualToString:@"000"]) {
            [itemArray addObjectsFromArray:_allItems];
        }
        for (int i = 0; i < _allItems.count; i++) {
            WSRichItemModel *item = _allItems[i];
            NSArray *memoItem = [item.memo componentsSeparatedByString:@","];
            for (int j = 0; j < memoItem.count; j++) {
                NSString *str2 = memoItem[j];
                if ([str2 isEqualToString:str]) {
                    [itemArray addObject:item];
                }
            }
        }
        _richItemModelArr = itemArray;
        
        [self.contentView reloadData];
        
    }else{
        
        //1.如果Str的前缀相同就替换
        NSArray *prefixArr = [str componentsSeparatedByString:@":"];
        NSString *prefixStr =  prefixArr[0];
        
        for (int i = 0; i<_prefixArray.count - 1; i++) {
            NSArray *prefixArrTemp = [_prefixArray[i] componentsSeparatedByString:@":"];
            if ([prefixStr isEqualToString:prefixArrTemp[0]]) {
                _prefixArray[i] = str;
            }
        }
        
        NSLog(@"_prefixArray%@",_prefixArray);
        
        NSMutableArray *dateMutablearray = [@[] mutableCopy];
        
        int j = 0;
        BOOL a = YES; //记录当前是否有选项
        
        //2.遍历前缀数组,如果是000则不查找数据,不是的话就在当前模块的筛选项中进行搜索.
        for (int k = 0;k < _prefixArray.count - 1;k++) {
            
             NSArray *parrTemp = [_prefixArray[k] componentsSeparatedByString:@":"];
            
            // 如果是000,显示该系列下面的所有数据.
            if ([parrTemp[1] isEqualToString:@"000"]){
                
                j++;
                
                
            }else{
                
                NSMutableArray *itemArray = [NSMutableArray array];
                
                //当前条件下的选项.
                for (int i = 0; i < _allItems.count; i++) {
                    WSRichItemModel *item = _allItems[i];
                    NSArray *memoItem = [item.memo componentsSeparatedByString:@","];
                    for (int j = 0; j < memoItem.count; j++) {
                        NSString *str2 = memoItem[j];
                        if ([str2 isEqualToString:_prefixArray[k]]) {
                            [itemArray addObject:item];
                        }
                    }
                }

                
                if (itemArray.count == 0) {
                    a = NO;
                }
                
                if (dateMutablearray.count > 0) {
                    
                    NSMutableArray *tempArray = [@[] mutableCopy];
                    for (int i = 0; i < itemArray.count ; i++) {
                        WSRichItemModel *item = itemArray[i];
                        for (int j = 0; j < dateMutablearray.count; j++) {
                            WSRichItemModel *item2 = dateMutablearray[j];
                            if([item.ID isEqualToString:item2.ID]){
                                [tempArray addObject:item2];
                            }
                        }
                    }
                    
                    dateMutablearray = tempArray;
                    
                    if (dateMutablearray.count == 0) {
                        a = NO;
                    }
                    
                }
                //dateMutablearray 去重之后的数组
                if (dateMutablearray.count == 0 && a == YES) { //可能是第一次进来,还有可能是前面筛选结果为0
                    dateMutablearray = itemArray;
                }
                
            }
            
            if (j == _prefixArray.count - 1) { //显示全部数据
                
                dateMutablearray = _allItems;
                
            }
            
        }
        
        _richItemModelArr = dateMutablearray;
        
        [self.contentView reloadData];
    }
}
#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _richItemModelArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isNotEdit) {
        WSShowRichMediaItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSRichMediaItemCell" forIndexPath:indexPath];
        cell.model = _richItemModelArr[indexPath.item];
        return cell;
        
    }else{ // 有加号的
        
        WSRichMediaItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WSRichMediaItemCell class]) forIndexPath:indexPath];
        
        cell.cellIndexPath = indexPath;
        
        WSRichItemModel * itemModel = _richItemModelArr[indexPath.item];
        
        cell.itemModel = itemModel;
        
        cell.isNotEdit = _isNotEdit;
        
        __weak typeof(self) weakSelf = self;
        
        cell.clickPlusBtn = ^(NSIndexPath *indexPath){
             // 如果数据库中有，则提示只能添加一次
          _addedArr =  [[WSRichMediaTemplateTable sharedTable]queryTableForRichItem:self.storeId andVisitTime:self.visitData].mutableCopy;

            //同一个富媒体只能添加一次.
            for (WSRichItemModel * richModel in _addedArr) {
                
                if ([itemModel.speid isEqualToString:richModel.speid]) {
                    NSString *title = NSLocalizedString(@"相同资料只能添加一次", nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    return;
                }
            }
            [_addedArr addObject:itemModel];
            
            WSRichMediaItemCell *cell2 = (WSRichMediaItemCell *)[weakSelf.contentView cellForItemAtIndexPath:indexPath];
            CGRect rc = [cell2 convertRect:cell2.plusBtn.frame toView:self.view];
            
            __block UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:[UIImage imageForName:@"richMedia_add.png"] forState:UIControlStateNormal];
            btn.frame = rc;
            
            [self.view addSubview:btn];
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CGPoint point = CGPointMake(self.view.width - 50, -30);
                btn.center = point;
                
            } completion:^(BOOL finished) {
                
                [btn removeFromSuperview];
            }];
            
            NSNotification * notice = [NSNotification notificationWithName:richMediaAddItem object:_richItemModelArr[indexPath.item] userInfo:@{@"VCName":self}];
            
            [[NSNotificationCenter defaultCenter] postNotification:notice];
            
        };
        return cell;

    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isNotEdit) {
        return CGSizeMake((self.view.width - 50)/4, 250);

    }else{
        return CGSizeMake(self.view.width/5, 200);

    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSRichItemModel *itemModel = _richItemModelArr[indexPath.item];
    [self itemClickCallH5WithItemModel:itemModel];
//    
//    if (!itemModel.h5_add || [itemModel.h5_add isEqualToString:@""] || [itemModel.h5_add containsString:@"."]) {
//        
//        BlockAlertView *alertView = [BlockAlertView alertWithTitle:@"警告" message:@"该资源暂未下载"];
//        [alertView setCancelButtonWithTitle:@"好的" block:nil];
//        [alertView show];
//        
//    }else{
//        
//        if ([self.delegate respondsToSelector:@selector(itemClickCallH5:itemModel:)]) {
//            [self.delegate itemClickCallH5:self itemModel:itemModel];
//        }
//    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dropTableViewDatasource.count + 1;
//    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserID = @"UITableViewCellReuserID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
    }
    if (indexPath.row == self.dropTableViewDatasource.count) {
        cell.textLabel.text = @"cancel_label";
        cell.backgroundColor = WSColor(127, 127, 127);
    }else{
        
        WSFilterItem * item = self.dropTableViewDatasource[indexPath.row];
        cell.textLabel.text =item.name;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.unSelectProdArray) {
        self.unSelectProdArray = _richItemModelArr;
    }
    
    if (indexPath.row == self.dropTableViewDatasource.count) {
        if ([self.tableViewType isEqualToString:Categary]) {
            [self.shrinkCategary setTitle:@"请选择类别" forState:UIControlStateNormal];
            [self.shrinkProduct setTitle:@"pls_select_product" forState:UIControlStateNormal];
            [self.shrinkProduct setTitleColor:WSColor(185, 185, 185) forState:UIControlStateNormal];
            self.shrinkProduct.enabled = NO;
            self.prodFilterCondition = @"";
        }else{
            [self.shrinkProduct setTitle:@"pls_select_product" forState:UIControlStateNormal];
            self.prodFilterCondition = [[self.prodFilterCondition componentsSeparatedByString:@"_"] firstObject];
            
        }

    }else{
       
        self.shrinkProduct.enabled = YES;
        [self.shrinkProduct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // 选中时应该做两件事情----记录下级数据的筛选条件，记录本次富媒体展示数据的筛选条件并刷新
        self.selectItem = self.dropTableViewDatasource[indexPath.row];
        if ([self.tableViewType isEqualToString:Categary]) {
            [self.shrinkCategary setTitle:self.selectItem.name forState:UIControlStateNormal];
            self.prodFilterCondition =  [[self.prodFilterCondition componentsSeparatedByString:@":"] firstObject];
            self.prodFilterCondition =  [self.prodFilterCondition stringByAppendingString:[NSString stringWithFormat:@":%@",self.selectItem._id]];
            [self.shrinkProduct setTitle:@"pls_select_product" forState:UIControlStateNormal];
        }else{
            [self.shrinkProduct setTitle:self.selectItem.name  forState:UIControlStateNormal];
            self.prodFilterCondition = [[self.prodFilterCondition componentsSeparatedByString:@"_"] firstObject];
            self.prodFilterCondition =  [self.prodFilterCondition stringByAppendingString:[NSString stringWithFormat:@"_%@",self.selectItem._id]];
        }
        
    }
    [self reloadDataByProdFilterCondition];
    [self removebgButton];

}
-(void)reloadDataByProdFilterCondition{
    
    NSArray * arr = [self.prodFilterCondition componentsSeparatedByString:@":"];
    if (arr.count > 1) {
        NSPredicate  *
        pred = [NSPredicate predicateWithFormat:@"self.memo contains[cd] %@ ",self.prodFilterCondition];
        _richItemModelArr = [self.allItems filteredArrayUsingPredicate:pred].mutableCopy;
        
        NSSortDescriptor *carNameDesc = [NSSortDescriptor sortDescriptorWithKey:@"speid" ascending:YES];
        NSArray *descriptorArray = [NSArray arrayWithObjects:carNameDesc, nil];
        _richItemModelArr = [[_richItemModelArr sortedArrayUsingDescriptors:descriptorArray] copy];
        
    }else{
        _richItemModelArr = self.unSelectProdArray.mutableCopy;
        self.unSelectProdArray = nil;
    }
    NSLog(@"%@",self.prodFilterCondition);
    [self.contentView reloadData];
    
}
-(void)reloadData{
    [super reloadData];
    self.allItems = self.allItemModel.mutableCopy;
    if (self.currentSelectIdString && self.currentSelectIdString.length > 0) {
        [self WSRichMediaOptionBarClickWithStringID:self.currentSelectIdString];

    }else{
        _richItemModelArr = self.allItems;
        [self.contentView reloadData];
    }

}
-(void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
