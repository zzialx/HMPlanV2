//
//  WSEmbeddedAcvtViewControllerDelegate.h
//  WinSFA
//
//  Created by yang on 17/4/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#ifndef WSEmbeddedAcvtViewControllerDelegate_h
#define WSEmbeddedAcvtViewControllerDelegate_h


#endif /* WSEmbeddedAcvtViewControllerDelegate_h */


@class WSEmbeddedAcvtViewController;

@protocol WSEmbeddedAcvtViewControllerDelegate <NSObject>

- (void)embeddedAcvtController:(WSEmbeddedAcvtViewController *)controller confirmData:(NSDictionary *)dic;
- (void)embeddedAcvtControllerBeginToVisitStore:(WSEmbeddedAcvtViewController *)controller;

@end
