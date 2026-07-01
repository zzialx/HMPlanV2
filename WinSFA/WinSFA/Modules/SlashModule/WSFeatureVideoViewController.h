//
//  WSFeatureVideoViewController.h
//  WinSFA
//
//  Created by Alicia on 2017/9/12.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WSFeatureVideoDelegate <NSObject>

- (void)donePlaying;

@end

@interface WSFeatureVideoViewController : UIViewController

@property (nonatomic, weak) id <WSFeatureVideoDelegate> delegate;

@end
