//
//  WSNeighborStoreController.h
//  WinSFA
//
//  Created by Nemo on 14-3-5.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "BaseViewController.h"
#import "WSNeighborPin.h"


typedef enum
{
    LOCATION_STATE_GETTING,
    LOCATION_STATE_RECEIVED,
} LOCATION_STATE;

@interface WSNeighborStoreController : BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate>


- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
