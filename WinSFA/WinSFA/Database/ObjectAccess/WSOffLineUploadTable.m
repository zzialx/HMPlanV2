//
//  WSOffLineUploadTable.m
//  WinChannelFrameWork
//
//  Created by Chen Angus on 12-2-3.
//  Copyright 2012年 dumbrock. All rights reserved.
//

#import "WSOffLineUploadTable.h"
#import "WSFMDatebase.h"
#import "WSAcvtModel.h"

@implementation WSOffLineUploadTable

static WSOffLineUploadTable *outLineUploadTable = nil;
+ (WSOffLineUploadTable *)sharedTable {
    
    if (outLineUploadTable == nil) {
        outLineUploadTable = [[WSOffLineUploadTable alloc] init];
    }
    return outLineUploadTable;
}

- (void)cleanOldData {
    
    LogInfo(@"WSOffLineUploadTable cleanOldData");
    
    NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray *whereNames = [NSArray arrayWithObjects:@"upload_flag", @"not biz_date", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:@"1", [NSString stringNotNilWithValue:currenTime], nil];
    
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (void)updateUploadFlagWithNotifyId:(NSString *)aNotifyId {
    
    LogInfo(@"WSOffLineUploadTable updateUploadFlagWithNotifyId notifyId = %@ upload_flag = 1", aNotifyId);
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
    
    NSArray *setNames = [NSArray arrayWithObjects:@"upload_flag", nil];
    NSArray *setValues = [NSArray arrayWithObjects:@"1", nil];
    NSArray *whereNames = [NSArray arrayWithObjects:@"notify", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:aNotifyId], nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
    
    NSArray *objArray = [self queryWithNames:@[@"upload_flag", @"is_photo", @"notify"] ArgumentsValue:@[@"1", @"0", [NSString stringNotNilWithValue:aNotifyId]]];
    WSOffLineUploadObject *object = [objArray firstObject];
    if (object) {
        [WSAcvtModel clearEnterBackgroundMarkWithMD5:object.img_idx];
    }
}






- (void)updateUploadFlagZeroWithNotifyId:(NSString *)aNotifyId
{
    LogInfo(@"\n [ loginfo - 更新离线上传数据状态为0  notifyId is %@]\n",aNotifyId);
    
    NSArray *setNames=[NSArray arrayWithObjects:@"upload_flag", nil];
    NSArray *setValues=[NSArray arrayWithObjects:@"0", nil];
    
    NSArray *whereNames=[NSArray arrayWithObjects:@"notify", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:aNotifyId], nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
}

-(void)updateUploadFlagErrorWithImageIndex:(NSString*)imageIndex notifyId:(NSString *)notifyId
{
    LogTrace();
    LogInfo(@"\n[ LogInfo 离线数据库的错误数据更新 imageIndex is %@ notifyId is %@]\n",imageIndex,notifyId);
    if (!imageIndex) {
        LogError(@"\n\n[ LogError 离线数据库的错误数据更新 imageIndex 为空 notifyId is %@]\n\n",notifyId);
        return;
    }
    NSArray *whereNames=[NSArray arrayWithObjects:@"upload_flag",@"img_idx",@"notify", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:@"0",imageIndex,notifyId, nil];
    NSArray *setNames=[NSArray arrayWithObjects:@"upload_flag", nil];
    NSArray *setValues=[NSArray arrayWithObjects:@"2", nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
}

-(void)updateErrorToUploadedError
{
    LogTrace();
    NSArray *whereNames=[NSArray arrayWithObjects:@"upload_flag", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:@"2", nil];
    NSArray *setNames=[NSArray arrayWithObjects:@"upload_flag", nil];
    NSArray *setValues=[NSArray arrayWithObjects:@"3", nil];
    
    [self updateWithNames:setNames values:setValues whereName:whereNames whereValue:whereValues];
}

- (NSArray*)queryWithUploadFlagType:(UploadFlagType)type
{
    NSArray *whereNames=nil;
    NSArray *whereValues=nil;
    if(type!=All){
        whereNames=[NSArray arrayWithObjects:@"upload_flag", nil];
        whereValues=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%lu",(unsigned long)type], nil];
    }
    
    return [self queryWithNames:whereNames ArgumentsValue:whereValues];
}

- (NSInteger)queryCountWithUploadFlagType:(UploadFlagType)type
{
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    BOOL isExists = [[WSFMDatebase getInstance] isTableExists:dbTableName];
    if (!isExists) {
        return 0;
    }
    
    NSArray *whereNames=nil;
    NSArray *whereValues=nil;
    if(type!=All){
        whereNames=[NSArray arrayWithObjects:@"upload_flag", nil];
        whereValues=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%lu",(unsigned long)type], nil];
    }
    
    return [self queryCountWithNames:whereNames ArgumentsValue:whereValues];
}

- (NSArray *)queryUploadFailedPhotoNames
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"upload_flag", @"not photo_filename", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:@"0", @"<null>", nil];
    
    NSArray *photoFileNamesDicArray =  [self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    NSMutableArray *photoFileNames = nil;
    if (photoFileNamesDicArray && [photoFileNamesDicArray count] > 0) {
        photoFileNames = [NSMutableArray array];
        for (WSOffLineUploadObject *object in photoFileNamesDicArray) {
            NSString *fileName = object.photo_filename;
            if (fileName && [fileName length] > 0) {
                [photoFileNames addObject:fileName];
            }
        }
    }
    
    return photoFileNames;
}

-(NSArray *)queryWithImg_idx:(NSString *)img_idx
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"emp_id", @"img_idx", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[WSAppData getObjectbyKey:APPDATA_EMPID],img_idx, nil];
    
    return [self queryWithNames:whereNames ArgumentsValue:whereValues];
}

-(BOOL) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    //person
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //date
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:aPostDate];
    //url
    [l_Values addObject:aUrl];
    //md5
    [l_Values addObject:aMd5];
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


-(BOOL) insertUploadMedia:(NSString *)aPostDate
                     Type:(NSString *)type
                      URL:(NSString *)aUrl
                      MD5:(NSString *)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString *)aNotifyName
            photoFileName:(NSString *)photoFileName
{
    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    //person
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //date
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:aPostDate];
    //url
    [l_Values addObject:aUrl];
    //md5
    [l_Values addObject:aMd5];
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
    if (photoFileName) {
        [l_Values addObject:photoFileName];
    }else
    {
        [l_Values addObject:[NSNull null]];
    }
    
    return [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
    
}


@end
