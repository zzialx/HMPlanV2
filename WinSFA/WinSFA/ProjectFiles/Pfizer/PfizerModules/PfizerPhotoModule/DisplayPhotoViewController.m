//
//  DisplayPhotoViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-26.
//
//

#import "DisplayPhotoViewController.h"
#import "WSEmpInfoBeanArray.h"
#import "WSEmpInfoBean.h"
#import "WSSelectListView.h"
#import "PayDisPlayBeanArray.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSPhotoGalleryViewController.h"
//#import "ConfigFileController.h"
#import "WSJSONBuilder.h"
#import "GetMD5byStr.h"
#import "WSPlistHelper.h"

#define kXSpace 10
#define kYSpace 0
#define kLabelHeight    50
#define kLabelWidth     250

static const CGFloat DPVC_LabelExtraWidth = 10.f;

@interface DisplayPhotoViewController ()

@property (nonatomic, strong) WSSelectListView *displayLV;
@property (nonatomic, assign) NSInteger displayLVSelectedIndex;

@property (nonatomic, strong) WSSelectListView *brandLV;
@property (nonatomic, assign) NSInteger brandLVSelectedIndex;

@property (nonatomic, strong) UILabel *startLable;
@property (nonatomic, strong) UILabel *endLable;

@property (nonatomic, strong) PayDisPlayBeanArray *payDisPlayBeanArray;

/*  存不同品牌照片的 Dictionary
 *  key     :   品牌的 main_id
 *  value   :   存放对应品牌所拍摄的所有照片
 */
@property (nonatomic, strong) NSMutableDictionary *photoDic;

/*  当前选择的品牌 bean
 */
@property (nonatomic, strong) PayDisPlayBean *currentBrandBean;

@end

@implementation DisplayPhotoViewController

@synthesize displayLV = _displayLV;
@synthesize displayLVSelectedIndex = _displayLVSelectedIndex;
@synthesize brandLV = _brandLV;
@synthesize brandLVSelectedIndex = _brandLVSelectedIndex;
@synthesize payDisPlayBeanArray = _payDisPlayBeanArray;
@synthesize currentBrandBean = _currentBrandBean;
@synthesize photoDic =_photoDic;


- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store {
    BOOL shouldPhoto = NO;
    
    /*  辉瑞零售 - 判断该门店需不需要 陈列拍照
     *  需要 陈列拍照 的门店会在 login 返回的数据节点 empInfo 节点中列出
     *  - empInfo       // login 返回的 empInfo 节点
     *      - [n]       // 需要陈列拍照的门店列表
     *  
     *  需如不需要拍照，则显示 “该店无陈列拍照“ (参考 Android)
     */
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    if ([projectName isEqualToString:@"PfizerOTCV2"] || [projectName isEqualToString:@"PfizerHosV2"]) {
        
        WSEmpInfoBeanArray *empArray = [WSAppData getObjectbyKey:EMPINFO];
        for (WSEmpInfoBean *bean in empArray.empInfoBeanArray) {
            if ([bean.store_id isEqualToString:store.sid]) {
                shouldPhoto = YES;
                break;
            }
        }
        if (!shouldPhoto) {
            NSString *title = NSLocalizedString(@"该店无陈列拍照", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return nil;
        }
    }
    
    PayDisPlayBeanArray *tmpPayBeans =nil;
    if (!store.plan) {
        NSDictionary *dic = [WSAppData getObjectbyKey:@"spestoreinfo"];
        NSArray *array = [dic objectForKey:@"payDisplay"];
        if (array && [array count] > 0) {
            tmpPayBeans = [[PayDisPlayBeanArray alloc] initWithObject:array];
        }
    } else {
        
        
        tmpPayBeans = store.payDisplayBeanArray;
    
    }
    // 对于不分计划内／计划外门店的数据采用此方法
    if (!tmpPayBeans) {
        
        tmpPayBeans = [[PayDisPlayBeanArray alloc]initWithFilter:store.Id];
         //tmpPayBeans = store.payDisplayBeanArray;
    
    }
    // 对于不分计划内／计划外门店的数据采用此方法
    if (tmpPayBeans.beanArray.count == 0) {
        
        
        NSString *title = NSLocalizedString(@"该店无陈列拍照", nil);
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    
        return nil;
    
    }
    
    self = [super initWithFuncs:funcs Store:store];
    if (self) {
        /*  辉瑞零售 - 需要陈列拍照的门店的 陈列 和 品牌 信息
         *  计划外 和 计划内 获取信息的规则不一样
         *  计划外 在 login 返回数据中的 payDisplay 节点中获取
         *  计划内 在门店列表中包含的 payDisplay 节点获取
         */
        self.payDisPlayBeanArray = tmpPayBeans;
        
        self.photoDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    int y_offset = kYSpace;
    
//    // 开始日期 y 的位置
//    y_offset += branRect.size.height + 5;
    
    // Label - 开始日期
    self.startLable = [[UILabel alloc] init];
    self.startLable.font = [UIFont systemFontOfSize:UI_Font];
    self.startLable.frame = CGRectMake(kXSpace, y_offset, kLabelWidth, kLabelHeight);
    [self.contentScrollView addSubview:self.startLable];
    
    // 结束日期 y 的位置
    y_offset += self.startLable.size.height;
    
    // Label - 结束日期
    self.endLable = [[UILabel alloc] init];
    self.endLable.font = [UIFont systemFontOfSize:UI_Font];
    self.endLable.frame = CGRectMake(kXSpace, y_offset, kLabelWidth, kLabelHeight);
    [self.contentScrollView addSubview:self.endLable];
    
    // 下一个 view y 的位置
    y_offset += self.endLable.size.height;
    
    // Label - 陈列
    UILabel *displayLabel = [[UILabel alloc] init];
    displayLabel.font = [UIFont systemFontOfSize:UI_Font];
    NSString *ln_display = NSLocalizedString(@"陈列", nil);
    CGSize textSize = [ln_display ws_sizeWithFont:displayLabel.font constrainedToWidth:kLabelWidth];
    
    displayLabel.frame =  CGRectMake(kXSpace, y_offset, textSize.width, kLabelHeight);
    displayLabel.text = ln_display;
    [self.contentScrollView addSubview:displayLabel];
    
    // 下列框 - 陈列
    NSMutableArray *displayContent = [NSMutableArray arrayWithCapacity:[_payDisPlayBeanArray.beanArray count]];
    for (PayDisPlayBean *bean in _payDisPlayBeanArray.beanArray) {
        [displayContent addObject:bean.name];
    }
    _displayLVSelectedIndex = 0;
    CGRect displayRect = displayLabel.frame;
    self.displayLV = [[WSSelectListView alloc] initWithFrame:CGRectMake(displayRect.origin.x + displayRect.size.width + 5, y_offset + 5, 400, 40)];
    self.displayLV.content = displayContent;
    self.displayLV.selectType = WSSelectLIstViewTypeDefaultShow; 
    self.displayLV.selectedIndex = _displayLVSelectedIndex;
    self.displayLV.selectListDelegate = self;
    [self.contentScrollView addSubview:self.displayLV];
    
    // 品牌 y 的位置
    y_offset += displayRect.size.height;

    // Label - 品牌
    UILabel *brandLabel = [[UILabel alloc] init];
    brandLabel.font = [UIFont systemFontOfSize:UI_Font];
    NSString *ln_brand = NSLocalizedString(@"pay_display_camera_brand", nil);
    CGSize tsize_brand = [ln_brand ws_sizeWithFont:brandLabel.font constrainedToWidth:kLabelWidth];

    brandLabel.frame =  CGRectMake(kXSpace, y_offset, tsize_brand.width, kLabelHeight);
    brandLabel.text = ln_brand;
    [self.contentScrollView addSubview:brandLabel];
    
    // 下列框 - 品牌
    PayDisPlayBean *subBean = [_payDisPlayBeanArray.beanArray objectAtIndex:_displayLVSelectedIndex];
    NSMutableArray *branContent = [NSMutableArray arrayWithCapacity:[subBean.inArray count]];
    
    for (PayDisPlayBean *bean in subBean.inArray) {
        [branContent addObject:bean.name];
    }
    _brandLVSelectedIndex = 0;
    CGRect branRect = brandLabel.frame;
    self.brandLV = [[WSSelectListView alloc] initWithFrame:CGRectMake(branRect.origin.x + branRect.size.width + 5, y_offset + 5, 400, 40)];
    self.brandLV.content = branContent;
    self.brandLV.selectType = WSSelectLIstViewTypeDefaultShow;
    self.brandLV.selectedIndex = _brandLVSelectedIndex;
    self.brandLV.selectListDelegate = self;
    [self.contentScrollView addSubview:self.brandLV];
    
    /*  当前品牌 currentBrandBean
     *  初始指向第一个陈列的第一个品牌
     */
    self.currentBrandBean = [subBean.inArray objectAtIndex:_brandLVSelectedIndex];
    
    y_offset += branRect.size.height;
    self.y_point = y_offset;
    
    //设置开始和结束日期内容
    PayDisPlayBean *inBean = [subBean.inArray objectAtIndex:_brandLVSelectedIndex];
    NSString *startDateString = NSLocalizedString(@"worklog_start_date", nil);
    NSString *labelTitle_startDate = [NSString stringWithFormat:@"%@：%@", startDateString, inBean.startTime];
    CGSize tsize_startDate = [labelTitle_startDate ws_sizeWithFont:self.startLable.font constrainedToWidth:self.view.bounds.size.width];
    
    CGRect tmpRect = self.startLable.frame;
    tmpRect.size.width = tsize_startDate.width + DPVC_LabelExtraWidth;
    self.startLable.frame = tmpRect;
    self.startLable.text = labelTitle_startDate;
    
    NSString *endDateString = NSLocalizedString(@"worklog_end_date", nil);
    NSString *endTitle_startDate = [NSString stringWithFormat:@"%@：%@", endDateString, inBean.endTime];
    CGSize tsize_endDate = [endTitle_startDate ws_sizeWithFont:self.endLable.font constrainedToWidth:self.view.bounds.size.width];
    
    tmpRect = self.endLable.frame;
    tmpRect.size.width = tsize_endDate.width + DPVC_LabelExtraWidth;
    self.endLable.frame = tmpRect;
    self.endLable.text = endTitle_startDate;
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y_offset);
    
    [self addPicture];
    [self addFuncsOtherBeanView];
    [self addOptView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addToolBar];
}


#pragma mark - delegate
- (void)selectListChange:(WSSelectListView *)aSelectListView {
    /*  如果 aSelectListView 为陈列下拉列表
     *  改变品牌下拉列表内容
     */
    if (aSelectListView == self.displayLV) {
        PayDisPlayBean *subBean = [_payDisPlayBeanArray.beanArray objectAtIndex:aSelectListView.selectedIndex];
        NSMutableArray *branContent = [NSMutableArray arrayWithCapacity:[subBean.inArray count]];
        
        for (PayDisPlayBean *bean in subBean.inArray) {
            [branContent addObject:bean.name];
        }
        _brandLVSelectedIndex = 0;
        if ([branContent count] == 0) {
            [branContent addObject:@""];
            [self.brandLV setSourceTableReadOnly:YES];
        }else {
            [self.brandLV setSourceTableReadOnly:NO];
        }
        self.brandLV.content = branContent;
        [self.brandLV flushTable];
        self.brandLV.selectedIndex = _brandLVSelectedIndex;
    }
    /*  选择了不同的品牌
     *  更改当前的品牌 self.currentBrandBean
     */
    PayDisPlayBean *l_bean = [_payDisPlayBeanArray.beanArray objectAtIndex:self.displayLV.selectedIndex];
    self.currentBrandBean = [l_bean.inArray objectAtIndex:self.brandLV.selectedIndex];
    
    /*  修改开始日期
     */
    NSString *startDateString = NSLocalizedString(@"worklog_start_date", nil);
    NSString *labelTitle_startDate = [NSString stringWithFormat:@"%@：%@", startDateString, self.currentBrandBean.startTime];
    self.startLable.text = labelTitle_startDate;
    /*  修改结束日期
     */
    NSString *endDateString = NSLocalizedString(@"worklog_end_date", nil);
    NSString *endTitle_startDate = [NSString stringWithFormat:@"%@：%@", endDateString, self.currentBrandBean.endTime];
    self.endLable.text = endTitle_startDate;
}

- (void)addPicture {
    NSString *photoString = NSLocalizedString(@"camera_capture",nil);
    UIBarButtonItem *makePhoto = [[UIBarButtonItem alloc]
                                  initWithTitle:photoString
                                  style: UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(makePhoto)];
    if(self.m_ParentViewController != nil)
        self.m_ParentViewController.navigationItem.rightBarButtonItem = makePhoto;
    else
        self.navigationItem.rightBarButtonItem = makePhoto;
    

}

- (void)makePhoto {    
    /*
     *  根据当前选择的品牌的 main_id
     *  找出保存的照片 photoArray
     *  并传给 PhotoGalleryViewController
     */
    NSString *main_id = self.currentBrandBean.main_id;
    NSMutableArray *photoArray = [self.photoDic objectForKey:main_id];
    if (!photoArray) {
        photoArray = [[NSMutableArray alloc] init];
        [self.photoDic setObject:photoArray forKey:main_id];
    }
    WSPhotoGalleryViewController *pgVc = [[WSPhotoGalleryViewController alloc] initWithImageIDArray:photoArray];
    [self.navigationController pushViewController:pgVc animated:YES];
}

- (BOOL)checkPhotos {
    for (PayDisPlayBean *displayBean in self.payDisPlayBeanArray.beanArray) {
        for (PayDisPlayBean *brand in displayBean.inArray) {
            NSString *main_id = brand.main_id;
            NSMutableArray *photoArray = [self.photoDic objectForKey:main_id];
            if ([photoArray count] == 0) {
                NSString *title = NSLocalizedString(@"scan_no_photo", nil);
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@->%@ %@", displayBean.name, brand.name, title] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return NO;
            }
        }
    }
    return YES;
}

- (void)upload {
    /*  检查是否每个 品牌 都拍照
     *  业务要求每个 品牌 都拍照
     */
    if (![self checkPhotos]) {
        return;
    };

    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    
    /*  jsonDataArray 包含了每个品牌的信息
     *  每个元素包含一个 dictionary，分别对应每一个品牌
     *  每个 dictionary 中存放 brandId, dispId, main_id
     *
     *  （
     *     个人觉得这是一个无用的数据节点
     *     既然都需要拍照为神马还要把每个品牌的信息传回去
     *     dictionary 中又不包含照片 id 什么之类的信息
     *     纯吐槽
     *   ）
     */
    NSMutableArray *jsonDataArray = [[NSMutableArray alloc] init];
    for (PayDisPlayBean *displayBean in self.payDisPlayBeanArray.beanArray) {
        for (PayDisPlayBean *brandBean in displayBean.inArray) {
            NSArray *keysArray = [NSArray arrayWithObjects:@"dispId", @"brandId", @"main_id", nil];
            NSArray *valuesArray = [NSArray arrayWithObjects:displayBean.Id, brandBean.Id, brandBean.main_id, nil];
            NSDictionary *cell = [NSDictionary dictionaryWithObjects:valuesArray
                                                              forKeys:keysArray];
            [jsonDataArray addObject:cell];
        }
    }
    
    
    NSString *postData = [WSJSONBuilder buildDisplayPhotoDatasbyFuncs:self.currentFuncs
                                                           HasPhoto:YES
                                                              Store:self.currentStore
                                                              cells:jsonDataArray
                                                                md5:self.md5
                                                         notifyName:notifyID];
    // 上传提示
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    // 插入数据库并上传
    BOOL insertUploadDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID];
    
    if (!insertUploadDataIsSucceed) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    [[WSRequestHelper shareInstance] uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyID md5:self.md5 isUpload:YES];

    /*  上传照片
     *  使用分类照片的上传方法
     */
    NSArray *photosIdArray = [self.photoDic allKeys];
    
    for (NSString *photoId in photosIdArray) {
        
        for (NSString *imageID in [self.photoDic objectForKey:photoId]) {
            
            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
            
            if (filePath) {
                NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID andImageType:photoId];
                NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                BOOL insertPhotoDataIsSucceed =[self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:self.md5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                if (!insertPhotoDataIsSucceed) {
                    [self showDBErrorTipAndHidAllHud];
                    return;
                }
                [uploadMgr uploadImageWithFilePath:filePath
                                            params:params
                                               url:URL_IMAGEUPLOAD
                                        notifyName:notifyID
                                               md5:self.md5];
                
            }
        }
    }
        
    /*  返回上级界面
     */
    
    
    // 上传提示消失
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    /*  
     调用父级 uploadVisitAction，做已完成步骤的标志
     */
    [super uploadVisitAction];
    [self backToParent];

    
}





@end
