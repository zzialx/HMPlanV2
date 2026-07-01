//
//  VistRemindViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSVistRemindViewController.h"
#import "WSStoreInfoBean.h"
#import "WSStoreInfoBeanArray.h"
#import "DataGridComponent.h"
#include <objc/runtime.h>
#import "WSVisitStoreActionTable.h"
#import "WSNavigationBar.h"

@interface WSVistRemindViewController ()
{
    BOOL _isFirstLoadView;
}

@end

@implementation WSVistRemindViewController

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstLoadView = YES;

    NSString *title = nil;
    if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
        title = self.currentStore.name;
    }
    title = self.currentStore.name ? title : NSLocalizedString(@"back_label",nil);
    if ([title length] > TITLE_MAX_LENGTH) {
        title = [NSString stringWithFormat:@"%@...",[title substringToIndex:TITLE_MAX_LENGTH - 1]];
    }
    
    if (self.currentVisitAction) {
        [[WSVisitStoreActionTable sharedTable] updateAction:self.currentVisitAction toStatus:ActionDone];
    }
    
    if (self.uploadButton) {
        NSMutableArray *barButtonArray = [NSMutableArray array];
        if(self.m_ParentViewController != nil)
        {
            [barButtonArray addObjectsFromArray:self.m_ParentViewController.navigationItem.rightBarButtonItems];
            if ([barButtonArray containsObject:self.uploadButton]) {
                [barButtonArray removeObject:self.uploadButton];
            }
            self.m_ParentViewController.navigationItem.rightBarButtonItems = barButtonArray;
        }
        else
        {
            [barButtonArray addObjectsFromArray:self.navigationItem.rightBarButtonItems];
            if ([barButtonArray containsObject:self.uploadButton]) {
                [barButtonArray removeObject:self.uploadButton];
            }
            self.navigationItem.rightBarButtonItems = barButtonArray;
        }
        
    }
    
    WSHTextField *memo = [self.contentScrollView viewWithTag:MEMOTAG];
    NSArray *memoValueArray = [self getMemoServerDisValue];
    if ([memoValueArray count] > 0) {
        if (memo) {
            memo.text = ((WSStoreInfoBean *)[memoValueArray firstObject]).col3;
        }else {
            
            for (WSStoreInfoBean *storeInfoBean in memoValueArray) {
                
                if (storeInfoBean.col2) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point+10,  self.view.bounds.size.width - 2 * k_LabelXOffset, 15)];
                    label.text = storeInfoBean.col2;
                    label.font = [UIFont systemFontOfSize:UI_Font];
                    label.textColor = [UIColor blackColor];
                    label.textAlignment = NSTextAlignmentLeft;
                    
                    [self.contentScrollView addSubview:label];
                    
                    self.y_point += 25;
                }
                
                if (storeInfoBean.col3) {
                    UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(k_LabelXOffset, self.y_point+5,  self.view.bounds.size.width - 2 * k_LabelXOffset, 35)];
                    textField.returnKeyType = UIReturnKeyDone;
                    textField.backgroundColor = [UIColor clearColor];
                    textField.textColor = [UIColor grayColor];
                    textField.textAlignment = NSTextAlignmentLeft;
                    textField.font = [UIFont systemFontOfSize:UI_Font];
                    textField.editable = NO;
                    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                    textField.layer.borderWidth = 1.0;
                    textField.layer.cornerRadius = 5.0;
                    textField.text = storeInfoBean.col3;
                    
                    CGSize size = [storeInfoBean.col3 ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:textField.width lineBreakMode:NSLineBreakByCharWrapping];
                    
                    if (size.height > 25) {
                        [textField sizeToFit];
                    }
                    
                    
                    [self.contentScrollView addSubview:textField];
                    
                    self.y_point += 5 + textField.height;
                }
                
            }
        }
    }
    
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray*)getDatasSources
{
    WSStoreInfoBeanArray *storeinfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
    NSMutableArray* l_dataArray = [[NSMutableArray alloc]init];
    
    NSArray *pTypArray = nil;
    if (self.currentFuncs.filter && [self.currentFuncs.filter length] > 0) {
        pTypArray = [self.currentFuncs.filter componentsSeparatedByString:@","];
    }
    
    NSString *storeId = self.currentStore.Id ? self.currentStore.Id : self.currentSubEmpStore.Id;
    for(WSStoreInfoBean* f_storeInfo in storeinfoBeans.storeinfoArray)
    {
        if([f_storeInfo.storeId isEqualToString:storeId]&&
           (pTypArray && [pTypArray containsObject:f_storeInfo.typ]))
        {
            [l_dataArray addObject:f_storeInfo];
        }
    }
    return l_dataArray;
}

- (void)initDataSource
{
    [super initDataSource];
    
    NSArray* l_dataSources = [self getDatasSources];
    if (l_dataSources && [l_dataSources count] > 0) {
        
        [self.m_dataSources addObjectsFromArray:l_dataSources];

    }

}

- (NSArray *)getMemoServerDisValue
{
    WSStoreInfoBeanArray *storeinfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
    
    NSString *pTyp = nil;
    if (self.currentFuncs.filter && [self.currentFuncs.filter length] > 0) {
        pTyp = [[self.currentFuncs.filter componentsSeparatedByString:@","] firstObject];
    }
    pTyp = [pTyp stringByAppendingString:@"_memo"];
    
    NSString *storeId = self.currentStore.Id ? self.currentStore.Id : self.currentSubEmpStore.Id;
    NSMutableArray *memoValueArray = [NSMutableArray array];
    for(WSStoreInfoBean* f_storeInfo in storeinfoBeans.storeinfoArray)
    {
        if([f_storeInfo.storeId isEqualToString:storeId] && [pTyp isEqualToString:f_storeInfo.typ])
        {
            [memoValueArray addObject:f_storeInfo];
        }
    }
    
    return memoValueArray;
    
}

-(void)setColumnsDatasOfTitles
{
    if([self.titles count]==0)
    {
//        if (![self.currentFuncs.fv isEqualToString:@"V20T02"] && ![self.currentFuncs.fv isEqualToString:@"V20T05"] )
        {
            NSString *item = nil;
            if ([self.currentFuncs.ds isKindOfClass:[NSString class]] && ([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC])) {
                item = NSLocalizedString(@"default_left_attach_header_label", nil);
            }else{
                
                item =  NSLocalizedString(@"table_dict_title_project", nil); //项目
                if ([self.currentFuncs.fv isEqualToString:@"V20T02"]) {
                    WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray firstObject];
                    if (fb_Param
                        && fb_Param.name
                        && [fb_Param.name length] > 0) {
                        item = fb_Param.name;
                    }
                }
            }
            [self.titles addObject:item];
        }
        
        NSInteger paramCount = [self.currentFuncs.paramArray count];
        for(int i = 0 ; i < paramCount; i++)
        {
            if (i != 0) {
                WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
                [self.titles addObject:fb_Param.name];
            }
        }
        
    }
    
}

-(NSString*)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aProds
{
    WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:0];
    WSStoreInfoBean *sbinfo = [aProds objectAtIndex:[aIndex intValue]];
    return [sbinfo valueForKey:param.col];
//    return [aIndex stringValue];
}

-(NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(WSStoreInfoBean*)aStoreInfo
{
    NSLog(@"%@", aParam.col);
    return [aStoreInfo valueForKey:aParam.col];
//    return aStoreInfo.col1;
}

-(NSArray*)getDataBaseDatas
{
    return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    LogTrace();
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden =YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstLoadView) {
        CGFloat storeNameLabelHeight =  INTERFACE_IS_PHONE ? self.storeNameLabel.height : 0;
        
        [self reDrawGrideWithHeight:self.view.bounds.size.height -  SPACEHEIGTH - storeNameLabelHeight];
        
        _isFirstLoadView = NO;
    }
    
}

//获取数据库的内容
-(NSString*)getDatasFromDataBaseWithParam:(WSFuncsBean_Param*)aParam Data:(WSStoreInfoBean*)aStoreInfo
{
    if (aParam && aStoreInfo) {
        NSString *key = aParam.col;
        if (key && ![key isKindOfClass:[NSNull class]]) {
            NSString *value = [aStoreInfo valueForKey:key];
            return value;
        }
    }
    return nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
