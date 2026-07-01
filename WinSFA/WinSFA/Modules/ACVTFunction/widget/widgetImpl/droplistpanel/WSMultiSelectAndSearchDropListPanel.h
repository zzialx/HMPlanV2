//
//  WSMultiSelectAndSearchDropListPanel.h
//  WinSFA
//
//  Created by HZH on 16/12/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"

typedef enum {
    WSMultiSelectAndSearchViewSelectModeSingleSelection = 0,
    WSMultiSelectAndSearchViewSelectModeMultipleChoice
}WSMultiSelectAndSearchViewSelectMode;

typedef enum {
    WSMultiSelectAndSearchViewTypeDefaultShow= 0,
    WSMultiSelectAndSearchViewTypePushNewVCShow
}WSMultiSelectAndSearchViewType;


@interface WSMultiSelectAndSearchDropListPanel : WSSingleTitlePanel

@property (nonatomic, strong) NSArray *allStores;

@property (nonatomic, strong) NSArray *dataSourceArray;

@property (nonatomic ,assign) BOOL sourceTableReadOnly;

@property (nonatomic, assign) WSMultiSelectAndSearchViewSelectMode selectMode;
@property (nonatomic, assign) WSMultiSelectAndSearchViewType  selectType;
@property (nonatomic, strong) NSObject<I_W_OptionDataItem> *selectedItem;  //for single select
@property (nonatomic, strong) NSMutableArray *selectedItemArray;   //for multiple choice
@property (nonatomic, strong) NSMutableArray *tempSelectedItemArray;   //for not sure multiple choice

@property (nonatomic, assign) BOOL needCheckValueChange;   //是否需要检查value change（放在acvtview的changeDic里面代表值已改变，未上传退出时会弹出提示）

- (void)setSourceTableReadOnly:(BOOL)readOnly;

@end
