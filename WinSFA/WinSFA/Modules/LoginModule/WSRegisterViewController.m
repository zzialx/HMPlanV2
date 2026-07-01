//
//  WSRegisterViewController.m
//  WinSFA
//
//  Created by winchannel on 16/4/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRegisterViewController.h"
#import "WSReportFormController.h"

#define UI_Content_FONT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16.0f : 20.0f)
#define UI_Content_XOffet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 5 : 30)
#define UI_Content_YOffet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 30)
#define UI_Content_ContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? self.view.bounds.size.width - 10 : self.view.bounds.size.width - 48)

#define UI_CancelBtnLabel_FONT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16.0f : 20.0f)

#define UI_CancelBtn_Height  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 60 : 60)

#define UI_CancelBtn_XOffet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 31 : 100)

#define UI_CancelBtn_Width  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 104 : 240)

#define UI_FootView_Height  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 60 : 120)

@interface WSRegisterViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *registerTableView;
@end

@implementation WSRegisterViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"termsandconditions_name", nil);
    
    
    UIView *footView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, UI_FootView_Height)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton  *cancelBtn =[[UIButton alloc]initWithFrame:CGRectMake(UI_CancelBtn_XOffet, (footView.height - UI_CancelBtn_Height)/2.0, UI_CancelBtn_Width, UI_CancelBtn_Height)];
    [cancelBtn.layer setMasksToBounds:YES];
    [cancelBtn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [cancelBtn.layer setBorderWidth:1.0]; //边框宽度
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:UI_CancelBtnLabel_FONT];
    [cancelBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitle:NSLocalizedString(@"拒 绝",nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageFromColor:[UIColor grayColor] with:cancelBtn.bounds] forState:UIControlStateSelected];
    [cancelBtn addTarget:self action:@selector(cancelButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:cancelBtn];
    
    UIButton  *registerBtn =[[UIButton alloc]initWithFrame:CGRectMake(footView.width - UI_CancelBtn_XOffet - UI_CancelBtn_Width, (footView.height - UI_CancelBtn_Height)/2.0, UI_CancelBtn_Width, UI_CancelBtn_Height)];
    registerBtn.backgroundColor = [UIColor clearColor];
    [registerBtn.layer setMasksToBounds:YES];
    [registerBtn.layer setCornerRadius:5.0];//设置矩形四个圆角半径
    [registerBtn.layer setBorderWidth:1.0]; //边框宽度
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:UI_CancelBtnLabel_FONT];
    [registerBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [registerBtn setTitle:NSLocalizedString(@"同 意",nil) forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[UIImage imageFromColor:[UIColor grayColor] with:registerBtn.bounds] forState:UIControlStateSelected];
    [registerBtn setTitleColor:[UIColor colorWithRed:0.47f green:0.83f blue:0.98f alpha:1.00f] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(OKButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:registerBtn];
    
    
    
    _registerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    _registerTableView.dataSource = self;
    _registerTableView.delegate = self;
    _registerTableView.tableFooterView = footView;
    _registerTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _registerTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_registerTableView];
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellInditifier = @"registerIdentifier";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellInditifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //[cell.contentView removeAllSubviews];
    NSString *noteContent = NSLocalizedString(@"termsandconditions", nil);
    
    CGFloat height = [self termsandconditionContentHeight];
    UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(UI_Content_XOffet, UI_Content_YOffet, UI_Content_ContentWidth, height)];
    contentLable.backgroundColor = [UIColor clearColor];
    contentLable.textAlignment = NSTextAlignmentLeft;
    contentLable.font = [UIFont systemFontOfSize:UI_Content_FONT];
    contentLable.numberOfLines = 0;
    contentLable.lineBreakMode = NSLineBreakByCharWrapping;
    contentLable.textColor = [UIColor blackColor];
    contentLable.text = noteContent;
    [cell.contentView addSubview:contentLable];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self termsandconditionContentHeight];
}

- (void)cancelButtonSelected{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppEverLaunch"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"everLogin"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstLogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // long-running task
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 exit(0);
                
            });
    });
    

   
}

- (void)OKButtonSelected{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"regsiterEnterLogin" object:nil];

}
- (CGFloat)termsandconditionContentHeight{
    
    NSString *noteContent = NSLocalizedString(@"termsandconditions", nil);
    CGSize size = [noteContent ws_sizeWithFont:[UIFont systemFontOfSize:UI_Content_FONT] constrainedToWidth:UI_Content_ContentWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    return size.height + 30;
    
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
