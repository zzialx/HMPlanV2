//
//  WSNewRouteTableViewCell.h
//  WinSFA
//
//  Created by zzialx on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRouteSetHeadView.h"
#import "WSNewRouteModel.h"

//typedef void(^clicikAction)(NSString * date,RouteViewBtnType clickType);

NS_ASSUME_NONNULL_BEGIN

@interface WSNewRouteTableViewCell : UITableViewCell

//@property (nonatomic, copy)clicikAction clicikAction;

@property (nonatomic, strong)WSNewRouteModel * routeModel;

@end

NS_ASSUME_NONNULL_END
