//
//  WSCalendarLogicService.m
//  WinSFA
//
//  Created by Alicia on 2017/6/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCalendarLogicService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtQstDisItem.h"
#import "WSDimensMacros.h"

@implementation WSCalendarLogicService


+ (NSMutableDictionary *)getCalendaDutyPlanIcon:(NSArray *)dateStrs usingGenId:(BOOL)isUsingGenid acvtModel:(WSAcvtModel *)acvtModel withoutEmptyDic:(BOOL)withoutEmpty{
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    WSBaseAcvtDBService *acvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSMutableDictionary *calendarIconsDic = [NSMutableDictionary dictionary];

    NSString *searchText = [dateStrs componentsJoinedByString:@" "];
    NSArray *genIds = isUsingGenid ? @[acvtModel.md5]:nil;
    NSArray *acvtQstDisItems = [service queryAcvtQstDatasWithStoreID:acvtModel.currentStore.Id acvtType:acvtModel.currentFuncs.filter searchText:searchText genIDs:genIds isRead:YES isRemoteSearch:YES];
    
    
    NSArray *indexArray;
    if ([acvtQstDisItems count] > 0) {
        // 结果为多组调查问卷的问题，同一组的问题 genId 相同
        indexArray = [acvtQstDisItems valueForKeyPath:@"@distinctUnionOfObjects.genId"];
    }
   //加载过程570ms左右，内部循环最大值12ms
    for (NSString *date in dateStrs) {
        NSMutableDictionary *curentDic = [NSMutableDictionary dictionary];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"acvtanswer == %@", date];
        //求这一天的答案，再求出这些天的genId组合，
        NSArray *acvtdateDisArray = [acvtQstDisItems filteredArrayUsingPredicate:predicate];
        NSArray *genIds = [acvtdateDisArray valueForKeyPath:@"@distinctUnionOfObjects.genId"];

        for (NSString *genId in genIds) {
            NSPredicate *genIdPredicate = [NSPredicate predicateWithFormat:@"genId == %@", genId];
            //通过genId 求出答案
            NSArray *acvtQstArray = [acvtQstDisItems filteredArrayUsingPredicate:genIdPredicate];
            for (WSAcvtQstDisItem *acvtQstDisItem in acvtQstArray) {
                
                NSString *isAcvtName = acvtQstDisItem.isacvtname;
                NSString *acvtQstAnswer = acvtQstDisItem.acvtanswer;

                if ([isAcvtName length] > 0 && [acvtQstAnswer length] > 0) {
                    
                    // 如果问题是单选类型 R 则acvtQstAnswer为 选项id，否则acvtQstAnswer 就是问题的答案，为实际的url
                    if ([acvtQstDisItem.qsttype isEqualToString:QST_TYPE_R]) {
                        acvtQstAnswer = [acvtDBService queryOptPicByOptName:acvtQstDisItem.answer];
//                        NSString *acvtQstId = acvtQstDisItem.acvtQstId;
//                        acvtQstAnswer = [acvtDBService queryOptPicByID:acvtQstAnswer acvtQstID:acvtQstId];
                    }
                    NSString *compeletUrl = [WSHttpURLHelper getImageCompleteURL:acvtQstAnswer];
                    if ([isAcvtName isEqualToString:kAcvtNameCalendarRightImg]) {
                        curentDic[LOAD_IMAGE_Number10URL] = [NSString stringNotNilWithValue:compeletUrl];
                    }else if ([isAcvtName isEqualToString:kAcvtNameCalendarBottomImg]){
                        curentDic[LOAD_IMAGE_Number12URL] = [NSString stringNotNilWithValue:compeletUrl];
                    }else if ([isAcvtName isEqualToString:kAcvtNameCalendarRightBottomImg]){
                        curentDic[LOAD_IMAGE_Number13URL] = [NSString stringNotNilWithValue:compeletUrl];
                    }
                }
                
            }

        }
        if (withoutEmpty) {
            if ([curentDic allKeys].count > 0) {
                [calendarIconsDic setObject:curentDic forKey:date];
            }
        }else{
            [calendarIconsDic setObject:curentDic forKey:date];
        }
    }
    return calendarIconsDic;
}




+ (NSMutableDictionary *)getCalendaDutyPlanIcon:(NSArray *)dateStrs usingGenId:(BOOL)isUsingGenid acvtModel:(WSAcvtModel *)acvtModel {
    
    return [self getCalendaDutyPlanIcon:dateStrs usingGenId:isUsingGenid acvtModel:acvtModel withoutEmptyDic:YES];
}



@end
