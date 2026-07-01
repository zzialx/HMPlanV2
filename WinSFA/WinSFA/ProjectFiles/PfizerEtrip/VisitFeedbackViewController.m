//
//  VisitFeedbackViewController.m
//  WinSFA
//
//  Created by zhangke on 14-5-9.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "VisitFeedbackViewController.h"
#import "WSEmpInfoBeanArray.h"
#import "WSEmpInfoBean.h"


@interface VisitFeedbackViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * empinfoArray;

@end


@implementation VisitFeedbackViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if(self.m_ParentViewController != nil) {
        self.m_ParentViewController.navigationController.toolbarHidden = YES;
    } else {
        self.navigationController.toolbarHidden = YES;
    }
}

- (void)loadView {
    [super loadView];
    
    WSEmpInfoBeanArray* array= [WSAppData getObjectbyKey:EMPINFO];
    NSString* filter=[[self.currentFuncs.funcsArray objectAtIndex:0] filter];
    NSPredicate* pre=[NSPredicate predicateWithFormat:@"typ==%@",filter];
    self.empinfoArray=[NSMutableArray arrayWithArray:[array.empInfoBeanArray filteredArrayUsingPredicate:pre]];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.empinfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"photoremindcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    [cell.contentView removeAllSubviews];
    
    WSEmpInfoBean *bean = [self.empinfoArray objectAtIndex:[indexPath row]];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.text = bean.col_name;
    if([bean.col_type isEqualToString:@"L"]){
        UILabel* detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-100-80, 0, 100, cell.height)];
        detailLabel.text=bean.col_value;
        detailLabel.font=[UIFont systemFontOfSize:UI_Font];
        detailLabel.textAlignment=NSTextAlignmentRight;
        [cell.contentView addSubview:detailLabel];
    }else if([bean.col_type isEqualToString:@"C"]){
        UIImage* image=[UIImage imageForName:@"icn_check"];
        UIImageView* checkImageView=[[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-image.size.width-80, 0, image.size.width, image.size.width)];
        [cell.contentView addSubview:checkImageView];
        
        if([bean.col_value isEqualToString:@"1"]){
            checkImageView.image=image;
        }else{
            checkImageView.image=[UIImage imageForName:@"icn_nocheck"];
        }
        
    }
    

    return cell;
}


@end
