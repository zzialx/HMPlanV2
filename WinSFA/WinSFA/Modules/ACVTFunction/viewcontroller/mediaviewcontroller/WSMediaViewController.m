
//
//  WSMediaViewController.m
//  WinSFA
//
//  Created by winchannel on 15/4/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMediaViewController.h"
#import "I_Media_OperationDelegate.h"
#import "I_Media.h"
#import "I_Media_Info.h"
#import "IAttachMent.h"
#import "WSInterAction.h"

#import "WSMediaPanel.h"

@interface WSMediaViewController ()<WSWidgetDelegate>{
    BOOL hasError;
}

@end

@implementation WSMediaViewController

@synthesize currentMediaInfo;

-(id)init{
    
    self = [super init];

    if (self) {
        
        
        mediaconfig =[[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mediaconfig" ofType:@"plist"]];
        
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    currentMediaInfo = (NSObject<IAttachment> *)[self.executeParam execute_class_param];
    
    NSString  *mediatype =[currentMediaInfo  getFileType];
    
    NSString  *classname = [mediaconfig valueForKey:mediatype];
    
    mediaview = [[NSClassFromString(classname) alloc] initMediaFrame:self.view.bounds];
    
    ((UIView *)mediaview).autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [mediaview setMediaPlayDelegate:self];
    
    [(WSMediaPanel*)mediaview setDelegate:self];
    
    [mediaview setMediaInfo:currentMediaInfo];
    
    
    [(WSMediaPanel*)mediaview setParentViewController:self];
    
    [self.view addSubview:(UIView *)mediaview];
    
    if (classname == nil || [classname length] == 0 || mediaview == nil) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:nil message:[NSString stringWithFormat:@"暂不支持%@类型的播放", mediatype]];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert show];
    }
    
    if ([currentMediaInfo getFilename]) {
        self.title = [currentMediaInfo getFilename];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!hasError && !self.isHidden) {
        [mediaview playTheMeida];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)showFinishButton {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"complete" style:UIBarButtonItemStyleDone target:self action:@selector(playFinish)];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)playFinish {
    if ([self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        [self.executeParam setExecute_result:currentMediaInfo];
        [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
    }
    
    if ([self.executeParam  direct_type]==DIRECT_TYPE_PUSH) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark WSXLSXPanel(WSWidgtDelegate) Method
- (void)executeAnyOperationWith:(WSInterAction *)interaction {
    self.isHidden = YES;
    if ([self.executeParam direct_type] == DIRECT_TYPE_PUSH) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark I_Media_OperationDelegate method
//开始播放当前媒体
-(void)beginPlayCurrentMedia:(NSObject<I_Media> *)widget{
    NSLog(@"begin play");
}
//当前媒体已经在播放阶段
-(void)currentMediaInPlay:(NSObject<I_Media> *)widget{
    NSLog(@"in play");
}
//当前媒体暂停播放
-(void)currentMediaInPause:(NSObject<I_Media> *)widget{
    NSLog(@"in pause");
}
//当前媒体播放完毕
-(void)currentMediaPlayEnd:(NSObject<I_Media> *)widget{
    
    NSLog(@"play end");
    
    [currentMediaInfo setIsExplored:YES];
    [self showFinishButton];
}

- (void)currentMediaPlayError:(NSObject<I_Media> *)widget {
    NSLog(@"play error");
    hasError = YES;
    [self showFinishButton];
}

@end
