//
//  MV_LISTViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface WSMV_LISTViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>{}
@property (nonatomic, strong) NSNumber *iParentItemInfo; //Product info parent id
@property (nonatomic, strong) WCBaseViewController *selectedController;
@property (nonatomic, assign) BOOL isBatchUpload;
@property (nonatomic, assign) BOOL isBatchUploadFirstBack;  //多个问卷上传时，只返回一次即可。
@property (nonatomic, copy) NSString * fromModuleName;


-(void) initData;
- (NSInteger)itemCount;
-(UIViewController*)generateNextPageWithRow:(NSInteger)row;

- (BOOL)isValueChange;

- (void)setSelectedIndex:(NSInteger)index;

- (void)batchUpload;
- (void)batchUploadBackAction;
- (void)batchUploadBackToSave;

- (NSString *)getUploadStyle;

- (void)addControllerToCurrentTab:(UIViewController *)viewController;
- (BOOL)removeOtherController;


@end
