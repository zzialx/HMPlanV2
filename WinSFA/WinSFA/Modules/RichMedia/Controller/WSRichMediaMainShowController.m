//
//  WSMediaMainController.m
//  WinSFA
//
//  Created by huzepei on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaMainShowController.h"
#import "PureLayout.h"
#import "WSDock.h"
#import "WSRecipeController.h"
#import "WSRichDemoListController.h"
#import "WSTemplateController.h"
#import "WSRichItemModel.h"
#import "WSRichShowProdController.h"
#import "WSRichMediaTemplateTable.h"
#import "WSProfessionalController.h"
#import "WSChannelPlanController.h"
#import "WSHomePageViewController.h"
#import "WSAboutUsController.h"
#import "WSMyCollectionController.h"
#import "WSSearchTableViewCell.h"
#import "WSRMShowBaseController.h"
#import "WSRichMediaTable.h"
#import "WSMediaOptionBtn.h"

#import "WSRichMediaTemplate.h"
#import "WSBaseAcvtDBService.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSAcvtModel.h"
#import "WSSearchBar.h"
#import "WSRichMediaOtherInfoTable.h"
#import "WSRichMediaOtherInfo.h"
#import "WSBaseDictsDBService.h"
#define richMediaAddItem @"richMediaAddItem"
#define STORESTITLEHEIGHT 44
#define PROGRESSVIEW STORESTITLEHEIGHT
#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define POPERWIDTH 336
#define POPERHEIGHT 561



@interface WSRichMediaMainShowController ()<WSDockDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

/** dock和contentView的父View */
@property (nonatomic,strong) UIView *containerView;

@property (nonatomic, strong) WSDock *dock;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *dockBackView;
@property (nonatomic, strong) UIButton *demoBtn;
@property (nonatomic, strong) UILabel *visitNameLabel;
@property (nonatomic, strong) UILabel *visitDataLabel;
@property (nonatomic, strong) UIButton *popDockViewButton;

@property (nonatomic, strong) UIPopoverController *pop;

@property (nonatomic, strong) NSMutableArray *demoListArray;

// 我的收藏 --> 数组（key:模板名称  value:演示列表）
@property (nonatomic, strong) NSMutableArray *templateArray;

@property (nonatomic,strong) WSTemplateController * temp;

@property(nonatomic,weak) WSRMShowBaseController *currentViewController;

@property(nonatomic,strong) UIBarButtonItem *searchItem;

@property(nonatomic,strong) UIBarButtonItem *exitItem;

@property(nonatomic,strong) UIView *bgGroundView;

@property(nonatomic,strong) UITableView *tabview;

@property(nonatomic,strong) WSSearchBar *searchBar;

@property(nonatomic,strong) NSMutableArray *datasource;

@property(nonatomic,strong) NSArray *searArray;

@property(nonatomic,strong) UIBarButtonItem * canButton;
@property (nonatomic , strong) NSArray * richMediaDictArray; // 富媒体分类的字典项

@end

@implementation WSRichMediaMainShowController

#pragma mark - view cycle

-(NSMutableArray *)datasource{
    if (_datasource == nil) {
        _datasource = [[NSMutableArray alloc]init];
    }
    return _datasource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _demoListArray = [NSMutableArray array];
    _templateArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    // 之前是个性化写的，现在修改后台可以根据配置 来控制需要显示哪些数据 ---- 查询语句如下 winSFA MSTD-4481
    self.richMediaDictArray = [[[WSBaseDictsDBService alloc]init] queryRichMediaDict];
    [self setUpDockAndContentView];
    [self setupChildViewControllers];
    
    // 根据控制器的情况 添加导航栏右侧的控件
    self.searchBar = [[WSSearchBar alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    self.searchBar.searchBar.placeholder = @"请输入关键字搜索";
    self.searchBar.searchBar.delegate = self;
   
    
    UIButton  *cancelbutton= [[UIButton alloc]
                        initWithFrame:CGRectMake(0, 0, 50, 40)];
    [cancelbutton setTitle:@"cancel_label" forState:UIControlStateNormal];
    [cancelbutton setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
    [cancelbutton addTarget:self action:@selector(removeWindow) forControlEvents:UIControlEventTouchUpInside];
    self.canButton = [[UIBarButtonItem alloc]initWithCustomView:cancelbutton];
    
    self.searchItem = [[UIBarButtonItem alloc]initWithCustomView:self.searchBar];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(notice:) name:richMediaAddItem object:nil];
    
    [self dock:_dock didSelectButtonFrom:1 to:1];
}

#pragma mark-  UISearchBarDelegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = @[/*self.exitItem,*/self.canButton,self.searchItem];

//    self.datasource = self.currentViewController.allItemModel.mutableCopy;
    self.datasource = [[WSRichMediaTable sharedTable ]queryTableItems].mutableCopy;
    self.searArray =  self.datasource.copy;
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    self.bgGroundView = [[UIView alloc]init];
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeWindow)];
    [self.bgGroundView addGestureRecognizer:recognizer];
    [windows addSubview:self.bgGroundView];
    self.bgGroundView.backgroundColor = [UIColor blackColor];
    self.bgGroundView.alpha = 0.6;
    [self.bgGroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
    CGRect rect = [self.searchBar convertRect:self.searchBar.bounds toView:self.bgGroundView];
    self.tabview = [[UITableView alloc]init];
    self.tabview.delegate = self;
    self.tabview.dataSource = self;
    self.tabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tabview.layer.cornerRadius = 8;
    self.tabview.layer.borderColor = MAIN_TINT_COLOT.CGColor;
    self.tabview.layer.borderWidth = 1;
    [windows addSubview:self.tabview];
    [self.tabview autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:rect.origin.x];
    [self.tabview autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:64];
    [self.tabview autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.tabview autoSetDimension:ALDimensionHeight toSize:300];
  
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
   
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
        cell = [[WSSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId withStyle:WSSearchTableViewCellStyleNone];
    }
    WSRichItemModel  * model = self.searArray[indexPath.row];
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self removeWindow];
    
    [self.currentViewController itemClickCallH5WithItemModel:self.searArray[indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 60;
}
-(void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.bgGroundView removeFromSuperview];
     [self.tabview removeFromSuperview];
}


-(void)removeWindow{
    self.searchBar.searchBar.text = @"";
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = @[/*self.exitItem,*/self.searchItem];

    [self.bgGroundView removeFromSuperview];
    [self.tabview removeFromSuperview];
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}
- (void)setupChildViewControllers
{
    NSDictionary  *mappingDict = @{NSLocalizedString(@"product_category", nil):@"WSRichShowProdController",
                                   NSLocalizedString(@"channel_plan", nil):@"WSChannelPlanController",
                                   NSLocalizedString(@"inspire_menu", nil):@"WSRecipeController",
                                   NSLocalizedString(@"professional_service", nil):@"WSProfessionalController",
                                   NSLocalizedString(@"Promotion", nil):@"WSProfessionalController",
                                   NSLocalizedString(@"about_our", nil):@"WSAboutUsController",

                                   };
    NSString * isShowRichMediaHome = [[NSUserDefaults standardUserDefaults] objectForKey:IS_SHOW_RICHMEDIA_HOME];
    if ([isShowRichMediaHome isEqualToString:@"1"]) {
        WSHomePageViewController *vc1 = [[WSHomePageViewController alloc] init]; // 首页
        vc1.filterName = @"首页";
        vc1.title = @"首页";
        [self addChildViewController:vc1];
    }
    
    for (WSDictBean * bean in self.richMediaDictArray) {
        NSString * className = [mappingDict objectForKey:bean.name];
     
        WSRMShowBaseController * contrl = [[NSClassFromString(className) alloc] init];
        contrl.filterName = bean.name;
        
        if ([className isEqualToString:@"WSRecipeController"]) {
            WSRecipeController * vc = (WSRecipeController *)contrl;
            vc.isNotEdit = YES;
            vc.vcName = bean.name;
            vc.filterName = bean.name;
            
        }
        contrl.title = bean.dtyp ? bean.dtyp : bean.name;
        [self addChildViewController:contrl];

    }
   /*
    WSRichShowProdController *vc2 = [[WSRichShowProdController alloc] init];  // 产品分类
    vc2.filterName = @"产品品类";
    [self addChildViewController:vc2];
    
    WSChannelPlanController *vc3 = [[WSChannelPlanController alloc] init];  // 渠道方案
    vc3.filterName = @"渠道方案";
    [self addChildViewController:vc3];
    
    WSRecipeController *vc4 = [[WSRecipeController alloc] init];  // 灵感菜谱
    vc4.isNotEdit = YES;
    vc4.vcName = @"灵感菜谱";
    vc4.filterName = @"灵感菜谱";
    [self addChildViewController:vc4];
    
    
    WSProfessionalController *vc5 = [[WSProfessionalController alloc] init]; // 专业服务
    
    vc5.filterName = @"专业服务";
    [self addChildViewController:vc5];
    
    
    WSProfessionalController *vc6 = [[WSProfessionalController alloc] init];  // 促销活动
    vc6.filterName = @"促销活动";
    
    [self addChildViewController:vc6];
  
    WSAboutUsController *vc7 = [[WSAboutUsController alloc] init];     // 关于我们
    vc7.filterName = @"about_our";
    [self addChildViewController:vc7];
      */
    WSMyCollectionController * shouchang = [[WSMyCollectionController alloc]init];
    shouchang.filterName = @"我的收藏";
    shouchang.title = @"我的收藏";
    [self addChildViewController:shouchang];

}

-(void)setUpDockAndContentView
{
    _contentView = [[UIView alloc] init];
    [_containerView addSubview:_contentView];
    
    self.dockBackView = [[UIView alloc]init];
    self.dockBackView.backgroundColor = RGBCOLOR(72, 72, 74);
//    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDockView)];
//    [self.dockBackView addGestureRecognizer:gestureRecognizer];
    
    _dock = [[WSDock alloc] initWithFrame:CGRectZero with:WSDockTypeVertical];
    _dock.dictArray = self.richMediaDictArray;
    [_dock setUpOptions];
    _dock.delegate = self;
    
    UIButton * hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hideButton addTarget:self action:@selector(hideDockView) forControlEvents:UIControlEventTouchUpInside];
    [hideButton setImage:[UIImage imageNamed:@"shouqi"] forState:UIControlStateNormal];

    [_containerView addSubview:self.dockBackView];
    [self.dockBackView addSubview:_dock];
    [self.dockBackView addSubview:hideButton];
    
    [_contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.dockBackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
    [self.dockBackView autoSetDimension:ALDimensionHeight toSize:80];
    
    [_dock autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_dock autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:110];
    [_dock autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [_dock autoSetDimension:ALDimensionHeight toSize:80];
    
    [hideButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeLeft];
    [hideButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_dock withMultiplier:0.1];
}

-(void)loadView
{
    [super loadView];
    _containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    [_containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    self.popDockViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.popDockViewButton.frame = CGRectMake(self.view.width - 150, self.view.height - 40, 80, 45);
//    [self.popDockViewButton setTitle:@"弹出" forState:UIControlStateNormal];
    [self.popDockViewButton setBackgroundImage:[UIImage imageForName:@"tanqi"] forState:UIControlStateNormal];
    [self.popDockViewButton addTarget:self action:@selector(popDockView) forControlEvents:UIControlEventTouchUpInside];
    [self.popDockViewButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:self.popDockViewButton];
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
        
        return self;
    }
    return nil;
}

-(void)setVisitData:(NSString *)visitData
{
    _visitData = visitData;
    
    _visitNameLabel.text = [NSString stringWithFormat:@"拜访门店 : %@",_m_currentStore.name];
    _visitDataLabel.text = [NSString stringWithFormat:@"拜访日期 : %@",_visitData];
    
}

#pragma mark - event
-(void)notice:(id)sender{
    
    sender =  (NSNotification *)sender;
    
    WSRichItemModel * im =  (WSRichItemModel *)[sender object];
    
    [_demoListArray addObject:im];
    
    NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%lu)",(unsigned long)_demoListArray.count];
    [self.demoBtn setTitle:demoStrList forState:UIControlStateNormal];
    
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
        
        NSString *demoStrList = [NSString stringWithFormat:@"演示列表(%lu)",(unsigned long)_demoListArray.count];
        [self.demoBtn setTitle:demoStrList forState:UIControlStateNormal];
    };
    
    demoList.saveSuc = ^(NSDictionary *dict){
        
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
    if (to == 0) {
        if (self.m_currentStore) {
            
            [self uploadRichMediaDate];
        }
        [self exit];
    }else{
        UIViewController *newVc ;
        if (self.childViewControllers.count > to -1 ) {
            newVc = self.childViewControllers[to -1];
        }
        self.currentViewController = (WSRMShowBaseController *)newVc;
        WSRMShowBaseController * vc = (WSRMShowBaseController *) self.currentViewController;
        vc.m_currentStore = self.m_currentStore;
        self.title = vc.title;
        self.datasource = vc.allItemModel.mutableCopy;
        self.searArray = self.datasource.copy;
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
        if ([newVc isKindOfClass:[WSHomePageViewController class]]) {
//            self.navigationItem.rightBarButtonItems = @[self.exitItem,self.searchItem];
             self.navigationItem.rightBarButtonItem =self.searchItem;
        }else{
            //        self.navigationItem.rightBarButtonItem = self.searchItem;
//            self.navigationItem.rightBarButtonItem = self.exitItem;
        }
        
        if (newVc.view.superview) return;
        newVc.view.frame = self.contentView.bounds;
    
        UIViewController *oldVc;
        UIViewController *lastVc = [self.childViewControllers lastObject];
        if (lastVc.view.superview) {
            oldVc = lastVc;
        } else {
            
            if (self.childViewControllers.count > from -1) {
                oldVc = self.childViewControllers[from -1];
            }
        }
        if (oldVc.view.superview) {
            [oldVc.view removeFromSuperview];
            [self.contentView addSubview:newVc.view];
        } else {
            [self.contentView addSubview:newVc.view];
        }

    }
}

-(void)hideDockView{
    
    [UIView animateWithDuration:0.25 animations:^{
        //
        self.dockBackView.top = self.view.height + 5;
    } completion:^(BOOL finished) {
        self.popDockViewButton.bottom = self.view.height;
    }];

}

-(void)popDockView{
    [UIView animateWithDuration:0.25 animations:^{
        self.popDockViewButton.top = self.view.height;
        self.dockBackView.bottom = self.view.height;
    } completion:^(BOOL finished) {
        //
    }];


}

#pragma mark - 上传富媒体点击时间
-(void)uploadRichMediaDate{
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadRichMediaClickDataFinshed:) name:@"RichMediaClick" object:nil];
    
    
    NSArray * demolists =  [[WSRichMediaTemplateTable sharedTable] queryTableFordemoList:self.m_currentStore.Id];
    if (demolists.count == 0) {
        return;
    }
    NSString  * uploadString = @"";
    int i = 0;
    for (WSRichMediaDemoList *object in demolists)
    {
         WSRichItemModel * richmodel =   [[[WSRichMediaTemplateTable sharedTable] queryAndReturnInfosBySql:[NSString stringWithFormat:@"select * from spe_richMedia where ID = '%@'",object.itemModel.ID] andClassName:@"WSRichItemModel"]firstObject ];
        
        NSString *clickTime = [[WSRichMediaOtherInfoTable sharedTable] getClickTimeWithStoreId:self.m_currentStore.Id richMediaId:richmodel.speid];
        
        if (clickTime.length > 0)
        {
            if (i == 0)
            {
                 uploadString = [uploadString stringByAppendingString:[NSString stringWithFormat:@"%@-%@",richmodel.speid,clickTime]];
            }else{
                 uploadString = [uploadString stringByAppendingString:[NSString stringWithFormat:@";%@-%@",richmodel.speid,clickTime]];
            }
            i++;
        }
    }
    
    if (uploadString.length == 0) {
        return ;
    }
    
    
    // 做上传操作  定制模块可以写死
    WSAcvtBean *acvtBean = [[[WSBaseAcvtDBService alloc]init] queryAcvtWithAcvtCode:@"fmtffcs"];
    WSAcvtBean_qst *acvt_qst = acvtBean.qsts[0];
    NSMutableDictionary  *jsonDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString  *qstKey = [NSString stringWithFormat:@"%@%@",acvt_qst.qstType,acvt_qst.acvtQstId];
    [jsonDic setObject:uploadString forKey:qstKey];
    WSAcvtModel *acvtModel = [[WSAcvtModel alloc] init];
    acvtModel.currentFuncs = self.m_currentFuncs;
    acvtModel.currentStore = self.m_currentStore;
    acvtModel.currentAcvtBean = acvtBean;
    acvtModel.isNewAddAcvt = NO;
    acvtModel.currentVisitAction = self.currentVisitAction;
    [acvtModel createMD5With:[acvtModel md5Param]];
   
    
    NSString *postData = [WSJSONBuilder buildAcvtDatasbyFuncs:self.m_currentFuncs
                                                         acvt:acvtBean
                                                      isPhoto:NO
                                                        Store:self.m_currentStore
                                                 qstValuesDic:jsonDic
                                                          md5:acvtModel.md5
                                                     submitId:acvtModel.md5
                                                       Others:nil
                                            addedAcvtForStore:nil
                                                   tableDatas:nil
                                                   photoNames:nil
                                                    isNeedAdd:NO
                                                        isAdd:NO];
    NSString *notifyID = [NSString stringWithFormat:@"%@%@%@", kOfflineTableNotifyIdPrefix,@"RichMediaClick",[WSJSONBuilder gen_uuid]];
    [self insertUploadData:postData URL:URL_UPLOAD MD5:acvtModel.md5 IsPhoto:NO NotifyName:notifyID];

    [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                              notifyName:notifyID
                                                     md5:acvtModel.md5
                                    isSynchronizeRequest:NO];
}

-(void)uploadRichMediaClickDataFinshed:(NSNotification *)noti{
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RichMediaClick" object:nil];
    NSLog(@"%@",noti);
}
@end
