//
//  WSShowImageCell.h
//  WinSFA
//
//  Created by mac on 16/9/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichItemModel.h"
@interface WSShowImageCell : UICollectionViewCell
@property (nonatomic,strong) NSIndexPath *cellIndexPath;
@property(nonatomic,strong)WSRichItemModel * model;
@property(nonatomic,strong)UIButton * deleteBtn;
@property(nonatomic,copy)void (^deleteItem)(NSIndexPath * index);
@end
