//
//  WSOptPhotoBrowseViewController.h
//  WinSFA
//
//  Created by winchannel on 2017/9/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSOptPhotoBrowseViewController;

@protocol WSOptPhotoBrowseViewControllerDelegate <NSObject>

@optional
- (void)photoBrowserDeletePhoto:(NSString *)imageID;

- (void)photoBrowserEditPhoto:(NSString *)imageID;

@end

@interface WSOptPhotoBrowseViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *imageIDs;
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (strong, nonatomic) UINavigationBar *navigationBar;
//@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UINavigationItem *myNavigationItem;

@property (nonatomic, assign) BOOL enableEdit;

@property (nonatomic,assign) BOOL isAllowDeletePhoto;

@property (nonatomic, assign) id<WSPhotoBrowserDelegate> delegate;

- (id)initWithImageIDs:(NSMutableArray *)imageIDs;
- (id)initWithImageIDs:(NSMutableArray *)imageIDs withImageDescription:(NSMutableArray *)descriptions;
- (void)gotoPage:(NSInteger)page;

@end
