//
//  WSNewSubMsgsViewController.h
//  WinSFA
//
//  Created by xiajl on 14-10-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSMsgsBean;

@interface WSNewSubMsgsViewController : UIViewController

@property (nonatomic, strong) WSMsgsBean *iMsgBean;
@property (nonatomic ,copy)NSString *categoryTitle;

- (id)initWithMsgsBean:(WSMsgsBean *)aMsgsBean;


- (BOOL) isScrolling;
@end
