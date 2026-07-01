//
//  WSDataGridRightTableModel.m
//  WinSFA
//
//  Created by HZH on 2017/7/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDataGridRightTableModel.h"
#import "WSProdBean.h"

#define hDefaultFirstColWidth 60.0


@implementation WSDataGridRightTableModel

- (void)setFirstColWidth:(CGFloat)firstColWidth
{
    if ((!firstColWidth || firstColWidth < hDefaultFirstColWidth) && !_isNeedHideFirstColAndKeepBlank) {
        _firstColWidth = hDefaultFirstColWidth;
    }else{
        _firstColWidth = firstColWidth;
    }
}

- (void)setProdsArray:(NSArray *)prodsArray
{
    
    _prodsArray = prodsArray;
    
    [self resetGridComViewCellHeightArray];

}

- (void)resetGridComViewCellHeightArray
{
    NSMutableArray *tempCellHeightArray = [[NSMutableArray alloc] init];

    if (_prodsArray && _prodsArray.count > 0) {

        for (WSProdBean *prod in _prodsArray) {
            CGFloat cellHeight = 44.0;
            
            if (!_isNeedHideFirstColAndKeepBlank) {
                cellHeight = [self getComViewCellRealHeightWithContentString:prod.name];
            }
            
            [tempCellHeightArray addObject:[NSNumber numberWithFloat:cellHeight]];
        }
    }
    
    _gridComViewCellHeightArray = tempCellHeightArray;
    
    [self resetComViewRealHeight];
}

- (CGFloat)getComViewCellRealHeightWithContentString:(NSString *)contentString
{
    CGSize prodNameSize = [contentString ws_sizeWithFont:FONT_SIZE_PINGFANG_MEDIUM(13.0) constrainedToWidth:_firstColWidth - 20.0 lineBreakMode:NSLineBreakByCharWrapping];
    
    return prodNameSize.height + 20.0;
    
}

- (void)resetComViewRealHeight
{
    CGFloat comViewRealHeight = 44.0;
    
    for (NSNumber *heightNum in _gridComViewCellHeightArray) {
        CGFloat height = [heightNum floatValue];
        
        comViewRealHeight += height;
    }
    
    _gridComViewHeight = comViewRealHeight;
}

@end
