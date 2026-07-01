//
//  BaseGrideViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WSPhotoGalleryViewController.h"
#import "PhotoTypeButton.h"
#import "WSFuncsBean_Param.h"
#import "WSSelectListView.h"
#import "WSHTextField.h"
#import "WSGridTextInputViewController.h"
#import "WSRadioButton.h"
#import "WSCheckBox.h"
#import "WSGridSearchView.h"
#import "WSSerieLinkView.h"
#import "WSBaseDataGridComponentDataSource.h"

#define NONEEXIST                    -1


@class DataGridComponent;

@interface WSBaseGrideViewController : BaseViewController <PhotoGalleryViewControllerDelegate, PhotoTypeButtonDelegate, WSValidateData, WSGridTextInputDelegate,WSGridSearchViewDelegate,WSSerieLinkViewDelegate>
{}

@property (nonatomic, strong) NSMutableArray    *m_DataBaseDatas;
@property (nonatomic, strong) NSMutableArray    *m_dataSources;
@property (nonatomic, strong) NSMutableArray    *moreProductArray;
@property (nonatomic, assign) NSInteger               m_moreProdsCount;
@property (nonatomic, strong) NSMutableDictionary *formulaDictionary;
@property (nonatomic, strong) NSMutableDictionary *abnormalReasonDict;
@property (nonatomic, strong) NSMutableArray *resonButtons;
@property (nonatomic, assign) BOOL isValueChange;
// 表头包含的checkBox数组
@property (nonatomic, strong) NSMutableArray  *checkBoxesArrayOfHeaderView;
@property (nonatomic, assign) BOOL                      isLastText;
@property (nonatomic, assign) NSInteger                       lastValueColunm;

@property (nonatomic, strong) WSGridSearchView *firstGridSearchView;
@property (nonatomic, strong) WSSerieLinkView *serieLinkView;
@property (nonatomic, strong) __block NSMutableArray    *m_addedDataSources;// 已填写的产品 用于妮维雅
@property (nonatomic, assign) BOOL showAddedProds; // 显示已经填写的产品
@property (nonatomic, strong) NSMutableArray *mSearchGridviewuploadDataSources; //已上报数据；

@property (nonatomic, strong) DataGridComponent *dataGridView;

@property (nonatomic, strong) NSString *firstColumnMaxWidth;

@property (nonatomic, strong) NSArray *deletedProdIds;

@property (nonatomic, strong) NSMutableDictionary *prod_cacheDataMDictionary;

@property (nonatomic, strong) WSBaseDataGridComponentDataSource *baseDataGridComponentDataSource;

// 前一页传入的产品品牌
@property (nonatomic, copy) NSString *iBrandId;

-(NSInteger)getSpecIndexbyParam:(WSFuncsBean_Param*)param;
-(UILabel*)setFirstColumnDataWithIndex:(NSInteger)aIndex Datas:(NSArray*)aDatas;
- (void)setDependedInfoWith:(id<WSValidateData>)aProtocal withParam:(WSFuncsBean_Param *)aParam withRow:(NSInteger)aRow andColumn:(NSInteger)aColumn;
-(WSCheckBox *)setGrideViewDataKindOfButton:(WSFuncsBean_Param*)aParam
                                       Data:(id)aData iRow:(NSInteger)row
                                    iColumn:(NSInteger)column;
-(UIButton*)setGrideViewDataKindOfBadReason:(WSFuncsBean_Param*)aParam;
- (WSSelectListView *)setGrideViewDataKindofSelectList:(WSFuncsBean_Param *)aParam Data:(id)aData;
- (UILabel *)setGrideViewDataKindofMultipleChoice:(WSFuncsBean_Param *)aParam Data:(id)aData;
- (PhotoTypeButton *)setGrideViewDataKindOfPhotoButton:(WSFuncsBean_Param *)aParam Data:(id)aData;
-(WSHTextField*)setGrideViewDataKindOfTextField:(WSFuncsBean_Param*)aParam
                                           data:(id)aData
                                      lastValue:(NSInteger)lastValue
                                           iRow:(NSInteger)row
                                        iColumn:(NSInteger)column;


- (void)initDataSource;


-(void)setGrideViewData;

- (BOOL)isRedisMoreHome;

- (void) loadGridViewSearchBar;
/**
 *  重绘baseView
 */
- (void)reLayoutBaseGridView;

- (void)reLayoutButtonAndGridViewWithIsAllProducts:(BOOL)isAllProducts;

/**
 * 重绘产品表格，目前只支持只有一个表格类型视图的self.contentScrollView视图。
 *
 *  @param newHeight <#newHeight description#>
 */
- (void)reDrawGrideWithHeight:(CGFloat) newHeight;

/**
 *  所有的支持计算公式的文本重新计算 MSTD-944
 *  目前只计算显示在表格中的数据
 */
- (void) recount;

- (void)createDataGridView;

/**
 *  服务器数据回显
 *
 *  @param   WSFuncsBean_Param
 *
 *
 *  @return bool
 */

- (BOOL)serverRedisWith:(WSFuncsBean_Param *)param;

/**
 *  表格本地数据回显（优于服务器回显）
 *
 *  @param
 *
 *  @return bool
 */
- (BOOL)nativeRedis;

/**
 *  初始化更多产品视图的数据，子类需要实现。
 */
- (void) addMoreProductToGrideView;

- (NSString *)getRedisFromServerWithParam:(WSFuncsBean_Param *)param data:(id)data;

/**
 * 验证数据合法性
 */
- (BOOL)validateData;

/**
 * 校验必填项(列)是否已填写
 */
- (BOOL)checkIfRequiredFilled;

/*验证表格是否有填写*/
- (BOOL)isValidateGridRequried;

//- (void)upload;

@end
