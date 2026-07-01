//
//  WSNoticeView.h
//  WinSFA
//
//  Created by Alicia on 2017/4/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WSCloseNoticeBlock)();

@interface WSNoticeView : UIView

@property (nonatomic, assign) BOOL isShowCloseButton;
@property (nonatomic, copy) WSCloseNoticeBlock closeBlock;

- (void)setNoticeText:(NSString *)text;

@end
