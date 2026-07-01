//
//  WSValidateTextView.h
//  WinSFA
//
//  Created by Stephanie on 16/6/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSValidateTextView;

@class WSFuncsBean_other;

//@protocol WSValidateTextViewDelegate <NSObject>
//
//@optional
//
//-(void)scaleCurrentText:(WSValidateTextView *)currentField;
//
//-(void)endCurrentEdit:(WSValidateTextView *)currentField;
//
//-(void)cancelCurrentEdit:(WSValidateTextView *)currentField;
//
//@end

@interface WSValidateTextView : UITextView<UITextViewDelegate, UIActionSheetDelegate, WSValidateData, WSGettingValues>{
    
    int calling_count;
}

@property (nonatomic, strong) NSString                  *m_max;

@property (nonatomic, strong) NSString                  *m_min;

@property (nonatomic, strong) NSString                  *m_pcs;     // 小数点

@property (nonatomic, strong) NSString                  *m_type;

@property (nonatomic, strong) NSString                  *m_length;

@property (nonatomic, strong) NSString                  *placeholder;
@property (nonatomic, strong) UILabel                   *placeholderLabel;

//@property (nonatomic, strong) NumberKeypadDecimalPoint  *m_numberKeyPad;

@property (nonatomic, assign) BOOL                      m_isGride;

@property (nonatomic, assign) BOOL                      isLastText;


//@property (nonatomic,weak) id<WSValidateTextViewDelegate>  inputdelegate;


// 控件的表格属性
@property (nonatomic, copy) NSString  *m_col;
// 表达式（显示汇总公式等 ，WSFuncsBean_other 的Value属性的值不为空）
@property (nonatomic, copy) NSString  *m_value;

//正则表达式公式
@property (nonatomic, copy) NSString *m_reg;
//校验不通过信息提示文本
@property (nonatomic, copy) NSString *m_regname;

//row and column
@property (nonatomic, assign) unsigned int m_nRow;
@property (nonatomic, assign) unsigned int m_nColumn;

@property (nonatomic, assign) float m_maxValue;
@property (nonatomic, copy) NSString *m_alert;

//是否被依赖
@property (nonatomic, assign) BOOL m_isDepended;

@property (nonatomic, strong) UIView *upKeyBoardView;

//前缀
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//依赖类型
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

@property (nonatomic, assign) BOOL isValueChange;

@property (nonatomic, strong) WSFuncsBean *currentFuncs;

@property (nonatomic, copy)NSString *iColumnName;
@property (nonatomic, copy)NSString *prodName;

@property (nonatomic, assign) BOOL editing;

//add by xiajl 2014-07-11 for MSTD-980 调查问卷中的文本输入框，最大化后，点完成按钮是否收起键盘的开关值。 默认值是假 意味着不收起。真是收起。
@property (nonatomic, assign) BOOL isNotBecomeFirstResponder;


@property (nonatomic, assign) BOOL isNeedValidateText;

- (id)initWithFrame:(CGRect) aRect Param:(WSFuncsBean_Param *)aParam;

- (id)initWithFrame:(CGRect) aRect Qst:(WSAcvtBean_qst *)aQst;

- (id)initWithFrame:(CGRect) aRect FuncsOther:(WSFuncsBean_other *)aOther;

-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue;

-(id)initWithFrame:(CGRect)aRect Param:(WSFuncsBean_Param*)aParam maxValue:(float)maxValue isLastText:(BOOL)isLastText;

- (BOOL)shouldReplacementString:(NSString *)string inRange:(NSRange)replaceRange;

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

@end
