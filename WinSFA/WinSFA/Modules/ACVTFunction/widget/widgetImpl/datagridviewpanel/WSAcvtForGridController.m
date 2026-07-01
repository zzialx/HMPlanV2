//
//  WSAcvtForGridController.m
//  WinSFA
//
//  Created by mac on 2017/10/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSAcvtForGridController.h"
#import "WSAcvtScrollView.h"
#import "WSAcvtView.h"
#import "WSAcvtBean.h"
#import "WSTableItem.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
@interface WSAcvtForGridController ()

@property (nonatomic, strong) WSAcvtScrollView *scrollView;
@property (nonatomic, strong) WSAcvtView  *acvtview;
@property (nonatomic ,assign)     BOOL firstLoad;  //是否第一次载入
@property (nonatomic , strong) WSAcvtModel * currentAcvtModel;
@property (nonatomic, strong) WSAcvtBean *currentAcvtBean;
@property (nonatomic, copy) NSString *itemId;

@end

@implementation WSAcvtForGridController

- (id)initWithAcvtBean:(WSTableItem *)tableItem withItemId:(NSString *)itemId withItemName:(NSString *)itemName withDisplayValue:(NSDictionary *)dict withLuaScript:(NSString *)luaScript{

    if(tableItem == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentAcvtBean = [[WSAcvtBean alloc] initAcvtBeanWithTableItem:tableItem withItemId:itemId withItemName:itemName  withLuaScript:luaScript];
        [self createAcvtModel:dict];

        return self;
    }
    return nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * confimButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"confirm", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backAndReloadGridView)];
    self.navigationItem.rightBarButtonItem = confimButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.firstLoad) {
        self.firstLoad = YES;
        int height = 0;
        

        _scrollView = [[WSAcvtScrollView alloc] initWithFrame:CGRectMake(self.view.origin.x, self.y_point + height, self.view.width, self.view.height - self.y_point - height) andAcvtBean:_currentAcvtBean];
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.acvtview = _scrollView.acvtView;

        if (height > 0) {
            self.acvtview.positionY = height;
        }
        
        [self.acvtview buildDisplayContent];
        
        [self.contentScrollView addSubview:_scrollView];

    }
    
}

-(void)createAcvtModel:(NSDictionary * )dict{
    self.currentAcvtModel = [[WSAcvtModel alloc]init];
    self.currentAcvtModel.currentAcvtBean = self.currentAcvtBean;
    self.currentAcvtModel.hasLocalData = YES;
    self.currentAcvtModel.qstDBValueDictionary = [dict mutableCopy];
    [WSDataSourceManager sharedInstance].currentActiveModel = self.currentAcvtModel;
}

-(void)backAndReloadGridView{
    
    if ([self.acvtview checkLuaScriptWhenUpload]) {
        NSMutableDictionary * dict = (NSMutableDictionary *)[self.acvtview getAllDataAboutQstIdAndValue];
        [dict removeObjectForKey:@"prodId"];
        if (self.reloadGridView) {
            self.reloadGridView(dict, self.itemId);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
