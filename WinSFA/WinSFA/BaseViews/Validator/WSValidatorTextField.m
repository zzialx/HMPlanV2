//
//  WSValidatorTextField.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-6.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSValidatorTextField.h"
#import "WSValidatorSource.h"
#import "WSAcvtBean_qst.h"
#import "WSUpKeyBoardView.h"

@interface WSValidatorTextField ()


@end

@implementation WSValidatorTextField

- (id)initWithFrame:(CGRect)aRect qst:(WSAcvtBean_qst *)aQst validatorSource:(WSValidatorSource *)aSource {
    self  = [super initWithFrame:aRect Qst:aQst];
    if (self) {
        _currentSource = aSource;
        self.delegate = self;
        _qst = aQst;
    }
    
    return self;
}

- (void)initKeyBoard {
    
//    self.upKeyBoardView=[[WSUpKeyBoardView alloc] initWithFrame:CGRectMake(0, 0, self.width, UI_KEYBOARD_VIEW_HEIGHT)];
//    UIButton* cButton=(UIButton*)[self.upKeyBoardView viewWithTag:98];
//    [cButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
//    UIButton* oButton=(UIButton*)[self.upKeyBoardView viewWithTag:100];
//    [oButton addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
//    self.inputAccessoryView= self.upKeyBoardView;
//    if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
//        for(UIButton* button in self.inputAccessoryView.subviews){
//            switch (button.tag) {
//                case 99:
//                    [button setTitle:NSLocalizedString(@"zoom_in", nil) forState:UIControlStateNormal];
//                    break;
//                case 100:
//                    [button setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
    
    self.textAlignment = NSTextAlignmentLeft;
    if (self.m_type != nil && [self.m_type isEqualToString:QST_TYPE_NR]) {
        if ([self.m_pcs isEqualToString:@"0"]) {
            self.keyboardType = UIKeyboardTypeNumberPad;
        } else {
            self.keyboardType = UIKeyboardTypeDecimalPad;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)validate {
    
//#define RANGE_TYPE_GE   @"GE"   // GE大于等于
//#define RANGE_TYPE_LE   @"LE"   // LE小于等于
//#define RANGE_TYPE_GT   @"GT"   // GT大于
//#define RANGE_TYPE_LT   @"LT"   // LT大于
//#define RANGE_TYPE_NE   @"NE"   // NE不等于
//#define RANGE_TYPE_EQ   @"EQ"   // EQ等于

    if (self.m_max) {
        float max = self.m_max.floatValue;
        float value = self.text.floatValue;
        if (value > max) {
            return NO;
        }
    }
    if (self.m_min) {
        float min = self.m_min.floatValue;
        float value = self.text.floatValue;
        if (value < min) {
            return NO;
        }
    }
    
    // 大于等于
    if ([_qst.range isEqualToString:RANGE_TYPE_GE]) {
        float value = self.text.floatValue;
        if (!(value >= self.currentSource.value)) {
            return NO;
        }
    } else if ([_qst.range isEqualToString:RANGE_TYPE_LE]) {
        float value = self.text.floatValue;
        if (!(value <= self.currentSource.value)) {
            return NO;
        }
    } else if ([_qst.range isEqualToString:RANGE_TYPE_GT]) {
        float value = self.text.floatValue;
        if (!(value > self.currentSource.value)) {
            return NO;
        }
    } else if ([_qst.range isEqualToString:RANGE_TYPE_LT]) {
        float value = self.text.floatValue;
        if (!(value < self.currentSource.value)) {
            return NO;
        }
    } else if ([_qst.range isEqualToString:RANGE_TYPE_NE]) {
        float value = self.text.floatValue;
        if (!(value != self.currentSource.value)) {
            return NO;
        }
    } else if ([_qst.range isEqualToString:RANGE_TYPE_EQ]) {
        float value = self.text.floatValue;
        if (!(value == self.currentSource.value)) {
            return NO;
        }
    }
    
    /*！
     *  第 2 条校验逻辑
     */
    
    if (_qst.range2) {
        if ([_qst.range2 isEqualToString:RANGE_TYPE_GE]) {
            float value = self.text.floatValue;
            if (!(value >= self.currentSource.value2)) {
                return NO;
            }
        } else if ([_qst.range2 isEqualToString:RANGE_TYPE_LE]) {
            float value = self.text.floatValue;
            if (!(value <= self.currentSource.value2)) {
                return NO;
            }
        } else if ([_qst.range2 isEqualToString:RANGE_TYPE_GT]) {
            float value = self.text.floatValue;
            if (!(value > self.currentSource.value2)) {
                return NO;
            }
        } else if ([_qst.range2 isEqualToString:RANGE_TYPE_LT]) {
            float value = self.text.floatValue;
            if (!(value < self.currentSource.value2)) {
                return NO;
            }
        } else if ([_qst.range2 isEqualToString:RANGE_TYPE_NE]) {
            float value = self.text.floatValue;
            if (!(value != self.currentSource.value2)) {
                return NO;
            }
        } else if ([_qst.range2 isEqualToString:RANGE_TYPE_EQ]) {
            float value = self.text.floatValue;
            if (!(value == self.currentSource.value2)) {
                return NO;
            }
        }
    }
    return YES;
}


@end
