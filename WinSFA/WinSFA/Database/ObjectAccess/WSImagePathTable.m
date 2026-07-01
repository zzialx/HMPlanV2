//
//  WSImagePathTable.m
//  WinSFA
//
//  Created by yang on 13-10-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSImagePathTable.h"
#import "WSAppData.h"


@implementation WSImagePathTable

static WSImagePathTable *imagePathTable = nil;
+ (WSImagePathTable *)sharedTable{
    
    if (imagePathTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            imagePathTable = [[WSImagePathTable alloc] init];
        });
    }
    return imagePathTable;
}

- (void)cleanOldData
{
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray *whereNames=[NSArray arrayWithObjects:@"not biz_date", nil];
//    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:currenTime], nil];
//    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
//SFA-25673 donghong
    
    NSString *lastTime = [WSAppData compareCurrentStrTime:currenTime withMonth:0 andDays:-7];
    NSString *sqlLast= [NSString stringWithFormat:@"delete  from wch_imagePath where biz_date < '%@'", [NSString stringNotNilWithValue:lastTime]];
    NSString *sql = [NSString stringWithFormat:@"delete  from wch_imagePath where IMG_IDX not in(select acvt_qst_answer from visit_store_acvt_data) and not biz_date = '%@'", [NSString stringNotNilWithValue:currenTime]];
    [self executeUpdateWithSqls:@[sqlLast,sql]];
    
}

- (void)updateWithImageIDX:(NSString *)imageIDX withValuesArray:(NSArray *)valuesArray
{
    [self deleteWithImageIDX:imageIDX];
    for(NSArray* array in valuesArray){
        [self insertWithArgumentsValue:array];
    }
}

- (void)deleteWithImageIDX:(NSString *)imageIDX
{
    LogInfo(@"delete imagePath,imageIndex is %@",imageIDX);
    
    NSArray *whereNames = [NSArray arrayWithObjects:@"img_idx", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:imageIDX], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (void)deleteWithImageIDX:(NSString *)imageIDX withImgKey:(NSString*)imgKeyStr
{
    LogInfo(@"delete imagePath,imageIndex is %@, %@",imageIDX, imgKeyStr);
    
    NSArray *whereNames = [NSArray arrayWithObjects:@"img_idx", @"img_path", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:imageIDX], [NSString stringNotNilWithValue:imgKeyStr], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (NSArray *)queryWithImageIDX:(NSString *)imageIDX
{
    NSArray *whereNames = [NSArray arrayWithObjects:@"img_idx", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:imageIDX], nil];
    return [self queryWithNames:whereNames ArgumentsValue:whereValues];
}

//查询图片路径
- (NSString *)backImagePathQueryWithImageIDX:(NSString *)imageIDX
{
    NSArray *imagePathArray = [self queryWithImageIDX:imageIDX];
    NSString *qstValue = imageIDX;
    if (imagePathArray.count > 0) {
        WSImagePathObject  * object= [imagePathArray firstObject];
        qstValue = object.img_path;
    }
    return qstValue;
}

@end
