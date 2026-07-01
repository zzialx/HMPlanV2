//
//  WSDropListHorizontalScrollButtonView.h
//  WinSFA
//
//  Created by HZH on 2018/3/22.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSBaseDropListView.h"

@interface WSDropListHorizontalScrollButtonView : WSBaseDropListView

@property (nonatomic, assign) BOOL isReadOnly;

@property (nonatomic, copy) NSString *displayMode;


@end
