//
//  WSAuthorizationViewController.m
//  WinSFA
//
//  Created by heju on 14-11-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAuthorizationViewController.h"
#import "WSReportFormController.h"
#import "WSMjetLoginManager.h"

#define TitleHeight 20
#define TitleLabelY 10
#define TextViewX 10

#define ScrollViewX 10
#define TextViewHeightMax 5000
#define TextViewAddHeight 50
#define ButtonAddY 10
#define ButtonsSpace 70
#define ButtonX   30
#define AuthorizationButtonWith 110
#define AuthorizationButtonHeight 30
#define ButtonBaeTag 1000

#define kURRegsterCountURL    (@"hw/speHwAwardMobileRegist.do?method=registIndex")

@interface WSAuthorizationViewController ()
@property (nonatomic, assign) CGRect currentRect;

@end

@implementation WSAuthorizationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
        //[[UIApplication sharedApplication] setStatusBarHidden:YES];
        //self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
    if (INTERFACE_IS_PAD) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg_lanscape.png"]];
    }
    else
    {
    	if (IsIphone5) {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg-568.png"]];
	    } else {
	        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bg.png"]];
        }
    }
     */
    if (self.navigationController) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    self.title = NSLocalizedString(@"termsandconditions_name", nil);
    [self createSubViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewWillDisappear:animated];
}
- (void)createSubViews {
    //
    self.currentRect = [self.view bounds];
    
       CGRect  scrollViewRect = CGRectMake(ScrollViewX, 0 ,  self.currentRect.size.width - ScrollViewX * 2, self.currentRect.size.height - 20*2 + 64);
    
    UIScrollView * authorizationScrollView = [[UIScrollView alloc]initWithFrame:scrollViewRect];

    authorizationScrollView.contentSize = CGSizeMake(self.view.width - ScrollViewX * 2,self.view.height );
   
    
    authorizationScrollView.pagingEnabled = NO;
    authorizationScrollView.scrollEnabled = YES;
    authorizationScrollView.showsHorizontalScrollIndicator = NO;
    authorizationScrollView.showsVerticalScrollIndicator = YES;
//    authorizationScrollView.layer.cornerRadius = 5.0f;
//    authorizationScrollView.layer.borderColor = [[UIColor grayColor] CGColor];
//    authorizationScrollView.layer.borderWidth = 1.0f;
    authorizationScrollView.clipsToBounds = YES;
    authorizationScrollView.bounces = NO;
    [self.view addSubview:authorizationScrollView];
    
//    //
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.width, TitleHeight)];
//    titleLabel.font = [UIFont systemFontOfSize:UI_Font];
//    titleLabel.backgroundColor = MAIN_TINT_COLOT;
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text = NSLocalizedString(@"termsandconditions_name", nil);
//    titleLabel.font = [UIFont systemFontOfSize:17];
//    titleLabel.text = @"注册须知";
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:titleLabel];
    
    //
    CGRect textViewRect = CGRectMake(0, 0, authorizationScrollView.size.width, self.view.height);
    UITextView *authorizationTextView = [[UITextView alloc]initWithFrame:textViewRect];
    authorizationTextView.textAlignment = NSTextAlignmentLeft;
    authorizationTextView.editable = NO;
    authorizationTextView.scrollEnabled = NO;
    authorizationTextView.backgroundColor = [UIColor whiteColor];
    authorizationTextView.font = [UIFont systemFontOfSize:UI_Font];
   
    authorizationTextView.text = NSLocalizedString(@"termsandconditions", nil);
    CGSize size;
    if (authorizationTextView.text) {
        size = [authorizationTextView.text ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:self.view.width - ScrollViewX * 2 lineBreakMode:NSLineBreakByCharWrapping];
        CGFloat systemVersion = [[UIDevice currentDevice] systemVersionByFloat];
        CGFloat heigthOffSet =  systemVersion < 7.0 ? 55.0f:70.0f; //
        size.height = size.height + heigthOffSet;
        textViewRect.size.height = size.height ;
        authorizationTextView.frame = textViewRect;
    }
    [authorizationScrollView addSubview:authorizationTextView];
   
    
    //
    UIFont *buttonFont = [UIFont systemFontOfSize:16];
    
    UIButton *authorizationButton = [[UIButton alloc]init];
    authorizationButton.frame = CGRectMake(ButtonX, size.height + ButtonAddY, AuthorizationButtonWith, AuthorizationButtonHeight);
    authorizationButton.tag = ButtonBaeTag;
    [authorizationButton setTitle:NSLocalizedString(@"refuse", nil) forState:UIControlStateNormal];
    [authorizationButton.titleLabel setFont:buttonFont];
    authorizationButton.backgroundColor = [UIColor whiteColor];
    authorizationButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    authorizationButton.layer.borderWidth = 1.0;
    authorizationButton.layer.cornerRadius = 5.0;
    
    [authorizationButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [authorizationButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [authorizationScrollView addSubview:authorizationButton];
    //
    UIButton *noAuthorizationButton = [[UIButton alloc]init];
    noAuthorizationButton.frame = CGRectMake(authorizationScrollView.width - ButtonX - AuthorizationButtonWith, size.height + ButtonAddY, AuthorizationButtonWith, AuthorizationButtonHeight);
    noAuthorizationButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    noAuthorizationButton.tag = ButtonBaeTag + 1;
    [noAuthorizationButton setTitle:NSLocalizedString(@"approval", nil) forState:UIControlStateNormal];
    
    [noAuthorizationButton.titleLabel setFont:buttonFont];
    
    [noAuthorizationButton setTitleColor:[UIColor colorWithRed:0.21f green:0.53f blue:0.90f alpha:1.00f] forState:UIControlStateNormal];
    
    [noAuthorizationButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    noAuthorizationButton.backgroundColor = [UIColor whiteColor];
    noAuthorizationButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    noAuthorizationButton.layer.borderWidth = 1.0;
    noAuthorizationButton.layer.cornerRadius = 5.0;
    
    [authorizationScrollView addSubview:noAuthorizationButton];
    
    // 重置 scrollView的 contentSize
//    if (self.navigationController) {
//            authorizationScrollView.contentSize = CGSizeMake(self.view.width - ScrollViewX * 2, authorizationTextView.frame.size.height  + AuthorizationButtonHeight + 2 * ButtonAddY +128);
//    }else{
            authorizationScrollView.contentSize = CGSizeMake(self.view.width - ScrollViewX * 2, authorizationTextView.frame.size.height  + AuthorizationButtonHeight + 2 * ButtonAddY + 100);
        
   // }

    
}



- (void)buttonClicked:(UIButton *)sender {
    
    if (sender.tag == ButtonBaeTag) {
        
        NSUserDefaults *firstLauchDefaults = [NSUserDefaults standardUserDefaults];
        BOOL firstLauch = [firstLauchDefaults boolForKey:@"AppFirstLaunch"];
        if (!firstLauch) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            [self.navigationController popViewControllerAnimated:YES];
            
        
        }else{
            
            exit(0);
        }
        
    } else if (sender.tag == ButtonBaeTag + 1) {
        
        NSString *isMjet = @"0";
        
        if ([WSMjetLoginManager isNeedMejtLogin]) {
            isMjet = @"1";
        }
        
        NSString *registerURL = [NSString stringWithFormat:@"%@%@&isMjetFlag=%@",[WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName],kURRegsterCountURL, isMjet];
        
        
        WSReportFormController *registerController =[[WSReportFormController alloc]initWithURL:[NSURL URLWithString:registerURL]];
        registerController.title = NSLocalizedString(@"sign_up",nil);
        [self.navigationController pushViewController:registerController animated:YES];
        

        NSString *authorization = [WSPlistHelper valueForKey:OPEN_TC_EVERY_TIME withPlistName:kConfilgFileName];
        NSUserDefaults *firstLoginDefaults = [NSUserDefaults standardUserDefaults];
        BOOL everLogin = [firstLoginDefaults boolForKey:@"everLogin"];
        if (authorization && [authorization isEqualToString:@"1"] && everLogin) {
            if ([_delegate respondsToSelector:@selector(wsAuthorizationViewController:didSelected:)]) {
                [_delegate wsAuthorizationViewController:self didSelected:sender];
            }
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
