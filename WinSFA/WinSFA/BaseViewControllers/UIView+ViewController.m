//
//  UIView+ViewController.m
//  pad2
//
//  Created by Niu Zhaowang on 11/5/12.
//
//

#import "UIView+ViewController.h"

@implementation UIView (ViewController)

-(UIViewController *)viewController
{
    for (UIView *next = [self superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
