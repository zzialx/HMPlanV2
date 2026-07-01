//
//  WCPrizerBusinessOtherVisitViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/9/13.
//
//

#import "WCPrizerBusinessOtherVisitViewController.h"
#import "WCPrizerBusinessAddEntityViewController.h"
#import "WSFacTable.h"

@interface WCPrizerBusinessOtherVisitViewController ()

@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) WSFuncsBean *currentFuncs;

@property (nonatomic, strong) NSArray *newsListArray;

@end

@implementation WCPrizerBusinessOtherVisitViewController


#pragma mark - init & dealloc methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithFuncs:(WSFuncsBean *)funcs {
    self = [super init];
    if (self) {
        // Do something
        self.currentFuncs = funcs;
    }
    return self;
}


- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:[self.view bounds] style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    
    NSString *addstring = NSLocalizedString(@"add_label", nil);
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:addstring style:UIBarButtonItemStylePlain target:self action:@selector(addEntity:)];
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItem = button;
    } else {
        self.navigationItem.rightBarButtonItem = button;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
//    _newsListArray = [[WSFacTable sharedTable] queryAcvtInfo:nil acvtNewStore:nil Funcs:self.currentFuncs AcvtId:@"null"];
    NSLog(@"%@", _newsListArray);
    [_tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_newsListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"otherVisitCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
//    NSDictionary *dic = [_newsListArray objectAtIndex:indexPath.row];
    NSString *theme = @"";
    NSString *visitType = @"";
    //请使用queryAcvtInfo方法提取数据然后修改。
//    NSArray *qstArray = [dic objectForKey:@"fac_qst"];
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable、WSAddAcvtTable、WSFacTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
    
//    for (WSFacQstObject* object in qstArray) {
//        NSString *qst_id = object.qst_id;
//        if ([qst_id isEqualToString:@"theme"]) {
//            theme = object.opt_val;
//        } else if ([qst_id isEqualToString:@"visitType"]) {
//            visitType = object.opt_val;
//        }
//    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", visitType, theme];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataSource = [_newsListArray objectAtIndex:indexPath.row];
    WCPrizerBusinessAddEntityViewController *vc = [[WCPrizerBusinessAddEntityViewController alloc] initWithFuncs:self.currentFuncs dataSource:dataSource];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.ownParentViewController.navigationController) {
        [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - UIBarButtonItem SEL
- (void)addEntity:(id)sender {
    WCPrizerBusinessAddEntityViewController *vc = [[WCPrizerBusinessAddEntityViewController alloc] initWithFuncs:self.currentFuncs];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.ownParentViewController.navigationController) {
        [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
    }
}

@end
