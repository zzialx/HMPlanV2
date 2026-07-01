//
//  WSContactsBookTools.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookTools.h"
#import "WSContactsBookServiceDataModel.h"
#import "WSContactsBookGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - 通讯录工具 延展(内部)
@interface WSContactsBookTools ()

//针对人员
@property (nonatomic, strong) WSContactsBookServiceDataModel *serviceDataModel;             //服务器下发原始数据
@property (nonatomic, assign, readwrite) BOOL isDepartment;                                 //是否存在部门标示
@property (nonatomic, strong, readwrite) NSMutableArray *nameIndexArray;                    //姓名索引下标数组
@property (nonatomic, strong, readwrite) NSMutableDictionary *nameSectionDictionary;        //姓名分组字典
@property (nonatomic, strong, readwrite) NSMutableArray *allInfoArray;                      //全部数据数组

//针对门店
@property (nonatomic, strong) WSContactsBookServiceDataModel *serviceStoreDataModel;        //服务器门店下发原始数据
@property (nonatomic, strong, readwrite) NSMutableArray *storeNameIndexArray;               //门店姓名索引下标数组
@property (nonatomic, strong, readwrite) NSMutableDictionary *storeNameSectionDictionary;   //门店姓名分组字典
@property (nonatomic, strong, readwrite) NSMutableArray *storeAllInfoArray;                 //门店全部数据数组

@end
//===================================================================================================================================================================

#pragma mark - 通讯录工具 延展(工具)
@interface WSContactsBookTools (Tools)

#pragma mark - 验证字符串配置方法 str:数据源字符串
- (BOOL)matchLetter:(NSString *)str;

#pragma mark - 获取姓名首字母方法 name:姓名
- (NSString *)getFirstLetterWithName:(NSString *)name;

#pragma marj - 多音字处理方法 str:字符
- (NSString *)polyphoneStringHandle:(NSString *)str;

#pragma mark - 初始化通讯录数据方法(人员) dic:数据源
- (void)initContactsBookServiceDataWithDic:(NSDictionary *)dic;

#pragma mark - 初始化门店通讯录数据方法(门店) dic:数据源
- (void)initStoreContactsBookServiceDataWithDic:(NSDictionary *)dic;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录工具
@implementation WSContactsBookTools

#pragma marm - 获取nameIndexArray方法
- (NSMutableArray *)nameIndexArray
{
    if(_nameIndexArray == nil)
        _nameIndexArray = [NSMutableArray array];
    return _nameIndexArray;
}

#pragma mark - 获取nameSectionDictionary方法
- (NSMutableDictionary *)nameSectionDictionary
{
    if(_nameSectionDictionary == nil)
        _nameSectionDictionary = [NSMutableDictionary dictionary];
    return _nameSectionDictionary;
}

#pragma marm - 获取allInfoArray方法
- (NSMutableArray *)allInfoArray
{
    if(_allInfoArray == nil)
        _allInfoArray = [NSMutableArray array];
    return _allInfoArray;
}

#pragma marm - 获取storeNameIndexArray方法
- (NSMutableArray *)storeNameIndexArray
{
    if(_storeNameIndexArray == nil)
        _storeNameIndexArray = [NSMutableArray array];
    return _storeNameIndexArray;
}

#pragma mark - 获取storeNameSectionDictionary方法
- (NSMutableDictionary *)storeNameSectionDictionary
{
    if(_storeNameSectionDictionary == nil)
        _storeNameSectionDictionary = [NSMutableDictionary dictionary];
    return _storeNameSectionDictionary;
}

#pragma marm - 获取storeAllInfoArray方法
- (NSMutableArray *)storeAllInfoArray
{
    if(_storeAllInfoArray == nil)
        _storeAllInfoArray = [NSMutableArray array];
    return _storeAllInfoArray;
}

#pragma mark - 获取共享通讯录工具
+ (instancetype)sharedManager
{
    static WSContactsBookTools *contactsBookTools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contactsBookTools = [[WSContactsBookTools alloc] init];
    });
    
    return contactsBookTools;
}

#pragma mark - 保存通讯录信息方法 dictionary:数据字典
- (void)saveContactsBookWithDictionary:(NSDictionary *)dictionary
{
    dispatch_async(dispatch_queue_create("com.saveContactsBook", DISPATCH_QUEUE_SERIAL), ^{
        [self initContactsBookServiceDataWithDic:dictionary];
    });
}

#pragma mark - 保存门店通信录信息方法 dictionary:数据字典
- (void)saveStoreContactsBookWithDictionary:(NSDictionary *)dictionary
{
    dispatch_async(dispatch_queue_create("com.saveStoreContactsBook", DISPATCH_QUEUE_SERIAL), ^{
        [self initStoreContactsBookServiceDataWithDic:dictionary];
    });
}

#pragma mark - 获取有效头像地址 downloadURL:下载url
- (NSString *)getEffectiveDownloadURL:(NSString *)downloadURL
{
    if(downloadURL.length <= 0)
        return downloadURL;
    
    NSString *urlStr = [WSHttpURLHelper getImageCompleteURL:downloadURL];
    return urlStr;
}

#pragma mark - 获取通讯录主题颜色方法
- (UIColor *)getContactsBookThemeColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookThemeColorMrak];
    return (color ? color : [UIColor colorWithRed:(53.0 / 255.0) green:(154.0 / 255.0) blue:(252.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录背景颜色方法
- (UIColor *)getContactsBookBgColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookBgColorMrak];
    return (color ? color : [UIColor colorWithRed:(245.0 / 255.0) green:(245.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录元素背景颜色方法
- (UIColor *)getContactsBookElementBgColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookElementBgColorMrak];
    return (color ? color : [UIColor colorWithRed:(255.0 / 255.0) green:(255.0 / 255.0) blue:(255.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录分组标题颜色方法
- (UIColor *)getContactsBookGroupingTitleColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookGroupingTitleColorMrak];
    return (color ? color : [UIColor colorWithRed:(93.0 / 255.0) green:(93.0 / 255.0) blue:(93.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录线颜色方法
- (UIColor *)getContactsBookLineColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookLineColorMrak];
    return (color ? color : [UIColor colorWithRed:(237.0 / 255.0) green:(237.0 / 255.0) blue:(237.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录标题黑颜色方法
- (UIColor *)getContactsBookTitleBlackColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookTitleBlackColorMrak];
    return (color ? color : [UIColor colorWithRed:(0.0 / 255.0) green:(0.0 / 255.0) blue:(0.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录标题白颜色方法
- (UIColor *)getContactsBookTitleWhiteColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookTitleWhiteColorMrak];
    return (color ? color : [UIColor colorWithRed:(255.0 / 255.0) green:(255.0 / 255.0) blue:(255.0 / 255.0) alpha:1.0]);
}

#pragma mark - 获取通讯录标题灰颜色方法
- (UIColor *)getContactsBookTitleGrayColor
{
    UIColor *color = [UIColor colorForKey:WSContactsBookTitleGrayColorMrak];
    return (color ? color : [UIColor colorWithRed:(161.0 / 255.0) green:(161.0 / 255.0) blue:(161.0 / 255.0) alpha:1.0]);
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录工具 延展(工具)
@implementation WSContactsBookTools (Tools)

#pragma mark - 验证字符串配置方法 str:数据源字符串
- (BOOL)matchLetter:(NSString *)str
{
    NSPredicate *regexA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[A-Z]$"];
    return [regexA evaluateWithObject:str];
}

#pragma mark - 获取姓名首字母方法 name:姓名
- (NSString *)getFirstLetterWithName:(NSString *)name
{
    NSMutableString *mutableString = [NSMutableString stringWithString:name];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSString *duoPinyin = [self polyphoneStringHandle:name];
    NSString *strPinYin = ((duoPinyin.length > 0) ? duoPinyin : [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]]);
    strPinYin = [strPinYin uppercaseString];
    NSString *firstString = (strPinYin.length > 0) ? [strPinYin substringToIndex:1] : @"";
    
    return ([self matchLetter:firstString] ? firstString : @"#");
}

#pragma marj - 多音字处理方法 str:字符
- (NSString *)polyphoneStringHandle:(NSString *)str
{
    if ([str hasPrefix:@"长"])
        return @"chang";
    
    if ([str hasPrefix:@"沈"])
        return @"shen";
    
    if ([str hasPrefix:@"厦"])
        return @"xia";
    
    if ([str hasPrefix:@"地"])
        return @"di";
    
    if ([str hasPrefix:@"重"])
        return @"chong";
    
    return nil;
}

#pragma mark - 初始化通讯录数据方法(人员) dic:数据源
- (void)initContactsBookServiceDataWithDic:(NSDictionary *)dic
{
    if(![[dic allKeys] containsObject:APPDATA_MAIL_LIST])
        return;
    
    WSContactsBookServiceDataModel *model = [[WSContactsBookServiceDataModel alloc] initWithDictionary:dic error:nil];
    self.serviceDataModel = model;
    
    NSMutableArray *nameIndexArrayTemp = [NSMutableArray array];
    NSMutableDictionary *nameSectionDictionaryTemp = [NSMutableDictionary dictionary];
    for(int i = 0; i < model.contactsArray.count; ++i)
    {
        WSContactsStandardInfo *info = [model.contactsArray objectAtIndex:i];
        if(![info.leafNode isEqualToString:@"1"])
        {
            self.isDepartment = YES;
            continue;
        }
        
        NSString *name = (info.name.length > 0) ? info.name : @"";
        NSString *firstStr = [self getFirstLetterWithName:name];
        
        if ((nameIndexArrayTemp.count <= 0) || (![nameIndexArrayTemp containsObject:firstStr]))
        {
            [nameIndexArrayTemp addObject:firstStr];
            [nameSectionDictionaryTemp setObject:[NSMutableArray arrayWithObject:info] forKey:firstStr];
        }
        else
        {
            NSMutableArray *array = [nameSectionDictionaryTemp objectForKey:firstStr];
            [array addObject:info];
        }
    }
    
    NSMutableArray *compareArray = [[NSMutableArray alloc] initWithArray:[nameSectionDictionaryTemp.allKeys sortedArrayUsingSelector:@selector(compare:)]];
    if(compareArray.count > 0)
    {
        NSString *firstName = [compareArray objectAtIndex:0];
        if (![self matchLetter:firstName])
        {
            [compareArray removeObjectAtIndex:0];
            [compareArray insertObject:firstName atIndex:compareArray.count];
        }
    }
    
    [self.allInfoArray removeAllObjects];
    [self.allInfoArray addObjectsFromArray:model.contactsArray];
    [self.nameIndexArray removeAllObjects];
    [self.nameIndexArray addObjectsFromArray:compareArray];
    [self.nameSectionDictionary removeAllObjects];
    [self.nameSectionDictionary setDictionary:nameSectionDictionaryTemp];
    LogInfo(@"读取通讯录数据完成");
}

#pragma mark - 初始化门店通讯录数据方法(门店) dic:数据源
- (void)initStoreContactsBookServiceDataWithDic:(NSDictionary *)dic
{
    if(![[dic allKeys] containsObject:APPDATA_CUS_MAIL_LIST])
        return;
    
    WSContactsBookServiceDataModel *model = [[WSContactsBookServiceDataModel alloc] initWithDictionary:dic error:nil];
    self.serviceStoreDataModel = model;
    
    NSMutableArray *nameIndexArrayTemp = [NSMutableArray array];
    NSMutableDictionary *nameSectionDictionaryTemp = [NSMutableDictionary dictionary];
    for(int i = 0; i < model.storeContactsArray.count; ++i)
    {
        WSContactsStandardInfo *info = [model.storeContactsArray objectAtIndex:i];
        
        NSString *name = (info.name.length > 0) ? info.name : @"";
        NSString *firstStr = [self getFirstLetterWithName:name];
        
        if ((nameIndexArrayTemp.count <= 0) || (![nameIndexArrayTemp containsObject:firstStr]))
        {
            [nameIndexArrayTemp addObject:firstStr];
            [nameSectionDictionaryTemp setObject:[NSMutableArray arrayWithObject:info] forKey:firstStr];
        }
        else
        {
            NSMutableArray *array = [nameSectionDictionaryTemp objectForKey:firstStr];
            [array addObject:info];
        }
    }
    
    NSMutableArray *compareArray = [[NSMutableArray alloc] initWithArray:[nameSectionDictionaryTemp.allKeys sortedArrayUsingSelector:@selector(compare:)]];
    if(compareArray.count > 0)
    {
        NSString *firstName = [compareArray objectAtIndex:0];
        if (![self matchLetter:firstName])
        {
            [compareArray removeObjectAtIndex:0];
            [compareArray insertObject:firstName atIndex:compareArray.count];
        }
    }
    
    [self.storeAllInfoArray removeAllObjects];
    [self.storeAllInfoArray addObjectsFromArray:model.storeContactsArray];
    [self.storeNameIndexArray removeAllObjects];
    [self.storeNameIndexArray addObjectsFromArray:compareArray];
    [self.storeNameSectionDictionary removeAllObjects];
    [self.storeNameSectionDictionary setDictionary:nameSectionDictionaryTemp];
    LogInfo(@"读取辅助通讯录数据完成");
}

@end
//===================================================================================================================================================================
