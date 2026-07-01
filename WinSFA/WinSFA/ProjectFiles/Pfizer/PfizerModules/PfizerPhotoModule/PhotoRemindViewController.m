//
//  PhotoRemindViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-25.
//
//

#import "PhotoRemindViewController.h"
#import "WSEmpInfoBeanArray.h"
#import "WSEmpInfoBean.h"

@interface PhotoRemindViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation PhotoRemindViewController

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
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
     [super viewDidLoad];
    
    WSEmpInfoBeanArray *storeinfoBeanArray = [WSAppData getObjectbyKey:@"empInfo"];
    NSString *filter = nil;
    if ([self.currentFuncs.fv isEqualToString:@"TB_V150"]) {
        for (WSFuncsBean *funcsBean in self.currentFuncs.funcsArray) {
            if ([funcsBean.fv isEqualToString:@"TAB_V1005"] && funcsBean.filter && [funcsBean.filter length] > 0) {
                filter = [funcsBean.filter copy];
                break;
            }
        }
    }else if ([self.currentFuncs.fv isEqualToString:@"TAB_V1005"] && self.currentFuncs.filter && [self.currentFuncs.filter length] > 0){
    
        filter = [self.currentFuncs.filter copy];
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    if (filter && [filter length] > 0) {
        for (WSEmpInfoBean *empInfoBean in storeinfoBeanArray.empInfoBeanArray) {
            if ([empInfoBean.typ isEqualToString:filter]) {
                [resultArray addObject:empInfoBean];
            }
        }
    }else{
        [resultArray addObjectsFromArray:storeinfoBeanArray.empInfoBeanArray];
    }
    self.dataArray = resultArray;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"photoremindcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    WSEmpInfoBean *storeInfoBean = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.text = storeInfoBean.col_name;
    return cell;
}

@end
