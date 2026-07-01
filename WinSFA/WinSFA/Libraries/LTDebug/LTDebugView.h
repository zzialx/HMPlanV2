//
//  LTViewControllerName.h
//  LTDebug
//
//  Created by Alicia on 17/3/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTDebugView : NSObject

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *otherLabel;

+ (instancetype)sharedInstance;

- (void)showThenHideWindow;
- (void)resetWindowAndViewByIsHidden:(BOOL)isHidden;

@end

# pragma mark - LTDebugViewController

/**
 * Allows handing over supportedInterfaceOrientations if needed.
 */
@interface LTDebugRootViewController : UIViewController
@end
