//
//  WinRPMapUserAnnotationView.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <MapKit/MapKit.h>
//=================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RP地图用户大头针
@interface WinRPMapUserAnnotationView : MKAnnotationView

- (void)hideCalloutView; //隐藏标注视图方法
- (void)showCalloutView; //显示标注视图方法

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================
