//
//  WSValidatorDdsItem.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-6.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSValidatorDdsItem.h"
#import "WSProdBean.h"

@interface WSValidatorDdsItem ()

@property (nonatomic, strong) NSMutableArray *valueFieldArray;

@end

@implementation WSValidatorDdsItem

- (float)getValue {
    if (_pageData) {
        if (_valueFieldArray == nil) {
            [self initViewArray];
        }
        if (!_valueFieldArray) {return 0;}
        if ([_function isEqualToString:FUNCTION_TYPE_COUNT]) {
            return [self countFunctionWithZero:YES];
        } else if ([_function isEqualToString:FUNCTION_TYPE_COUNT_NONZERO]) {
            return [self countFunctionWithZero:NO];
        } else if ([_function isEqualToString:FUNCTION_TYPE_SUM]) {
            return [self sumFunction];
        }

    }
    return 0;
}

- (float)countFunctionWithZero:(BOOL)withZero {
    float result = 0;
    for (UIView *view in _valueFieldArray) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            NSString *valueString = field.text;
            if (withZero) {
                if (valueString && ![valueString isEqualToString:@""]) {
//                    float value = field.text.floatValue;   
                    result += 1;
                }
            } else {
                if (valueString && ![valueString isEqualToString:@""] && ![valueString isEqualToString:@"0"]) {
//                    float value = field.text.floatValue;
                    result += 1;
                }
            }
        }
    }
    return result;
}

- (float)sumFunction {
    float result = 0;
    for (UIView *view in _valueFieldArray) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *field = (UITextField *)view;
            NSString *valueString = field.text;
            if (valueString && ![valueString isEqualToString:@""]) {
                float value = field.text.floatValue;
                result += value;
            }
        }
    }
    return result;
}

- (void)initViewArray {
    _valueFieldArray = [[NSMutableArray alloc] init];
    WSAcvtBean_qst *acvt_qst = nil;
    for (WSAcvtBean_qst *qst in _acvtBean.qsts) {
        if ([qst.qstCod isEqualToString:_acvtQstCode]) {
            acvt_qst = qst;
            break;
        }
    }
    if (acvt_qst == nil) {return;}
    if ([acvt_qst.qstType isEqualToString:QST_TYPE_TB]) {
        WSAcvtDataGridComponentView *dataView = (WSAcvtDataGridComponentView *)_view;
        WSAcvtDataGridComponentDataSource *dataViewSource = [dataView getAcvtDataSource];
        NSInteger colNum = -1;
        for (int i = 0; i < [dataViewSource.currentTableItem.paramArray count]; i++) {
            WSFuncsBean_Param *param = [dataViewSource.currentTableItem.paramArray objectAtIndex:i];
            if ([_qstCol isEqualToString:param.col]) {
                colNum = 0;
                break;
            }
        }
        if (colNum < 0) {return;}
        NSArray *dataSource = dataViewSource.dataSource;
        NSInteger count = [dataViewSource.data count];
        for (int i = 0; i < count; i++) {
//        for (NSArray *array in dataViewSource.data) {
            BOOL addValue = YES;
            if ([_checkType isKindOfClass:[NSString class]]) {
                id source = [dataSource objectAtIndex:i];
                if ([source isKindOfClass:[WSProdBean class]]) {
                    WSProdBean *product = (WSProdBean *)source;
                    if (![_checkType isEqualToString:product.memo5]) {
                        addValue = NO;
                    }
                }
            }
            if (addValue) {
                NSArray *array = [dataViewSource.data objectAtIndex:i];
                
                UIView *view = [array objectAtIndex:colNum + 1];
                [_valueFieldArray addObject:view];
            }
        }
    } else if ([acvt_qst.qstType isEqualToString:QST_TYPE_N] ||
               [acvt_qst.qstType isEqualToString:QST_TYPE_NR]) {
        UITextField *textField = (UITextField *)_view;
        [_valueFieldArray addObject:textField];
    }
}

@end
