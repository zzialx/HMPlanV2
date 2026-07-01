//
//  WinRPMapUserAnnotation.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//=================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RP地图用户注解
@interface WinRPMapUserAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;//位置
@property (nonatomic, copy) NSString *title;                    //标题
@property (nonatomic, copy) NSString *subtitle;                 //子标题

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================

