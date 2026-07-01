//
//  WSEmbeddedNewAcvtViewController.m
//  WinSFA
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEmbeddedNewAcvtViewController.h"
#import "WSNestedNewAcvtModel.h"

@interface WSEmbeddedNewAcvtViewController ()

@end

@implementation WSEmbeddedNewAcvtViewController

- (void)createModel
{
    self.model = [[WSNestedNewAcvtModel alloc] init];
    
    self.hideUploadAlert = YES;
}
#pragma mark--AcvtViewDelegate---

- (void)acvtViewReloadHeaderTitle:(NSString*)headerTitle{
    
    headerTitle = [ISNULL(headerTitle) length] == 0 ?@"":headerTitle;
    if (self.reloadHeaderTitleBlock) {
        self.reloadHeaderTitleBlock(headerTitle, self);
    }
}





@end
