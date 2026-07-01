 //
//  WSNewAllSubMsgsViewController.h
//  WinSFA
//
//  Created by xiajl on 14-10-28.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSMsgsBean;

@interface WSNewAllSubMsgsViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *msgArray;


- (instancetype)initWithArrayMsgsBean:(NSMutableArray *)msgArray;

- (BOOL) isScrolling;
@end
