//
//  ManuallyUploadViewController.h
//  WinChannelFrameWork
//
//  Created by yang's on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol WSManuallyUploadViewControllerDelegate <NSObject>

- (void)manualUploadBackAction;

@end

@interface WSManuallyUploadViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) BOOL isInCheckUploadedDataFlow;

@property (nonatomic, assign) BOOL autoUploadDatas;

@property (nonatomic, weak) id<WSManuallyUploadViewControllerDelegate> delegate;

-(void)uploadCountRefresh;

@end
