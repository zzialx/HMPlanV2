//
//  BGLogation.h
//  WinSFA
//
//  Created by mac on 2018/8/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface BGLogation : NSObject<CLLocationManagerDelegate>
- (void)startLocation ;
@end
