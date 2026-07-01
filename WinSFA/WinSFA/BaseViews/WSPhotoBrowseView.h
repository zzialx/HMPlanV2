//
//  WSPhotoView.h
//  WinSFA
//
//  Created by yang on 14-5-30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPhotoBrowserViewController.h"
#import "UzysAssetsPickerController.h"
@class WSAcvtBean_qst, WSImagePickerController, WSPhotoBrowseView;
//=============================================================================================================================

#pragma mark - 照片浏览视图协议
@protocol WSPhotoBrowseViewDelegate <NSObject>

@optional
- (void)executeLuaScript;                                                                                                               //执行脚本协议
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didAddedImageForID:(NSString *)imageID;                                    //添加图片协议
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didDeletedImageForID:(NSString *)imageID;                                  //删除图片协议
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didSelectImageId:(NSString *)imageId;                                      //点击预览协议
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didLoadNetWorkImageFinish:(BOOL)finish;                                    //网络图片下载完成协议
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView presentViewController:(UIViewController *)controller animated:(BOOL)flag;  //弹出视图管理器协议
- (BOOL)photoBrowseViewTakePhotoOnClickExecuteScript:(WSPhotoBrowseView *)photoBrowseView;                                              //拍照执行脚本协议

@end
//=============================================================================================================================

#pragma mark - 照片浏览视图
@interface WSPhotoBrowseView : UIView <WSPhotoBrowserDelegate, WSValidateData>

@property (nonatomic, weak) UIViewController *viewController;       //视图管理器(用于present使用)
@property (nonatomic, weak) id<WSPhotoBrowseViewDelegate> delegate; //代理指针

@property (nonatomic, assign) BOOL isSupperLocalPhoto;              //是否本地照片标识(YES时 会弹出拍照/相册 选择框)
@property (nonatomic, assign) BOOL isSupperHttpPhoto;               //是否网络照片标识
@property (nonatomic, assign) BOOL enableEdit;                      //是否启动编辑标识
@property (nonatomic, assign) BOOL readOnly;                        //是否只读标识

@property (nonatomic, strong) WSAcvtBean_qst *qstItem;              //当前问题模型
@property (nonatomic, strong) WSStoreBean *currentStore;            //当前门店模型
@property (nonatomic, strong) NSMutableArray *imageIDArray;         //照片id数组
@property (nonatomic, strong) NSMutableArray *photoViewArray;       //照片视图控件数组(元素WSPhotoView)
@property (nonatomic, strong) NSMutableArray *imageArray;           //图片数组

@property (nonatomic, copy) NSString *luaWaterMark;                 //照片水印文
@property (nonatomic, copy) NSString *pz_type;                      //trax类型
@property (nonatomic, copy) NSString *pz_uuid;                      //trax_id
@property (nonatomic, copy) NSString *pz_tiltModel;                 //trax倾斜度校验标识

- (id)initWithFrame:(CGRect)frame funs:(WSFuncsBean *)funcs withImageIDArray:(NSArray *)imageIDArray withSupperLocalPic:(BOOL)isSupperLocalPic
  withSupperHttpPic:(BOOL)isSupperHttpPic withMaxPhotoNum:(NSInteger)maxPhoto delegate:(id<WSPhotoBrowseViewDelegate>)delegateObj
              align:(NSString *)align withDisPlayMode:(NSString *)disPalyMode;
- (id)initWithFrame:(CGRect)frame funs:(WSFuncsBean *)funcs withImageIDArray:(NSArray *)imageIDArray withSupperLocalPic:(BOOL)isSupperLocalPic
  withSupperHttpPic:(BOOL)isSupperHttpPic withMaxPhotoNum:(NSInteger)maxPhoto delegate:(id<WSPhotoBrowseViewDelegate>)delegateObj
              align:(NSString *)align withDisPlayMode:(NSString *)disPalyMode xbuildInfo: (WSAcvtBean_qst*)xbuildInfo;
- (void)reloadData;
- (void)deleteAllImage;
- (void)fetchImagesFromNetWorkWith:(NSObject *)value;
- (void)addImageID:(NSString *)imageID withImage:(UIImage *)image;
- (void)setTakePhotoButtonHidden:(BOOL)isHidden;
- (void)takePhotoAction:(NSString*)sender;

@end
//=============================================================================================================================
