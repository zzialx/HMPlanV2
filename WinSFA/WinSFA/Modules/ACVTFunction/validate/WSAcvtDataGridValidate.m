//
//  WSAcvtDataGridValidate.m
//  WinSFA
//
//  Created by yang on 15/4/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridValidate.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "DataGridComponent.h"
#import "WSAcvtDataGridViewPanel.h"
#import "I_W_BuildInfo.h"
#import "WSMessageCenter.h"
#import "WSMessageObject.h"
#import "WSGridWidget.h"
#import "WSNRLabel.h"
#import "WSLuaScript.h"

#import "WSAcvtModel.h"

#import "WSDataSourceManager.h"

@implementation WSAcvtDataGridValidate

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget
{
    if (![widget isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
        return YES;
    }
    
    BOOL isPassed = YES;
    BOOL isPassedForGrid = NO;
    
    NSString *qst_isReq = [buildinfo getISRequire];
    
    WSAcvtDataGridViewPanel *dataGridPanel = (WSAcvtDataGridViewPanel *)widget;
    WSAcvtDataGridComponentDataSource *ds = (WSAcvtDataGridComponentDataSource *)dataGridPanel.dataGridView.dataSource;
    WSAcvtDataGridComponentView *acvtDataGridComponentView = dataGridPanel.dataGridView;
    NSString *needSelect = ds.currentTableItem.opt.needSelect;
    
    /*验证是否选择了所有产品*/
    if ([needSelect isKindOfClass:[NSString class]] && ([needSelect isEqualToString:@"1"] || [needSelect isEqualToString:@"2"])) {
        if (acvtDataGridComponentView.popupView.selectedBrandIndex != 0) {
//            NSString *TakePhotoString = NSLocalizedString(@"请选择所有产品页面再上传！",@"请选择所有产品页面再上传！");
            NSString *TakePhotoString = NSLocalizedString(@"select_fill_upload",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            // MSTD-4956 系列选择，在选择某一品牌系列的时候点击右上角确定，直接回到所选产品页面，不用用户手动点击到所选产品页面再去上传，可简化操作。
            // 调查问卷部分也要像普通表格一样做相应调整。
            [acvtDataGridComponentView gridLinkPopupViewBackToAllSelectedProdsView];
            
            return NO;
        }
    }
    
    if ([[buildinfo getISRequire] isEqualToString:@"1"] && ![[buildinfo getIsHidden] isEqualToString:@"1"] && (!ds.dataSource || ds.dataSource.count == 0)) {
        NSString  *message = [NSString stringWithFormat:NSLocalizedString(@"not_filled", nil),[buildinfo getQuestName]];
        WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
        [[WSMessageCenter shareInstance] showMessageView:messageobject];
        return NO;
    }
    
    if ([ds loadValidateLuaScript]) {
      if ([WSLuaExecutorManager shareInstance].isErrorFromScript) {
            return NO;
        }
    }

    for (int i = 0; i < [ds.currentTableItem.paramArray count]; i++) {
        
        WSFuncsBean_Param *param = [ds.currentTableItem.paramArray objectAtIndex:i];
        /*验证列必填(列的每一个都要填写)*/
        if ((param.isReq && [param.isReq isEqualToString:@"1"]) && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
            
            for (int j = 0; j < [ds.data count]; j++) {
                
                NSArray *row = [ds.data objectAtIndex:j];
                NSObject <I_W_OptionDataItem> *option = ds.dataSource[j];
                WSGridWidget *gridWidget = [row objectAtIndex:i + 1];
                id view = [gridWidget getView];
                BOOL needCheck = YES;
                /*判断是否需要校验  若可用就校验是否必填*/
                if ([view respondsToSelector:@selector(iDataType)] && [view respondsToSelector:@selector(entityIsEnable)]) {
                    
//                    NSInteger dependOtherData = [view iDataType];
//                    BOOL isEable = [view entityIsEnable];
                    
                    if ([view iDataType] == WSValidateDataDependOtherData && ![view entityIsEnable]) {
                        needCheck = NO;
                    }
                }
                
                if (needCheck) {
//                    YIHAIKERRY-2821 donghong  只要是必填的字段 都要验证
//                    if (view != nil && [view respondsToSelector:@selector(entityIsEnable)]){
//                        if ([view entityIsEnable] || param.readonly == 1) {
                            if ([view respondsToSelector:@selector(isValueLegal)]){
                                //textField.isReq 玛氏是否效验必填 有值的时候证明是玛氏的特殊需求 当值等于1的时候走以前逻辑  0的时候跳过效验 跟安卓统一  没有值得时候按照以前逻辑
                                if ([view isKindOfClass:[WSHTextField class]])
                                {
                                        WSHTextField *textField =  (WSHTextField *)view;
                                        if (textField.isReq.length && ![textField.isReq boolValue])
                                        {
                                            break;
                                        }
                                }

                                if (![view isValueLegal]) {
                                    isPassed = NO;
                                    NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"[%@ ,%@]未填写", nil),[option   getDataItemName],param.name];
                                    WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                                    [[WSMessageCenter shareInstance] showMessageView:messageobject];
                                    
                                    return NO;
                                }
//                            }
//                        }
                        
                    }
                    
                }
                
            }
        }
        
        /*验证表格必填*/
        if (qst_isReq && [qst_isReq isKindOfClass:[NSString class]] && [qst_isReq isEqualToString:@"1"] && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
            
            for (int j = 0; j < [ds.data count]; j++) {
                NSArray *row = [ds.data objectAtIndex:j];
                WSGridWidget *gridWidget = [row objectAtIndex:i + 1];
                id view = [gridWidget getView];
                if (view != nil && [view respondsToSelector:@selector(entityIsEnable)]){
//                    MN-2604
//                    【蒙牛智网行动_低温】IOS：“竞品采集 - 竞品产品铺市”：提示异常，无法上传 
//                    if ([view entityIsEnable]) {
                        if ([view respondsToSelector:@selector(isValueLegal)]){
                            if ([view isValueLegal]) {
                                isPassedForGrid = YES;
                                break;
                                
                            }
                        }
//                    }
                
                }
            }
        }else{
            isPassedForGrid = YES;
        }
        
    }
    if (!isPassedForGrid && qst_isReq && [qst_isReq isKindOfClass:[NSString class]] && [qst_isReq isEqualToString:@"1"] && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
        NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"not_filled", nil),[buildinfo getQuestName]];
        WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
        [[WSMessageCenter shareInstance] showMessageView:messageobject];
        return NO;
    }

    if (isPassed) {
        /*验证最小值是否合法*/
        isPassed = ![self  validateAcvtDataGridHasMinValueTipWith:ds];
    }
    return isPassed;
}


- (BOOL)validateAcvtDataGridHasMinValueTipWith:(WSAcvtDataGridComponentDataSource *) acvtDataGridComponentDataSource {
    for (int aIndex = 0 ; aIndex < [acvtDataGridComponentDataSource.dataSource count]; aIndex++) {
        id object = [acvtDataGridComponentDataSource.dataSource objectAtIndex:aIndex];
        NSArray *rowViewDatas = [acvtDataGridComponentDataSource.data objectAtIndex:aIndex];
        for (int i = 0; i < [acvtDataGridComponentDataSource.currentTableItem.paramArray count]; i++) {
            WSFuncsBean_Param *param = [acvtDataGridComponentDataSource.currentTableItem.paramArray objectAtIndex:i];
            NSString *paraMinExpression = param.min;
//  SFA-26368  董宏
            if(i+1 > rowViewDatas.count - 1)
            {
                continue;
            }
            WSGridWidget *gridWidget = [rowViewDatas objectAtIndex:i + 1];
            
            id <WSValidateData> validatedView = nil;
            if ([gridWidget isKindOfClass:[WSGridWidget class]]) {
                validatedView = (id <WSValidateData>)[gridWidget getView];
            } else {
                validatedView = (id <WSValidateData>)gridWidget;
            }
            
            NSString *validateValue = nil;
            // SFA-25611 添加 paraMinExpression 非空判断
            if ([paraMinExpression length] > 0 && ([paraMinExpression rangeOfString:@"{"].location != NSNotFound) && [paraMinExpression rangeOfString:@"}"].location != NSNotFound) {
                
                if ([validatedView isKindOfClass:[WSHTextField  class]]) {
                    validateValue = [(WSHTextField *)validatedView text];
                } else if ([validatedView isKindOfClass:[WSNRLabel class]]) {
                    validateValue = [(WSNRLabel *)validatedView text];
                }
                for (NSInteger i = 0; i< [rowViewDatas count]; i++) {
                    UIView *view = rowViewDatas[i];
                    if ([view isKindOfClass:[WSHTextField class]]) {
                        WSHTextField *textField = (WSHTextField *)view;
                        NSString *textField_m_col = textField.m_col;
                        if ([paraMinExpression rangeOfString:textField_m_col].location != NSNotFound) {
                            paraMinExpression = [paraMinExpression stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",textField_m_col] withString: [NSString stringNotNilWithValue:textField.text ] ];
                        }
                    } else if ([view isKindOfClass:[WSNRLabel  class]]) {
                        WSNRLabel *label = (WSNRLabel*)view;
                        NSString *label_m_col = label.m_col;
                        if ([paraMinExpression rangeOfString:label_m_col].location != NSNotFound) {
                            paraMinExpression = [paraMinExpression stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",label_m_col] withString:[NSString stringNotNilWithValue: label.text]];
                        }
                    }
                }
                NSString *value = [[WSLuaScript getInstance] arithmeticExpressions:paraMinExpression];
                if ([validateValue floatValue] < [value floatValue]) {
                    NSString *title = nil;
                    if ([object isKindOfClass:[WSProdBean class]]) {
                        title = [(WSProdBean *)object name];
                    }else if ([object isKindOfClass:[WSDictBean class]]) {
                        title = [(WSDictBean *)object name];
                    }
                    /*
                    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:name message:[NSString stringWithFormat:@"%@最小值只能输入%@",param.name,value] delegate:nil cancelButtonTitle:nil otherButtonTitles: NSLocalizedString(@"confirm", nil), nil];
                    [alterView show];
                     */
                    [self acvtDataGridValidateWithFuncsBean_Param:param andValue:value title:title];

                    return YES;
                    
                }
            } else {
                
                if ([validatedView isKindOfClass:[WSHTextField  class]]) {
                    WSHTextField *textField = (WSHTextField *)validatedView;
                    validateValue = [textField text];
                    NSString *value = textField.m_min;
                    //  SFA-22645
                    //YIHAIKERRY-3894   CHT 类型 最大值最小值都没配的时候不做校验 董宏
                    if ((textField.m_max.length > 0 || textField.m_min.length > 0) && ([validateValue floatValue] < [value floatValue])) {
                        NSString *title = nil;
                        if ([object isKindOfClass:[WSProdBean class]]) {
                            title = [(WSProdBean *)object name];
                        }
                        
                        [self acvtDataGridValidateWithFuncsBean_Param:param andValue:value title:title];
                        return YES;
                    }
                }
                
            }
        }
        
    }
    return NO;
}
- (void)acvtDataGridValidateWithFuncsBean_Param:(WSFuncsBean_Param *)param andValue:(NSString *)value title:(NSString *)title
{
    NSString *message = [NSString stringWithFormat:@"%@最小值只能输入%@",param.name,value];
    NSString *destructiveTitle = NSLocalizedString(@"confirm", nil);
    if (IOS8_OR_LATER) {
        UIAlertController *alterController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        }];
        [alterController addAction:destructiveAction];
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        [model.ownAcvtViewController presentViewController:alterController animated:YES completion:nil];
        
    } else {
        UIAlertView *clearCacheAlterView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:destructiveTitle, nil];
        [clearCacheAlterView show];
    }
    
}

@end
