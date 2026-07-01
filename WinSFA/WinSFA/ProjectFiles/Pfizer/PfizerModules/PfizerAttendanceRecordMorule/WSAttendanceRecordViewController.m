//
//  WSAttendanceRecordViewController.m
//  WinSFA
//
//  Created by heju on 15/5/5.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAttendanceRecordViewController.h"
#import "WSMonthCalenderPanel.h"
#import "WSRequestHelper.h"


#define kNotifyName_speAattendancedetail @"speAattendancedetail"

@interface WSAttendanceRecordViewController ()

@property (nonatomic ,strong)WSMonthCalenderPanel *monthPanel;

@property (nonatomic, strong)UIScrollView *contentScrollView;
@property (nonatomic, strong)WSFuncsBean *funcs;

@end

@implementation WSAttendanceRecordViewController


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        // to  do something
        if (!_funcs) {
            _funcs = [[WSFuncsBean alloc] init];
        }
        _funcs = funcs;
        return self;
    }
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView {
    [super loadView];

    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.contentScrollView];
    
    if ([WSAppData getObjectbyKey:DUTY_ATTENDANCEDETAIL] && !_funcs.opt.searchCondReqNode) {
        [self showMonthCalenderPanel];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    if (_funcs.opt.searchCondReqNode && _funcs.opt.searchCondReqNode.length > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishRequest:)
                                                     name:kNotifyName_speAattendancedetail
                                                   object:nil];
        [[WSRequestHelper shareInstance] postRequestOnRoadsManager:@{@"objId" : _funcs.opt.searchCondReqNode} notifyName:kNotifyName_speAattendancedetail];
    }

}

- (void)finishRequest:(NSNotification *)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyName_speAattendancedetail object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error) {
        return ;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    id dataDic = [info objectFromJSONString];
    //考勤历史记录数据 节点
    WSDutyBeanArray *dutyArray = [[WSDutyBeanArray alloc] initWithObject:dataDic];
    if (dutyArray) {
        [[WSAppData sharedManager].datas setObject:dutyArray forKey:DUTY_ATTENDANCEDETAIL];
    }
    if ([WSAppData getObjectbyKey:DUTY_ATTENDANCEDETAIL] /*&& INTERFACE_IS_PAD*/) {
        [self showMonthCalenderPanel];
    }
}

- (void)showMonthCalenderPanel {
    if (_monthPanel == nil) {
        _monthPanel = [[WSMonthCalenderPanel alloc] initWithFrame:self.view.bounds funcs:self.funcs];
        _monthPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentScrollView addSubview:_monthPanel];
    } else {
        _monthPanel.hidden = NO;
        [_monthPanel reloadCollectionView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
