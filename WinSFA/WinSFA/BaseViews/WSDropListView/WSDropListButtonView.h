//
//  WSDropListButtonView.h
//  WinSFA
//
//  Created by Alicia on 17/1/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSBaseDropListView.h"

typedef NS_ENUM(NSInteger, WSDropListButtonStyle) {
    WSDropListButton,
    WSDropListButtonFit            // 文字自适应，SFA-17308 样式
};

@interface WSDropListButtonView : WSBaseDropListView

@property (nonatomic, assign) WSDropListButtonStyle buttonStyle;

@end
