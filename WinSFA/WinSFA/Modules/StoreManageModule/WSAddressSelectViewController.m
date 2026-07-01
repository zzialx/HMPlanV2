//
//  AddressSelectViewController.m
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAddressSelectViewController.h"
#import "ZJPAddressPickerView.h"
#import "WSInterAction.h"

@interface WSAddressSelectViewController ()

@property (nonatomic, strong) ZJPAddressPickerView *apv;

@property (nonatomic, strong) NSDictionary *preInfoDic;

@end

@implementation WSAddressSelectViewController
@synthesize apv = _apv;
@synthesize preAddress = _preAddress;


-(CGRect)generateViewRect:(CGRect)frame{

    CGRect listRect;

    if (IOS8_OR_LATER) { //8.0及以上
        
        listRect = CGRectMake(0, 0,frame.size.width,frame.size.height-64);
    
    }
    
    else if (IOS7_OR_LATER){//7.0
        
        listRect  = CGRectMake(0, 0, frame.size.height, frame.size.width - 64);
        
    }
    
    else{// 6.0

        
        listRect = CGRectMake(0, 0,frame.size.height, frame.size.width-44);
        
    }

    return listRect;
    
}

- (id)initWithPreInfoDic:(NSDictionary *)infoDic {
    self = [super init];
    if (self) {
        self.preInfoDic = [NSDictionary dictionaryWithDictionary:infoDic];
    }
    return self;
}

- (void)done {
    
    if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
         NSDictionary *dic = [_apv resultWithDic];
        [self.executeParam  setExecute_result:dic];
        if ([self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
            
            [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
        }
    }else if (self.addressSelectDelegate && [self.addressSelectDelegate respondsToSelector:@selector(addressSelected:resultDic:)]) {
        NSDictionary *dic = [_apv resultWithDic];
        [self.addressSelectDelegate addressSelected:self resultDic:dic];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"complete",nil) style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    CGRect listRect = [self generateViewRect:self.view.frame];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back_label",nil)  style:UIBarButtonItemStylePlain target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back_label" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:item, leftItem, nil];
    
    self.apv = [[ZJPAddressPickerView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(listRect), 150) withPreInfoDic:self.preInfoDic];
    [self.view addSubview:_apv];
    self.view.backgroundColor = [UIColor whiteColor];
    

    // Do any additional setup after loading the view from its nib.
}

- (NSString *)address {
    return _apv.address;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
