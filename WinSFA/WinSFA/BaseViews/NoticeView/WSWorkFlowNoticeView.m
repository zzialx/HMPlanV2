//
//  WSWorkFlowNoticeView.m
//  WinSFA
//
//  Created by Alicia on 2017/4/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWorkFlowNoticeView.h"

@implementation WSWorkFlowNoticeView

- (void)viewTapAction:(UITapGestureRecognizer *)tapRecognizer {
    if (self.noticeBlock) {
        if (!self.fb) {
            DDLogError(@"Not set fb");
            return;
        }
        self.noticeBlock(self.fb);
    }
    [self removeFromSuperview];
}

@end
