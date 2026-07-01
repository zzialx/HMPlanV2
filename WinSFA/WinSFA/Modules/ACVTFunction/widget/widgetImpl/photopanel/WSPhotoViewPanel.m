//
//  WSPhotoViewPanel.m
//  WinSFA
//
//  Created by xiajl on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPhotoViewPanel.h"
#import "WidgetConstant.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSCustomTimeTable.h"
#import "WSPhotoBrowseView.h"
#import "WSInterAction.h"
#import "I_W_ValueChangeObject.h"
#import "WSArrayValueChangeChecker.h"
#import "WSPhotoLogicService.h"
#import "WSJSONBuilder.h"
#import "WSImagePathTable.h"
#import "WSEnvrionment.h"
#import "UIImage+ExtraInfo.h"
#import "WSPaiPaiManager.h"

#define KImageIDSuffix @"_originalPic" //原始图片标识(拍照时 可根据设置 进行2张照片保留<一张包含水印 一张原照片>)
//=============================================================================================================================

#pragma mark - 照片视图面板 延展(内部)
@interface WSPhotoViewPanel () <WSPhotoBrowseViewDelegate>

@property (nonatomic, copy) NSString *serverImageIndex; //服务器图片索引标识
@property (nonatomic, copy) NSString *pz_type;          //拍照类型
@property (nonatomic, copy) NSString *pz_uuid;          //拍照参数(uuid)

@end
//=============================================================================================================================

#pragma mark - 照片视图面板
@implementation WSPhotoViewPanel

#pragma mark - 获取delPhotoBrowses方法
- (NSMutableArray *)delPhotoBrowses {
    
    if (!_delPhotoBrowses) {
        _delPhotoBrowses = [[NSMutableArray alloc] init];
    }
    return _delPhotoBrowses;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.xvalueChangeChecker = [[WSArrayValueChangeChecker alloc] init];
        self.randomMD5 = [[WSJSONBuilder gen_uuid] md5];
    }
    return self;
}

#pragma mark - 重写buildDisplayContent方法 构建显示内容方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    _originalValue = [xdisplayValue getDisplayValueFor:xbuildInfo];
    
    NSMutableArray *newDisplayValue = [NSMutableArray array];
    if ([_originalValue isKindOfClass:[NSArray class]]) {
        
        NSArray *originalValueArray = (NSArray *)_originalValue;
        [newDisplayValue addObjectsFromArray:originalValueArray];
        
        for (NSString *valueItem in originalValueArray) {
            
            if ([WSEnvrionment getUseAliyun]) {
                
                NSArray *strArray = [valueItem componentsSeparatedByString:@"@"];
                if (strArray.count == 1) {
                    
                    NSString *imageIDX = [WSPhotoLogicService getPhotoKeyFromServerRedisValue:valueItem];
                    NSString *imageId = [[WSImagePathTable sharedTable] backImagePathQueryWithImageIDX:imageIDX];
                    NSInteger index = [newDisplayValue indexOfObject:valueItem];
                    newDisplayValue[index] = imageId;
                }
            }
            
            self.serverImageIndex = [WSPhotoLogicService getImageIndexFromServerRedisValue:valueItem];
            if (self.serverImageIndex) {
                break;
            }
        }
    }
    
    BOOL isSupperLocalPic = NO;
    NSInteger isSupperLocalInt = [xbuildInfo isSupperLocalPhotoForXB];
    if (isSupperLocalInt == 0) {
        isSupperLocalPic = [[self getAcvtModel] isSupperChangedLocalPhoto];
    }
    else if (isSupperLocalInt == 1) {
        isSupperLocalPic = YES;
    }
    else if (isSupperLocalInt == 2) {
        isSupperLocalPic = NO;
    }
    
    CGFloat y = self.titleLabel.frame.size.height;
    self.photoView = [[WSPhotoBrowseView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.bounds), PHOTO_PANEL_HEIGHT)
                                                         funs:[self getAcvtModel].currentFuncs
                                             withImageIDArray:newDisplayValue
                                           withSupperLocalPic:isSupperLocalPic
                                            withSupperHttpPic:NO
                                              withMaxPhotoNum:[xbuildInfo getMaxPhoto] > 0 ? [xbuildInfo getMaxPhoto] : [[xbuildInfo getMlen] integerValue]
                                                     delegate:self
                                                        align:[xbuildInfo getQstAlign]
                                              withDisPlayMode:nil
                                                   xbuildInfo:(WSAcvtBean_qst*)xbuildInfo];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.photoView.currentStore = [self getAcvtModel].currentStore;
    self.photoView.qstItem = (WSAcvtBean_qst *)xbuildInfo;
    self.photoView.enableEdit = ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_PE] ? YES : NO);
    self.photoView.readOnly = (([[xbuildInfo getReadOnly] integerValue] == 1) ? YES : NO);
    [self addSubview:self.photoView];
    
    if (isSupperLocalInt != 0 && isSupperLocalInt != 1) {
        [self setTakePhotoType:[NSString stringWithFormat:@"%ld", isSupperLocalInt]];
    }

    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds), PHOTO_PANEL_HEIGHT + y);
}

#pragma mark - 重写widgetDidLoadFinish方法 部件加载完成方法
- (void)widgetDidLoadFinish {
    
//    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
//        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
//            [self.delegate executeLuaScript:xbuildInfo widget:self];
//        }
//    }
}






#pragma mark - 重写reloadCurrentWidgetWithValue:方法 重载当前部件方法
- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    
    if (value) {
        [self.photoView fetchImagesFromNetWorkWith:value];
    }
}

#pragma mark - 重写setTakePhotoType:方法 设置拍摄照片类型方法
- (void)setTakePhotoType:(NSString *)photoType {
    
    self.pz_type = photoType;
    self.photoView.pz_type = photoType;
}

#pragma mark - 重写setReadonly:方法 设置只读方法
- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    [self.photoView setReadOnly:(([[xbuildInfo getReadOnly] integerValue] == 1) ? YES : NO)];
}

#pragma mark - 重写setIsSupperLocalPhoto:方法 设置是否本地照片标识方法
- (void)setIsSupperLocalPhoto:(NSString *)isSupperLocalPhoto {
    
    BOOL isSupport = NO;
    if ([isSupperLocalPhoto isEqualToString:@"true"] || [isSupperLocalPhoto isEqualToString:@"1"]) {
        isSupport = YES;
    }
    [self.photoView setIsSupperLocalPhoto:isSupport];
}

#pragma mark - 重写setCurrentValueWithPresentation:方法 设置当前数值方法
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    
    if (valuePresentation && valuePresentation.length > 0) {
        
        NSArray *params = [(NSString *)valuePresentation componentsSeparatedByString:@"@"];
        if ([params count] == 1) {
            
            NSString *imageIndex = params[0];
            [self.photoView addImageID:imageIndex withImage:nil];
        }
        return;
    }
        
    [self.photoView deleteAllImage];
}

#pragma mark - 重写setParam:方法 设置参数方法
- (void)setParam:(NSString *)param {
    
    self.pz_uuid = param;
    self.photoView.pz_uuid = param;
}

#pragma mark - 重写setPhotoWaterMark:方法 设置照片水印数据方法
- (void)setPhotoWaterMark:(NSString *)photoWaterMark {
    
    self.photoView.luaWaterMark = photoWaterMark;
}

#pragma mark - 重写setLenzTiltModel:方法 设置拍拍赚(trax)倾斜度校验方设法
- (void)setLenzTiltModel:(NSString *)tiltType {
    
    self.photoView.pz_tiltModel = tiltType;
}

#pragma mark - 重写getCurrentValue方法 获取当前数值方法
- (NSObject *)getCurrentValue {
    
    return self.photoView.imageIDArray;
}

#pragma mark - 重写getDataCount方法 获取当前数据数量方法
- (NSString *)getDataCount {
    
    return [NSString stringWithFormat:@"%ld", self.photoView.imageIDArray.count];
}

#pragma mark - 重写getCurrentValuePresentation方法 获取当前数值(文本)方法
- (NSObject *)getCurrentValuePresentation {
    
    return [self.photoView.imageIDArray componentsJoinedByString:@"|"];
}

#pragma mark - 重写performClickButton:方法
- (void)performClickButton:(id)sender {
    
    if (self.photoView) {
        [self.photoView takePhotoAction:sender];
    }
}

#pragma mark - 重写setLenzActivityType:方法 设置拍拍赚(trax)类型方法
- (void)setLenzActivityType:(NSString *)lenzActivityType {
    
    [[WSPaiPaiManager sharedInstance] modifyLenzTaskInfoWithTaskId:lenzActivityType];
}

#pragma mark - 重写setCheckType:方法 设置检查类型方法
- (void)setCheckType:(NSString*)checkType {
    
    [xbuildInfo setCheckType:([checkType isEqualToString:@"true"] ? @"1" : @"")];
}

#pragma mark - 重写getOriginalValue方法 获取OriginalValue原始数值方法
- (NSObject *)getOriginalValue {
    
    return _originalValue;
}

#pragma mark - 重写getResultDirectly方法 获取结果方法
- (NSObject *)getResultDirectly {
    
    WSAcvtModel *acvtModel = nil;
    if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]]) {
        acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    }
    
    if (self.photoView && self.photoView.imageIDArray && [self.photoView.imageIDArray count] > 0 && acvtModel) {
        
        NSString *flag = [xbuildInfo getPhotoIsCoverNewId];
        if ((!flag || [flag isEqualToString:@"0"]) && [self.serverImageIndex length] > 0) {
            
            if ([acvtModel isNeedNewImageIndex]) {
                return [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:self.randomMD5 acvtQstId:[xbuildInfo getAcvtQstId]];
            }
            return self.serverImageIndex;
        }
        
        if ([acvtModel isNeedNewImageIndex] || [[xbuildInfo getAcvtMemo3] isEqualToString:@"E"]) {
            return [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:self.randomMD5 acvtQstId:[xbuildInfo getAcvtQstId]];
        }
        
        return [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:[xbuildInfo getAcvtQstId]];
    }
    
    return nil;
}

#pragma mark - 重写showConfirmDialog:方法
- (void)showConfirmDialog:(NSString *)dialog {
    
    __weak typeof(self) weakSelf = self;
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:(dialog.length > 0 ? dialog : @"")];
    [alert addButtonWithTitle:@"确定" block:^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.resultCheck = @"confirm";
        
        NSString *script = [WSLuaExecutorManager getSubLuaScriptWith:[xbuildInfo getLuaScript] ByFuntionName:@"function confirm("];
        if ([strongSelf.delegate respondsToSelector:@selector(executeLuaScript:script:widget:)] && script.length > 0) {
            [strongSelf.delegate executeLuaScript:xbuildInfo script:script widget:strongSelf];
        }
        
        strongSelf.resultCheck = @"";
        
        WSLuaExecutorManager *wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.isErrorFromScript = NO;
    }];
    
    [alert show];
}

#pragma mark - 获取acvtQstId问题ID方法(.h定义 对外方法)
- (NSString *)getAcvtQstId {
    
    if (xbuildInfo) {
        return [xbuildInfo getAcvtQstId];
    }
    return nil;
}






#pragma mark - 实现WSPhotoBrowseViewDelegate--executeLuaScript协议(执行脚本)
- (void)executeLuaScript {

    NSString *luaScript = [xbuildInfo getLuaScript];
    if (luaScript && [luaScript length] > 0) {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo script:luaScript funcName:@"function setValue(" widget:self];
        }
    }
}

#pragma mark - 实现WSPhotoBrowseViewDelegate--photoBrowseView:didAddedImageForID:协议(添加图片)
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didAddedImageForID:(NSString *)imageID {
    
    [[[self getAcvtModel] qstDBValueDictionary] setObject:photoBrowseView.imageIDArray forKey:[xbuildInfo getAcvtQstId]];
    [self checkValueChange];
    [self executeLuaScript];
}

#pragma mark - 实现WSPhotoBrowseViewDelegate--photoBrowseView:didDeletedImageForID:协议(删除图片)
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didDeletedImageForID:(NSString *)imageID {
    
    BOOL isExist = NO;
    for (NSMutableArray *tmpArray in self.delPhotoBrowses) {
        
        if (tmpArray.count < 2) {
            continue;
        }
        
        WSPhotoBrowseView *tmpView = [tmpArray objectAtIndex:0];
        if (tmpView == photoBrowseView) {
            
            NSMutableArray *imageIds = [tmpArray objectAtIndex:1];
            [imageIds addObject:imageID];
            isExist = YES;
            
            break;
        }
    }
    
    if (!isExist) {
        
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithObjects:photoBrowseView, [NSMutableArray arrayWithObjects:imageID, nil], nil];
        [self.delPhotoBrowses addObject:newArray];
    }
     
    if ([photoBrowseView.imageIDArray count] > 0) {
        [[[self getAcvtModel] qstDBValueDictionary] setObject:photoBrowseView.imageIDArray forKey:[xbuildInfo getAcvtQstId]];
    }
    else {
        [self removeObjectFromMarkDictionaryforQst:photoBrowseView.qstItem];
    }

    [self checkValueChange];
    [self executeLuaScript];
}

#pragma mark - 实现WSPhotoBrowseViewDelegate--photoBrowseView:didSelectImageId:协议(点击预览)
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didSelectImageId:(NSString *)imageId {
    
    if (!photoBrowseView.imageIDArray || !imageId) {
        return;
    }
    
    WSPhotoBrowserViewController *photoBrowser = nil;
    if (photoBrowseView.isSupperHttpPhoto) {
        photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImageIDs:photoBrowseView.imageArray];
    }
    else {
        NSMutableArray *imageIDArray = [self getDisPlayImageId:photoBrowseView];
        photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImageIDs:imageIDArray];
    }
    
    BOOL isAllowDeletePhoto = YES;
    BOOL isPjxj = (([self.pz_type isEqualToString:PPCamera_connect]) ? YES : NO);
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"rnd"] || [[xbuildInfo getReadOnly] isEqualToString:@"1"] || isPjxj) {
        isAllowDeletePhoto = NO;
    }
    photoBrowser.isAllowDeletePhoto = isAllowDeletePhoto;
    photoBrowser.delegate = photoBrowseView;
    photoBrowser.enableEdit = photoBrowseView.enableEdit;
    
    if (photoBrowseView.isSupperHttpPhoto) {
        [photoBrowser gotoPage:[imageId intValue]];
    }
    else {
        [photoBrowser gotoPage:[photoBrowseView.imageIDArray indexOfObject:imageId]];
    }
    
    photoBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoBrowser];
}

#pragma mark - 实现WSPhotoBrowseViewDelegate--photoBrowseView:didLoadNetWorkImageFinish:协议(网络图片下载完成)
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didLoadNetWorkImageFinish:(BOOL)finish {
    
}

#pragma mark - 实现WSPhotoBrowseViewDelegate--photoBrowseView:presentViewController:animated:协议(弹出视图管理器)
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView presentViewController:(UIViewController *)controller animated:(BOOL)flag {
    
    [self presentViewController:controller];
}

#pragma mark - 实现WSPhotoBrowseViewDelegate--photoBrowseViewTakePhotoOnClickExecuteScript:协议(拍照执行脚本)
- (BOOL)photoBrowseViewTakePhotoOnClickExecuteScript:(WSPhotoBrowseView *)photoBrowseView {
    
    return [self photoBrowseViewExecuteScript:photoBrowseView];
}






#pragma mark - 获取acvtModel调查问卷模型方法
- (WSAcvtModel *)getAcvtModel {

    WSAcvtModel *acvtModel = nil;
    if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]]) {
        acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    }
    return acvtModel;
}

#pragma mark - 获取过滤掉原图的数据方法
- (NSMutableArray *)getDisPlayImageId:(WSPhotoBrowseView *)photoBrowseView {
    
    NSMutableArray *imageIDArray = [NSMutableArray array];
    NSMutableArray *originImageIDArray = photoBrowseView.imageIDArray;
    for (int i = 0; i < [originImageIDArray count]; i++) {
        
        NSString *ImageID = originImageIDArray[i];
        if (![ImageID containsString:KImageIDSuffix]) {
            [imageIDArray addObject:ImageID];
        }
    }

    return imageIDArray;
}

#pragma mark - 展示视图管理器方法
- (void)presentViewController:(UIViewController *)controller {
    
    WSInterAction *interaction = [[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo getAcvtQstId]];
    [interaction setExecute_controller:controller];
    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

#pragma mark - 从问题字典项中删除标记(针对本地数据库内容)方法
- (void)removeObjectFromMarkDictionaryforQst:(WSAcvtBean_qst *)ab_qst {
    
    NSMutableDictionary *mutbledictionary = [NSMutableDictionary dictionaryWithCapacity:[[self getAcvtModel].qstDBValueDictionary count]];
    [[[self getAcvtModel] qstDBValueDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if (![key isEqualToString:ab_qst.acvtQstId]) {
            [mutbledictionary setObject:obj forKey:key];
        }
    }];
    
    [[self getAcvtModel] setQstDBValueDictionary:mutbledictionary];
}

#pragma mark - 拍照点击执行脚本方法
- (BOOL)photoBrowseViewExecuteScript:(WSPhotoBrowseView *)photoBrowseView {
   
    WSLuaExecutorManager *wsLuaExecutor = [WSLuaExecutorManager shareInstance];
    wsLuaExecutor.isErrorFromScript = NO;
        
    if (xbuildInfo.getLuaScript.length > 0 && [self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
        [self.delegate executeLuaScript:xbuildInfo widget:self];
    }
    return wsLuaExecutor.isErrorFromScript;
}

@end
//=============================================================================================================================
