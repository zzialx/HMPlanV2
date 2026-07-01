//
//  PhotoBrowserViewController.h
//  PhotoBrowserTest
//
//  Created by Jiepeng Zheng on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSPhotoBrowserViewController;

@protocol WSPhotoBrowserDelegate <NSObject>

@optional
- (void)photoBrowserDeletePhoto:(NSString *)imageID;

- (void)photoBrowserEditPhoto:(NSString *)imageID;

@end

@interface WSPhotoBrowserViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *imageIDs;
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UINavigationItem *myNavigationItem;

@property (nonatomic, assign) BOOL enableEdit;

@property (nonatomic,assign) BOOL isAllowDeletePhoto;
@property (nonatomic, weak) id<WSPhotoBrowserDelegate> delegate;
@property (nonatomic , strong) NSDictionary * shareDataDict;


- (id)initWithImages:(NSMutableArray *)images;
- (id)initWithImageIDs:(NSMutableArray *)imageIDs;
- (void)gotoPage:(NSInteger)page;

@end
