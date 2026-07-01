//
//  WSWorkFlowNoticeView.h
//  WinSFA
//
//  Created by Alicia on 2017/4/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNoticeView.h"

typedef void (^WSWorkFlowNoticeBlock)(WSFuncsBean *);

@interface WSWorkFlowNoticeView : WSNoticeView

@property (nonatomic, copy) WSWorkFlowNoticeBlock noticeBlock;
@property (nonatomic, strong) WSFuncsBean *fb;

@end
