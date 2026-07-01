//
//  ProductManagerViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 8/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSProductManagerViewController.h"
#import "SuperWorkSpaceViewController.h"
#import "WSAcvtBean.h"
#import "WSFuncsBeanArray.h"
#import "WSFuncsBean.h"
//#import "ConfigFileController.h"
#import "WSAddNewProductViewController.h"
#import "WSPlistHelper.h"

@interface WSProductManagerViewController ()


@end

@implementation WSProductManagerViewController


#pragma mark - Private API

- (void)AddNewProduct
{
    if([self.currentFuncs.funcsArray count]<1)
        return;
    WSFuncsBean* l_fb = [self.currentFuncs.funcsArray objectAtIndex:0];
    WSAddNewProductViewController* newproductVC = [[WSAddNewProductViewController alloc] initWithFuncs:l_fb];
    [self.navigationController pushViewController:newproductVC animated:YES];
}

- (void)valueChange:(id)sender
{
    [super valueChange:sender];
    
    NSInteger selected = 0;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *sc = (UISegmentedControl *)sender;
        selected = sc.selectedSegmentIndex;
    }else if ([sender isKindOfClass:[NSNumber class]]) {
        selected = [sender intValue];
    }
    
    if (selected == 0) {
//        NSString* btntitle = NSLocalizedString(@"add_label", nil);
//        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:btntitle 
//                                                        style:UIBarButtonItemStylePlain 
//                                                        target:self 
//                                                        action:@selector(AddNewProduct)];
//        
//        self.navigationItem.rightBarButtonItem = button;
    }
    
}

@end

