//
//  WSShowH5ViewController.h
//  WinSFA
//
//  Created by mac on 16/9/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichItemModel.h"

@interface WSShowH5ViewController : UIViewController
@property(nonatomic,copy) NSString *filterName;
@property(nonatomic,copy)void (^reloadBlock)();
- (void)itemClickCallH5WithItemModel:(WSRichItemModel *)item;
@end
