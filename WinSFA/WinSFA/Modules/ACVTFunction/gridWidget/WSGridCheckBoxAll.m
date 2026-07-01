//
//  WSGridCheckBoxAll.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridCheckBoxAll.h"
#import "WSCheckBox.h"

@implementation WSGridCheckBoxAll

- (void)checkBoxPressed:(WSCheckBox *)sender {
    [super checkBoxPressed:sender];
    
    WSCheckBox *checkBoxSelected = (WSCheckBox *)sender;
    
    NSInteger column = checkBoxSelected.iColumn;
    BOOL resultSelected = checkBoxSelected.selected;
    
    // 采集表格每一项UI针对一种产品，目前没有找到内存数据项，只能遍历UI
    if (self.isHeader) {
        //查找表格中数组里同列checkBox
        [self setCheckBoxArraySelected:resultSelected columIndex:column isHeader:NO];
     
    } else {
        if (resultSelected) {
            NSInteger countPro = 0;
            NSInteger countSelected = 0;
            
            WSGridWidget *widgetGroup = [self.delegate dataSourceGetGroupViewByType:self.groupName];
            for (NSString *key in [widgetGroup getGridWidgetAllKeys]) {
                WSGridCheckBoxAll *otherWidget = (WSGridCheckBoxAll *)[widgetGroup getGridWidgetByKey:key];
                if (otherWidget.isHeader) {
                    continue;
                }
                WSCheckBox *checkBoxTemp = (WSCheckBox *)[otherWidget getView];
                if (checkBoxTemp.iColumn == column) {
                    if (checkBoxTemp.selected) {
                        countSelected = countSelected + 1;
                    }
                    countPro = countPro + 1;
                }
            }
            //所有产品该列都被选中，则全部选择项为选中状态
            if (countPro == countSelected) {
                [self setCheckBoxArraySelected:YES columIndex:column isHeader:YES];
            }
        } else {
            //取消选中一项CheckBox，则重置同列 checkBoxALL 的selected状态
            [self setCheckBoxArraySelected:resultSelected columIndex:column isHeader:YES];
        }
    }
}

#pragma mark - Private Method
- (void)setCheckBoxArraySelected:(BOOL)selected columIndex:(NSInteger)iColumn isHeader:(BOOL)isHeader {
    WSGridWidget *widgetGroup = [self.delegate dataSourceGetGroupViewByType:self.groupName];
    for (NSString *key in [widgetGroup getGridWidgetAllKeys]) {
        WSGridCheckBoxAll *otherWidget = (WSGridCheckBoxAll *)[widgetGroup getGridWidgetByKey:key];
        if (otherWidget.iColumn == iColumn && (!isHeader || (isHeader && otherWidget.isHeader))) {
            WSCheckBox *checkBoxTemp = (WSCheckBox *)[otherWidget getView];
            [checkBoxTemp setSelected:selected];
        }
    }
}


@end
