//
//  SubempstoreBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSSubempstoreBean.h"

@implementation WSSubempstoreBean

@synthesize empId=_empId;
@synthesize Id=_Id;
@synthesize name=_name;
@synthesize InArray=_InArray;
@synthesize outPlanStoreArray=_outPlanStoreArray;
@synthesize acvtArray=_acvtArray;
@synthesize cod=_cod;
@synthesize styp=_styp;
@synthesize orgId=_orgId;
@synthesize orgName=_orgName;
@synthesize orgCode=_orgCode;
@synthesize InArr=_InArr;
@synthesize outArr=_outArr;
@synthesize acvtArr=_acvtArr;
@synthesize actionState=_actionState;
@synthesize parentId = _parentId;
@synthesize detailArray = _detailArray;
@synthesize leafNode = _leafNode;




- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)initWithInArrayData{
    
    NSUInteger count = [_InArr count];
     _InArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (id inPlanStore in self.InArr) {
        WSStoreBean *subEmpStoreBean_in = [[WSStoreBean alloc] initStoreWithObject:inPlanStore IsPlan:YES storeAccessMode:WSStoreAccessModeSubEmp];
        [self.InArray addObject:subEmpStoreBean_in];
    }

}

-(void)initWithOutArrayData{
    
    NSUInteger count = [_outArr count];
    _outPlanStoreArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (id outPlanStore in self.outArr) {
        WSStoreBean *subEmpStoreBean_out = [[WSStoreBean alloc] initStoreWithObject:outPlanStore IsPlan:NO storeAccessMode:WSStoreAccessModeSubEmp];
        [self.outPlanStoreArray addObject:subEmpStoreBean_out];
    }

}

-(void)initWithAcvtArrayData{
    
    for (int i = 0; i < [self.acvtArr count]; i++) {
     WSAcvtBean *subBean_acvt = [[WSAcvtBean alloc] initWithObject:[self.acvtArr objectAtIndex:i]];
        [self.acvtArray insertObject:subBean_acvt atIndex:i];
    }
}

-(void)initWithDetailArrayData:(NSDictionary *)dic{
    
    NSArray *tmpArray = [dic objectForKey:@"detail"];
    for (int i = 0; i < [tmpArray count]; i++) {
        NSDictionary *tmpDic = [tmpArray objectAtIndex:0];
        if (tmpDic) {
            WSDetailInfo *tmpInfor = [[WSDetailInfo alloc] initWithObject:tmpDic];
            [_detailArray addObject:tmpInfor];
        }
    }
}

- (id)initWithObject:(id)object
{
     
    if (nil == object) 
        return nil;
     
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)object;
            
            _Id = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_ID]];
            
            _name = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_NAME]];
            
            _empId = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_EMPID]];
            
            _InArr = [dic objectForKey:SUBEMPSTORE_IN];
            
            _outArr = [dic objectForKey:SUBEMPSTORE_OUT];
            
            _acvtArr=[dic objectForKey:SUBEMPSTORE_ACVT];
            
            _cod = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_COD]];
            
            _styp = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_STYP]];
            
            _acvtArray=[[NSMutableArray alloc]initWithCapacity:[_acvtArr count]];

            _orgId = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_ORGID]];
            
            _orgName = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_ORGNAME]];
            
            _orgCode = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_ORGCODE]];
            
            _level_code = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_LEVELCODE]];
            
            _sub_level_code = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_SUBLEVELCODE]];
            
            _parentId = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_PARENTID]];
            
            _sonBean = [[NSMutableArray alloc]init];
            _jobTitle = [NSString stringWithValue:[dic objectForKey:@"jobTitle"]];
            
            _detailArray = [[NSMutableArray<WSDetailInfo> alloc] init];
            
            _leafNode = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_LEAFNODE]];
            
            _imgUrl = [NSString stringWithValue:[dic objectForKey:SUBEMPSTORE_IMGURL]];
            
            [self initWithInArrayData];
            [self initWithOutArrayData];
            [self initWithAcvtArrayData];
            [self initWithDetailArrayData:dic];
            
        }
    }
    
  return self;  
} 


- (void)setSubempStore:(WSBaseStoreObject *)baseStore {
    _Id = baseStore.store_id;
    _empId = baseStore.empid;
    _name = baseStore.name;
    _cod = baseStore.code;
    _styp = baseStore.styp;
}

- (id)copyWithZone:(NSZone *)zone {
    WSSubempstoreBean *copy = [[[self class] allocWithZone:zone] init];

    copy.empId = [self.empId copy];
    copy.Id = [self.Id copy];
    copy.name = [self.name copy];
    copy.InArray = [self.InArray copy];
    copy.acvtArray = [self.acvtArray copy];
    copy.outPlanStoreArray = [self.outPlanStoreArray copy];
    copy.cod = [self.cod copy];
    copy.styp = [self.styp copy];
    copy.orgId = [self.orgId copy];
    copy.orgName = [self.orgName copy];
    copy.orgCode = [self.orgCode copy];
    copy.InArr = [self.InArr copy];
    copy.acvtArr = [self.acvtArr copy];
    copy.outArr = [self.outArr copy];
    copy.level_code =[self.level_code copy];
    copy.sub_level_code = [self.sub_level_code copy];
    copy.parentId =[self.parentId copy];
    copy.sonBean = [[NSMutableArray alloc] initWithArray:self.sonBean copyItems:YES];
    copy.jobTitle = [self.jobTitle copy];
    copy.imgUrl = [self.imgUrl copy];
    copy.isOption = self.isOption;
    copy.isExpland = self.isExpland;
    copy.isAllExpand = self.isAllExpand;
    copy.detailArray = [self.detailArray copy];
    copy.leafNode = [self.leafNode copy];

    
    return copy;
}


#pragma mark - I_W_Cell
- (NSString *)getName {
    return self.name;
}

- (NSString *)getCode{
    
    return self.cod;
}
- (NSString *)getOrgName {
    return self.orgName;
}

- (NSString *)getOrgCode {
    return self.orgCode;
}

- (NSString *)getLevelCode{
    
    return self.level_code;
    
}

- (NSString *)getSub_Level_Code{
    return self.sub_level_code;
}
- (NSString *)getPid{
    
    return self.parentId;
}
- (NSString *)getId{
    
    return self.Id;
}
- (BOOL)getIsExpland{
    
    return self.isExpland;
}
- (NSArray *)getSonBean{
    
    return self.sonBean;
}
- (void)setIsExpland:(BOOL)isExpland{
    
    _isExpland = isExpland;
}

- (void)setLevel_code:(NSString *)level_code{
    _level_code = level_code;
}

- (void)setSonBean:(NSMutableArray *)sonBean{

    _sonBean = sonBean;
}

- (NSString *)getStyp{
    return nil;
}


- (BOOL)getIsAllExpand {
    return self.isAllExpand;
}

- (void)setIsAllExpand:(BOOL)isAllExpand {
    _isAllExpand = isAllExpand;
}

- (NSString *)getDataItemID {
    return self.Id;
}

- (NSString *)getDataItemName {
    return  self.name;
}

- (NSString *)getOrgId{
    return self.orgId;
}

- (BOOL)getOptioned {
    return self.isOption;
}

- (void)setOptioned:(BOOL)isOptioned{
    
    _isOption = isOptioned;
}

- (NSString *)getLeafNode {
    return self.leafNode;
}


@end
    
#pragma makr - 联系人详细信息
@implementation WSDetailInfo

- (id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self)
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = (NSDictionary *)object;
            _hxCode = [NSString stringWithValue:[dic objectForKey:@"hxCode"]];
            _name  = [NSString stringWithValue:[dic objectForKey:@"name"]];
            _phone  = [NSString stringWithValue:[dic objectForKey:@"phone"]];
            _headPhoto  = [NSString stringWithValue:[dic objectForKey:@"headPhoto"]];
            _jobTitle  = [NSString stringWithValue:[dic objectForKey:@"jobTitle"]];
            _orgName  = [NSString stringWithValue:[dic objectForKey:@"orgName"]];
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    WSDetailInfo *copy = [[[self class] allocWithZone:zone] init];
    
    copy.hxCode = [self.hxCode copy];
    copy.phone = [self.phone copy];
    copy.name = [self.name copy];
    copy.orgName = [self.orgName copy];
    copy.jobTitle = [self.jobTitle copy];
    copy.headPhoto = [self.headPhoto copy];

    return copy;
}

@end
