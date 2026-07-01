//
//  WSFuncTipsModel.h
//  WinSFA
//
//  Created by zzialx on 2023/11/18.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSFuncTipsModel : NSObject

@property (nonatomic, copy) NSString *tip;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fc;
@property (nonatomic, copy) NSString *isShow;
@property (nonatomic, copy) NSString *refuseNum;
@property (nonatomic, copy) NSString *passNum;

@end

@interface WSFuncTipsList : NSObject

@property (nonatomic, strong) NSArray <WSFuncTipsModel*> *funcTip;

@end

NS_ASSUME_NONNULL_END
