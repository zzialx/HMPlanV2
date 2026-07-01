//
//  WSAcvtService.m
//  WinSFA
//
//  Created by winchannel on 15/8/25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtService.h"
#import "WSAcvtDisArray.h"
#import "WSAcvtDisBean.h"
#import "WSAcvtDisQstBean.h"
#import "WSAcvtBean.h"
#import "WSAcvtBean_qst.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSAcvtManagementObj.h"
#import "DateUtil.h"
#import "WSFacTable.h"
#import "WSFacQstTable.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSSqliteUtil.h"
#import "WSAcvtDisArray.h"
#import "WSBaseAcvtDBService.h"


#define WSACVTSERVICE_REQUEST_QUERY_NODE @"query_node"

typedef enum {
    // 保存本地数据
    WSSaveLocalData = 0,
    // 保存服务器返回数据
    WSSaveSeachedData
}WSSavedDataType;



@implementation WSAcvtService
@synthesize dynamic_node_name;
@synthesize fc;
@synthesize fv;
@synthesize current_acvt_md5;
@synthesize current_emp_id;



-(id)init{
    
    self = [super init];
    if (self) {
        
        dynamic_node_name = @"acvtdis";
        return self;
    }
    return nil;
}

-(void)requestAcvtDisplayByNode:(NSString *)acvtNodeName genId:(NSString *)genId empId:(NSString *)empId version:(NSString *)version {
    
    dynamic_node_name = acvtNodeName;
    
    current_edit_genid = genId;
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:WSACVTSERVICE_REQUEST_QUERY_NODE
                                               object:nil];
    
    NSMutableDictionary  *request_dict = [[NSMutableDictionary alloc] init];
    
    [request_dict setValue:acvtNodeName forKey:@"objId"]; //节点名称
    
    [request_dict setValue:genId forKey:@"genId"];  //  节点的genId
    
    [request_dict setValue:empId forKey:@"empId"]; //   empId
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr postRequestData:request_dict notifyName:WSACVTSERVICE_REQUEST_QUERY_NODE];
    

}

-(void)finishRequest:(id)sender
{
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    
    NSMutableDictionary  *dict = [info mutableObjectFromJSONString];
    
    current_acvt_dis_array= [[WSAcvtDisArray alloc] initWithObject:dict];
    
    if (current_acvt_dis_array) {
        [WSAppData putObject:current_acvt_dis_array forKey:ACVTDIS];
    }

    if ([self updateAlltheAcvtDis:current_acvt_dis_array]) {
        
        if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteSuccessed:andResultObject:)]) {
            
            [self.service_call_back_delegate serviceExecuteSuccessed:self andResultObject:current_acvt_dis_array];
            
        }
        
    }else{
        
        
        if ([self.service_call_back_delegate respondsToSelector:@selector(serviceExecuteFailed:andResultObject:andError:)]) {
            
            [self.service_call_back_delegate serviceExecuteFailed:self andResultObject:nil andError:nil];
        
        }
    }
}


-(BOOL)updateAlltheAcvtDis:(WSAcvtDisArray *)disarray{
    
    
    BOOL isupdate = NO;
    
    NSArray  *newdisarray =[disarray acvtDisArray];
    
    WSAcvtDisBean  *filterDisBean;
    
    for (int i=0; i<[newdisarray count]; i++) {
        
        WSAcvtDisBean *acvtDisBean = [newdisarray objectAtIndex:i];
        
        if ([acvtDisBean gen_id]!=nil && [[acvtDisBean gen_id] isEqualToString:current_edit_genid]) {
        
            filterDisBean = acvtDisBean;
            
            break;
            
        }
    }
    
    NSString * queryreleatesql =[self generateQuerySql: filterDisBean];
    
    NSMutableArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:queryreleatesql andClassName:@"WSAddStoreQstObject"];
    
    isupdate =[self updateAcvtDisplay:array andQstDataArray:[filterDisBean acvtDisQsts]];
    
    return isupdate;

}

-(NSString *)generateQuerySql:(WSAcvtDisBean *)disbean{
    
    NSMutableString *m_str =[[NSMutableString alloc] init];
    
    NSArray  *disarray = [disbean  acvtDisQsts];
   
    NSString  *gensql =@"select * from wch_addstoreQst where ans_id='%@' and QST_ID='%@' and ACVT_ID='%@'";
    
    for (int i=0; i<[disarray count]; i++) {
        
        WSAcvtDisQstBean   *qst_bean  =[disarray objectAtIndex:i];
        if (i<[disarray count]-1) {
            
            [m_str appendFormat:gensql,[qst_bean gen_id],[qst_bean qstId],[qst_bean acvtId]];
            [m_str appendFormat:@" %@ ",@"union"];
            
        }else{
            
            [m_str appendFormat:gensql,[qst_bean gen_id],[qst_bean qstId],[qst_bean acvtId]];
        }
       
        
    }
    return m_str;
    
}

-(BOOL)updateAcvtDisplay:(NSMutableArray *)updateDataArray andQstDataArray:(NSArray *)qstDataArray{
    
    BOOL isupdate =NO;
    
    NSMutableArray *sqlupdate_array = [[NSMutableArray alloc] init];
    
//    NSString  *update_add_qst_store_sql = @" update wch_addstoreQst set OPT_VAL='%@' where ans_id='%@' and QST_ID='%@' and ACVT_ID='%@' ";
    
    NSString  *delete_facqst_sql_with_format = @"DELETE FROM wch_facqst where ANS_ID IN (select IMG_IDX from wch_fac WHERE p_gen_id='%@')";
    
    NSString  *delete_facqst_sql = [NSString stringWithFormat:delete_facqst_sql_with_format,current_acvt_md5];
    
    [sqlupdate_array addObject:delete_facqst_sql]; //先删关联表
    
    NSString *delete_fac_sql_with_format = @"delete from wch_fac where p_gen_id='%@'";
    
    NSString *delete_fac_sql = [NSString stringWithFormat:delete_fac_sql_with_format,current_acvt_md5];
    
    [sqlupdate_array addObject:delete_fac_sql]; //再删主表
    
    NSString *update_all_addstore_qst = [NSString stringWithFormat:@"update wch_addStoreQst set OPT_VAL='' where ANS_ID='%@'",current_acvt_md5];
    
    [sqlupdate_array addObject:update_all_addstore_qst]; //修改所有的opt_val为空
    
    for (int i=0;i<[updateDataArray count]; i++) {
        
        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，AN类型在新调查问卷中已经支持，应该不需要此处的处理了，遇见问题时请根据实际情况修改
//        WSAddStoreQstObject *qust = [updateDataArray objectAtIndex:i];
//        
//        WSAcvtDisQstBean  *qustforupdate = [self matchTheDisQstBeanByAcvtId:[qust acvt_id] qstId:[qust qst_id] genId:[qust ans_id] andMatchDataArray:qstDataArray];
//        
//        NSString  *update_sql_for_execute = [NSString stringWithFormat:update_add_qst_store_sql,[qustforupdate qstValue],[qust ans_id],[qust qst_id],[qust acvt_id]];
//        
//        [sqlupdate_array addObject:update_sql_for_execute];
//        
//        
//        if ([[qust qst_type] isEqualToString:@"AN"]) {
//            
//            NSMutableArray *array = [self fetchANQstArray:[qustforupdate qstValue]];
//            
//            for (int j=0; j<[array count]; j++) {
//                
//                NSString *update_fac_qst_sql = [array objectAtIndex:j];
//                
//                [sqlupdate_array addObject:update_fac_qst_sql];
//                
//            }
//        }
    }
    
    isupdate=[[WSFMDatebase getInstance] executeUpdateWithSqls:sqlupdate_array];
    
    return isupdate;
}


-(WSAcvtDisQstBean *)matchTheDisQstBeanByAcvtId:(NSString *)acvtId
                                    qstId:(NSString *)qustId
                                    genId:(NSString *)genId
                        andMatchDataArray:(NSArray *)matchDataArray{

    
    for (int i=0; i<[matchDataArray count]; i++) {
        
       WSAcvtDisQstBean  *qustforupdate = [matchDataArray objectAtIndex:i];
        
        if ([acvtId isEqualToString:[qustforupdate acvtId]] && [qustId isEqualToString:[qustforupdate qstId]] && [genId isEqualToString:[qustforupdate gen_id]]) {
            
            return qustforupdate;
        }
        
    }
    
    return nil;
    
}

-(NSMutableArray *)fetchANQstArray:(NSString *)genId {
    
    
    NSMutableArray *sql_array =[[NSMutableArray alloc] init];
    
    NSArray *genIds= [genId componentsSeparatedByString:@","];

    
    for (int i=0; i<[genIds count]; i++) {
        
        NSString *gen_id = [genIds objectAtIndex:i];
        
 
        
        for (int j=0; j<[[current_acvt_dis_array acvtDisArray] count];j++) {
            
            WSAcvtDisBean  *dis_bean = [[current_acvt_dis_array acvtDisArray] objectAtIndex:j];
            
            
            if ([[dis_bean gen_id] isEqualToString:gen_id]) {
                
            NSArray  *array = [dis_bean acvtDisQsts];
                    
            NSDate  *date = [[NSDate alloc] init];
                    
            NSString  *datestr = [[[DateUtil alloc] init] obtainDate:date formateString:DATE_FORMAT_CH];
            NSString *facsql = [NSString stringWithFormat:@"INSERT INTO wch_fac (SR_ID,ACVT_ID,EMP_ID,RSPN_ID,STORE_ID,BIZ_DATE,UPLOAD_FLAG,UPLOAD_DATE,IMG_IDX,FUNC_CODE,FUNC_VIEW,IS_PLANED,MEMO,p_gen_id) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",@"null",[dis_bean acvtId],self.current_emp_id,@"",@"-1",datestr,@"1",datestr,[dis_bean gen_id],fc,fv,@"0",@"",current_acvt_md5];
                
                [sql_array addObject:facsql];
                
                NSString  *delete_sql= [NSString stringWithFormat:@"delete from wch_facQst where ANS_ID='%@'",gen_id];
                
               [sql_array  addObject:delete_sql];
               
               for (int k=0; k<[array count]; k++) {
                   
                        WSAcvtDisQstBean  *dis_qst = [array objectAtIndex:k];
                   
                        WSAcvtBean_qst *qst_bean = [self queryAcvtBeanById:[dis_qst acvtId] andQstId:[dis_qst qstId] andGenId:[dis_qst gen_id]];
                   
                        NSString  *fac_qst_sql = [NSString stringWithFormat:@"insert into wch_facQst (ANS_ID,OPT_VAL,QST_ID,QST_TYPE) values ('%@','%@','%@','%@')",[dis_qst gen_id],[dis_qst qstValue],[dis_qst qstId],[qst_bean qstType]];
                   
                        [sql_array addObject:fac_qst_sql];
                   
               }
            }
        }
        
    }
    return sql_array;
}

-(WSAcvtBean_qst *)queryAcvtBeanById:(NSString *)acvtId andQstId:(NSString *)qstId andGenId:(NSString *)genId{
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtID:acvtId];
    
    return [acvtBean getQstBeanByAcvtQstID:qstId];

}




@end
