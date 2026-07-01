//
//  UILabel+Additional.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 3/11/13.
//
//

#import <UIKit/UIKit.h>

@interface UILabel (Additional)

@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *filter;

- (void) setTextColorWithHexStr:(NSString *)cString;

- (CGSize)labelResize:(CGSize)size;
- (CGSize)labelResize:(CGSize)size ratio:(CGFloat)ratio;
- (CGSize)labelAndPaddingResize:(CGSize)size ratio:(CGFloat)ratio;

@end
