//
//  WSImageBrowserViewController.m
//  WinSFA
//
//  Created by Stephanie on 16/8/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSImageBrowserViewController.h"
#import "WSImageBrowserView.h"
#import "WSNavigationBar.h"

@interface WSImageBrowserViewController ()
{
    NSArray *_imageArray;
    NSInteger _index;
}

@end

@implementation WSImageBrowserViewController

- (instancetype)initWithImages:(NSArray *)imageArr index:(NSInteger)index
{
    self = [super init];
    
    if (self) {
        _imageArray = imageArr;
        _index = index;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self backItemAction:@selector(backAction) target:self];
    
    WSImageBrowserView * view = [[WSImageBrowserView alloc]initWithFrame:INTERFACE_IS_PAD ? CGRectMake(0, 0, BROWSERVC_WIDTH, BROWSERVC_HEIGNT) : self.view.bounds andImage:_imageArray andImageIndex:_index];
    
    if (INTERFACE_IS_PAD) {
        view.frame = CGRectMake((BROWSERVC_WIDTH - view.width)/2,(BROWSERVC_HEIGNT - view.size.height)/2, view.size.width, view.size.height);
    } else {
        view.frame = CGRectMake(view.origin.x,(self.view.height - view.size.height)/2, view.size.width, view.size.height);
    }
    
    [self.view addSubview:view];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
