//
//  WSAddNewStoreSelectCell.h
//  WinSFA
//
//  Created by Alicia on 17/2/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAddNewStoreCellFontSize   12

#define kAddNewStoreImageWH     50
#define kAddNewStoreIconWH      12
#define kAddNewStoreLeftWdith   (MAIN_PADDING * 3 + kAddNewStoreImageWH + kAddNewStoreIconWH)

@interface WSAddNewStoreSelectCell : UITableViewCell

@property (nonatomic, strong) WSStoreBean *storeBean;

@end
