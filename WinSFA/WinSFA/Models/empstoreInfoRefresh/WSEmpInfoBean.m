//
//  EmpInfoBean.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-25.
//
//

#import "WSEmpInfoBean.h"
#import "NSDictionary+Additional.h"

@implementation WSEmpInfoBean

@synthesize empId = _empId;
@synthesize store_id = _store_id;
@synthesize col_name = _col_name;
@synthesize col_value = _col_value;
@synthesize col_type = _col_type;
@synthesize typ = _typ;

@synthesize subEmpInfoArray = _subEmpInfoArray;


- (id)initWithObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        NSDictionary *dic = (NSDictionary *)object;
        _empId = [[dic getStringValueWithKeyName:EMPID] copy];
        _store_id = [[dic getStringValueWithKeyName:STORE_ID] copy];
        _col_name = [[dic getStringValueWithKeyName:COL_NAME] copy];
        _col_value = [[dic getStringValueWithKeyName:COL_VALUE] copy];
        _col_type = [[dic getStringValueWithKeyName:COL_TYPE] copy];
        _typ = [[dic getStringValueWithKeyName:TYP] copy];
        
        NSArray *array = [dic objectForKey:SUBEMPINFO];
        if (array) {
            NSMutableArray *subArray = [NSMutableArray arrayWithCapacity:[array count]];
            for (NSDictionary *subDic in array) {
                WSEmpInfoBean *bean = [[WSEmpInfoBean alloc] initWithObject:subDic];
                if (bean) {
                    [subArray addObject:bean];
                }
            }
            _subEmpInfoArray = [NSArray arrayWithArray:subArray];
        }
    }
    return self;
}

@end
