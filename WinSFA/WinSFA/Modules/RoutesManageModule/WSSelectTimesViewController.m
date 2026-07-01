//
//  SelectTimesViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSelectTimesViewController.h"
#import "WSCurrentTime.h"
#import "MBProgressHUD.h"
#import "WSOutPlanStoreBean.h"
#import "WSSubmicsBeanArray.h"

@interface WSSelectTimesViewController ()

@property (nonatomic,strong) NSMutableArray* listArray;
@property (nonatomic,strong) UIButton* timeBtn;
@property (nonatomic,strong) MBProgressHUD* m_HUD;
@property (nonatomic,copy) NSString* objID;


@end


@implementation WSSelectTimesViewController

- (MBProgressHUD *)m_HUD {
    if (!_m_HUD) {
        _m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.m_HUD];
    }
    return _m_HUD;
}

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        return self;
        
    }
    return nil;
}

- (void)loadView
{
    [super loadView];
    
    
    if ([self.currentFuncs.method length] > 0) {
        self.objID = self.currentFuncs.method;
    }else {
        self.objID = @"callPlan";
    }
    
    UILabel *timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    timeLabel.backgroundColor=[UIColor clearColor];
    timeLabel.textAlignment=NSTextAlignmentRight;
    timeLabel.text=NSLocalizedString(@"query_date", nil) ;
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    self.timeBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    self.timeBtn.frame=CGRectMake(80, 0, 120, 44);
    [self.timeBtn addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.timeBtn setTitle:[dateFormat stringFromDate:[WSCurrentTime getCurrentServerDate]] forState:UIControlStateNormal];
    
    UIButton* searchButton=[UIButton buttonWithType:UIButtonTypeSystem];
    searchButton.frame=CGRectMake(timeLabel.width+self.timeBtn.width, 0, 80, 44);
    [searchButton addTarget:self action:@selector(searchBarSearchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setTitle:NSLocalizedString(@"query", nil) forState:UIControlStateNormal];
    
    UIBarButtonItem* labelBarItem=[[UIBarButtonItem alloc]initWithCustomView:timeLabel];
    UIBarButtonItem* timeBarItem=[[UIBarButtonItem alloc]initWithCustomView:self.timeBtn];
    UIBarButtonItem* searchBarItem=[[UIBarButtonItem alloc]initWithCustomView:searchButton];

    UIToolbar*heardBarView=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [heardBarView setItems:[NSArray arrayWithObjects:labelBarItem,timeBarItem,searchBarItem, nil]];
    heardBarView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    
    self.listArray=[NSMutableArray array];
    
    self.tableView.tableHeaderView = heardBarView;
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
}


- (void)showDatePicker{
    WSPickerViewType pickerViewType = WSPickerViewTypeDate;
    
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType];
    
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
}

- (void)setDateContent:(NSDate *)date {
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [self.timeBtn setTitle:[dateFormat stringFromDate:date] forState:UIControlStateNormal];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    [self showDatePicker]; 
    return NO;
}


- (void)searchBarSearchButtonClicked{
    
    self.m_HUD.labelText = NSLocalizedString(@"please_wait",nil);
    [self.m_HUD show:YES];
    
    NSMutableDictionary*willPostDic=[[NSMutableDictionary alloc]init];
    if (self.timeBtn.titleLabel.text) {
        [willPostDic setObject:self.timeBtn.titleLabel.text forKey:@"docDate"];
    }
    
    [willPostDic setObject:self.objID forKey:@"objId"];


    //点击搜索按钮开始发送请求
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestHaveBeenDone:) name:@"roadManagerRequest" object:nil];
    
    [[WSRequestHelper shareInstance] postRequestOnRoadsManager:willPostDic notifyName:@"roadManagerRequest"];
}

//请求完数据后 该方法将被调用
-(void)requestHaveBeenDone:(NSNotification*)notification{
    
    [self.m_HUD hide:YES];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"roadManagerRequest" object:nil];

    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary*requestData=[[notification object] objectFromJSONString];
        if(![notification.object isKindOfClass:[NSError class]]){
            if(self.listArray.count>0){
                [self.listArray removeAllObjects];
            }
            [self.listArray addObjectsFromArray:[requestData objectForKey:self.objID]];
            [self.tableView reloadData];
        }
    }
}

#pragma mark tableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headHeight = 0;
    return headHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.listArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: SimpleTableIdentifier];

    }
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    NSDictionary*searchResultData=[self.listArray objectAtIndex:indexPath.row];
    
    if([self.objID isEqualToString:@"callPlan"]){
        
        NSString *text = [searchResultData objectForKey:@"name"];
        NSString *code = searchResultData[@"cod"];
        if ([code length] > 0) {
            text = [NSString stringWithFormat:@"%@-%@",code,text];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
        cell.textLabel.text = text;
        
        
    }else{
        if(![[searchResultData objectForKey:@"subEmpName"] isKindOfClass:[NSNull class]]){
            cell.textLabel.text=[searchResultData objectForKey:@"subEmpName"];
        }else{
            cell.textLabel.text=[searchResultData objectForKey:@"subOrgName"];
        }
    }
    return cell;
    
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
}


@end
