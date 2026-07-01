//
//  AcvtBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtBean.h"
#import "WSAcvtBean_qst.h"
#import "I_W_Cell.h"
#import "WSDownloadFileTable.h"
#import "WSDownloadUtil.h"
#import "WSAcvtService.h"
#import "WSAppData.h"
#import "WSTableItem.h"
#import "WSProdBean.h"


@implementation WSAcvtBean

@synthesize acvtId = _acvtId;
@synthesize acvtCode = _acvtCode;
@synthesize acvtName = _acvtName;
@synthesize acvtObj = _acvtObj;
@synthesize empId = _empId;
@synthesize typ = _typ;
@synthesize qsts = _qsts;
@synthesize iOriginalAcvtId = _iOriginalAcvtId;
@synthesize isBlock = _isBlock;
@synthesize gen_id = _gen_id;
@synthesize submitempid = _submitempid;
@synthesize isReadonly = _isReadonly;
@synthesize isUploaded = _isUploaded;
@synthesize acvt_Service;
@synthesize parentgenId;
@synthesize acvtParentQstId;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
     
    }
    
    return self;
}

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
            _acvtId = [NSString stringWithValue:[dic objectForKey:ACVT_ID]];
            _acvtCode = [NSString stringWithValue:[dic objectForKey:ACVT_CODE]];
            _acvtName = [NSString stringWithValue:[dic objectForKey:ACVT_NAME]];
            _acvtObj = [NSString stringWithValue:[dic objectForKey:ACVT_OBJ]];
            _empId = [NSString stringWithValue:[dic objectForKey:ACVT_EMPID]];
            _gen_id= [NSString stringWithValue:[dic objectForKey:ACVT_GENID]];
            _isReadonly= [NSString stringWithValue:[dic objectForKey:@"isReadonly"]];
            _isUploaded= [NSString stringWithValue:[dic objectForKey:@"isUploaded"]];
            _isReq = [NSString stringWithValue:[dic objectForKey:ACVT_ISREQ]];
            NSArray *qstarray = [dic objectForKey:ACVT_QST];
            _typ = [NSString stringWithValue:[dic objectForKey:ACVT_TYP]] ;
            _dateTyp = [NSString stringWithValue:[dic objectForKey:ACVT_DATE_TYP]] ;
            _publisher = [NSString stringWithValue:[dic objectForKey:ACVT_PUBLISHER]] ;

            _submitempid=[NSString stringWithValue:[dic objectForKey:@"submitempid"]];
            id oid = [dic objectForKey:ACVT_ORIGINALACVTID];
            if (oid != nil) {
                _iOriginalAcvtId = [[NSString stringWithValue: oid] copy];
            }
            _qsts = [[NSMutableArray alloc] initWithCapacity:[qstarray count]];
        
            _qstIdsForOriginReadonly = [[NSMutableArray alloc] initWithCapacity:[qstarray count]];
            _acvtIconUrl = [NSString stringWithValue:[dic objectForKey:@"acvtIconUrl"]];
            for (int i = 0; i < [qstarray count]; i++)
            {
                WSAcvtBean_qst *subqst = [[WSAcvtBean_qst alloc] 
                               initWithObject:[qstarray objectAtIndex:i]];
                if ([subqst.readonly isKindOfClass:[NSString class]] && [subqst.readonly isEqualToString:@"1"]) {
                    [_qstIdsForOriginReadonly addObject:subqst.acvtQstId];
                }
                
               [_qsts insertObject:subqst atIndex:i];
            }
            NSString *blockStr = [dic objectForKey:ACVT_IS_BLOCK];
            
            _isBlock = [NSString stringWithValue:blockStr];
            _luaScript = [NSString stringWithValue: [dic objectForKey:ACVT_FTEXT]];
        
            //存储在ws_download_file_store， storeid，url。。。。先解析qst，按照LT的isacvtname为1存名字，LC的defluatvalue 为url，通过storeid查询出url，再查询处名字返回
            if([_acvtCode rangeOfString:@"wt_training_exam"].location !=NSNotFound){
                __block NSString* filename=nil;
                __block NSString* fileurl=nil;
                __block NSString* filetype=nil;
                __block BOOL needSave=YES;
                
                NSString *configFileString = [[NSBundle mainBundle] pathForResource:@"configFile" ofType:@"plist"];
                NSMutableDictionary* plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:configFileString];
                NSString* severIP=[[[plistDic objectForKey:@"ServerIP"] componentsSeparatedByString:@"/mobile/"] firstObject];
                
                [_qsts enumerateObjectsUsingBlock:^(WSAcvtBean_qst* qst, NSUInteger idx, BOOL *stop){
                    if([qst.isAcvtName isEqualToString:@"1"]){
                        filename=qst.qstName;
                    }
                    if([qst.isAcvtName isEqualToString:@"4"]){
                        NSString* value=[qst.defaultValue stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                        
                        fileurl=[NSString stringWithFormat:@"%@%@",severIP,value];
                        
                        NSLog(@"===>>>> %@",fileurl);
                        
                        NSArray* fileArray=[[WSDownloadFileTable sharedTable] queryWithFileURL:fileurl];
                        if(fileArray.count>0){
                            needSave=NO;
                        }
                        filetype=[[qst.defaultValue componentsSeparatedByString:@"."] lastObject];
                    }
                }];
                
                if(needSave && filename && fileurl && filetype){
                    
                    NSMutableArray* fileArray=[NSMutableArray array];
                    [fileArray addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
                    [fileArray addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
                    [fileArray addObject:_acvtId];
                    [fileArray addObject:fileurl];
                    [fileArray addObject:filename];
                    [fileArray addObject:fileurl];
                    [fileArray addObject:@""];
                    [fileArray addObject:@""];
                    [fileArray addObject:filetype];
                    [fileArray addObject:[WSDownloadUtil getLocalFileNameWithUrl:fileurl fileTpye:filetype]];
                    [fileArray addObject:@"0"];
                    [fileArray addObject:@""];
                    [fileArray addObject:@""];
                    [fileArray addObject:@""];
                    [[WSDownloadFileTable sharedTable] insertWithFileArray:fileArray];
                
                }
                
            }
            
        }
    }
    
    return self;
}

- (WSAcvtBean_qst *)getQstBeanByQstID:(NSString *)qstID
{
    if (!qstID || [qstID length] == 0) {
        return nil;
    }
    
    for (WSAcvtBean_qst *qst in self.qsts) {
        if ([qst.qstId isEqualToString:qstID]) {
            return qst;
        }
    }
    
    return nil;
}

- (WSAcvtBean_qst *)getQstBeanByAcvtQstID:(NSString *)acvtQstID
{
    if (!acvtQstID || [acvtQstID length] == 0) {
        return nil;
    }
    
    for (WSAcvtBean_qst *qst in self.qsts) {
        if ([qst.acvtQstId isEqualToString:acvtQstID]) {
            return qst;
        }
    }
    
    return nil;
    
}

- (WSAcvtBean_qst *)getQstBeanByQstCod:(NSString *)qstCod
{
    if (!qstCod || [qstCod length] == 0) {
        return nil;
    }
    
    for (WSAcvtBean_qst *qst in self.qsts) {
        if ([qst.qstCod isEqualToString:qstCod]) {
            return qst;
        }
    }
    
    return nil;
}


- (NSMutableArray *)qsts {
    if (_qsts == nil) {
        _qsts = [[NSMutableArray alloc] init];
    }
    return _qsts;
}

-(NSMutableArray *)qstIdsForOriginReadonly{
    if (_qstIdsForOriginReadonly == nil) {
        _qstIdsForOriginReadonly = [[NSMutableArray alloc] init];
    }
    return _qstIdsForOriginReadonly;
}

- (WSAcvtBean_qst *)getQstBeanByQstName:(NSString *)qstName
{
    if (!qstName || [qstName length] == 0) {
        return nil;
    }
    
    for (WSAcvtBean_qst *qst in self.qsts) {
        if ([qst.qstName isEqualToString:qstName]) {
            return qst;
        }
    }
    
    return nil;
}

- (id)initAcvtBeanWithTableItem:(WSTableItem *)tableItem withItemId:(NSString *)itemId withItemName:(NSString *)itemName withLuaScript:(NSString *)luaScript{
    
    if (nil == tableItem) {
        return nil;
    }
    self = [super init];
    if (self) {
        _dateTyp = tableItem.dateTyp;
        _acvtId = itemId;
        _acvtName = itemName;
        _luaScript = luaScript;
        _qsts = [[NSMutableArray alloc] initWithCapacity:[tableItem.paramArray count]];
    
        for (int i = 0; i < tableItem.paramArray.count; i++) {
            WSFuncsBean_Param *param = [tableItem.paramArray objectAtIndex:i];
            WSAcvtBean_qst *subqst = [[WSAcvtBean_qst alloc] initAcvtQstWithFuncsParam:param withAcvtId:itemId];
            [_qsts insertObject:subqst atIndex:i];
        }
        
        WSAcvtBean_qst *subTypeQst = [[WSAcvtBean_qst alloc] init];
        subTypeQst.qstName = @"产品来源";
        subTypeQst.qstType = @"T";
        subTypeQst.qstCod = @"prodSource";
        subTypeQst.qstId = @"prodSource";
        subTypeQst.acvtQstId = @"prodSource";
        subTypeQst.orientation = @"1";
        subTypeQst.isHidden = @"1";
        [_qsts insertObject:subTypeQst atIndex:0];
        
        WSAcvtBean_qst *subqst = [[WSAcvtBean_qst alloc] init];
        subqst.qstName = @"产品名称";
        subqst.qstType = @"T";
        subqst.qstCod = @"prodId";
        subqst.qstId = @"prodId";
        subqst.acvtQstId = @"prodId";
        subqst.orientation = @"1";
        subqst.isHidden = @"1";
        [_qsts insertObject:subqst atIndex:0];
    }
    return self;
}
 

#pragma mark -
#pragma mark I_W_Cell method

-(NSArray *)getCellContentArray{
    
    return self.qsts;
}
#pragma mark I_W_OptionDataItem method
#pragma mark - I_W_OptionDataItem
- (NSString *)getDataItemID {
    return self.acvtId;
}

- (NSString *)getDataItemName {
    return self.acvtName;
}

@end
