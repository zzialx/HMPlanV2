//
//  WSOfflineDataDBService.h
//  WinSFA
//
//  Created by yang on 15/4/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//


@interface WSOfflineDataDBService : NSObject

+ (BOOL) insertUploadData:(NSString*)aPostDate
                      URL:(NSString*)aUrl
                      MD5:(NSString*)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString*)aNotifyName;

+ (BOOL) insertUploadMedia:(NSString *)aPostDate
                      Type:(NSString *)type
                       URL:(NSString *)aUrl
                       MD5:(NSString *)aMd5
                   IsPhoto:(BOOL)aIsPhoto
                NotifyName:(NSString *)aNotifyName
             photoFileName:(NSString *)photoFileName;

@end
