//
//  MsgsBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"

#import "WSBaseMsgTable.h"
#import "WSMappingObject.h"
@implementation WSMsgsBean

@synthesize cod = _cod;
@synthesize empId = _empId;
@synthesize Id = _Id;
@synthesize k = _k;
@synthesize name = _name;
@synthesize msg = _msg;
@synthesize icon_url = _icon_url;



- (id)initWithObject:(id)object
{
    return  [self initWithObject:object storeId:@""];

}
- (id)initWithObject:(id)object storeId:(NSString*)storeId
{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *msgInfo = (NSDictionary *)object;
            _cod = [NSString stringWithValue:[msgInfo objectForKey:MSGS_COD]];
            _empId = [NSString stringWithValue:[msgInfo objectForKey:MSGS_EMPID]];
            _Id = [NSString stringWithValue:[msgInfo objectForKey:MSGS_ID]];
            _k = [NSString stringWithValue:[msgInfo objectForKey:MSGS_K]];
            _name = [NSString stringWithValue:[msgInfo objectForKey:MSGS_NAME]];
            _icon_url = [NSString stringWithValue:[msgInfo objectForKey:MSGS_ICON_URL]];
            
            
            if ([msgInfo objectForKey:MSGS_MSG] != nil) {
                NSArray *submsg = [msgInfo objectForKey:MSGS_MSG];
                _msg = [[NSMutableArray alloc]
                        initWithCapacity:[submsg count]];
                
                for (int i = 0; i < [submsg count]; i++) {
                    
                    NSObject *object = [submsg objectAtIndex:i];
                    WSMsgsBean_msg *subMsgBean = [[WSMsgsBean_msg alloc]
                                                  initWithObject:object];
                    subMsgBean.componentMsgs = [subMsgBean generateComponentMsgsWith:subMsgBean fileUrl:subMsgBean.fileUrl];
                    [self.msg insertObject:subMsgBean atIndex:i];
                    
                }
            }
        }else if ([object isKindOfClass:[WSBaseMsgTypeObject class]]){
            WSBaseMsgTypeObject * baseMsgType = (WSBaseMsgTypeObject *)object;
            _cod = baseMsgType.cod;
            _empId = [NSString stringWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
            _Id = [NSString stringWithFormat:@"%d",baseMsgType.ID];
            _k = [NSString stringWithFormat:@"%@_%@",_empId,_Id];
            _name = baseMsgType.name;
            _icon_url = baseMsgType.icon_url;
            NSArray * msgArray;
//            msgArray = [[[WSBaseMsgTable sharedTable] queryBaseMsgWithPid:_Id] copy];

            if (storeId.length>0) {
                msgArray = [[[WSBaseMsgTable sharedTable] queryStoreMsgByPid:_Id storeId:storeId] copy];
            }
            else
            {
                 msgArray = [[[WSBaseMsgTable sharedTable] queryBaseMsgWithPid:_Id] copy];
            }
            _msg = [[NSMutableArray alloc]initWithCapacity:[msgArray count]];
            for (int i = 0; i < [msgArray count]; i ++) {
                NSObject * object = [msgArray objectAtIndex:i];
                WSMsgsBean_msg * subMsgBean = [[WSMsgsBean_msg alloc]initWithObject:object];
                subMsgBean.componentMsgs = [subMsgBean generateComponentMsgsWith:subMsgBean fileUrl:subMsgBean.fileUrl];
                [self.msg insertObject:subMsgBean atIndex:i];
            }
        }
    }
    
    
    return self;
}


@end
