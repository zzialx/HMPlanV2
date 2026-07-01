//
//  WSContactsBookTools.h
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//===================================================================================================================================================================

#pragma mark - 通讯录工具
@interface WSContactsBookTools : NSObject

//针对人员
@property (nonatomic, assign, readonly) BOOL isDepartment;                              //是否存在部门标示
@property (nonatomic, strong, readonly) NSMutableArray *nameIndexArray;                 //姓名索引下标数组
@property (nonatomic, strong, readonly) NSMutableDictionary *nameSectionDictionary;     //姓名分组字典
@property (nonatomic, strong, readonly) NSMutableArray *allInfoArray;                   //全部数据数组

//针对门店
@property (nonatomic, strong, readonly) NSMutableArray *storeNameIndexArray;            //门店姓名索引下标数组
@property (nonatomic, strong, readonly) NSMutableDictionary *storeNameSectionDictionary;//门店姓名分组字典
@property (nonatomic, strong, readonly) NSMutableArray *storeAllInfoArray;              //门店全部数据数组

#pragma mark - 获取共享通讯录工具
+ (instancetype)sharedManager;

#pragma mark - 保存通讯录信息方法 dictionary:数据字典
- (void)saveContactsBookWithDictionary:(NSDictionary *)dictionary;

#pragma mark - 保存门店通信录信息方法 dictionary:数据字典
- (void)saveStoreContactsBookWithDictionary:(NSDictionary *)dictionary;

#pragma mark - 获取有效头像地址 downloadURL:下载url
- (NSString *)getEffectiveDownloadURL:(NSString *)downloadURL;

#pragma mark - 获取通讯录主题颜色方法
- (UIColor *)getContactsBookThemeColor;

#pragma mark - 获取通讯录背景颜色方法
- (UIColor *)getContactsBookBgColor;

#pragma mark - 获取通讯录元素背景颜色方法
- (UIColor *)getContactsBookElementBgColor;

#pragma mark - 获取通讯录分组标题颜色方法
- (UIColor *)getContactsBookGroupingTitleColor;

#pragma mark - 获取通讯录线颜色方法
- (UIColor *)getContactsBookLineColor;

#pragma mark - 获取通讯录标题黑颜色方法
- (UIColor *)getContactsBookTitleBlackColor;

#pragma mark - 获取通讯录标题白颜色方法
- (UIColor *)getContactsBookTitleWhiteColor;

#pragma mark - 获取通讯录标题灰颜色方法
- (UIColor *)getContactsBookTitleGrayColor;

@end
//===================================================================================================================================================================
