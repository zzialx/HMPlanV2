//
//  AcvtBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol I_W_Cell;
@class WSAcvtService,WSAcvtBean_qst,WSTableItem,WSProdBean;
//acvtController的描述，有qst问题数组
@interface WSAcvtBean : NSObject<I_W_Cell,I_W_OptionDataItem>

/*为用yymodel 权衡利弊后去掉readonly  */
@property (nonatomic, copy/*, readonly*/) NSString          *acvtId;
@property (nonatomic, copy/*, readonly*/) NSString          *acvtCode;
@property (nonatomic, copy/*, readonly*/) NSString          *acvtName;
@property (nonatomic, copy/*, readonly*/) NSString          *acvtObj;
@property (nonatomic, copy/*, readonly*/) NSString          *empId;
@property (nonatomic, copy/*, readonly*/) NSString          *typ;
@property (nonatomic, strong/*, readonly*/) NSMutableArray  *qsts;
@property (nonatomic, copy/*, readonly*/) NSString          *dateTyp;

/*isBlock为1:上传同步  为2:此调查问卷为只读（这种情况是问卷不是新增问卷的情况），点击右上角请求按钮后请求后台刷新数据，然后变为可编辑*/
@property (nonatomic, copy/*, readonly*/)NSString           *isBlock;
@property (nonatomic, copy/*, readonly*/) NSString          *luaScript;


@property (nonatomic,copy) NSString *acvtParentQstId;
@property (nonatomic,copy) NSString *parentgenId;
@property (nonatomic,copy) NSString *parentAcvtId;
@property (nonatomic,copy) NSString *parentReadonly;
@property (nonatomic,copy) NSString *publisher;


//辉瑞ECALL
@property (nonatomic, copy/*, readonly*/) NSString          *gen_id;
@property (nonatomic, copy/*, readonly*/) NSString          *submitempid;
@property (nonatomic, copy/*, readonly*/) NSString          *isReadonly;
@property (nonatomic, copy/*, readonly*/) NSString          *isUploaded;
@property (nonatomic, copy/*, readonly*/) NSString          *isReq;

//中粮稽核
@property (nonatomic, copy)NSString *iOriginalAcvtId;
@property (nonatomic, strong) WSAcvtService *acvt_Service;

@property (nonatomic, copy)NSMutableArray *qstIdsForOriginReadonly;
@property (nonatomic, copy)NSString *acvtIconUrl;  // 调查问卷的icon
@property (nonatomic, copy) NSString   *parentQstCode;

- (id)initWithObject:(id)object;

- (WSAcvtBean_qst *)getQstBeanByQstID:(NSString *)qstID;

- (WSAcvtBean_qst *)getQstBeanByAcvtQstID:(NSString *)acvtQstID;

- (WSAcvtBean_qst *)getQstBeanByQstCod:(NSString *)qstCod;

- (WSAcvtBean_qst *)getQstBeanByQstName:(NSString *)qstName;

- (id)initAcvtBeanWithTableItem:(WSTableItem *)tableItem withItemId:(NSString *)itemId withItemName:(NSString *)itemName withLuaScript:(NSString *)luaScript;

@end
