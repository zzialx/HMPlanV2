//
//  WSRPMapViewTablCell.h
//  WinSFA
//
//  Created by mac on 17/4/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface WSRPMapViewTablCell : UITableViewCell
@property (nonatomic , strong) AMapPOI * modelPOI;
@property (nonatomic , assign) BOOL isSelect;
@property (nonatomic , strong) WSStoreBean * store;

+(CGFloat)heightForcell:(AMapPOI *)POI;

+(CGFloat)heightForcellStore:(WSStoreBean *)store;

@end
