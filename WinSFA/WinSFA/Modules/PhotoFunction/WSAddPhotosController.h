//
//  WSAddPhotosController.h
//  WinSFA
//
//  Created by winchannel on 16/1/14.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "WSPhotoBrowseView.h"

@interface WSAddPhotosController : WCBaseViewController<WSPhotoBrowseViewDelegate>

@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UINavigationItem *myNavigationItem;

@property (nonatomic, strong) WSPhotoBrowseView *photoBrowseView;
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, assign) int index;


@end
