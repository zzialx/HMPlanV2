//
//  WSSuggestedTableShowController.m
//  WinSFA
//
//  Created by huzepei on 16/7/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSuggestedTableShowController.h"
#import "PureLayout.h"
#import "WSSuggest.h"
#import "WSSuggestView.h"
#import "WSGenerateSuggestController.h"
#import "WSRichMediaMainController.h"
#import "YYModel.h"

#import "WSSuggestWholesale.h"
#import "WSPopUpSuggestStyleViewController.h"
#import "WSSuggestTableInstance.h"
#import "WSSugDemoListController.h"
#import "WSSuggestListTable.h"

#import "WSPopUpSuggestStyleViewController.h"
#import "WSSuggestTableInstance.h"
#import "WSGenerateSuggestForHomeViewController.h"
#import "WSSuggestHome.h"


#define SUGGESTBGCOUNT 6
#define MAXCLOS 3
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)
#define STORESTITLEHEIGHT 44
#define PROGRESSVIEW STORESTITLEHEIGHT
#define SUGBGVIEWSTARTX 32
#define SUGBGVIEWSTARTY 40
#define TAGBASE 1000
#define POPERWIDTH 336
#define POPERHEIGHT 561

#define WHOLESALE @"02"

#define k_UISCREN_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 1024)
#define k_UISCREN_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? : 768)
#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]


@interface WSSuggestedTableShowController ()<WSSuggestViewDelegate>

@property (nonatomic,strong) WSSuggestView *suggestView;

@property (nonatomic,strong) UIView *storesTitle;

@property (nonatomic,strong) NSMutableArray *suggests;


@property (nonatomic, strong) UIButton *demoBtn;

@property (nonatomic, strong) UILabel *visitNameLabel;
@property (nonatomic, strong) UILabel *visitDataLabel;

@property (nonatomic, strong) UIPopoverController *pop;

@property (nonatomic, strong) NSMutableArray *demoListArray;



@end

@implementation WSSuggestedTableShowController


#pragma mark - view cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //第一次进来要根据门店type 去加载用家还是批发.(根据门店ID查询本地回显数据)
    //数据库中查询模板
    
    if (!self.prepareDate) {
        self.prepareDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    }
    
    if ([_m_currentStore.styp isEqualToString: WHOLESALE]) { //批发
        
        _suggests = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"02" sid:_m_currentStore.Id className:@"WSSuggestWholesale" withbiz_date:self.prepareDate] mutableCopy];
        
    }else{ //用家
        
        _suggests = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"01" sid:_m_currentStore.Id className:@"WSSuggestHome" withbiz_date:self.prepareDate] mutableCopy];
    }
    
    //刷新视图
    [self reloadDataForSuggestView];
    
    [self updateDemoCount];
    [self.view setBackgroundColor:[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1.0]];
}

/**
 *  加载界面
 */
-(void)loadView
{
    [super loadView];

    UIView *storesTitle = [[UIView alloc] init];
    [self.view addSubview:storesTitle];
    
    [storesTitle autoSetDimension:ALDimensionHeight toSize:STORESTITLEHEIGHT];
    ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    [storesTitle autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];
    
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleView];
    [titleView autoSetDimension:ALDimensionHeight toSize:PROGRESSVIEW];
    [titleView autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];
    
    
    _visitNameLabel = [[UILabel alloc] init];
    _visitNameLabel.font = [UIFont systemFontOfSize:16];
    _visitNameLabel.textColor = [UIColor grayColor];
    _visitNameLabel.backgroundColor = [UIColor clearColor];
    [titleView addSubview:_visitNameLabel];
    [_visitNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0];
    [_visitNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_visitNameLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    _visitDataLabel = [[UILabel alloc] init];
    _visitDataLabel.font = [UIFont systemFontOfSize:16];
    _visitDataLabel.textColor = [UIColor grayColor];
    _visitDataLabel.backgroundColor = [UIColor clearColor];
    [titleView addSubview:_visitDataLabel];
    
    [_visitDataLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_visitNameLabel withOffset:15.0];
    [_visitDataLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_visitDataLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    
    [_storesTitle autoSetDimension:ALDimensionHeight toSize:STORESTITLEHEIGHT];
    [_storesTitle autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];
    
    UIImage *sugBgImage = [UIImage imageForName:@"bg-kuang.png"];
    
    //演示列表
    UIButton *demoBtn = [[UIButton alloc] init];
    [demoBtn addTarget:self action:@selector(clickSugDemo) forControlEvents:UIControlEventTouchUpInside];
    UIImage * image = [UIImage imageForName:@"richMedia_yslb_bg"];
    [demoBtn setBackgroundImage:image forState:UIControlStateNormal];
    [demoBtn setImage:[UIImage imageForName:@"richMedia_yslb"] forState:UIControlStateNormal];
    [demoBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [titleView addSubview:demoBtn];
    [demoBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [demoBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:titleView withOffset:-20.0];
    self.demoBtn = demoBtn;

    CGFloat sugBgViewW = sugBgImage.size.width - 50;
    CGFloat sugBgViewH = sugBgImage.size.height;
    
    CGFloat sugBgViewStartX = SUGBGVIEWSTARTX;
    CGFloat sugBgViewStartY = SUGBGVIEWSTARTY + STORESTITLEHEIGHT;
    CGFloat sugBgViewX = 0;
    CGFloat sugBgViewY = 0;
    CGFloat sugBgViewXmargin = (k_UISCREN_Width  - 2 * sugBgViewStartX - MAXCLOS * sugBgViewW) / (MAXCLOS - 1);
    CGFloat sugBgViewYmargin = (k_UISCREN_Height - 64 - 2 * sugBgViewStartY - 2 * sugBgViewH);
    
    
    for (int i = 0; i < SUGGESTBGCOUNT; i++) {
        
        int row = i / MAXCLOS;
        int col = i % MAXCLOS;
        sugBgViewX = sugBgViewStartX + col * (sugBgViewXmargin + sugBgViewW);
        sugBgViewY = sugBgViewStartY + row * (sugBgViewH + sugBgViewYmargin);
        _suggestView = [[WSSuggestView alloc] initWithFrame:CGRectMake(sugBgViewX, sugBgViewY, sugBgViewW, sugBgViewH)];
        _suggestView.tag = (TAGBASE+i) << 8 | 0;
        _suggestView.delegate = self;
        [self.view addSubview:_suggestView];
    }
}

/**
 *  更新演示列表的数量
 */
-(void)updateDemoCount
{
    //数据库中查询模板
    if ([_m_currentStore.styp isEqualToString: WHOLESALE]) { //批发
        
        _demoListArray = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"02" className:@"WSSuggestWholesale" ] mutableCopy];
        
    }else{ //用家
        
        _demoListArray = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"01" className:@"WSSuggestHome"] mutableCopy];
        
    }
    NSString *demoList = [NSString stringWithFormat:@"模板:(%zd)",_demoListArray.count];
    [self.demoBtn setTitle:demoList forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - funs
/**
 *  演示列表
 */
-(void)clickSugDemo
{
    
    WSSugDemoListController *demoList  =  [[WSSugDemoListController alloc]init];
    
    demoList.sugClick = ^(WSSuggestWholesale *suggest){
      
        
        if (self.suggests.count == 6) {
            
            NSString *title = NSLocalizedString(@"最多存在6个建议单", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
        }else{
            
            BOOL isReplace = NO;
            for (int i = 0; i < self.suggests.count; i++) {
                
                WSSuggestWholesale *arrItem = self.suggests[i];
                
                if ([suggest.name isEqualToString:arrItem.name]) {
                    
                    [self.suggests replaceObjectAtIndex:i withObject:suggest];
                    
//                    [[WSSuggestListTable sharedTable] updateWithNames:@[@"name"] values:@[arrItem.name] whereName:@[@"item"] whereValue:@[arrItem.item]];
                    
                     [[WSSuggestListTable sharedTable] updateWithNames:@[@"item"] values:@[arrItem.item] whereName:@[@"name"] whereValue:@[arrItem.name]];
                    
                    isReplace = YES;
                }
            }
            if (!isReplace) {
                [[WSSuggestListTable sharedTable] insertTableWithType:@"02" model:suggest sid:_m_currentStore.Id withbiz_date:self.prepareDate];
                NSArray * array = [[WSSuggestListTable sharedTable] queryWithType:@"02" name:suggest.name sid:_m_currentStore.Id withbiz_date:self.prepareDate className:@"WSSuggestWholesale"];
                if (array.count > 0) {
                    [self.suggests addObject:array[0]];
                }
            }else{
                NSString *title = NSLocalizedString(@"已替换相同建议单", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

            }
            
            [self reloadDataForSuggestView];
            
        }
    };
    
    
    demoList.sugHomeClick = ^(WSSuggestHome *suggest){
      
        if (self.suggests.count == 6) {
            
            NSString *title = NSLocalizedString(@"最多存在6个建议单", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
        }else{
            //更新到视图上面(去重)
            BOOL isReplace = NO;
            for (int i = 0; i < self.suggests.count; i++) {
                
                WSSuggestWholesale *arrItem = self.suggests[i];
                
                if ([suggest.name isEqualToString:arrItem.name]) {
                    
                    [self.suggests replaceObjectAtIndex:i withObject:suggest];
                    
//                    [[WSSuggestListTable sharedTable] updateWithNames:@[@"name"] values:@[arrItem.name] whereName:@[@"item"] whereValue:@[arrItem.item]];
                    
                    [[WSSuggestListTable sharedTable] updateWithNames:@[@"item"] values:@[arrItem.item] whereName:@[@"name"] whereValue:@[arrItem.name]];
                    
                    isReplace = YES;
                }
            }
            if (!isReplace) {
                
                [[WSSuggestListTable sharedTable] insertTableWithType:@"01" homeModel:suggest sid:_m_currentStore.Id withbiz_date:self.prepareDate];
                NSArray * array = [[WSSuggestListTable sharedTable] queryWithType:@"01" name:suggest.name sid:_m_currentStore.Id withbiz_date:self.prepareDate className:@"WSSuggestHome"];
                if (array.count > 0) {
                    [self.suggests addObject:array[0]];
                }

            }else{

                NSString *title = NSLocalizedString(@"已替换相同建议单", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            }

            [self reloadDataForSuggestView];
            
        }
    };
    
    
    demoList.delegateSuc = ^(){
        
        [self updateDemoCount];
        
    };
    
    //如果是批发用户
    if ([_m_currentStore.styp isEqualToString: WHOLESALE]) {// 批发的
        
        demoList.stype = @"02";
        
    }else{ //用家
        
        demoList.stype = @"01";
    }
    
    
    demoList.dmeoListArray = _demoListArray;
    
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

/**
 *  刷新建议单
 */
-(void)reloadDataForSuggestView
{
    for (int i = 0; i < SUGGESTBGCOUNT; i++) {
        WSSuggestView *suggestView = [self.view viewWithTag:(TAGBASE+i) << 8 | 0];
        [suggestView removeContainerViewAndPlusBtn];
    }
    
    for (int i=0; i < self.suggests.count; i++) {
        WSSuggestView *suggestView = [self.view viewWithTag:(TAGBASE+i) << 8 | 0];
        [suggestView setupViews];
        
        
        if ([_m_currentStore.styp isEqualToString: WHOLESALE]) {// 批发的
            suggestView.suggestWholesale = self.suggests[i];
            
        }else{ //用家
            
            suggestView.suggestHome = self.suggests[i];
            
        }
        suggestView.suggestIndex = i;
        
        
        if ((self.suggests.count < SUGGESTBGCOUNT) && (i + 1) <= SUGGESTBGCOUNT) {
            WSSuggestView *suggestView = [self.view viewWithTag:(TAGBASE+i+1) << 8 | 0];
            [suggestView setUpPlusBtn];
            suggestView.showPlus = YES;
        }
    }
    
    if (self.suggests.count == 0) {
        WSSuggestView *suggestView = [self.view viewWithTag:(TAGBASE) << 8 | 0];
        [suggestView setUpPlusBtn];
        suggestView.showPlus = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - setter,getter
-(NSMutableArray *)suggests
{
    if (!_suggests) {
        _suggests = [NSMutableArray array];
    }
    return _suggests;
}

-(void)setPrepareDate:(NSString *)prepareDate
{
    _prepareDate = prepareDate;
    
    _visitDataLabel.text = [NSString stringWithFormat:@"拜访门店 : %@",_m_currentStore.name];
    _visitNameLabel.text = [NSString stringWithFormat:@"拜访日期 : %@",_prepareDate];
    
}

#pragma mark - _suggestViewDelagete
/**
 *  删除建议单
 */
-(void)WSSuggestViewDidClickCloseBtn:(WSSuggestView *)suggestView WithIndex:(NSInteger)index
{
    //数据库中删除本地的回显数据
    if ([_m_currentStore.styp isEqualToString: WHOLESALE]) { //批发的
        
        WSSuggestWholesale * whoesale = self.suggests[index];
        [[WSSuggestListTable sharedTable] deleteSuggestWithNames:@[@"ID"] ArgumentsValue:@[whoesale.ID]];
        
    }else{//用家的
        
        WSSuggestHome * home = self.suggests[index];
        [[WSSuggestListTable sharedTable] deleteSuggestWithNames:@[@"ID"] ArgumentsValue:@[home.ID]];
    }
    
    [self.suggests removeObjectAtIndex:index];
    [self reloadDataForSuggestView];
    
}

/**
 *  点击 + 号:  添加
 */
-(void)WSSuggestViewDidClickPlusBtn:(WSSuggestView *)suggestView WithIndex:(NSInteger)index
{

    WSPopUpSuggestStyleViewController * popUp = [WSPopUpSuggestStyleViewController new];
    
    popUp.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        popUp.preferredContentSize = CGSizeMake(POP_CREATE_NEW_VIEWWIDTH,POP_CREATE_NEW_VIEWHEIGHT);
        
    }else{
        
        popUp.view.superview.center = CGPointMake(550 , 1024 / 2);
        
        popUp.view.superview.size = CGSizeMake(POP_CREATE_NEW_VIEWWIDTH,POP_CREATE_NEW_VIEWHEIGHT);
    }
    
    if ([_m_currentStore.styp isEqualToString: WHOLESALE]) { //批发的
        popUp.sType = @"02";
    }else{  //用家的
        popUp.sType = @"01";
    }
    
    popUp.suggestName = ^(NSString *suggestName,NSString *type){
        
        if ([_m_currentStore.styp isEqualToString: WHOLESALE]) { //批发
            
            WSGenerateSuggestController *generate = [[WSGenerateSuggestController alloc] initWithNibName:@"WSGenerateSuggestController" bundle:nil];
            
            generate.storeID = _m_currentStore.Id;
            generate.suggestName = suggestName;
            generate.prepareDate = self.prepareDate;
            generate.sug = ^(WSSuggestWholesale *suggest){
                
                [[WSSuggestListTable sharedTable] insertTableWithType:@"02" model:suggest sid:_m_currentStore.Id withbiz_date:self.prepareDate];
                
                self.suggests = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"02" sid:_m_currentStore.Id className:@"WSSuggestWholesale" withbiz_date:self.prepareDate] mutableCopy];
                
                [self reloadDataForSuggestView];
                [self updateDemoCount];
            };
            [self presentViewController:generate animated:YES completion:nil];
            
        }else{  //用家的
            
            WSGenerateSuggestForHomeViewController *generate = [[WSGenerateSuggestForHomeViewController alloc] initWithNibName:@"WSGenerateSuggestForHomeViewController" bundle:nil];
            
            generate.storeID = _m_currentStore.Id;
            generate.sStyle = type;
            generate.sTableName = suggestName;
            generate.prepareDate = self.prepareDate;

            generate.sug = ^(WSSuggestHome *suggest){
                
                [[WSSuggestListTable sharedTable] insertTableWithType:@"01" homeModel:suggest sid:_m_currentStore.Id withbiz_date:self.prepareDate];
                
                self.suggests = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"01" sid:_m_currentStore.Id className:@"WSSuggestHome" withbiz_date:self.prepareDate] mutableCopy];
                
                [self reloadDataForSuggestView];
                [self updateDemoCount];
                
            };
            
            [self presentViewController:generate animated:YES completion:nil];
            
        }
    };
    
    [self presentViewController:popUp animated:YES completion:nil];
}

/**
 *  点击内容重新打开建议单
 */

-(void)WSSuggestViewDidClickContainerView:(WSSuggestView *)suggestView WithIndex:(NSInteger)index
{
    
    if ([_m_currentStore.styp isEqualToString: WHOLESALE]) {  //批发
        
        WSGenerateSuggestController *generate = [[WSGenerateSuggestController alloc] initWithNibName:@"WSGenerateSuggestController" bundle:nil];
        
        generate.storeID = _m_currentStore.Id;
        WSSuggestWholesale * suggestWho = self.suggests[index];
        generate.suggestWho = suggestWho;
        generate.prepareDate = self.prepareDate;

        generate.sug = ^(WSSuggestWholesale *suggest){
            
            //根据ID查询 本地回显的数据
            NSMutableArray * localArray = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"02" sid:_m_currentStore.Id className:@"WSSuggestWholesale" withbiz_date:self.prepareDate] mutableCopy];
            
            
            for (int i = 0; i < localArray.count; i++) {
                
                WSSuggestWholesale *arrItem = localArray[i];
                
                if ([suggest.name isEqualToString:arrItem.name]) {
                    
                    [[WSSuggestListTable sharedTable] updateWithNames:@[@"item",@"name"] values:@[suggest.item,suggest.name] whereName:@[@"ID"] whereValue:@[suggest.ID]];
                    
                }
            }
            //这里更新ID是为了删除
            suggest.ID = suggestWho.ID;
            
            [self.suggests replaceObjectAtIndex:index withObject:suggest];
            
            [self reloadDataForSuggestView];
            [self updateDemoCount];
            
        };
        [self presentViewController:generate animated:YES completion:nil];
        
    }else{
        
        WSGenerateSuggestForHomeViewController *generate = [[WSGenerateSuggestForHomeViewController alloc] initWithNibName:@"WSGenerateSuggestForHomeViewController" bundle:nil];
        
        generate.storeID = _m_currentStore.Id;
        WSSuggestHome * suggestHome = self.suggests[index];
        generate.suhome = suggestHome;
        generate.sStyle = suggestHome.sugHomeModel.sStype;
        generate.prepareDate = self.prepareDate;

        generate.sug = ^(WSSuggestHome *suggest){
            
            //根据ID查询 本地回显的数据
            NSMutableArray * localArray = [[[WSSuggestListTable sharedTable] queryTableForSuggestListType:@"01" sid:_m_currentStore.Id className:@"WSSuggestHome" withbiz_date:self.prepareDate] mutableCopy];
            
            
            for (int i = 0; i < localArray.count; i++) {
                
                WSSuggestHome *arrItem = localArray[i];
                
                if ([suggest.ID isEqualToString:arrItem.ID]) {
                    
                    [[WSSuggestListTable sharedTable] updateWithNames:@[@"item",@"name"] values:@[suggest.item,suggest.name] whereName:@[@"ID"] whereValue:@[suggest.ID]];
                    
                }
            }
            
            //这里更新ID是为了删除
//            suggest.ID = suggestHome.ID;
            
            [self.suggests replaceObjectAtIndex:index withObject:suggest];
            
            
            [self reloadDataForSuggestView];
            [self updateDemoCount];
            
        };
        
        [self presentViewController:generate animated:YES completion:nil];

    }
}
@end
