//
//  WSAcvtService.h
//  WinSFA
//
//  Created by winchannel on 15/8/25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//



#import "WSBaseService.h"

@class WSAcvtDisArray;
@class WSAcvtManagementObj;

@interface WSAcvtService : WSBaseService{
    
    NSString *dynamic_node_name;
    
    
    NSString  *current_edit_genid;
    
    NSString  *fc;
    NSString  *fv;
    NSString  *current_acvt_md5;
    NSString  *current_emp_id;
    
    WSAcvtDisArray  *current_acvt_dis_array;
}

@property (nonatomic,strong) NSString *fc;
@property (nonatomic,strong) NSString *fv;
@property (nonatomic,strong) NSString *current_acvt_md5;
@property (nonatomic,strong) NSString *dynamic_node_name;
@property (nonatomic,strong) NSString *current_emp_id;


/*
   @function-name:requestAcvtDisplayByNode:genId:empId;
   @param  acvtNodeName
   @param  genId
   @param  empId
   @param  version
   remark -根据节点名称，问卷编号，以及员工编号来查询

 */

-(void)requestAcvtDisplayByNode:(NSString *)acvtNodeName genId:(NSString *)genId empId:(NSString *)empId version:(NSString *)version;





@end
