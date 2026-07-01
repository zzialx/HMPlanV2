//
//  WSBaseHttpService.m
//  
//
//  Created by yang on 15/12/24.
//
//

#import "WSBaseHttpService.h"

@implementation WSBaseHttpService

- (id)initWithParamDictionary:(NSDictionary *)requestDic{
    self = [super init];
    if (self) {
        
        _paramDic = [[NSMutableDictionary alloc]initWithDictionary:requestDic];
    }
    
    return self;
}
- (NSString *)getEmpID
{
    if ([self.srID length] > 0) {
        return self.srID;
    }

    return [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
}

@end
