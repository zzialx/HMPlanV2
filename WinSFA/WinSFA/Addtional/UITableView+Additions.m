//
//  UITableView+Additions.m
//  WinSFA
//
//  Created by Alicia on 16/11/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "UITableView+Additions.h"
#import "objc/runtime.h"

@implementation UITableView (Additions)


void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load {
    swizzleMethod([self class], @selector(willMoveToSuperview:), @selector(swizzle_willMoveToSuperview:));
}

- (void)swizzle_willMoveToSuperview:(nullable UIView *)newSuperview {
    [self swizzle_willMoveToSuperview:newSuperview];
    if (IOS9_OR_LATER) {
        self.cellLayoutMarginsFollowReadableWidth = NO;
    }
    self.separatorColor = MAIN_TABLEVIEW_SEPERATE_COLOR;
}
@end
