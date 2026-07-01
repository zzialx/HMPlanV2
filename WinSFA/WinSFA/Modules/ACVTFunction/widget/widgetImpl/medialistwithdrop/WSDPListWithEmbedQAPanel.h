//
//  WSMediaListPanel.h
//  WinSFA
//
//  Created by winchannel on 15/4/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"
#import "WSTableView.h"

@class WSOpenCloseBtn;

@class WSTableView;

@class WSCellContentView;

@class WSInterActionForTableCell;

@interface WSDPListWithEmbedQAPanel : WSSingleTitlePanel<WSTableViewDelegate,UIAlertViewDelegate>{
    
    
    WSOpenCloseBtn  *openclosebtn;
    
    WSTableView   *tableview;

    UIView   *contentview;
    
    CGRect oldrect;
    
    WSCellContentView  *selectedContentView;
    
    NSMutableDictionary  *viewdict;
    
    
    
    
    NSMutableDictionary *resultInterActionsMap;
    
    
    
    
}

- (NSString *) getState;

@end
