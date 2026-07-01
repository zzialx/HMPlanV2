//
//  WSStoredDictDisBean.h
//  WinSFA
//
//  Created by xiajl on 14-11-20.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSStoredDictDisBean : NSObject

@property (nonatomic, copy ,readonly)   NSString   *m_empId;
@property (nonatomic, strong ,readonly) NSArray    *m_p;
@property (nonatomic, strong ,readonly) NSString   *gen_id;

- (id)initWithObject:(id)object;

@end
