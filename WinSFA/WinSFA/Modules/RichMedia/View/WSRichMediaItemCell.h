//
//  WSRichMediaItemCell.h
//  WinSFA
//
//  Created by huzepei on 16/8/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichItemModel.h"


@interface WSRichMediaItemCell : UICollectionViewCell

@property (nonatomic,strong) NSIndexPath *cellIndexPath;

@property (nonatomic,copy) void (^clickPlusBtn)(NSIndexPath *path);

@property (nonatomic,strong) WSRichItemModel *itemModel;

@property (weak, nonatomic) IBOutlet UIButton *plusBtn;

@property (nonatomic,assign) BOOL isNotEdit;

@end
