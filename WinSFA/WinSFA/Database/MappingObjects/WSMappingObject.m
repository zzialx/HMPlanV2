//
//  WS.m
//  WinSFA
//
//  Created by zhangke on 14/9/3.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSMappingObject.h"


@implementation WSAddProductObject

@end



@implementation WSAddProductQstObject


@end


@implementation WSBaseStoreDataObject



@end


@implementation WSCustomTimeObject



@end


@implementation WSDictObject


- (NSString *)getDataItemID {
    return self.dict_id;
}


- (NSString *)getDataItemName {
    return nil;
}

@end


@implementation WSFdtObject


@end

@implementation WSFptObject


@end



@implementation WSImagePathObject


@end


@implementation WSInoutStoreObject

@end



@implementation WSOffLineUploadObject


@end


@implementation WSProductObject

- (NSString *)getDataItemID {
    return self.prod_id;
}


- (NSString *)getDataItemName {
    return nil;
}

@end



@implementation WSRequestDataCacheObject


@end



@implementation WSVisitPeoplePlanObject

@end


@implementation WSVisitStoreActionObject


- (id)copyWithZone:(NSZone *)zone {
	WSVisitStoreActionObject *copy = [[self class] allocWithZone:zone];
	copy.ID = self.ID;
	copy.parent_action_id = self.parent_action_id;
	copy.store_id = [self.store_id copy];
    copy.newstore_id = [self.newstore_id copy];
    copy.func_code = [self.func_code copy];
    copy.biz_date = [self.biz_date copy];
    copy.status = [self.status copy];
    copy.emp_id = [self.emp_id copy];
    copy.dict_id = [self.dict_id copy];
    copy.is_required = [self.is_required copy];
    copy.title = [self.title copy];
    copy.module_fc = [self.module_fc copy];
    copy.fromModuleName = [self.fromModuleName copy];
	return copy;
}
-(NSString *)description{
    NSString *des = [NSString stringWithFormat:@"Visit_store_actionObjects{_id=%d,parent_action_id=%d,store_id=%@,func_code=%@,biz_date=%@,status=%@,emp_id=%@,dict_id=%@,is_required=%@,title=%@,module_fc=%@,new_store_id=%@,fromModuleName=%@}",
                     self.ID,self.parent_action_id,self.store_id,
                     self.func_code,self.biz_date,self.status,self.emp_id,
                     self.dict_id,self.is_required,self.title,self.module_fc, self.newstore_id,self.fromModuleName];
    return des;
}


@end



@implementation WSVisitStorePlanObject

@end

@implementation WSDownloadFileObject

@end

@implementation WSBaseStoreObject


@end

@implementation WSBaseStoreVisitPlanObject


@end

@implementation WSBaseStoreOtherDataObject


@end

@implementation WSBaseMsgObject


@end

@implementation WSBaseMsgTypeObject


@end

@implementation WSBaseStoreAcvtObject


@end

@implementation WSBaseStoreAcvtDisObject

- (NSString *)getDataItemID
{
    return self.gen_id;
}

- (NSString *)getDataItemName
{
    return self.acvt_qst_answer;
}

@end

@implementation WSBaseStoreProdDisObject


@end

@implementation WSBaseStoreDictDisObject


@end

@implementation WSVisitStoreStatusObject


@end

@implementation WSBaseAcvtObject


@end

@implementation WSBaseInStoreProdObject


@end


@implementation WSVisitStoreAcvtDataObject

@end


@implementation WSBaseFunsObject


@end

@implementation  WSBaseSmsDataObject

@end

@implementation  WSUserBehaviorStatisticsObject

@end

@implementation WSBaseStoreDistruleObject

@end

@implementation  WSBdLocationDataObject

@end
@implementation  WSFuncsMenuNoticeObject

@end


