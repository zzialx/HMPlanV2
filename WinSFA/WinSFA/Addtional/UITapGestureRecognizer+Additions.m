//
//  UITapGestureRecognizer+Additions.m
//  WinSFA
//
//  Created by zhangke on 14-5-14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "UITapGestureRecognizer+Additions.h"
#import <objc/runtime.h>

const void *urlkey = &urlkey;

@implementation UITapGestureRecognizer (Additions)

@dynamic url;

-(void)setUrl:(NSURL *)url
{
    objc_setAssociatedObject(self, urlkey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSURL *)url
{
    return objc_getAssociatedObject(self, urlkey);
}



@end
