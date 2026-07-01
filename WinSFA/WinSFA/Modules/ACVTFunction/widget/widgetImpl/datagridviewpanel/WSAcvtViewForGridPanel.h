//
//  WSAcvtViewForGridPanel.h
//  WinSFA
//
//  Created by HZH on 2017/10/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSTableItem;
@class WSProdBean;

@interface WSAcvtViewForGridPanel : UIView

@property (nonatomic,copy) void (^reloadGridView)(NSDictionary * dict,NSString * rowId);

- (id)initWithAcvtBean:(WSTableItem *)tableItem withItemId:(NSString *)itemId withItemName:(NSString *)itemName withDisplayValue:(NSDictionary *)dict withLuaScript:(NSString *)luaScript andCurrentStore:(WSStoreBean *)currentStore andCurrentSubEmpStore:(WSSubempstoreBean *)currentSubEmpStore andIsReadOnly:(BOOL)readonly;

- (void)show;
- (void)dismiss;

- (UIView *)getCenterView;
@end
