//
//  WSScanSelectView.h
//  WinSFA
//
//  Created by Alicia on 2017/9/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WSScanSelectDelegate

- (void)selectedData:(NSArray *)selectedArray;

@end



@interface WSScanSelectView : UIView

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) id<WSScanSelectDelegate> delegate;

@end
