//
//  WSCheckBoxWithReasonPanel.m
//  WinSFA
//
//  Created by Stephanie on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCheckBoxWithReasonPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "WidgetConstant.h"
#import "WSOptionView.h"
#import "I_W_DisplayValue.h"
#import "WSArrayValueChangeChecker.h"

#define kOptionViewLeftSpace (INTERFACE_IS_PAD ? 0 : 0)

@implementation WSCheckBoxWithReasonPanel


- (void)setUpSubviews
{
    [self.optionViewArray removeAllObjects];
    
    CGFloat height = self.titleLabel.height;;
    
    CGFloat left = kOptionViewLeftSpace;
    
    for (int i = 0; i < self.dataSourceArray.count; i++) {
        
        NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:i];
        
        CGRect optionRect = CGRectMake(left, height, self.width, 40);
        
        WSOptionView *optionView = [[WSOptionView alloc] initWithFrame:optionRect andDataItem:dataItem hasReason:YES readonly:[self getReadOnly]];
        
        [optionView.button setImage:[UIImage scaledImageForName:@"icn_nocheck" ofType:@"png"] forState:UIControlStateNormal];
        
        if ([self getReadOnly]) {
            [optionView.button setImage:[UIImage scaledImageForName:@"icn_check_2" ofType:@"png"] forState:UIControlStateSelected];
        }else {
            [optionView.button setImage:[UIImage scaledImageForName:@"icn_check" ofType:@"png"] forState:UIControlStateSelected];
        }
        
        if ([self getReadOnly]) {
            [optionView optionViewEnable:NO];
        }
        
        optionView.delegate = self;
        
        [self addSubview:optionView];
        [self.optionViewArray addObject:optionView];
        
        height += optionView.height;
    }
    
    NSString *originValueString = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    
    NSArray *dataArray = [originValueString componentsSeparatedByString:@";"];
    
    _originalValue = dataArray;
    
    NSMutableArray *selectItemIDArray = [NSMutableArray arrayWithCapacity:dataArray.count];
    for (NSString *data in dataArray) {
        NSArray *s = [data componentsSeparatedByString:@","];
        if ([s count] > 0) {
            [selectItemIDArray addObject:[s firstObject]];
        }
    }
    
    [self setupSelectionBySelectItemIDArray:selectItemIDArray];
    
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}


//用NSString返回所选项的ID，多个选项以“,”分隔（与服务器所需的上传格式一致）
-(NSObject *)getResultDirectly{
    
    NSMutableArray *totalArray = [NSMutableArray arrayWithCapacity:self.dataSourceArray.count];
    for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
        NSMutableArray *itemData = [NSMutableArray arrayWithCapacity:3];
        [itemData addObject:[dataItem getDataItemID]];
        BOOL isSelected = [self.selectedItems containsObject:dataItem];
        [itemData addObject: isSelected? @"1" : @"0"];
        if (!isSelected) {
            NSString *reason = nil;
            
            for (WSOptionView *optionView in self.optionViewArray) {
                if (optionView.dataItem == dataItem) {
                    reason = optionView.reasonTextField.text;
                    break;
                }
            }
            
            if ([reason length] > 0) {
                [itemData addObject:reason];
            }
        }
        
        [totalArray addObject:[itemData componentsJoinedByString:@","]];
    }
    
    return [totalArray componentsJoinedByString:@";"];
}

- (NSObject *)getResultPresentation {
    return [self getResultDirectly];
}

- (NSObject *)getDisplayValuePresentation{
    
    return [self getResultPresentation];
}


- (NSObject *)getCurrentValue {
    
    NSMutableArray *totalArray = [NSMutableArray arrayWithCapacity:self.dataSourceArray.count];
    for (NSObject<I_W_OptionDataItem> *dataItem in self.dataSourceArray) {
        NSMutableArray *itemData = [NSMutableArray arrayWithCapacity:3];
        [itemData addObject:[dataItem getDataItemID]];
        BOOL isSelected = [self.selectedItems containsObject:dataItem];
        [itemData addObject: isSelected? @"1" : @"0"];
        if (!isSelected) {
            NSString *reason = nil;
            
            for (WSOptionView *optionView in self.optionViewArray) {
                if (optionView.dataItem == dataItem) {
                    reason = optionView.reasonTextField.text;
                    break;
                }
            }
            
            if (reason) {
                [itemData addObject:reason];
            }
        }
        
        [totalArray addObject:[itemData componentsJoinedByString:@","]];
    }
    
    if ([totalArray count] > 0) {
        return totalArray;
    }
    
    return nil;
    
}


#pragma mark - WSOptionViewDelegate

- (void)optionView:(WSOptionView *)optionView didClickItem:(NSObject<I_W_OptionDataItem> *)dataItem
{
    [self setButton:optionView.button selected:!optionView.button.selected];
    if ([self.selectedItems containsObject:dataItem]) {
        [self.selectedItems removeObject:dataItem];
    }
    else
    {
        [self.selectedItems addObject:dataItem];
    }
    
    [self checkValueChange];
    
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
}

@end
