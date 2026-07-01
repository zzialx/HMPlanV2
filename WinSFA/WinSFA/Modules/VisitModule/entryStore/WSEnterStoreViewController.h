//
//  EnterStoreViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "WSInoutStoreTable.h"
#import "WSValidateData.h"
#import "WSRadioButton.h"

@interface WSEnterStoreViewController : BaseViewController <UIAlertViewDelegate, WSValidateData>
{}
@property (nonatomic, copy) NSString *md5;

@property (nonatomic, strong) NSDictionary *isPhotoRequire;

@property (nonatomic,assign) int reflect_parent_id;

@end
