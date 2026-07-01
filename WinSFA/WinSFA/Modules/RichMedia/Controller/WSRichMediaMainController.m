//
//  WSMediaMainController.m
//  WinSFA
//
//  Created by huzepei on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaMainController.h"
#import "PureLayout.h"
#import "WSDock.h"
#import "WSRecipeController.h"
#import "WSRichDemoListController.h"
#import "WSTemplateController.h"
#import "WSRichItemModel.h"

#import "WSRichMediaTemplateTable.h"
#import "WSBaseAcvtDBService.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "QRCodeGenerator.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"

#import "WSSearchTableViewCell.h"
#import "WSRichMediaTable.h"
#import "WSShowH5ViewController.h"
#import "WSRichMediaTemplate.h"
#import "WSSearchBar.h"
#import "WSAcvtModel.h"
#import "WSBaseDictsDBService.h"
#import "WSDictBean.h"
#define richMediaAddItem @"richMediaAddItem"
#define STORESTITLEHEIGHT 44
#define PROGRESSVIEW STORESTITLEHEIGHT
#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define POPERWIDTH 336
#define POPERHEIGHT 561

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]



@interface WSRichMediaMainController ()<WSDockDelegate,WSRecipeControllerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

/** dock和contentView的父View */
@property (nonatomic,strong) UIView *containerView;

@property (nonatomic, strong) WSDock *dock;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *demoBtn;
@property (nonatomic, strong) UILabel *visitNameLabel;
@property (nonatomic, strong) UILabel *visitDataLabel;

@property(nonatomic,strong) UIView *bgGroundView;

@property(nonatomic,strong) UITableView *tabview;

@property(nonatomic,strong) WSSearchBar *searchBar;

@property(nonatomic,strong) NSMutableArray *datasource;

@property(nonatomic,strong) NSArray *searArray;


@property (nonatomic, strong) UIPopoverController *pop;

@property (nonatomic, strong) NSMutableArray *demoListArray;
@property(nonatomic,weak) WSRMShowBaseController *currentViewController; // 选择dock时的控制器

// 我的收藏 --> 数组（key:模板名称  value:演示列表）
@property (nonatomic, strong) NSMutableArray *templateArray;

@property (nonatomic,strong) WSTemplateController * temp;
@property (nonatomic , strong) NSArray * richMediaDictArray ; // 富媒体分类字典项

//
//@property (nonatomic, strong) UIButton *closeBtn;
//
//@property (nonatomic ,  strong)UIView * QRView;
//
//@property(nonatomic,strong) UIButton * shareButton;
//
//@property(nonatomic,strong) UIView *jingQingQiDai;
//
//@property(nonatomic,strong) UIImageView * imageview;

//@property(nonatomic,assign) BOOL isShow;
//@property(nonatomic,strong) WSRichItemModel *richItem;
@property(nonatomic,strong)UIWindow *windows;
@end

@implementation WSRichMediaMainController

-(NSMutableArray *)datasource{
    if (_datasource == nil) {
        _datasource = [[NSMutableArray alloc]init];
    }
    return _datasource;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeWindow];
}

#pragma mark - view cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDemoListDataFinshed:) name:@"demoList" object:nil];
    
    if (!self.visitData) {
        self.visitData = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    }
    
    __weak typeof(self) weakSelf = self;
    
    _uploadDemolist = ^(){
        
        //上传演示列表

        WSAcvtBean *acvtBean = [[[WSBaseAcvtDBService alloc]init] queryAcvtWithAcvtCode:@"yanshiliebiao"];
        
        if (acvtBean.qsts.count > 1) {
            WSAcvtBean_qst *acvt_qst = acvtBean.qsts[0];
            WSAcvtBean_qst *acvt_qst2 = acvtBean.qsts[1];
            
            //拜访日期key
            NSString *visitDataKey ;
            //素材IDkey
            NSString *itemIDKey ;
            
            if ([acvt_qst.qstCod isEqualToString:@"baifangriqi"]) {
                
                visitDataKey = [NSString stringWithFormat:@"%@%@",acvt_qst.qstType,acvt_qst.acvtQstId];
                itemIDKey = [NSString stringWithFormat:@"%@%@",acvt_qst2.qstType,acvt_qst2.acvtQstId];
                
            }else{
                visitDataKey = [NSString stringWithFormat:@"%@%@",acvt_qst2.qstType,acvt_qst2.acvtQstId];
                itemIDKey = [NSString stringWithFormat:@"%@%@",acvt_qst.qstType,acvt_qst.acvtQstId];
            }
          
            // demolist用,分隔
            NSString *itemID = [NSString string];
            for (int i = 0; i < weakSelf.demoListArray.count; i++) {
                WSRichItemModel *itemModel = weakSelf.demoListArray[i];
                
                if (i == 0) {
                    itemID = itemModel.speid;
                }else{
                    itemID = [itemID stringByAppendingFormat:@",%@",itemModel.speid];
                }
            }
            
            if (itemID.length == 0) return;
            NSMutableDictionary *postDataDict = [NSMutableDictionary dictionary];
            NSMutableDictionary *jsonDataDict = [NSMutableDictionary dictionary];
            
            [jsonDataDict setObject:weakSelf.visitData forKey:visitDataKey];
            [jsonDataDict setObject:itemID forKey:itemIDKey];
            
            NSString *jsonData = [jsonDataDict JSONString];
            
            [postDataDict setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:APPDATA_BIZDATE];
            [postDataDict setObject:weakSelf.m_currentStore.Id forKey:@"storeid"];
            [postDataDict setObject:jsonData forKey:@"jsonData"];
            
            WSAcvtModel *acvtModel = [[WSAcvtModel alloc] init];
            acvtModel.currentFuncs = weakSelf.m_currentFuncs;
            acvtModel.currentStore = weakSelf.m_currentStore;
            acvtModel.currentAcvtBean = acvtBean;
            acvtModel.isNewAddAcvt = NO;
            [acvtModel createMD5With:[acvtModel md5Param]];

            NSString *postData = [WSJSONBuilder buildAcvtDatasbyFuncs:weakSelf.m_currentFuncs
                                                                 acvt:acvtBean
                                                              isPhoto:NO
                                                                Store:weakSelf.m_currentStore
                                                         qstValuesDic:jsonDataDict
                                                                  md5:acvtModel.md5
                                                             submitId:acvtModel.md5
                                                               Others:nil
                                                    addedAcvtForStore:nil
                                                           tableDatas:nil
                                                           photoNames:nil
                                                            isNeedAdd:NO
                                                                isAdd:NO];
            NSString *notifyID = [NSString stringWithFormat:@"%@%@%@", kOfflineTableNotifyIdPrefix,@"demoList",[WSJSONBuilder gen_uuid]];
            [weakSelf insertUploadData:postData URL:URL_UPLOAD MD5:acvtModel.md5 IsPhoto:NO NotifyName:notifyID];
            [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                                      notifyName:notifyID
                                                             md5:acvtModel.md5
                                            isSynchronizeRequest:[acvtModel isSynchronizeRequest]];
            
            
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
            
            NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        }
       
        
    };
    
    self.richMediaDictArray = [[[WSBaseDictsDBService alloc]init] queryRichMediaDict];
    [self setUpDockAndContentView];
    [self setupChildViewControllers];
    
    [self dock:_dock didSelectButtonFrom:0 to:0];
    
    self.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(notice:) name:richMediaAddItem object:nil];
    

//    UIButton * closeBtn = [[UIButton alloc] init];
//    [closeBtn setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
//    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [closeBtn addTarget:self action:@selector(clickedCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
//    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//    self.closeBtn = closeBtn;
//    
//    _QRView = [[UIView alloc]init];
//    _QRView.backgroundColor = [UIColor whiteColor];
//    _imageview = [[UIImageView alloc]init];

    self.windows = [UIApplication sharedApplication].keyWindow;
    
    /* 逻辑有误，先注掉，setVisitData的时候已经查询过demolist的数据
    [_demoListArray removeAllObjects];
    NSArray *oldList = [[WSRichMediaTemplateTable sharedTable] queryTableForRichItem:_m_currentStore.Id];
    if (oldList.count > 0) {
        [_demoListArray addObjectsFromArray:oldList];
    }
     */
    
    NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%zd)",_demoListArray.count];
    [self.demoBtn setTitle:demoStrList forState:UIControlStateNormal];

}
-(void)uploadDemoListDataFinshed:(NSNotification *)sender
{
    NSLog(@"sender %@",sender);
}


//-(void)clickedCloseBtn:(UIButton *)sender
//{
//    [self.webView removeFromSuperview];
//    [self.closeBtn removeFromSuperview];
//    [self.shareButton removeFromSuperview];
//    [self.QRView removeFromSuperview];
//    [self.jingQingQiDai removeFromSuperview];
//    [self.imageview removeFromSuperview];
//}


-(void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupChildViewControllers
{
    
 
    
    for (WSDictBean *obj in self.richMediaDictArray) {
        WSRecipeController *vc = [[WSRecipeController alloc] init];
        vc.vcName = obj.name;
        vc.delegate = self;
        vc.visitData = self.visitData;
        vc.storeId = _m_currentStore.Id;
        [self addChildViewController:vc];

    }
    /*
    WSRecipeController *vc1 = [[WSRecipeController alloc] init];
    vc1.vcName = @"产品品类";
    vc1.delegate = self;
    vc1.visitData = self.visitData;
    vc1.storeId = _m_currentStore.Id;
//    vc1.addedArr = _demoListArray.mutableCopy;
    [self addChildViewController:vc1];
    
    WSRecipeController *vc2 = [[WSRecipeController alloc] init];
    vc2.vcName = @"渠道方案";
    vc2.delegate = self;
    vc2.visitData = self.visitData;
    vc2.storeId = _m_currentStore.Id;

    [self addChildViewController:vc2];
    
    WSRecipeController *vc3 = [[WSRecipeController alloc] init];
    vc3.vcName = @"灵感菜谱";
    vc3.delegate = self;
    vc3.visitData = self.visitData;
    vc3.storeId = _m_currentStore.Id;

    [self addChildViewController:vc3];
    
    WSRecipeController *vc4 = [[WSRecipeController alloc] init];
    vc4.vcName = @"专业服务";
    vc4.delegate = self;
    vc4.visitData = self.visitData;
    vc4.storeId = _m_currentStore.Id;
    [self addChildViewController:vc4];
    
    WSRecipeController *vc5 = [[WSRecipeController alloc] init];
    vc5.vcName = @"促销活动";
    vc5.delegate = self;
    vc5.visitData = self.visitData;
    vc5.storeId = _m_currentStore.Id;


    [self addChildViewController:vc5];
    
    WSRecipeController *vc6 = [[WSRecipeController alloc] init];
    vc6.vcName = @"about_our";
    vc6.delegate = self;
    vc6.visitData = self.visitData;
    vc6.storeId = _m_currentStore.Id;


    [self addChildViewController:vc6];
    */
    
    
    _temp  = [[WSTemplateController alloc] init];
    
    __weak typeof(self) weakSelf = self;
    _temp.listArr = ^(NSMutableArray *array){
        
        
        NSInteger oldCount = array.count;
        
        //判断是否有重复数据
        for (int i = 0;i < array.count;i++) {
            
            WSRichItemModel * listrichModel = array[i];
            
            for (WSRichItemModel * temprichModel in weakSelf.demoListArray) {
                
                if ([temprichModel.speid isEqualToString:listrichModel.speid]) {
                    
                    [array removeObject:listrichModel];
                    
                    i--;
                
                }
            }
        }
        
        NSInteger newCount = array.count;
        
        if (oldCount != newCount) {
            NSString *title = NSLocalizedString(@"已自动过滤重复内容", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
        }
        
        [weakSelf.demoListArray addObjectsFromArray:array];
        for (WSRichItemModel * model in array) {
              [[WSRichMediaTemplateTable sharedTable] insertDemoListTabWithStore:weakSelf.m_currentStore richMedia:model visitData:weakSelf.visitData];
        }
        NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%zd)",weakSelf.demoListArray.count];
        [weakSelf.demoBtn setTitle:demoStrList forState:UIControlStateNormal];
    };
    
    [self addChildViewController:_temp];
}

-(void)setUpDockAndContentView
{
    _contentView = [[UIView alloc] init];
    [_containerView addSubview:_contentView];
    
    _dock = [[WSDock alloc] initWithFrame:CGRectZero with:WSDockTypeHorizontal];
    _dock.dictArray = self.richMediaDictArray;
    [_dock setUpOptions];
    _dock.delegate = self;
    [_containerView addSubview:_dock];
    
    [_dock autoSetDimension:ALDimensionWidth toSize:110];
    [_dock autoPinEdgesToSuperviewEdgesWithInsets: ALEdgeInsetsMake(0.0,10.0,20.0,0.0) excludingEdge:ALEdgeRight];
    [_contentView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_dock withOffset:15.0];
    [_contentView autoPinEdgesToSuperviewEdgesWithInsets: ALEdgeInsetsMake(0.0,0,20.0,15.0) excludingEdge:ALEdgeLeft];
}

-(void)loadView
{
    [super loadView];
    
//    UIImageView *bgImageView = [[UIImageView alloc] init];
//    [bgImageView setImage:[UIImage imageForName:@"suggest_bg.png"]];
//    [self.view addSubview:bgImageView];
//    [bgImageView autoPinEdgesToSuperviewEdges];
    
    UIView *storesTitle = [[UIView alloc] init];
    [self.view addSubview:storesTitle];
    
    [storesTitle autoSetDimension:ALDimensionHeight toSize:STORESTITLEHEIGHT];
    ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    [storesTitle autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];
    
    UIView *titleView = [[UIView alloc] init];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:titleView];
    [titleView autoSetDimension:ALDimensionHeight toSize:PROGRESSVIEW];
    [titleView autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];
    
//    UIImageView *titleImageView  = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"suggest_toolbar_bg.png"]];
//    [titleView addSubview:titleImageView];
//    [titleImageView autoCenterInSuperview];
    
    _visitNameLabel = [[UILabel alloc] init];
    _visitNameLabel.font = [UIFont systemFontOfSize:16];
//    _visitNameLabel.textColor = [UIColor colorWithRed:155/255.0 green:60/255.0 blue:40/255.0 alpha:1.0];
    _visitNameLabel.textColor = [UIColor grayColor];
    _visitNameLabel.backgroundColor = [UIColor clearColor];
    [titleView addSubview:_visitNameLabel];
    [_visitNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0];
    [_visitNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_visitNameLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    _visitDataLabel = [[UILabel alloc] init];
    _visitDataLabel.font = [UIFont systemFontOfSize:16];
//    _visitDataLabel.textColor = [UIColor colorWithRed:155/255.0 green:60/255.0 blue:40/255.0 alpha:1.0];
    _visitDataLabel.textColor = [UIColor grayColor];
    _visitDataLabel.backgroundColor = [UIColor clearColor];
    [titleView addSubview:_visitDataLabel];
    
    [_visitDataLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_visitNameLabel withOffset:15.0];
    [_visitDataLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_visitDataLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    
    self.searchBar = [[WSSearchBar alloc]init];
    self.searchBar.searchBar.placeholder = @"请输入关键字搜索";
    self.searchBar.searchBar.delegate = self;
    
    [titleView addSubview:self.searchBar];
    [self.searchBar autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_visitDataLabel];
    [self.searchBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:150];
    [self.searchBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:titleView];
    [self.searchBar autoSetDimension:ALDimensionWidth toSize:300];
    
    [self.searchBar resetViews];
    
    //演示列表
    UIButton *demoBtn = [[UIButton alloc] init];
   
    [demoBtn addTarget:self action:@selector(clickDemoList) forControlEvents:UIControlEventTouchUpInside];
    UIImage * image = [UIImage imageForName:@"richMedia_yslb_bg"];
    [demoBtn setBackgroundImage:image forState:UIControlStateNormal];
    [demoBtn setImage:[UIImage imageForName:@"richMedia_yslb"] forState:UIControlStateNormal];
    [demoBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [titleView addSubview:demoBtn];
    [demoBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [demoBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:titleView withOffset:-20.0];
    self.demoBtn = demoBtn;
    
    _containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    [_containerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view withOffset:5.0];
    [_containerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleView withOffset:15.0];
    [_containerView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    [_containerView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.datasource = [[WSRichMediaTable sharedTable ]queryTableItems].mutableCopy;
    self.searArray = self.datasource;
    if (!self.bgGroundView) {
        self.bgGroundView = [[UIView alloc]init];
    }
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeWindow)];
    [self.bgGroundView addGestureRecognizer:recognizer];
    [self.windows addSubview:self.bgGroundView];
    self.bgGroundView.backgroundColor = [UIColor blackColor];
    self.bgGroundView.alpha = 0.6;
    [self.bgGroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(104, 0, 0, 0)];
    CGRect rect = [self.searchBar convertRect:self.searchBar.bounds toView:self.bgGroundView];
    if (!self.tabview) {
        self.tabview = [[UITableView alloc]init];
    }
    self.tabview.delegate = self;
    self.tabview.dataSource = self;
    self.tabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tabview.layer.cornerRadius = 8;
    self.tabview.layer.borderColor = MAIN_TINT_COLOT.CGColor;
    self.tabview.layer.borderWidth = 1;
    [self.windows addSubview:self.tabview];
    [self.tabview autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:rect.origin.x];
    [self.tabview autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:104];
    [self.tabview autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.tabview autoSetDimension:ALDimensionHeight toSize:300];
    
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",searchText];
        self.searArray = [self.datasource filteredArrayUsingPredicate:predicate].mutableCopy;
    }else{
        self.searArray = self.datasource.copy;
        
    }
    
    [self.tabview reloadData];
}

#pragma mark-  UITableViewDelegate,UITableViewDataSource

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.searArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * reuserId = @"WSSearchTableViewCell";
    WSSearchTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[WSSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId withStyle:WSSearchTableViewCellStyleAdd];
    }
    
    WSRichItemModel  * model = self.searArray[indexPath.row];
    cell.model = model;
    
//    __weak typeof(cell) weakCell = cell;
    
    __weak typeof(self) weakSelf = self;
    
    
    cell.addDemolist = ^(WSRichItemModel *model){
        

        for (WSRichItemModel * richModel in _demoListArray) {
            
            if ([model.speid isEqualToString:richModel.speid]) {
                NSString *title = NSLocalizedString(@"相同资料只能添加一次", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                
                return;
            }
        }
        
        if (_demoListArray.count == 15) {
            
            NSString *title = NSLocalizedString(@"已达上限", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            [_demoListArray removeObject:model];
            
            return;
        }

        [_demoListArray addObject:model];
        
               //  周一问下胡泽培 这个数据没有插入数据
       [[WSRichMediaTemplateTable sharedTable] insertDemoListTabWithStore:_m_currentStore richMedia:model visitData:_visitData];
        
        WSSearchTableViewCell *cell2 = (WSSearchTableViewCell *)[weakSelf.tabview cellForRowAtIndexPath:indexPath];
        
        
        
        CGRect rc = [cell2 convertRect:cell2.addButton.frame toView:weakSelf.windows];
        
        __block UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageForName:@"richMedia_add.png"] forState:UIControlStateNormal];
        btn.frame = rc;
        
        [weakSelf.windows addSubview:btn];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            CGPoint point = CGPointMake(weakSelf.windows.bounds.size.width - 50, 86);
            btn.center = point;
            
        } completion:^(BOOL finished) {
            
            NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%zd)",_demoListArray.count];
            [self.demoBtn setTitle:demoStrList forState:UIControlStateNormal];
            
            [btn removeFromSuperview];
        }];

    };
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;

    WSShowH5ViewController  *h5Ctrl = [[WSShowH5ViewController alloc]init];
    h5Ctrl.filterName = weakSelf.currentViewController.filterName;
    [h5Ctrl itemClickCallH5WithItemModel:self.searArray[indexPath.row]];
    h5Ctrl.reloadBlock = ^(){
        [weakSelf.currentViewController reloadData];
    };
    [self presentViewController:h5Ctrl animated:YES completion:nil];
    
//    [self itemClickCallH5:nil itemModel:self.searArray[indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 60;
}

-(void)removeWindow{
    
    [self.bgGroundView removeFromSuperview];
    [self.tabview removeFromSuperview];
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}
#pragma mark - funs
-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)aStore
{
    if(funcs == nil || aStore == nil)
        return nil;
    
    if(self != nil)
    {
        _m_currentFuncs = funcs;
        _m_currentStore = aStore;
        
        _demoListArray = [NSMutableArray array];
        _templateArray = [NSMutableArray array];
        
        return self;
    }
    return nil;
}

-(void)setVisitData:(NSString *)visitData
{
    _visitData = visitData;
    
    _visitDataLabel.text = [NSString stringWithFormat:@"拜访门店 : %@",_m_currentStore.name];
    _visitNameLabel.text = [NSString stringWithFormat:@"拜访日期 : %@",_visitData];
    [_demoListArray removeAllObjects];

    NSArray * array = [[WSRichMediaTemplateTable sharedTable] queryTableFordemoList:_m_currentStore.Id andVisitTime:_visitData];
    for (WSRichMediaDemoList * model in array) {
        [_demoListArray addObject:model.itemModel];
    }
    
    [self.demoBtn setTitle:[NSString stringWithFormat:@"演示列表(%lu)",(unsigned long)_demoListArray.count ] forState:UIControlStateNormal];
}

#pragma mark - event
/**
 *  添加成功
 */
-(void)notice:(id)sender{
    
    sender =  (NSNotification *)sender;
    WSRichItemModel * im =  (WSRichItemModel *)[sender object];
    
    NSDictionary *dict = [sender userInfo];
    
    WSRecipeController *vc = dict[@"VCName"];
    
    if (_demoListArray.count == 15) {
        
        NSString *title = NSLocalizedString(@"已达上限", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        
        [vc.addedArr removeObject:im];
        
        return;
    }
    
    [_demoListArray addObject:im];
    //每次添加成功插入就数据库
    BOOL a = [[WSRichMediaTemplateTable sharedTable] insertDemoListTabWithStore:_m_currentStore richMedia:im visitData:_visitData];
    
    if (a) {
        NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%zd)",_demoListArray.count];
        [self.demoBtn setTitle:demoStrList forState:UIControlStateNormal];
    }
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self];
}

-(void)clickDemoList
{
    WSRichDemoListController *demoList  =  [[WSRichDemoListController alloc]init];
    demoList.dmeoListArray = _demoListArray;
    demoList.deleteSuc = ^(NSArray *demoListArray,WSRichItemModel *im){
        
        //数据库删除操作
        BOOL a = [[WSRichMediaTemplateTable sharedTable] deleteRichListWithNames:@[@"name"] ArgumentsValue:@[im.name]];
        
        if (a) {
            NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%zd)",_demoListArray.count];
            [self.demoBtn setTitle:demoStrList forState:UIControlStateNormal];
        }
        
        //通知到recipeController,该选项已经删除.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteDemoList" object:demoListArray];
        
    };
    
    demoList.saveSuc = ^(NSDictionary *dict){
        
        //查询数据库,模板上线是20个,超过不许入库
        NSArray *templateArr = [[WSRichMediaTemplateTable sharedTable] queryTableForTemplate];
        
        if (templateArr.count > 20) {
            
            NSString *title = NSLocalizedString(@"已达上限", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            return;
        }
        
        //如果演示模板存在名称相同的模板,提示覆盖
        
        
        
//        NSString *pid;
//        for (NSDictionary * tempnam in templateArr) {
//            
//            NSLog(@"templateArr %@",tempnam.allKeys[0]);
//            
//            NSString *key = dict.allKeys[0];
//            if ([tempnam.allKeys[0] isEqualToString:key]) { //同名覆盖
//                
//                NSString *pidStr = [NSString stringWithFormat:@"SELECT spe.ID FROM spe_richMedia_template AS spe WHERE spe.name = '%@' AND spe.type = 'template';",key];
//                NSMutableArray *pidArray = [[WSRichMediaTemplateTable sharedTable] queryDatasBySql:pidStr columnArr:@[@"ID"]];
//                
//                if (pidArray.count > 0) {
//                    pid = pidArray[0];
//                }
//                
//                //删除模板
//                [[WSRichMediaTemplateTable sharedTable] deleteWithNames:@[@"name",@"type"] ArgumentsValue:@[key,@"template"]];
//                
//                //删除模板下的演示列表数组
//                [[WSRichMediaTemplateTable sharedTable] deleteWithNames:@[@"pid"] ArgumentsValue:@[pid]];
//                
//            }
//        }
        
        [[WSRichMediaTemplateTable sharedTable] deleteWithNames:@[@"storeID",@"visitName"] ArgumentsValue:@[_m_currentStore.Id,_visitData]];
        
        [_templateArray addObject:dict];
        
        [[WSRichMediaTemplateTable sharedTable] insertTableWithStore:_m_currentStore dict:dict visitData:_visitData];
        
        if (_temp) {
            _temp.templateArr = _templateArray;
        }
        
    };
    
    CGRect rect = CGRectMake(self.demoBtn.width / 2,self.demoBtn.height,20,0);
    CGSize contentSize = CGSizeMake(POPERWIDTH, POPERHEIGHT);
    if ([[UIDevice currentDevice] systemVersionHigherThan:@"8.0"]) {
        demoList.modalPresentationStyle=UIModalPresentationPopover;
        demoList.preferredContentSize= contentSize ;
        demoList.popoverPresentationController.permittedArrowDirections=  UIPopoverArrowDirectionUp;
        demoList.popoverPresentationController.sourceRect= self.demoBtn.bounds;
        
        UIPopoverPresentationController*pop  = demoList.popoverPresentationController;
        pop.permittedArrowDirections=  UIPopoverArrowDirectionUp;
        pop.sourceRect= rect;
        pop.backgroundColor = WSColor(167, 171, 46);
        pop.sourceView = self.demoBtn ;
        [self presentViewController:demoList animated:YES completion:nil];
        
    }else{
        
        _pop =[[UIPopoverController alloc]initWithContentViewController:demoList];
        _pop.popoverContentSize = contentSize;
        [_pop presentPopoverFromRect:rect inView:self.demoBtn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}
#pragma mark - WSDockDelegate
-(void)dock:(WSDock *)dock didSelectButtonFrom:(int)from to:(int)to
{
    UIViewController *newVc = self.childViewControllers[to];
    if (newVc.view.superview) return;
    newVc.view.frame = self.contentView.bounds;
    self.currentViewController = (WSRMShowBaseController *)newVc;

    UIViewController *oldVc;
    UIViewController *lastVc = [self.childViewControllers lastObject];
    if (lastVc.view.superview) {
        oldVc = lastVc;
    } else {
        oldVc = self.childViewControllers[from];
    }
    if (oldVc.view.superview) {
        [oldVc.view removeFromSuperview];
        [self.contentView addSubview:newVc.view];
    } else {
        [self.contentView addSubview:newVc.view];
    }
}

- (void)itemClickCallH5:(WSRecipeController *)Recipe itemModel:(WSRichItemModel *)item
{
//    _isShow = NO;
//    self.richItem = item;
//
//    
//    if (item.share_url && item.share_url.length > 0) {
//        _shareButton = [[UIButton alloc]init];
//        [_shareButton setImage:[UIImage imageNamed:@"fx.png"] forState:UIControlStateNormal];
//        _shareButton.backgroundColor = [UIColor colorWithHexString:@"008000"];
//        _shareButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//        [_shareButton addTarget:self action:@selector(showQRImage) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    if (!item.h5_add || [item.h5_add isEqualToString:@""] || [item.h5_add containsString:@"."]) {
//        
//        _jingQingQiDai = [[UIView alloc]init];
//        _jingQingQiDai.backgroundColor = [UIColor redColor];
//        [self.windows addSubview:_jingQingQiDai];
//        UIImageView * bgImageView = [[UIImageView alloc]init];
//        bgImageView.image = [UIImage imageNamed:@"jqqd"];
//        
//        [_jingQingQiDai addSubview:bgImageView];
//        
//        [bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//        
//        [_jingQingQiDai autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
//        [_jingQingQiDai addSubview:self.closeBtn];
//        
//        [self.closeBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
//        [self.closeBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
//        [self.closeBtn autoSetDimension:ALDimensionWidth toSize:44];
//        [self.closeBtn autoSetDimension:ALDimensionHeight toSize:44];
//        
//        [_jingQingQiDai addSubview:_shareButton];
//        
//        [_shareButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:45.0];
//        [_shareButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:100.0];
//        [_shareButton autoSetDimension:ALDimensionWidth toSize:50];
//        [_shareButton autoSetDimension:ALDimensionHeight toSize:50];
//        
//    }else{
//        

    
  
    
}
//
//-(void)showQRImage{
//    
//    if (self.richItem.share_url.length > 0) {
//        if (_jingQingQiDai != nil ) {
//            [_jingQingQiDai addSubview:_QRView];
//        }else{
//            [_webView addSubview:_QRView];
//        }
//    }
//    [_QRView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
//    [_QRView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_shareButton];
//    [_QRView autoSetDimension:ALDimensionWidth toSize:140];
//    [_QRView autoSetDimension:ALDimensionHeight toSize:140];
//    _QRView.hidden = _isShow;
//    _isShow = !_isShow;
//    
//    [_QRView addSubview:_imageview];
//    [_imageview autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    NSString * serverurl ;
//    WSServerIPList *svip = [WSAppData getObjectbyKey:SERVERURL];
//    if (svip && svip.serverIPArray && [svip.serverIPArray count]) {
//        WSServerIPController *serverIP = [svip.serverIPArray objectAtIndex:0];
//        serverurl = serverIP.ServerIPString;
//    }
//    _imageview.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@%@",serverurl,self.richItem.share_url] imageSize:130];
//}
//
//-(void)isHiddenQRImage{
//    
//    _QRView.hidden = YES;
//    _isShow = NO;
//}
//
//
//#pragma mark UIGestureRecognizerClick
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
//
//{
//    
//    return YES;
//    
//}

@end
