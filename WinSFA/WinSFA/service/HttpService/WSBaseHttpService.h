//
//  WSBaseHttpService.h
//  
//
//  Created by yang on 15/12/24.
//
//

#import <Foundation/Foundation.h>
#import "WSHttpRequestDefine.h"

typedef void(^WSBaseHttpServiceBlock)(NSDictionary * dic, NSError *error);

@interface WSBaseHttpService : NSObject


@property (nonatomic, strong) WSStoreBean *storeBean;
@property (nonatomic, copy)   NSString    *objID;
@property (nonatomic, strong) NSString    *srID;
@property (nonatomic, strong) NSString    *genID;
@property (nonatomic, strong) WSSubempstoreBean *subEmpStoreBean;

@property (nonatomic, strong) NSDictionary *paramDic;

- (id)initWithParamDictionary:(NSDictionary *)requestDic;

- (NSString *)getEmpID;


@end
