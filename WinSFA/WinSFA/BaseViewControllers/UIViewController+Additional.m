//
//  UIViewController+Additional.m
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 10/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Additional.h"
#import <objc/runtime.h>

@implementation UIViewController (Additional)


@dynamic currentStore, currentVisitAction, showActionTip;

NSString * const kFuncBean = @"kFuncBean";
NSString * const kStoreBean = @"kStoreBean";
NSString * const kCurrentVisitAction = @"kCurrentVisitAction";
NSString * const kShowActionTip = @"kShowActionTip";
NSString * const kPrepareVisitDate = @"kPrepareVisitDate";


- (void)setCurrentStore:(WSStoreBean *)aStore
{
    objc_setAssociatedObject(self, (__bridge const void *)(kStoreBean), (id)aStore, OBJC_ASSOCIATION_RETAIN);
}

- (WSStoreBean *)currentStore
{
	return (WSStoreBean *)objc_getAssociatedObject(self, (__bridge const void *)(kStoreBean));
}

- (void)setCurrentVisitAction:(WSVisitStoreActionObject *)aAction
{
    objc_setAssociatedObject(self, (__bridge const void *)(kCurrentVisitAction), (id)aAction, OBJC_ASSOCIATION_RETAIN);
}

- (WSVisitStoreActionObject *)currentVisitAction
{
	return (WSVisitStoreActionObject *)objc_getAssociatedObject(self, (__bridge const void *)(kCurrentVisitAction));
}

- (void)setShowActionTip:(BOOL)aShowActionTip
{
    objc_setAssociatedObject(self, (__bridge const void *)(kShowActionTip), [NSNumber numberWithBool:aShowActionTip], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)showActionTip
{
	return [((NSNumber *)objc_getAssociatedObject(self, (__bridge const void *)(kShowActionTip))) boolValue];
}

- (void)setPrepareVisitDate:(NSString *)prepareVisitDate
{
    objc_setAssociatedObject(self, (__bridge const void *)(kPrepareVisitDate), (NSString *)prepareVisitDate, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)prepareVisitDate
{
    return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(kPrepareVisitDate));
}

@end
