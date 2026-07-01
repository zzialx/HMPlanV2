//
//  UIViewController+LTDebug.m
//  LTDebug
//
//  Created by Alicia on 16/12/30.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "UIViewController+LTDebug.h"

#import "objc/runtime.h"
#import "LTDebugMacro.h"
#import "LTDebugView.h"
#import "WSEnvrionment.h"

static NSString* const kViewDidAppearTag = @"LTDebugViewDidAppear ";

@implementation UIViewController (LTDebug)

+ (BOOL)isLogOn {
    return [WSEnvrionment getUseDebugTool];
}

+ (void)load {
    if (![self isLogOn]) {
        return;
    }
    
    lt_vc_swizzleMethod([self class], @selector(viewDidAppear:), @selector(swizzle_viewDidAppear:));
}

void lt_vc_swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzle_viewDidAppear:(BOOL)animated {
    // [self printLog];
    [self showName];
    
    [self swizzle_viewDidAppear:animated];
}

- (void)showName {
    NSString *className = NSStringFromClass(self.class);
    if (![className hasPrefix:@"UI"]  && ![className hasPrefix:@"_"]) {
        UILabel *nameLabel = [[LTDebugView sharedInstance] nameLabel];
        nameLabel.text = [NSString stringWithFormat:@"%@", [self.class description]];
    }
}

- (void)printLog {
    if ([self parentViewController] == nil) {
        [self printLogWithDepth:0];
    } else if([[self parentViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)[self parentViewController];
        NSInteger integer = [[nav viewControllers] indexOfObject:self];
        [self printLogWithDepth:integer];
    } else if ([[self parentViewController] isKindOfClass:[UITabBarController class]]) {
        [self printLogWithDepth:1];
    } else {
         [self printLogWithDepth:-1];
    }
}

- (void)printLogWithDepth:(NSInteger)depth {
    NSString *padding = kViewDidAppearTag;
    if (depth < 0) {
        NSLog(@"%@-- Now show -- %@", padding, [self.class description]);
    } else {
        for (NSUInteger i = 0; i <= depth; i++) {
            padding = [padding stringByAppendingFormat:@"----"];
        }
        NSLog(@"%@---| %@", padding, [self.class description]);
    }
}

@end
