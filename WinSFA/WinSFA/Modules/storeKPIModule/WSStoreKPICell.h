//
//  WSStoreKPICell.h
//  WinSFA
//
//  Created by Alicia on 17/2/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSStoreKPICell : UICollectionViewCell

@property (nonatomic, strong) NSObject<I_W_BuildInfo> *buildInfo;
@property (nonatomic , strong) UILabel * separatorLable;

- (NSString *)getSegmentedResult; //获取分割结果方法

@end
