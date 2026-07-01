//
//  WSOfflineDataDBService.m
//  WinSFA
//
//  Created by yang on 15/4/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSOfflineDataDBService.h"

@implementation WSOfflineDataDBService

+ (BOOL) insertUploadData:(NSString*)aPostDate
                      URL:(NSString*)aUrl
                      MD5:(NSString*)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString*)aNotifyName

{
    LogTrace();
    if (!aNotifyName) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为空");
        return NO;
    }
    if ([aNotifyName isKindOfClass:[NSNull class]]) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为NULL");
        return NO;
    }
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    
    // emp_id
    NSString *emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [l_Values addObject:(emp_id != nil) ? emp_id : [NSNull null]];
//    SFA-27590 董宏
    if(!emp_id)
    {
        LogError(@"离线上传数据库插入未执行，原因：emp_id为NULL");
        return NO;
    }
    // biz_date
    NSString *biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [l_Values addObject:(biz_date != nil) ? biz_date : [NSNull null]];
    
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:(aPostDate != nil) ? aPostDate : [NSNull null]];
    //url
    [l_Values addObject:(aUrl != nil) ? aUrl : [NSNull null]];
    //md5
    [l_Values addObject:(aMd5 != nil) ? aMd5 : [NSNull null]];
    //isphoto
    if(aIsPhoto)
    {
        [l_Values addObject:@"1"];
        
    }else
        [l_Values addObject:@"0"];
    
    [l_Values addObject:aNotifyName];
    
    // 为保存向前兼容，不修改其它调用此方法的类，将之前使用此方法保存的数据都定为 D 类型
    [l_Values addObject:@"D"];
    
    //图片类型的存储图片路径，其他类型不需要使用，保持兼容，存个null
    [l_Values addObject:[NSNull null]];
    
    return [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
    
}

+ (BOOL) insertUploadMedia:(NSString *)aPostDate
                      Type:(NSString *)type
                       URL:(NSString *)aUrl
                       MD5:(NSString *)aMd5
                   IsPhoto:(BOOL)aIsPhoto
                NotifyName:(NSString *)aNotifyName
             photoFileName:(NSString *)photoFileName
{
    if (!aNotifyName) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为空");
        return NO;
    }
    if ([aNotifyName isKindOfClass:[NSNull class]]) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为NULL");
        return NO;
    }
    
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    
    // emp_id
    NSString *emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [l_Values addObject:(emp_id != nil) ? emp_id : [NSNull null]];
    
    // biz_date
    NSString *biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [l_Values addObject:(biz_date != nil) ? biz_date : [NSNull null]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:(aPostDate != nil) ? aPostDate : [NSNull null]];
    //url
    [l_Values addObject:(aUrl != nil) ? aUrl : [NSNull null]];
    //md5
    [l_Values addObject:(aMd5 != nil) ? aMd5 : [NSNull null]];
    //isphoto
    if(aIsPhoto)
    {
        [l_Values addObject:@"1"];
    }else
        [l_Values addObject:@"0"];
    
    [l_Values addObject:aNotifyName];
    
    // 使用 saveImg 方法上传的照片定为 P 类型
    [l_Values addObject:type];
    
    //图片类型的存储图片路径，用于清除图片缓存时判断是否已上传
    [l_Values addObject:(photoFileName != nil) ? photoFileName : [NSNull null]];
    
    return [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
    
}

@end
