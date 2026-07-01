//
//  ModifyStoreInfoViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSModifyStoreInfoViewController.h"
#import "WSRequestHelper.h"
//#import "ConfigFileController.h"
#import "WSFuncsBean_other.h"
#import <QuartzCore/QuartzCore.h>

#define RENEWSTOREINFO          @"renewStoreInfo"

@interface WSModifyStoreInfoViewController ()

@property (nonatomic, strong) NSDictionary *storeInfoDic;

@property (nonatomic, assign) NSInteger viewOffset;
@property (nonatomic, strong) NSMutableDictionary *otherViewDic;

@end

@implementation WSModifyStoreInfoViewController

@synthesize alert;
@synthesize m_CellContentViews = _m_CellContentViews;
@synthesize grow = grow_;
@synthesize storeInfoDic = _storeInfoDic;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store StoreInfo:(NSDictionary *)dic {
    self = [super initWithFuncs:funcs Store:store];
    if (self) {
        self.storeInfoDic = dic;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self addOptView];
    [self addFuncsOtherBeanView];

}


-(void)uploadFinished:(id)sender
{
    
    //NSString* info = [[sender userInfo]JSONString];
    //NSLog(@"info is = %@",info);
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:RENEWSTOREINFO 
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
//        NSString *UpdateString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:UpdateString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    }
        
}


//-(void)sendModifyStoreInfo
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(uploadFinished:)
//                                                 name:RENEWSTOREINFO 
//                                               object:nil];
//    
//    NSMutableDictionary* l_dic = [[[NSMutableDictionary alloc]init]autorelease];
//    if([self.datas count]>0&&[self.m_CellContentViews count]>1)
//    {
////        [l_dic setObject:[self.datas objectAtIndex:0] forKey:@"name"];
////        [l_dic setObject:[self.datas objectAtIndex:1] forKey:@"cod"];
////        [l_dic setObject:[self.datas objectAtIndex:2] forKey:@"addr"];
////        [l_dic setObject:self.linkman forKey:@"linkman"];
////        [l_dic setObject:self.linktel forKey:@"linktel"];
//        [l_dic setObject:[self.datas objectAtIndex:0] forKey:@"name"];
//        [l_dic setObject:[self.datas objectAtIndex:1] forKey:@"cod"];
//        [l_dic setObject:[self.datas objectAtIndex:2] forKey:@"linkman"];
//        [l_dic setObject:self.linktel forKey:@"linktel"];
//        [l_dic setObject:self.linkAddress forKey:@"addr"];
//        
//    }else
//        return;
//    
//    [[WSRequestHelper shareInstance]PostModifyStoreInfo:l_dic NotifyName:RENEWSTOREINFO Store:self._store];
//    
//    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    aiv.hidesWhenStopped = YES;
//    [aiv startAnimating];
//    NSString *tmpString = NSLocalizedString(@"正在更新\n请稍候...",nil); 
//    alert = [[[UIAlertView alloc] initWithTitle:tmpString
//                                        message:nil
//                                       delegate:self 
//                              cancelButtonTitle:nil 
//                              otherButtonTitles:nil, nil] 
//             autorelease];
//    
//    aiv.frame = [[ConfigFileController sharedInstanceMethod] getCGRectFromString:@"PartOfActivityFrame"];
//    [alert addSubview:aiv];
//    [alert show];
//    [aiv release];
//}
//
//

- (id)initWithStoreInfo:(id)store
{

    if (self)
    {

    }
    
    return self;
}


-(void)addFuncsOtherBeanView {
    if(self.currentFuncs.otherArray == nil)
        return;
    int i = 0;
    int y_point = 5;
    
//    BOOL existTypeS = NO;
//    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:[self.currentFuncs.otherArray count]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height - 108)];
    
    self.otherViewDic = [[NSMutableDictionary alloc] init];
    for (WSFuncsBean_other *f_otherBean in self.currentFuncs.otherArray) {
        if ([f_otherBean.tpy isEqualToString:OTHER_TPY_TL]) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y_point, 300, 29)];
            titleLabel.text = f_otherBean.name;
            [scrollView addSubview:titleLabel];
            y_point += 29;
            
            NSString *content = [self.storeInfoDic objectForKey:f_otherBean.col];
            UIFont *font = [UIFont systemFontOfSize:16];
            if (![content isKindOfClass:[NSString class]]) {
                content = @"";
            }
            CGSize size = [content ws_sizeWithFont:font constrainedToWidth:300 lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y_point, 300, size.height + 10)];
            contentLabel.text = content;
            contentLabel.numberOfLines = 0;
            contentLabel.font = font;
            
            contentLabel.layer.borderWidth = 1;
            contentLabel.layer.cornerRadius = 5;
            contentLabel.layer.masksToBounds = YES;
            contentLabel.layer.borderColor = [[UIColor grayColor] CGColor];
            contentLabel.backgroundColor = [UIColor lightGrayColor];
            
            [scrollView addSubview:contentLabel];
            y_point += contentLabel.size.height + 5;
        }
        if ([f_otherBean.tpy isEqualToString:OTHER_TPY_T]) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y_point, 300, 29)];
            label.text = f_otherBean.name;
            [scrollView addSubview:label];
            y_point += 29;
            
            UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, y_point, 300, 29)];
            textfield.tag = OTHER_TEXTFIELD_TAG + i;
            textfield.returnKeyType = UIReturnKeyDone;
            textfield.backgroundColor = [UIColor whiteColor];
            [textfield setBorderStyle:UITextBorderStyleRoundedRect];
            
            NSString *content = [self.storeInfoDic objectForKey:f_otherBean.col];
            if (![content isKindOfClass:[NSString class]]) {
                content = @"";
            }
            textfield.text = content;
            [textfield addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
            [self addCancellOKButton:textfield];
            [scrollView addSubview:textfield];
            y_point += 29 + 5;
            
            if (textfield) {
                [self.otherViewDic setObject:textfield forKey:f_otherBean.col];
            }
        }
        i++;
    }
    scrollView.contentSize = CGSizeMake(320, y_point);
    [self.view addSubview:scrollView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addToolBar];
}


- (void)upload {
    [self uploadDatas];
    [self backToParent];
}

- (void)uploadDatas {
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSArray *titleArr = [self.otherViewDic allKeys];
    for (NSString *title in titleArr) {
        UIView *view = [self.otherViewDic objectForKey:title];
        NSString *content = nil;
        if ([view isKindOfClass:[UITextField class]]) {
            content = ((UITextField *)view).text;
        }
        [dic setValue:content forKey:title];
    }
    
    [uploadMgr PostModifyStoreInfo:dic NotifyName:RENEWSTOREINFO Store:self.currentStore];
//    [self performSelector:@selector(backToParent)];
    
    [super uploadVisitAction];
}

- (void)textWatcher:(id)sender {
    self.m_CurrentInputView = sender;
}

- (void)keyboardWasShown:(NSNotification *)notif {
    UIView *view = nil;
    if ([self.m_CurrentInputView isKindOfClass:[UIView class]]) {
        view = (UIView *)self.m_CurrentInputView;
    }
    CGRect rect = self.view.frame;
    if (rect.origin.y < 0) {
        return;
    }
    UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    CGPoint point = [[view superview] convertPoint:view.frame.origin toView:wc];
    float offset = 175;
    if (point.y > offset) {
        rect.origin.y -= point.y - offset;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = rect;
    }];   
}

- (void)keyboardWasHidden:(NSNotification *)notif {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, 320, 480);
    }];
}

@end
