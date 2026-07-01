//
//  WSVisitPrepareViewController.m
//  WinSFA
//
//  Created by Stephanie on 16/8/31.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSVisitPrepareViewController.h"
#import "WSBaseAcvtDBService.h"
#import "WSJSONBuilder.h"
#import "WSAcvtModel.h"
#import "WSRequestHelper.h"
#import "WSBaseDictsDBService.h"

@implementation WSVisitPrepareViewController

- (void)confirmCompletion
{
    [super confirmCompletion];
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvtBean = [service queryAcvtWithAcvtCode:STORE_PREPARE_ACVT_CODE];
    WSAcvtBean_qst *prepareQst = [acvtBean getQstBeanByQstCod:STORE_PREPARE_ACVT_CODE];
    WSAcvtBean_qst *dateQst = [acvtBean getQstBeanByQstCod:@"baifangriqi"];
    
    if (acvtBean && prepareQst) {
        
        NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
        
        WSAcvtModel *acvtModel = [[WSAcvtModel alloc] init];
        acvtModel.currentFuncs = self.currentFuncs;
        acvtModel.currentStore = self.currentStore;
        acvtModel.currentAcvtBean = acvtBean;
        acvtModel.prepareVisitDate = self.prepareVisitDate;
        [acvtModel createMD5With:[acvtModel md5Param]];
        
        WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
        NSArray *dictsArray = [dictService queryDictsForAcvtGridWithFilter:prepareQst.filter];
        WSDictBean *prepareDict = nil;
        for (WSDictBean *dicBean in dictsArray) {
            if ([dicBean.cod isEqualToString:PREPARE_STATE_READY]) {
                prepareDict = dicBean;
                break;
            }
        }
        
        if (!prepareDict.Id) {
            return;
        }
        
        NSMutableDictionary *qstValuesDic = [@{[NSString stringWithFormat:@"%@%@",prepareQst.qstType, prepareQst.acvtQstId]:prepareDict.Id} mutableCopy];
        if (dateQst) {
            [qstValuesDic setValue:self.prepareVisitDate forKey:[NSString stringWithFormat:@"%@%@",dateQst.qstType, dateQst.acvtQstId]];
        }
        
        NSString *postData = [WSJSONBuilder buildAcvtDatasbyFuncs:self.currentFuncs
                                                             acvt:acvtBean
                                                          isPhoto:NO
                                                            Store:self.currentStore
                                                     qstValuesDic:qstValuesDic
                                                              md5:acvtModel.md5
                                                         submitId:acvtModel.md5
                                                           Others:nil
                                                addedAcvtForStore:nil
                                                       tableDatas:nil
                                                       photoNames:nil
                                                        isNeedAdd:NO
                                                            isAdd:NO];
        
        [self insertUploadData:postData URL:URL_UPLOAD MD5:acvtModel.md5 IsPhoto:NO NotifyName:notifyID];
        
        [acvtModel saveAcvtDatasToDB:qstValuesDic useNewMd5:nil];
        
        [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                                  notifyName:notifyID
                                                         md5:acvtModel.md5
                                        isSynchronizeRequest:[acvtModel isSynchronizeRequest]];
        
    }
}

@end
