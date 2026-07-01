//
//  WCBaseView.m
//  Quad
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCBaseView.h"

@implementation WCBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [[PKResManager sharedInstance] addChangeStyleObject:self];
    }
    return self;
}

- (void)changeStyle:(id)sender {
    // 第一步：重置需要手动更新的素材
    // 第二步：重新显示 [RSView setNeedLayout] && [RSViewController viewWillApear]
}
- (void)dealloc{
//    [[PKResManager sharedInstance] removeChangeStyleObject:self];
}
@end
