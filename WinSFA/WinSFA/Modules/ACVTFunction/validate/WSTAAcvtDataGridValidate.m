//
//  WSTAAcvtDataGridValidate.m
//  WinSFA
//
//  Created by heju on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSTAAcvtDataGridValidate.h"

#import "WSTAAcvtDataGridViewPanel.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "WSMessageCenter.h"
#import "WSMessageObject.h"
#import "WSGridWidget.h"

@implementation WSTAAcvtDataGridValidate


-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    
    if (![widget isKindOfClass:[WSTAAcvtDataGridViewPanel class]]) {
        return YES;
    }
    
    BOOL isPassed = YES;
    
    WSTAAcvtDataGridViewPanel *dataGridPanel = (WSTAAcvtDataGridViewPanel *)widget;
    WSTAAcvtDataGridComponentDataSource *ds = (WSTAAcvtDataGridComponentDataSource *)dataGridPanel.dataGridView.dataSource;
    for (int i = 0; i < [ds.currentTableItem.paramArray count]; i++)
    {
        WSFuncsBean_Param *param = [ds.currentTableItem.paramArray objectAtIndex:i];
        if (param.isReq && [param.isReq isEqualToString:@"1"])
        {
            for (int j = 0; j < [ds.data count]; j++) {
                NSArray *row = [ds.data objectAtIndex:j];
                WSAcvtBean_qst_opt *opt = [ds.dataSource objectAtIndex:j];
                WSGridWidget *gridWidget = [row objectAtIndex:i + 1];
                id view = [gridWidget getView];
                
                if (view != nil && [view respondsToSelector:@selector(entityIsEnable)]){
                    if ([view entityIsEnable]) {
                        if ([view respondsToSelector:@selector(isValueLegal)]){
                            if (![view isValueLegal]) {
                                isPassed = NO;
                                
                                NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"%@ 【%@】 未填写!", nil),opt.optName,param.name];
                                WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                                
                                break;
                            }
                        }
                    }
                    
                }
                
            }
        }
        if (!isPassed) {
            break;
        }
    }
    return isPassed;
}



























@end
