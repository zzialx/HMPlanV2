//
//  MsgsBean_msg.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSMsgsBean_msg.h"
#import "WSMappingObject.h"
#import "WSMsgsBean_Component_msg.h"

@implementation WSMsgsBean_msg

- (id)initWithObject:(id)object
{
    
    if (nil == object) 
    {
        return nil;
    }
    
    self = [super init];
    
    if (self)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *submsg = (NSDictionary *)object;
            _cont = [NSString stringWithValue:[submsg objectForKey:MSGS_CONT]];
            _empId = [NSString stringWithValue:[submsg objectForKey:MSGS_EMPID]];
            _Id = [NSString stringWithValue:[submsg objectForKey:MSGS_ID]];
            _isread = [NSString stringWithValue:[submsg objectForKey:MSGS_ISREAD]];
            _pid = [NSString stringWithValue:[submsg objectForKey:MSGS_PID]];
            _pubdate = [NSString stringWithValue:[submsg objectForKey:MSGS_PUBDATA]];
            _s = [NSString stringWithValue:[submsg objectForKey:MSGS_S]];
            _title = [NSString stringWithValue:[submsg objectForKey:MSGS_TITLE]];
            _typcode = [NSString stringWithValue:[submsg objectForKey:MSGS_TYPCODE]];
            _url = [NSString stringWithValue:[submsg objectForKey:MSGS_URL]];
            _acvtId = [NSString stringWithValue:[submsg objectForKey:MSGS_ACVTID]];
            _fileUrl = [NSString stringWithValue:[submsg objectForKey:MSGS_FILEURL]];
            _fileName = [NSString stringWithValue:[submsg objectForKey:MSGS_FILENAME]];
            _visitAddress = [NSString stringWithValue:[submsg objectForKey:MSGS_VISIT_ADDRESS]];
            _headrail = [NSString stringWithValue:[submsg objectForKey:MSGS_HEADRAIL]];
            _pinyin = [NSString stringWithValue:[submsg objectForKey:MSGS_PINYIN]];
            _store_id = [NSString stringWithValue:[submsg objectForKey:MSGS_STORE_ID]];

            
            
        }else if ([object isKindOfClass:[WSBaseMsgObject class]]){
            WSBaseMsgObject * submsg = (WSBaseMsgObject *)object;
            _empId = [NSString stringWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
            _s = [NSString stringWithFormat:@"%@_%@_0",_empId,submsg.pid];
           _typcode = [NSString stringWithValue:submsg.typcode];
//           _acvtId = [NSString stringWithValue:[submsg objectForKey:MSGS_ACVTID]]; //   ???
            _Id = [NSString stringWithFormat:@"%d",submsg.ID ? :[submsg._id intValue]];
            _cont = submsg.cont;
            _isread = submsg.isread;
            _pid = submsg.pid;
            _pubdate = submsg.pubdate;
            _title = submsg.title;
            _url = submsg.url;
            _fileName = submsg.filename;
            _fileUrl = submsg.fileurl;
            _visitAddress = submsg.visit_address;
            _video_url = submsg.video_url;
            _video_path = submsg.video_path;
            _sound_url = submsg.sound_url;
            _sound_path = submsg.sound_path;
            _update_time = submsg.updatetime;
            _organization = submsg.organization;
            _publisher = submsg.publisher;
            _headrail = submsg.headrail;
            _pinyin = submsg.pinyin;
            _store_id = submsg.store_id;
            _seq = submsg.seq;


            
        }
    }
    
    return self;
}


- (NSMutableArray *)generateComponentMsgsWith:(WSMsgsBean_msg *)object fileUrl:(NSString *)fileUrl {
    
    NSMutableArray *componentMsgs = [NSMutableArray array];
    NSArray *fileUrls = [fileUrl componentsSeparatedByString:@","];
    NSArray *fileNames = [object.fileName componentsSeparatedByString:@","];
    if ([fileUrls count] > 0) {
        for (NSInteger i = 0 ; i < [fileUrls count]; i++) {
            NSString *componentMsgFileUrl = [fileUrls objectAtIndex:i];
            WSMsgsBean_Component_msg *msg =[[WSMsgsBean_Component_msg alloc] initWithObject:object];
            msg.fileUrl = componentMsgFileUrl;
            if ([fileNames count]>i) {
                [msg setValue:fileNames[i] forKey:@"fileName"];
            }
            
            [componentMsgs addObject:msg];
        }
    }
    return componentMsgs;
}



- (NSString *)getDefaultValue {
    return self.fileUrl ?: self.url;
}



@end
