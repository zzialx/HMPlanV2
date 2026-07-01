//
//  NewStoreListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSHeaderSearchView.h"
#import "WSBaseNewAcvtListViewController.h"

@interface WSNewStoreListViewController : WSBaseNewAcvtListViewController <WSHeaderSearchViewDelegate>

@property (nonatomic, copy) NSMutableString *addStoreStyle;
@property (nonatomic, strong) NSString *relate_sub_menu_code;




@end
