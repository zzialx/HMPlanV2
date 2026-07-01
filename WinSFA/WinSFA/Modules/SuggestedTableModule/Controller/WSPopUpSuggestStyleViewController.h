//
//  WSPopUpSuggestStyleViewController.h
//  WinSFA
//
//  Created by HZH on 16/9/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSPopUpSuggestStyleViewController : UIViewController

@property (nonatomic, copy) NSString *sType;

@property(nonatomic,copy) void (^suggestName)(NSString *,NSString *);

@end
