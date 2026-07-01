//
//  NSMutableAttributedString+Addtions.h
//  WinSFA
//
//  Created by admin on 2022/12/16.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Addtions)


/// 获取固定的富文本数据
/// - Parameter content:
+ (NSMutableAttributedString*)getCustomAttributeWithContent:(NSString*)content;


@end

NS_ASSUME_NONNULL_END
