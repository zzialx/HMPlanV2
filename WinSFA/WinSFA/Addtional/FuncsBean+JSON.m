//
//  FuncsBean+JSON.m
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import "FuncsBean+JSON.h"
#import "WSFuncsBean_opt.h"
#import "WSFuncsBean_Param.h"
#import "WSFuncsBean_other.h"

@implementation WSFuncsBean (JSON)

- (NSString *)jsonFromFuncsBean {
    NSString *ret = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[self dictFromSpec] forKey:FUNCS_SPEC];
    [dict setValue:self.name forKey:FUNCS_NAME];
    [dict setValue:self.fv forKey:FUNCS_FV];
    [dict setValue:self.fc forKey:FUNCS_FC];
    
    [dict setValue:[self arrayFromSubFuncs] forKey:FUNCS_FUNCS];
    
    ret = [dict JSONString];
    return ret;
}

- (NSDictionary *)dictFromSpec {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithInteger:self.maxRow] forKey:FUNCS_MAXROW];
    [dict setValue:self.required forKey:FUNCS_REQUIRED];
    [dict setValue:self.styp forKey:FUNCS_STYP];
    // opt
    [dict setValue:[self dictFromOpt] forKey:FUNCS_OPT];
    [dict setValue:self.ds forKey:FUNCS_DS];
    [dict setValue:self.filter forKey:FUNCS_FILTER];
    [dict setValue:self.isStoreInfo forKey:FUNCS_STOREINFO];
    [dict setValue:self.sqlw forKey:FUNCS_SQLW];
    [dict setValue:self.submenu forKey:FUNCS_SUBMENU];
    [dict setValue:[NSNumber numberWithInteger:self.wfcol] forKey:FUNCS_WFCOL];
    [dict setValue:self.isAcvtList forKey:FUNCS_ISACVTLIST];
    // param
    [dict setValue:[self arrayFromParam] forKey:FUNCS_PARAM];
    // other
    [dict setValue:[self arrayFromOther] forKey:FUNCS_OTHER];
    [dict setValue:self.typ forKey:FUNCS_TYP];
    [dict setValue:self.cocall forKey:FUNCS_COCALL];
    [dict setValue:self.cochk forKey:FUNCS_COCHK];
    [dict setValue:self.dateTyp forKey:FUNCS_DATETYP];
    [dict setValue:[NSNumber numberWithInteger:self.readonly] forKey:FUNCS_READONLY];
    [dict setValue:[NSNumber numberWithInteger:self.redis] forKey:FUNCS_REDIS];
    [dict setValue:[NSNumber numberWithInteger:self.unredo] forKey:FUNCS_UNREDO];
    [dict setValue:[NSNumber numberWithBool:self.lockCol] forKey:FUNCS_LOCKCOL];
    [dict setValue:self.showtyp forKey:FUNCS_SHOWTYP];
    [dict setValue:self.empTyp forKey:FUNCS_EMPTYP];
    
    return dict;
}

- (NSDictionary *)dictFromOpt {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.opt.isPic forKey:FUNCS_OPT_isPic];
    [dict setValue:self.opt.isGps forKey:FUNCS_OPT_isGps];
    [dict setValue:self.opt.typGps forKey:FUNCS_OPT_typGps];
    [dict setValue:self.opt.isMemo forKey:FUNCS_OPT_isMemo];
    [dict setValue:[NSNumber numberWithInteger:self.opt.numMemo] forKey:FUNCS_OPT_numMemo];
    [dict setValue:self.opt.label forKey:FUNCS_OPT_label];
    return dict;
}

- (NSArray *)arrayFromParam {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (WSFuncsBean_Param *param in self.paramArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:param.col forKey:FUNCS_PARAM_COL];
        [dict setValue:param.name forKey:FUNCS_PARAM_NAME];
        [dict setValue:param.tpy forKey:FUNCS_PARAM_TPY];
        [dict setValue:[NSNumber numberWithInteger:param.wcol] forKey:FUNCS_PARAM_WCOL];
        [dict setValue:param.max forKey:FUNCS_PARAM_MAX];
        [dict setValue:param.min forKey:FUNCS_PARAM_MIN];
        [dict setValue:param.pcs forKey:FUNCS_PARAM_PCS];
        [dict setValue:[NSNumber numberWithInteger:param.readonly] forKey:FUNCS_PARAM_READONLY];
        [dict setValue:param.redis forKey:FUNCS_PARAM_REDIS];
        [dict setValue:param.value forKey:FUNCS_PARAM_VALUE];
        [dict setValue:param.listener forKey:FUNCS_PARAM_LISTENER];
        [dict setValue:param.reg forKey:FUNCS_PARAM_REG];
        [arr addObject:dict];
    }
    
    return arr;
}

- (NSArray *)arrayFromOther {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (WSFuncsBean_other *other in self.otherArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:other.col forKey:FUNCS_OTHER_COL];
        [dict setValue:other.name forKey:FUNCS_OTHER_NAME];
        [dict setValue:other.tpy forKey:FUNCS_OTHER_TPY];
        [dict setValue:[NSNumber numberWithInteger:other.wcol] forKey:FUNCS_OTHER_WCOL];
        [dict setValue:other.max forKey:FUNCS_OTHER_MAX];
        [dict setValue:other.min forKey:FUNCS_OTHER_MIN];
        [dict setValue:other.pcs forKey:FUNCS_OTHER_PCS];
        [dict setValue:[NSNumber numberWithInteger:other.readonly] forKey:FUNCS_OTHER_READONLY];
        [dict setValue:other.redis forKey:FUNCS_OTHER_REDIS];
        [dict setValue:other.value forKey:FUNCS_OTHER_VALUE];
        [dict setValue:other.reg forKey:FUNCS_OTHER_REG];
        [arr addObject:dict];
    }
    
    return arr;
}

- (NSArray *)arrayFromSubFuncs {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (WSFuncsBean *fb in self.funcsArray) {
        NSString *json = [fb jsonFromFuncsBean];
        [arr addObject:[json JSONString]];
    }
    return arr;
}

@end
