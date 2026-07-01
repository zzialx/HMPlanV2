//
//  UILabel+Additional.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 3/11/13.
//
//

#import "UILabel+Additional.h"
#import <objc/runtime.h>

@implementation UILabel (Additional)

@dynamic productID;
@dynamic filter;

NSString * const kProductCode = @"productID";
NSString * const kFilter      = @"filter";

- (void)setProductID:(NSString *)productID
{
    objc_setAssociatedObject(self, (__bridge const void *)(kProductCode), (id)productID, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)productID
{
    return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(kProductCode));
}

- (void)setFilter:(NSString *)filter
{
    objc_setAssociatedObject(self, (__bridge const void *)(kFilter), (id)filter, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)filter
{
    return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(kFilter));
}

- (void) setTextColorWithHexStr:(NSString *)cString
{
    if (cString && [cString length] > 0 ) {
        self.textColor = [UIColor colorWithHexString:cString];
    }else{
        self.textColor = [UIColor blackColor];
    }
    
}

- (NSInteger)lineCount:(CGSize)size {
    NSInteger lineCount = size.height / self.font.lineHeight;
    return lineCount;
}

- (CGSize)labelResize:(CGSize)size {
    return [self labelResize:size ratio:1.0];
}

- (CGSize)labelResize:(CGSize)size ratio:(CGFloat)ratio {
    CGFloat height = MAIN_CELL_HEIGHT * ratio;
    if (size.height < height) {
        NSInteger line = size.height / self.font.lineHeight;
        if (line > 1) {
            size.height += MAIN_CELL_PADDING;
        } else {
            size.height = height;
        }
    } else {
        size.height += MAIN_CELL_PADDING;
    }
    return size;
}

- (CGSize)labelAndPaddingResize:(CGSize)size ratio:(CGFloat)ratio {
    CGFloat height = MAIN_CELL_HEIGHT * ratio;
    if (size.height < height) {
        NSInteger line = size.height / self.font.lineHeight;
        if (line > 1) {
            size.height += MAIN_CELL_PADDING * 2 * ratio;
        } else {
            size.height = height;
        }
    } else {
        size.height += MAIN_CELL_PADDING * 2 * ratio;
    }
    return size;
}

@end


