//
//  WSDownloadFileTable.m
//  WinSFA
//
//  Created by winchannel on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDownloadFileTable.h"

@implementation WSDownloadFileTable

static WSDownloadFileTable* downloadTable=nil;

+ (WSDownloadFileTable *)sharedTable
{
    if(downloadTable==nil){
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            downloadTable=[[WSDownloadFileTable alloc] init];
        });
    }
    return downloadTable;
}


//清除前天数据
- (void)cleanOldData
{
    NSString *currentTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    [self deleteWithNames:@[@"not biz_date"] ArgumentsValue:@[currentTime]];
}

//插入数据
- (BOOL)insertWithFileArray:(NSArray *)fileValues
{
    return [self insertWithArgumentsValue:fileValues];
}

//根据url查询数据
- (NSArray *)queryWithFileURL:(NSString *)aURL
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];

//    NSArray *whereN=[NSArray arrayWithObjects:@"biz_date",@"empid",@"file_url" ,nil];
    NSArray *whereN=[NSArray arrayWithObjects:@"empid",@"file_url" ,nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:empid], aURL,nil];
    
    return [self queryWithNames:whereN ArgumentsValue:whereV];
}


//根据url更新数据
- (BOOL)updateWithFileURL:(NSString *)aURL status:(NSString*)file_download_status
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
//    NSArray *whereN=[NSArray arrayWithObjects:@"biz_date",@"empid",@"file_url" ,nil];
    NSArray *whereN=[NSArray arrayWithObjects:@"empid",@"file_url" ,nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:empid], aURL,nil];
    
    NSArray* N=[NSArray arrayWithObjects:@"file_download_status", nil];
    NSArray* V=[NSArray arrayWithObjects:file_download_status, nil];

    
   return [self updateWithNames:N values:V whereName:whereN whereValue:whereV];
    
}

- (BOOL)updateWithFileURL:(NSString *)aURL status:(NSString*)file_download_status file_szie:(NSNumber *)size downloadSize:(NSNumber *)downloadsize {
   
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    //    NSString *date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    //    NSArray *whereN=[NSArray arrayWithObjects:@"biz_date",@"empid",@"file_url" ,nil];
    NSArray *whereN=[NSArray arrayWithObjects:@"empid",@"file_url" ,nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:empid], aURL,nil];
    
    NSArray* N=[NSArray arrayWithObjects:@"file_download_status", @"file_length",@"file_download_size",nil];
    NSArray* V=[NSArray arrayWithObjects:file_download_status,size,downloadsize, nil];
    
    
    return [self updateWithNames:N values:V whereName:whereN whereValue:whereV];

}

- (BOOL)insertWithFileURL:(NSString *)aURL status:(NSString*)file_download_status file_szie:(NSNumber *)size downloadSize:(NSNumber *)downloadsize fileName:(NSString *)fileName
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString * fileId = [aURL md5];
     NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString * insert = [NSString stringWithFormat:@"INSERT INTO %@ (file_id,empid,file_download_status, file_name, file_url,file_length,file_download_size) VALUES ('%@','%@', '%@', '%@','%@','%@','%@')",dbTableName,fileId,empid,file_download_status,fileName,aURL,size, downloadsize];
    
    return [[WSFMDatebase getInstance] executeUpdateWithSql:insert];

}
@end
