//
//  ModifyStoreInfoViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreInfoViewController.h"
#import "BaseViewController.h"

@interface WSModifyStoreInfoViewController : BaseViewController <UITextFieldDelegate, UITextViewDelegate>
{}

@property (nonatomic, strong) UIAlertView       *alert;
@property (nonatomic, strong) NSMutableArray    *m_CellContentViews;
@property (nonatomic, readwrite) NSInteger      grow;

- (id)initWithStoreInfo:(id)store;
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store StoreInfo:(NSDictionary *)dic;

@end
