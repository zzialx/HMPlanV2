//
//  WSAddNewStoreSelectView.h
//  WinSFA
//
//  Created by Alicia on 17/2/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNewStoreSelectDelegate

- (void)addNewStoreByIsAdd:(BOOL)isAdd overideStore:(WSStoreBean *)store;

@end

@interface WSAddNewStoreSelectView : UIView

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) id<AddNewStoreSelectDelegate> delegate;

@end
