//
//  WSTextFiledWithRangePanel+InfoLabel.m
//  WinSFA
//
//  Created by yang on 15/7/9.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTextFiledWithRangePanel+InfoLabel.h"
#import <objc/runtime.h>
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"

@implementation WSTextFiledWithRangePanel (InfoLabel)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(buildDisplayContent);
        SEL swizzledSelector = @selector(buildDisplayContentWithInfoLabel);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)buildDisplayContentWithInfoLabel
{
    // Forward to primary implementation.
    [self buildDisplayContentWithInfoLabel];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        if (textField.text > 0) {
            warningLabel.hidden = YES;
            NSLineBreakMode lineBreakMode = NSLineBreakByCharWrapping;
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            CGSize size = [textField.text ws_sizeWithFont:font constrainedToWidth:self.textField.width - 5 lineBreakMode:lineBreakMode];
            
            if (size.height > self.textField.height) {
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(self.textField.origin.x, self.textField.origin.y, self.textField.width, size.height + 20)];
                textView.font = font;
                textView.textColor = self.textField.textColor;
                textView.layer.cornerRadius = 5;
                textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                textView.layer.borderWidth = 0.5;
                textView.dataDetectorTypes = UIDataDetectorTypeNone;
                textView.text = self.textField.text;
                textView.backgroundColor = [UIColor whiteColor];
                textView.editable = NO;
                if (IOS7_OR_LATER) {
                    textView.selectable = NO;
                }
                [self addSubview:textView];
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + (textView.height - self.textField.height));
            }
        }
    }
}

@end
