//
//  WSAcvtQuestionAnswerBean.h
//  WinSFA
//
//  Created by donghong on 2018/3/28.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtQuestionAnswerBean : NSObject
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) NSString *acvt_qst_answer;
@property (nonatomic, strong) NSString *acvtId;
@property (nonatomic, strong) NSString *gen_id;
@property (nonatomic, assign) NSInteger unReadNum;
@property (nonatomic, assign) NSInteger readNum;
@property (nonatomic, strong) NSString *local_acvt_qst_answer;

@end
