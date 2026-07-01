//
//  CollectionViewCell.h
//  日历
//
//  Created by zhiqing on 16/7/21.
//  Copyright © 2016年 asdfghj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCalendarModel.h"
@interface WSCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)  WSCalendarModel*dateModel;
@end
