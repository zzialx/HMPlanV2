//
//  WinSystemStorePointAnnotation.h
//  WinSFA
//
//  Created by yuanji on 2023/3/30.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 系统门店点注释
@interface WinSystemStorePointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;//位置
@property (nonatomic, copy) NSString *title;                    //标题
@property (nonatomic, copy) NSString *subtitle;                 //子标题

@end

NS_ASSUME_NONNULL_END
//================================================================================================================================================================================================
