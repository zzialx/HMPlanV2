//
//  WCHTextField.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSFuncsBean_Param.h"
#import "NumberKeypadDecimalPoint.h"
#import "WSAcvtBean_qst.h"
#import "WSProdBean.h"
#import "WSValidateData.h"
#import "WSGettingValues.h"
#import "WSFuncsBean.h"

@class WSFuncsBean_other,WSHTextField;

@class WSHTextField;

@protocol WSHTextFieldDelegate <NSObject>

@optional

-(void)scaleCurrentText:(WSHTextField *)currentField;

-(void)endCurrentEdit:(WSHTextField *)currentField;

-(void)cancelCurrentEdit:(WSHTextField *)currentField;

@end


@interface WSHTextField : UITextField <UITextFieldDelegate, UIActionSheetDelegate, WSValidateData, WSGettingValues>{
    
    __unsafe_unretained  id<WSHTextFieldDelegate>  inputdelegate;
    
    int calling_count;
}

@property (nonatomic, strong) NSString                  *isReq;              //玛氏是否效验必填 等于1的时候走以前逻辑  0的时候跳过效验 跟安卓统一

@property (nonatomic, strong) NSString                  *m_max;

@property (nonatomic, strong) NSString                  *m_min;

@property (nonatomic, strong) NSString                  *m_pcs;     // 小数点

@property (nonatomic, strong) NSString                  *m_type;

@property (nonatomic, strong) NSString                  *m_length;



//@property (nonatomic, strong) NumberKeypadDecimalPoint  *m_numberKeyPad;

@property (nonatomic, assign) BOOL                      m_isGride;

@property (nonatomic, assign) BOOL                      isLastText;


@property (nonatomic,assign) id<WSHTextFieldDelegate>  inputdelegate;


// 控件的表格属性
@property (nonatomic, copy) NSString  *m_col;
// 表达式（显示汇总公式等 ，WSFuncsBean_other 的Value属性的值不为空）
@property (nonatomic, copy) NSString  *m_value;

//正则表达式公式
@property (nonatomic, copy) NSString *m_reg;
//校验不通过信息提示文本
@property (nonatomic, copy) NSString *m_regname;

//row and column
@property (nonatomic, assign) unsigned int m_nRow;  // 依赖的行号
@property (nonatomic, assign) unsigned int m_nColumn; // 依赖的列号

@property (nonatomic, copy) NSString *dNotificationPrefix;
@property (nonatomic, assign) unsigned int m_dRow;  // 被依赖的行号
@property (nonatomic, assign) unsigned int m_dColumn; // 被依赖的列号

@property (nonatomic, assign) float m_maxValue;
@property (nonatomic, copy) NSString *m_alert;

@property (nonatomic, copy) NSString *m_displayMode;

//是否被依赖
@property (nonatomic, assign) BOOL m_isDepended;

@property (nonatomic, strong) UIView *upKeyBoardView;

//前缀
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;
// 列表用
@property (nonatomic, copy) NSString *gridWidgetKey;

//依赖类型
@property (nonatomic, assign)WSValidateDataDependType iDataType;
//被依赖类型
@property (nonatomic, assign)WSValidateDataDependType dDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

@property (nonatomic, assign) BOOL isValueChange;

//@property (nonatomic, strong) WSFuncsBean *currentFuncs; // MSTD-7881 重构发现该值只设置无获取，后期可删

@property (nonatomic, copy)NSString *iColumnName;
@property (nonatomic, copy)NSString *prodName;

 
//add by xiajl 2014-07-11 for MSTD-980 调查问卷中的文本输入框，最大化后，点完成按钮是否收起键盘的开关值。 默认值是假 意味着不收起。真是收起。
@property (nonatomic, assign) BOOL isNotBecomeFirstResponder;


@property (nonatomic, assign) BOOL isNeedValidateText;

// MSTD-7602 是否是调查问卷表格中的编辑框
@property (nonatomic ,assign) BOOL isAcvtGrid;

- (id)initWithFrame:(CGRect) aRect Param:(WSFuncsBean_Param *)aParam;
// 初始化输入框 要先判断Grid
- (id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam isAcvtGrid:(BOOL)isAcvtGrid;

- (id)initWithFrame:(CGRect) aRect Qst:(WSAcvtBean_qst *)aQst;

- (id)initWithFrame:(CGRect) aRect FuncsOther:(WSFuncsBean_other *)aOther;

-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue;

-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue isLastText:(BOOL)isLastText;

- (BOOL)shouldReplacementString:(NSString *)string inRange:(NSRange)replaceRange;
- (BOOL)checkMaxValue:(NSString *)valueString;

//WSValidateData function
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;

- (void)startObservingEntity;

- (BOOL)entityIsEnable;

//Getting value
- (NSString *)getTextValue;

- (BOOL)isValueLegal;

/**
 *   文本校验
 *
 *
 *  @return 返回假为校验不通过
 */
-(BOOL)textCheck;

// 清空旧的text值，防止有重复出现旧值的现象
-(void)clearTextOldValue;

//验证文本方法 text:需要验证的文本
- (BOOL)validateText:(NSString *)text;

//未处理文本(没有经过numberFormatter处理的文本) 2017-10-20-yuanji-(MENGNIU-534)
@property (nonatomic, copy, readonly) NSString *untreatedText;

@end

