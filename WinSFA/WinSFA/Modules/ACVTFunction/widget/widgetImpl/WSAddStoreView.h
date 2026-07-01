//
//  WSAddStoreView.h
//  WinSFA
//
//  Created by 董宏 on 2019/12/19.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WSAddStoreViewDelegate <NSObject>

- (void)deleteStore;

@end

@interface WSAddStoreView : UIView

- (void)setWithCode:(NSString*)code andName:(NSString*)name andAddr:(NSString*)addr;

@property (nonatomic, weak) id<WSAddStoreViewDelegate> addStoreViewDelegate;

@end

NS_ASSUME_NONNULL_END
