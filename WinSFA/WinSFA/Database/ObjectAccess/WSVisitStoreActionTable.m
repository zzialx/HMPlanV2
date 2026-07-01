//
//  WSVisitStoreActionTable.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-20.
//
//


#import "WSVisitStoreActionTable.h"
#import "WSAppData.h"
#import "WSFuncsBeanArray.h"
#import "WSBaseFunsDBService.h"

static WSVisitStoreActionTable *sharedVisitAction = nil;

@implementation WSVisitStoreActionTable

+ (WSVisitStoreActionTable *)sharedTable {
    @synchronized(self) {
        if (sharedVisitAction == nil) {
            sharedVisitAction = [[WSVisitStoreActionTable alloc] init];
        }
    }
    return sharedVisitAction;
}

- (void)cleanOldData
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction toStatus:(NSString *)aStatus
{
    WSVisitStoreActionObject *newAction = [aAction copy];
    if (newAction.status != aStatus) {
        newAction.status = aStatus;
        
        
        NSArray *namesAndValuesFromAction = [self getActionObjectNamesAndValuesArray:aAction];
       
        NSArray *whereNamesArray = [namesAndValuesFromAction firstObject];
       
        
        NSArray *whereValuesArray = [namesAndValuesFromAction lastObject];
        
       
        
        NSArray *namesAndValuesFromNewAction = [self getActionObjectNamesAndValuesArray:newAction];
        
        NSArray *namesArray = [namesAndValuesFromNewAction firstObject];
        
       
        
        NSArray *valuesArray = [namesAndValuesFromNewAction lastObject];
        
    
        BOOL updateSuccess = [self updateWithNames:namesArray values:valuesArray whereName:whereNamesArray whereValue:whereValuesArray];
        if (!updateSuccess) {
            return NO;
        }
    }
    
    //顺便更新父亲级别的状态
    if (aAction.parent_action_id == 0) {
        return YES;
    }else {
        WSVisitStoreActionObject *tempAction = [[WSVisitStoreActionObject alloc] init];
        tempAction.parent_action_id = aAction.parent_action_id;
        tempAction.module_fc = aAction.module_fc;
        
        NSArray *brotherActionArr = [self queryActionsWithObject:tempAction];
        BOOL brotherActionAllComplete = YES;
        for (WSVisitStoreActionObject *subAction in brotherActionArr)
        {
            if ([subAction.is_required isEqualToString:@"R"] && ([subAction.status isEqualToString:ActionNotStart] || [subAction.status isEqualToString:ActionWorking])) {
                brotherActionAllComplete = NO;
                break;
            }
        }
        
        tempAction = [[WSVisitStoreActionObject alloc] init];
        tempAction.ID = aAction.parent_action_id;
        
        NSArray *parentArr = [self queryActionsWithObject:tempAction];
        
        NSString *parentStatus = ActionWorking;
        if (brotherActionAllComplete) {
            parentStatus = ActionDone;
        }
        if(parentArr.count>0){
            BOOL updateSuccess = [self updateAction:[parentArr objectAtIndex:0] toStatus:parentStatus];
            if (!updateSuccess) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction toStatus:(NSString *)aStatus inOutFlag:(NSString *)flag
{
    return [self updateAction:aAction toStatus:aStatus inOutFlag:flag parentForceToDone:NO];
}

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction toStatus:(NSString *)aStatus inOutFlag:(NSString *)flag parentForceToDone:(BOOL)parentForceToDone
{
    return [self updateAction:aAction toStatus:aStatus inOutFlag:flag parentForceToDone:parentForceToDone updateParentStatus:YES];
}

- (BOOL)updateAction:(WSVisitStoreActionObject *)aAction
            toStatus:(NSString *)aStatus
           inOutFlag:(NSString *)flag
   parentForceToDone:(BOOL)parentForceToDone
  updateParentStatus:(BOOL)updateParentStatus{
    WSVisitStoreActionObject *newAction = [aAction copy];
    
    
    if (newAction.status != aStatus) {
        newAction.status = aStatus;
        
        
        NSArray *namesAndValuesFromAction = [NSArray array];
        
        NSArray *whereNamesArray =[NSArray array];
        
        NSArray *whereValuesArray =[NSArray array];
        
        NSArray *namesAndValuesFromNewAction = [NSArray array];
        
        NSArray *namesArray =[NSArray array];
        
        NSArray *valuesArray =[NSArray array];
        
        if (flag) {
            namesAndValuesFromAction = [self getActionObjectNamesAndValuesArray:aAction andFlag:flag];
            
            whereNamesArray = [namesAndValuesFromAction firstObject];
            
            
            whereValuesArray = [namesAndValuesFromAction lastObject];
            
            
            namesAndValuesFromNewAction = [self getActionObjectNamesAndValuesArray:newAction andFlag:flag];
            
            namesArray = [namesAndValuesFromNewAction firstObject];
            
            valuesArray = [namesAndValuesFromNewAction lastObject];
            
        }
        
        else {
            namesAndValuesFromAction = [self getActionObjectNamesAndValuesArray:aAction];
            
            whereNamesArray = [namesAndValuesFromAction firstObject];
            
            whereValuesArray = [namesAndValuesFromAction lastObject];
            
            namesAndValuesFromNewAction = [self getActionObjectNamesAndValuesArray:newAction];
            
            namesArray = [namesAndValuesFromNewAction firstObject];
            
            valuesArray = [namesAndValuesFromNewAction lastObject];
            
        }
        
        
        
        BOOL updateSuccess = [self updateWithNames:namesArray values:valuesArray whereName:whereNamesArray whereValue:whereValuesArray];
        if (!updateSuccess) {
            return NO;
        }
    }
    
    //顺便更新父亲级别的状态
    if (aAction.parent_action_id == 0 || updateParentStatus == NO) {
        //return;
        
        /*
         
         此处return 无所谓，
         */
    }else {
        WSVisitStoreActionObject *tempAction = [[WSVisitStoreActionObject alloc] init];
        tempAction.parent_action_id = aAction.parent_action_id;
        tempAction.module_fc = aAction.module_fc;
        
        // WRIGLEY-1834 按照 Android 逻辑调整
//        NSString *parentStatus = ActionWorking;
//        
//        if (parentForceToDone) {
//            parentStatus = ActionDone;
//        }else {
//            NSArray *brotherActionArr = [self queryActionsWithObject:tempAction];
//            BOOL brotherActionAllComplete = YES;
//            for (WSVisitStoreActionObject *subAction in brotherActionArr)
//            {
//                if ([subAction.is_required isEqualToString:@"R"] && ([subAction.status isEqualToString:ActionNotStart] || [subAction.status isEqualToString:ActionWorking])) {
//                    brotherActionAllComplete = NO;
//                    break;
//                }
//            }
//            
//            if (brotherActionAllComplete) {
//                parentStatus = ActionDone;
//            }
//        }
        NSString *parentStatus = ActionDone;
        
        tempAction = [[WSVisitStoreActionObject alloc] init];
        tempAction.ID = aAction.parent_action_id;
        tempAction.fromModuleName = aAction.fromModuleName;
        NSArray *parentArr = [self queryActionsWithObject:tempAction];
        
        if(parentArr.count>0){
            BOOL updateSuccess = [self updateAction:[parentArr objectAtIndex:0] toStatus:parentStatus inOutFlag:flag];
            if (!updateSuccess) {
                return NO;
            }
        }
    }
    
    return YES;
}


// 前一步骤状态
/*
- (VisitActionStatus)queryPreActionStatus:(WSVisitStoreActionObject *)aAction
{
    if (aAction.ID - 1 == 0) {
        return ActionDone;
    }
    WSVisitStoreActionObject *queryBean = [[WSVisitStoreActionObject alloc] init];
    queryBean.ID = aAction.ID - 1;
    queryBean.parent_action_id = aAction.parent_action_id;
    queryBean.store_id = aAction.store_id;
    queryBean.biz_date = aAction.biz_date;
    queryBean.emp_id = aAction.emp_id;
    queryBean.module_fc = aAction.module_fc;
    
    NSArray *arr = [self queryActionsWithObject:queryBean];
    if (arr && arr.count>0) {
        WSVisitStoreActionObject *action = [arr objectAtIndex:0];
//        donghong  SFA-19573 排除非必填的影响
        if([action.is_required isEqualToString:@"R"])
        {
            return action.status;
        }
    }
    
    return ActionDone;
}
 */

// 查找顺序在当前状态之前（id < 当前 id）且必填 (is_required 为 R) 并没有完成拜访（status 非 ActionDone）的数据
- (NSArray *)getPreRequiredUndoneAction:(WSVisitStoreActionObject *)aAction {
    NSString *sql = [NSString stringWithFormat:@"select title from visit_store_action where parent_action_id = %ld and store_id  = '%@' and biz_date = '%@' and emp_id = '%@' and module_fc = '%@' and is_required = 'R' and _id < %ld  and status <> '%@'",
                     (long)aAction.parent_action_id, aAction.store_id, aAction.biz_date, aAction.emp_id, aAction.module_fc,  (long)aAction.ID, ActionDone];
    
    if (aAction.fromModuleName.length>0&&[aAction.fromModuleName isEqualToString:kHelpSales_Name]) {
        sql = [NSString stringWithFormat:@"%@ and fromModuleName = '%@'",sql,kHelpSales_Name];
    }else{
        sql = [NSString stringWithFormat:@"%@ and fromModuleName  is NULL ",sql];
    }
    NSArray *arr = [self queryAndReturnInfosBySql:sql andClassName:@"WSVisitStoreActionObject"];
    LogInfo(@"查找顺序在当前状态之sql:%@",sql);
    return arr;
}


// 未完成的必填项
- (NSArray *)queryNotCompleteButRequiredAction:(WSVisitStoreActionObject *)aAction {
    if (aAction == nil) {
        return nil;
    }
    WSVisitStoreActionObject *queryBean = [[WSVisitStoreActionObject alloc] init];
    queryBean.parent_action_id = aAction.parent_action_id;
    queryBean.store_id = aAction.store_id;
    queryBean.biz_date = aAction.biz_date;
    queryBean.emp_id = aAction.emp_id;
    queryBean.status = ActionNotStart;
    queryBean.is_required = @"R";
    queryBean.module_fc = aAction.module_fc;
    queryBean.nouploadInfo = @"1";
    queryBean.fromModuleName = aAction.fromModuleName;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSArray *notStartArray = [self queryActionsWithObject:queryBean];
    if (notStartArray) {
        [resultArray addObjectsFromArray:notStartArray];
    }
    
    queryBean.status = ActionWorking;
    
    NSArray *workingArray = [self queryActionsWithObject:queryBean];
    if (workingArray) {
        [resultArray addObjectsFromArray:workingArray];
    }

    return resultArray;
}


- (void)insertCurrentAction:(WSVisitStoreActionObject *)aAction {
    
    NSArray *actions = [self queryActionsWithObject:aAction];
    if (!([actions count] > 0)) {
        [self insertTable:aAction];
    }
}

- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction isQueryTitle:(BOOL)isQueryTitle {
    return [self queryActionStatus:aAction intOutFlag:nil isQueryTitle:isQueryTitle];
}

- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction {
    return [self queryActionStatus:aAction intOutFlag:nil isQueryTitle:NO];
}

- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction intOutFlag:(NSString *)flag {
    
    return [self queryActionStatus:aAction intOutFlag:flag isQueryTitle:NO];
}

- (VisitActionStatus)queryActionStatus:(WSVisitStoreActionObject *)aAction intOutFlag:(NSString *)flag isQueryTitle:(BOOL)isQueryTitle {
    WSVisitStoreActionObject *tempAction = [aAction copy];
    if (!isQueryTitle) {
        // MSTD-4877 中英文切换，不查询 title
        tempAction.title = nil;
    }
    NSArray *arr = [self queryActionsWithObject:tempAction andFlag:flag];
    
    if (arr && arr.count>0)
    {
        WSVisitStoreActionObject *action = [arr objectAtIndex:0];
        
        return action.status;
    }
    else
    {
        aAction.status = ActionNotStart;
        
        if (flag!=nil && flag.length>0) {
            
            if (![flag isEqualToString:aAction.module_fc]) {
                
                aAction.module_fc = flag;
            }
            
        }

        [self insertTable:aAction];
    }
    
    return ActionNotStart;
    
}

- (int)queryActionId:(WSVisitStoreActionObject *)aAction
{
    NSArray *arr = [self queryActionsWithObject:aAction];
    if (arr && arr.count>0) {
        WSVisitStoreActionObject *action = [arr objectAtIndex:0];
        return action.ID;
    }
    return 0;
}

- (NSArray *)queryActionsWithObject:(WSVisitStoreActionObject *)aObject
{
    NSArray *namesAndValues = [self getQueryActionObjectNamesAndValuesArray:aObject];
    NSArray *whereNameArray = [namesAndValues firstObject];
    NSArray *whereValueArray = [namesAndValues lastObject];
    return [self queryWithNames:whereNameArray ArgumentsValue:whereValueArray];
}

-(NSArray *)queryActionsWithObjectExceptParentId:(WSVisitStoreActionObject *)aObject{
    
    
    NSArray *nameAndValues = [self getActionObjectNamesAndValuesExceptParentIdArray:aObject];
    
    NSArray *whereNameArray = [nameAndValues firstObject];
    NSArray *whereValueArray = [nameAndValues lastObject];
    
     return [self queryWithNames:whereNameArray ArgumentsValue:whereValueArray];
}


- (NSArray *)queryActionsWithObject:(WSVisitStoreActionObject *)aObject andFlag:(NSString *)inoutFlag
{
    NSArray *namesAndValues = [self getQueryActionObjectNamesAndValuesArray:aObject andFlag:inoutFlag];
    NSArray *whereNameArray = [namesAndValues firstObject];
    NSArray *whereValueArray = [namesAndValues lastObject];
    return [self queryWithNames:whereNameArray ArgumentsValue:whereValueArray];
}

- (void)insertTable:(WSVisitStoreActionObject *)aValue {
    
    if (aValue == nil) {
        return;
    }
    NSMutableArray *aValArray = [[NSMutableArray alloc] init];
    NSInteger parent_action_id = aValue.parent_action_id;
    NSString *store_id = aValue.store_id;
    NSString *func_code = aValue.func_code;
    NSString *biz_date = aValue.biz_date;
    NSString *status = aValue.status;
    NSString *emp_id = aValue.emp_id;
    NSString *dict_id = aValue.dict_id;
    NSString *is_required = aValue.is_required;
    NSString *title = aValue.title;
    NSString *module_fc = aValue.module_fc;
    NSString *newStore_id = aValue.newstore_id;
    
    [aValArray addObject:[NSString stringWithFormat:@"%ld", (long)parent_action_id]];
    [aValArray addObject:(store_id != nil) ? store_id : [NSNull null]];
    [aValArray addObject:(func_code != nil) ? func_code : [NSNull null]];
    [aValArray addObject:(biz_date != nil) ? biz_date : [NSNull null]];
    [aValArray addObject:(status != nil) ? status : [NSNull null]];
    [aValArray addObject:(emp_id != nil) ? emp_id : [NSNull null]];
    [aValArray addObject:(dict_id != nil) ? dict_id : [NSNull null]];
    [aValArray addObject:(is_required != nil) ? is_required : [NSNull null]];
    [aValArray addObject:(title != nil) ? title : [NSNull null]];
    [aValArray addObject:(module_fc != nil) ? module_fc : [NSNull null]];
    [aValArray addObject:(newStore_id != nil) ? newStore_id : [NSNull null]];
    
    if (aValue.fromModuleName.length>0&&[aValue.fromModuleName isEqualToString:kHelpSales_Name]) {
        [aValArray addObject:aValue.fromModuleName];
    }else{
        [aValArray addObject:[NSNull null]];
    }

    [self insertWithArgumentsValue:aValArray];
}


- (NSArray *)getActionObjectNamesAndValuesArray:(WSVisitStoreActionObject *)aObject
{
    NSMutableArray *namesAndValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    if (aObject.ID != 0) {
        [nameArray addObject:@"_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.ID]];
    }
  
    if (aObject.store_id != nil) {
        [nameArray addObject:@"store_id"];
        [valueArray addObject:aObject.store_id];
    }
    
    if (aObject.biz_date != nil) {
        [nameArray addObject:@"biz_date"];
        [valueArray addObject:aObject.biz_date];
    }
    if (aObject.status != nil) {
        [nameArray addObject:@"status"];
        [valueArray addObject:aObject.status];
    }
    if (aObject.emp_id != nil) {
        [nameArray addObject:@"emp_id"];
        [valueArray addObject:aObject.emp_id];
    }
    if (aObject.dict_id != nil) {
        [nameArray addObject:@"dict_id"];
        [valueArray addObject:aObject.dict_id];
    }
    if (aObject.is_required != nil) {
        [nameArray addObject:@"is_required"];
        [valueArray addObject:aObject.is_required];
    }
    if (aObject.title != nil) {
        [nameArray addObject:@"title"];
        [valueArray addObject:aObject.title];
        
    }
        
    if (aObject.parent_action_id != 0) {
        
        [nameArray addObject:@"parent_action_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.parent_action_id]];
    }
    
    if (aObject.func_code != nil) {
        [nameArray addObject:@"func_code"];
        [valueArray addObject:aObject.func_code];
    }
        
    if ([aObject.nouploadInfo isEqualToString:@"1"]) {
        if (aObject.module_fc != nil&&![aObject.module_fc isEqualToString:@""]) {
            [nameArray addObject:@"module_fc"];
            [valueArray addObject:aObject.module_fc];
        }
    }
    
    if (aObject.newstore_id != nil) {
        [nameArray addObject:@"newstore_id"];
        [valueArray addObject:aObject.newstore_id];
    }
    [namesAndValuesArray addObject:nameArray];
    [namesAndValuesArray addObject:valueArray];
    return namesAndValuesArray;
}
- (NSArray *)getQueryActionObjectNamesAndValuesArray:(WSVisitStoreActionObject *)aObject
{
    NSMutableArray *namesAndValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    if (aObject.ID != 0) {
        [nameArray addObject:@"_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.ID]];
    }
  
    if (aObject.store_id != nil) {
        [nameArray addObject:@"store_id"];
        [valueArray addObject:aObject.store_id];
    }
    
    if (aObject.biz_date != nil) {
        [nameArray addObject:@"biz_date"];
        [valueArray addObject:aObject.biz_date];
    }
    if (aObject.status != nil) {
        [nameArray addObject:@"status"];
        [valueArray addObject:aObject.status];
    }
    if (aObject.emp_id != nil) {
        [nameArray addObject:@"emp_id"];
        [valueArray addObject:aObject.emp_id];
    }
    if (aObject.dict_id != nil) {
        [nameArray addObject:@"dict_id"];
        [valueArray addObject:aObject.dict_id];
    }
    if (aObject.is_required != nil) {
        [nameArray addObject:@"is_required"];
        [valueArray addObject:aObject.is_required];
    }
    if (aObject.title != nil) {
        [nameArray addObject:@"title"];
        [valueArray addObject:aObject.title];
        
    }
        
    if (aObject.parent_action_id != 0) {
        
        [nameArray addObject:@"parent_action_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.parent_action_id]];
    }
    
    if (aObject.func_code != nil) {
        [nameArray addObject:@"func_code"];
        [valueArray addObject:aObject.func_code];
    }
        
    if ([aObject.nouploadInfo isEqualToString:@"1"]) {
        if (aObject.module_fc != nil&&![aObject.module_fc isEqualToString:@""]) {
            [nameArray addObject:@"module_fc"];
            [valueArray addObject:aObject.module_fc];
        }
    }
    
    if (aObject.newstore_id != nil) {
        [nameArray addObject:@"newstore_id"];
        [valueArray addObject:aObject.newstore_id];
    }
    if (aObject.fromModuleName != nil && aObject.fromModuleName.length>0 && [aObject.fromModuleName isEqualToString:kHelpSales_Name]) {
        [nameArray addObject:@"fromModuleName"];
        [valueArray addObject:aObject.fromModuleName];
    }else{
        [nameArray addObject:@"fromModuleName"];
        [valueArray addObject:[NSNull null]];
    }
    [namesAndValuesArray addObject:nameArray];
    [namesAndValuesArray addObject:valueArray];
    return namesAndValuesArray;
}


-(NSArray *)getActionObjectNamesAndValuesExceptParentIdArray:(WSVisitStoreActionObject *)aObject{
    
    NSMutableArray *namesAndValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    if (aObject.ID != 0) {
        [nameArray addObject:@"_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.ID]];
    }
    
    if (aObject.store_id != nil) {
        [nameArray addObject:@"store_id"];
        [valueArray addObject:aObject.store_id];
    }
    
    if (aObject.biz_date != nil) {
        [nameArray addObject:@"biz_date"];
        [valueArray addObject:aObject.biz_date];
    }
    if (aObject.status != nil) {
        [nameArray addObject:@"status"];
        [valueArray addObject:aObject.status];
    }
    if (aObject.emp_id != nil) {
        [nameArray addObject:@"emp_id"];
        [valueArray addObject:aObject.emp_id];
    }
    if (aObject.dict_id != nil) {
        [nameArray addObject:@"dict_id"];
        [valueArray addObject:aObject.dict_id];
    }
    if (aObject.is_required != nil) {
        [nameArray addObject:@"is_required"];
        [valueArray addObject:aObject.is_required];
    }
    if (aObject.title != nil) {
        [nameArray addObject:@"title"];
        [valueArray addObject:aObject.title];
        
    }
    if (aObject.func_code != nil) {
        [nameArray addObject:@"func_code"];
        [valueArray addObject:aObject.func_code];
    }
    
    
//    if (aObject.module_fc != nil) {
//        [nameArray addObject:@"module_fc"];
//        [valueArray addObject:aObject.module_fc];
//    }
    if (aObject.newstore_id != nil) {
        [nameArray addObject:@"newstore_id"];
        [valueArray addObject:aObject.newstore_id];
    }
    
    [namesAndValuesArray addObject:nameArray];
    [namesAndValuesArray addObject:valueArray];
    return namesAndValuesArray;
    
}

- (NSArray *)getActionObjectNamesAndValuesArray:(WSVisitStoreActionObject *)aObject andFlag:(NSString *)inOutFlag
{
    NSMutableArray *namesAndValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    if (aObject.ID != 0) {
        [nameArray addObject:@"_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.ID]];
    }
    
    
    if (aObject.biz_date != nil) {
        [nameArray addObject:@"biz_date"];
        [valueArray addObject:aObject.biz_date];
    }
    if (aObject.status != nil) {
        [nameArray addObject:@"status"];
        [valueArray addObject:aObject.status];
    }
    if (aObject.emp_id != nil) {
        [nameArray addObject:@"emp_id"];
        [valueArray addObject:aObject.emp_id];
    }
    if (aObject.dict_id != nil) {
        [nameArray addObject:@"dict_id"];
        [valueArray addObject:aObject.dict_id];
    }
    if (aObject.is_required != nil) {
        [nameArray addObject:@"is_required"];
        [valueArray addObject:aObject.is_required];
    }
    
    if (aObject.store_id != nil) {
        [nameArray addObject:@"store_id"];
        [valueArray addObject:aObject.store_id];
    }
    
    if (aObject.title != nil) {
        [nameArray addObject:@"title"];
        [valueArray addObject:aObject.title];
        
    }
   
    if (aObject.func_code != nil) {
        [nameArray addObject:@"func_code"];
        [valueArray addObject:aObject.func_code];
    }
    
    if (inOutFlag == nil) {

//        if (aObject.module_fc != nil&&![aObject.module_fc isEqualToString:@""]) {
//            [nameArray addObject:@"module_fc"];
//            [valueArray addObject:aObject.module_fc];
//        }
        
        if (aObject.parent_action_id != 0) {
            [nameArray addObject:@"parent_action_id"];
            [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.parent_action_id]];
        }
       
        
        
    }
    if (aObject.newstore_id != nil) {
        [nameArray addObject:@"newstore_id"];
        [valueArray addObject:aObject.newstore_id];
    }
    [namesAndValuesArray addObject:nameArray];
    [namesAndValuesArray addObject:valueArray];
    return namesAndValuesArray;
}
- (NSArray *)getQueryActionObjectNamesAndValuesArray:(WSVisitStoreActionObject *)aObject andFlag:(NSString *)inOutFlag
{
    NSMutableArray *namesAndValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    if (aObject.ID != 0) {
        [nameArray addObject:@"_id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.ID]];
    }
    
    
    if (aObject.biz_date != nil) {
        [nameArray addObject:@"biz_date"];
        [valueArray addObject:aObject.biz_date];
    }
    if (aObject.status != nil) {
        [nameArray addObject:@"status"];
        [valueArray addObject:aObject.status];
    }
    if (aObject.emp_id != nil) {
        [nameArray addObject:@"emp_id"];
        [valueArray addObject:aObject.emp_id];
    }
    if (aObject.dict_id != nil) {
        [nameArray addObject:@"dict_id"];
        [valueArray addObject:aObject.dict_id];
    }
    if (aObject.is_required != nil) {
        [nameArray addObject:@"is_required"];
        [valueArray addObject:aObject.is_required];
    }
    
    if (aObject.store_id != nil) {
        [nameArray addObject:@"store_id"];
        [valueArray addObject:aObject.store_id];
    }
    
    if (aObject.title != nil) {
        [nameArray addObject:@"title"];
        [valueArray addObject:aObject.title];
        
    }
   
    if (aObject.func_code != nil) {
        [nameArray addObject:@"func_code"];
        [valueArray addObject:aObject.func_code];
    }
    
    if (inOutFlag == nil) {

//        if (aObject.module_fc != nil&&![aObject.module_fc isEqualToString:@""]) {
//            [nameArray addObject:@"module_fc"];
//            [valueArray addObject:aObject.module_fc];
//        }
        
        if (aObject.parent_action_id != 0) {
            [nameArray addObject:@"parent_action_id"];
            [valueArray addObject:[NSString stringWithFormat:@"%d", aObject.parent_action_id]];
        }
       
        
        
    }
    if (aObject.newstore_id != nil) {
        [nameArray addObject:@"newstore_id"];
        [valueArray addObject:aObject.newstore_id];
    }
    if (aObject.fromModuleName != nil && aObject.fromModuleName.length>0 && [aObject.fromModuleName isEqualToString:kHelpSales_Name]) {
        [nameArray addObject:@"fromModuleName"];
        [valueArray addObject:aObject.fromModuleName];
    }else{
        [nameArray addObject:@"fromModuleName"];
        [valueArray addObject:[NSNull null]];
    }
    [namesAndValuesArray addObject:nameArray];
    [namesAndValuesArray addObject:valueArray];
    return namesAndValuesArray;
}

- (BOOL) updateNewColumnContent:(NSArray *)columns
{

    
    return YES;
}
- (void)updateStatusWithStoreId:(NSString *)storeId funcCode:(NSString *)funCode empId:(NSString *)empId withStatus:(NSString *)status
{
        NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
        NSString* func_code = [NSString stringNotNilWithValue:funCode];
        //    NSArray *query_names = @[@"emp_id",@"store_id",@"biz_date",@"func_code"];
        //    NSArray *query_values = @[[NSString stringNotNilWithValue: empId],storeId,biz_date,func_code];
        NSString *updateSql = [NSString stringWithFormat:@"update visit_store_action set status = '%@' where  emp_id = '%@' and store_id = '%@' and biz_date = '%@' and func_code = '%@'",status,empId,storeId,biz_date, @"F20S01_99"];
        [[WSVisitStoreActionTable sharedTable] executeUpdateWithSqls:@[updateSql]];
}
- (NSString *)queryNotCompleteBrotherFuncsFromMustFillFuncsWithCurrentFc:(NSString *)currentFc withStype:(NSString *)styp withStoreId:(NSString *)storeId{
    
    WSBaseFunsDBService *funcsdb = [[WSBaseFunsDBService alloc]init];
    NSString *funcsId = [funcsdb getFuncsIdWithCurrentFc:currentFc];
    
    //styp
    if (!styp || [styp length] == 0) {
        return @"";
    }
    NSString *stypReplaceStr = @"";
    NSArray *stypReplaces = [styp componentsSeparatedByString:@"-"];
    if ([stypReplaces count] > 0) {
        stypReplaceStr = [NSString stringWithFormat:@" or styp ='%@'", stypReplaces[0]];
    }
    
    NSString *currentStyp = [NSString stringWithFormat:@" and (styp = '%@' or styp is null or styp like '%%%@,%%' %@)", styp, styp, stypReplaceStr];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    //key && value
    NSArray *keyArray = @[@"$storeId$", @"$funcsId$", @"$func_styp$", @"$emp_id$"];
    NSArray *valueArray = @[storeId, funcsId, currentStyp,empId];
    
    if ([keyArray count] != [valueArray count]) {
        NSLog(@"keyArray count  != valueArray count !");
        return nil;
    }
    NSString * path = [[NSBundle mainBundle]pathForResource:@"QuerySql.plist" ofType:nil];
    NSDictionary  *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString * sql = [plistDict objectForKey:@"notFillFuncsQuerySql"];
    
    
    for (int i = 0; i < keyArray.count ; i++) {
        sql =  [sql stringByReplacingOccurrencesOfString:keyArray[i] withString:valueArray[i]];
    }
    
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    NSString *names = @"";
    NSInteger count = 0;
    while ([rs next]) {
        NSString *funcsName = [rs stringForColumn:@"a.name"];
        if (count > 0) {
            names = [names stringByAppendingString:@","];
        }
        names = [names stringByAppendingFormat:@"%@", funcsName];
        count++;
    }
    return names;
}
@end
