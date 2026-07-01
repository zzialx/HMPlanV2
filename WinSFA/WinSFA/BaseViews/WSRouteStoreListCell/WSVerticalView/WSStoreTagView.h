//
//  WSStoreTagView.h
//  WinSFA
//
//  Created by zzialx on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSStoreTagView : UIView

/// 列表
@property(nonatomic,strong)UITableView * table;

@property(nonatomic,strong)UICollectionView * collectionView;

///问卷code
@property(nonatomic,copy)NSString  * acvtCode;

/// 门店信息
@property(nonatomic,strong)WSStoreBean * storeBean;


@end

NS_ASSUME_NONNULL_END
