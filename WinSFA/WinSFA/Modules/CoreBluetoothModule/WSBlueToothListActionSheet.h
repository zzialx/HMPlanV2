//
//  WSBlueToothListActionSheet.h
//  WinSFA
//
//  Created by sunhongfu on 2017/12/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEPrinterManager.h"

@interface WSBlueToothListActionSheet : UIView
/**
 初始化
 @pragma baseController WSBlueToothListActionSheet展示的父controller
 @pragma manager 蓝牙打印manager
 @pragma printParam 打印的数据
 */
- (id)initWithFrame:(CGRect)frame WithBaseController:(UIViewController *)baseController withSEPrinterManager:(SEPrinterManager *)manager withPrintParam:(NSString *)printParam;
- (void)show;                                   //展示
- (void)dismissSelf;                            //释放方法
- (void)reloadPrintParam:(NSString *)printParam;//重载打印参数方法

@end
