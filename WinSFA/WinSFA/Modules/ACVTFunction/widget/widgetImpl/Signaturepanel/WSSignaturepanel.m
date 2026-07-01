//
//  WSSignaturepanel.m
//  WinSFA
//
//  Created by zhiqing on 16/8/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSignaturepanel.h"
#import "PureLayout.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"
#import "WSAcvtModel.h"
#import "WSJSONBuilder.h"
#import "WSDataSourceManager.h"
#import "WSServerIPList.h"
#import "WSSignatureViewController.h"
#import "WSInoutStoreTable.h"
#import "WSPhotoLogicService.h"
#import "WSRequestHelper.h"
#import "ImageHelper.h"

/*  这个控件加入了特殊需求（如果是下一次新的拜访不回显上次签名的图片），后期需要加配置或者再优化 适应多种需求  */
@interface WSSignaturepanel ()<WSSignatureViewControllerDelegate>
{
    UIImageView *_signImageView;
    WSAcvtModel *_model;
    NSString * _inStoreString;  //  本次拜访的进店时间
}

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) NSString *serverImageIndex;

@end


@implementation WSSignaturepanel
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self showSignatureView];
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    
}

- (NSString *) getAcvtQstId
{
    if (xbuildInfo) {
        return [xbuildInfo getAcvtQstId];
    }
    return nil;
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    self.imageIDArray = [[NSMutableArray alloc]init];

    UIImage *dashImage = [UIImage scaledImageForName:@"dashed_frame" ofType:@"png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(30, 30, 30, 30);
    dashImage = [dashImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeTile];
    UIImageView *dashImageView = [[UIImageView alloc] initWithImage:dashImage];
    dashImageView.frame = CGRectMake(MAIN_CELL_PADDING, 0, self.frame.size.width - MAIN_CELL_PADDING * 2, OPERATION_HEIGHT);
    dashImageView.userInteractionEnabled = YES;
    [self addSubview:dashImageView];
    
    [self bringSubviewToFront:self.titleLabel];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"click_to_sign", nil);
    //    lable.textColor = [UIColor colorForKey:@"MainTintColor"];
    label.font = [UIFont systemFontOfSize:UI_Enhance_Font];
    label.textColor = [UIColor redColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = dashImageView.bounds;
    [dashImageView addSubview:label];
    self.promptLabel = label;
    
    _signImageView = [[UIImageView alloc]init];
    [dashImageView addSubview:_signImageView];
    CGFloat width = dashImageView.width - 2 ;
    [_signImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_signImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_signImageView autoSetDimensionsToSize:CGSizeMake(width, OPERATION_HEIGHT - MAIN_PADDING)];
    
    _model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    BOOL isSupperLocalPic = NO;
    NSInteger isSupperLocalInt= [xbuildInfo isSupperLocalPhotoForXB];
    
    if (isSupperLocalInt == 0) {
        /*是否禁止使用本地照片  需要补录时间表里是否有时间*/
        isSupperLocalPic = [_model isSupperChangedLocalPhoto];
    } else if (isSupperLocalInt == 1) {
        isSupperLocalPic = YES;
    } else if (isSupperLocalInt == 2) {
        /*禁止使用本地照片*/
        isSupperLocalPic = NO;
    }
    _originalValue = [xdisplayValue getDisplayValueFor:xbuildInfo];
    [self getServerDisImageIndex]; //MN-4765 获取服务器回显imageIndex
    if (_originalValue && isSupperLocalPic) {
        
        [self.imageIDArray addObjectsFromArray:(NSArray *)_originalValue];
    }
 
    _inStoreString = [[WSInoutStoreTable sharedTable]getEnterStoreTime:_model.currentStore andOtherParam:_model.currentFuncs.iParentFuncsBean.fc andParamType:EParameterType_ParentFC];  // 进店时间
    
    NSString * imageID = [(NSArray *)_originalValue firstObject];
    if (imageID && self.imageIDArray.count == 0) {
        [self.imageIDArray addObject:imageID];
    }
    NSString * recordTime = @"";
    
    if (_model.currentStore.Id) {
       recordTime = [[NSUserDefaults standardUserDefaults] objectForKey:_model.currentStore.Id];
    }
    
    UIImage *image ;
    if ([_inStoreString isEqualToString:recordTime]) { // 进店时间 如果和照片拼的时间戳一样，说明是该次拜访没结束
       image  = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
    }
    
    if (image) {
        _signImageView.image = image;
        self.promptLabel.hidden = YES;
    }else if(_originalValue){
        if (isSupperLocalPic) {
            [self fetchImagesFromNetWorkWith:_originalValue];
        } else {
            [self reloadDataWithImageID:imageID];
        }
    }
    

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,  OPERATION_CELL_HEIGHT);

}
//获取服务器回显的imageIndex
- (void)getServerDisImageIndex {
    if ([_originalValue isKindOfClass:[NSArray class]]) {
        //获取服务器回显的imageIndex
        for (NSString *valueItem in (NSArray *)_originalValue) {
            
            self.serverImageIndex = [WSPhotoLogicService getImageIndexFromServerRedisValue:valueItem];
            
            if (self.serverImageIndex) {
                break;
            }
            
        }
    }
}
-(void)saveImage:(UIImage *)image{
    _signImageView.image = image;
    if (image) {
        [self.promptLabel setHidden:YES];
        [self addImage:image];
    } else {
        self.delectImageID = [self.imageIDArray firstObject];
        [self.imageIDArray  removeAllObjects];
        [self.promptLabel setHidden:NO];
    }
}

- (void)showSignatureView{
    
    WSSignatureViewController * ctrl = [[WSSignatureViewController alloc]init];
    ctrl.signImage = _signImageView.image;
    ctrl.delegate = self;
    [self.viewController presentViewController:ctrl animated:YES completion:nil];
}

- (void)addImage:(UIImage *)image
{
    LogTrace();
    
    if (image == nil) {
        return;
    }

   
    NSString * genID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
    
    if (_inStoreString.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_inStoreString forKey:_model.currentStore.Id];
    }
    
    LogInfo(@"imageID:%@",genID);
    
    if (genID == nil) {
        return;
    }
    
    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
    [[SDImageCache sharedImageCache] storeImage:image imageImgCompress:imgCompress forKey:genID toDisk:YES toDocument:YES isSynchronized:YES];
    [self.imageIDArray  removeAllObjects];
    [self.imageIDArray addObject:genID];
    [[_model qstDBValueDictionary] setObject:self.imageIDArray forKey:[xbuildInfo getAcvtQstId]];
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation
{
    //脚本执行，获取图片路径，给图片赋值 SFA-25465  SFA-立白-IOS-订单页面点订单预览按钮，没有显示出签名
    if (valuePresentation.length > 0) {
        _signImageView.image = [UIImage imageWithContentsOfFile:valuePresentation];
    }else {
        _signImageView.image = nil;
    }
}
-(NSObject *)getResultDirectly{

    if (_signImageView.image
        && [self.imageIDArray count] > 0
        && _model) {
        
        NSString *flag = [xbuildInfo getPhotoIsCoverNewId];
        if ((!flag || [flag isEqualToString:@"0"]) && [self.serverImageIndex length] > 0) {
            return self.serverImageIndex;
        }else {
            return [WSPhotoLogicService getAcvtImageIndexWithFC:_model.currentFuncs.fc acvtMD5:_model.md5 acvtQstId:[xbuildInfo getAcvtQstId]];
        }
        
    }
    else
    {
        return nil;
    }

}

- (NSObject *)getResultPresentation {
    
    return [self getResultDirectly];
    
}


/*从网络获取图片并刷新*/
- (void)fetchImagesFromNetWorkWith:(NSObject *)value {
    if (value) {
        // value 可能是string 类型 也可能是array类型
        NSArray *tmpImageIdArray = (NSArray *)value;
        WSServerIPList *svip = [WSAppData getObjectbyKey:SERVERURL];
        WSServerIPController *serverIP = [svip.serverIPArray firstObject];
        NSString *stringURL = nil;
        for (int index =0; index < tmpImageIdArray.count; index ++) {
            stringURL = [NSString stringWithFormat:@"%@%@",[serverIP ServerIPString],[tmpImageIdArray objectAtIndex:index ]];
            stringURL = [stringURL stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];//字符转换
            
            [[WSRequestHelper shareInstance]  downloadImageWithUrl:stringURL progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                // 处理下载进度
            } completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
                UIImage * scaleImage = image;
                CGFloat imageViewW;
                CGFloat imageViewH;
                
                
                NSString * genID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
                
                if (_inStoreString.length > 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:_inStoreString forKey:_model.currentStore.Id];
                }
                
                
                LogInfo(@"imageID:%@",genID);
                if (genID == nil) {
                    return;
                }
                if (image && finished) {
                    
                    if ((scaleImage.size.width > self.width) && (scaleImage.size.height > self.height) ) {
                        scaleImage = [ImageHelper imageCompressForWidthScale:image targetWidth:self.height];
                    }else if (scaleImage.size.width > self.width){
                        scaleImage = [ImageHelper imageCompressForWidthScale:image targetWidth:self.width - 20];
                    }else if (image.size.height > self.height){
                        scaleImage = [ImageHelper imageCompressForWidthScale:image targetWidth:self.height];
                    }
                    imageViewW = scaleImage.size.width ;
                    imageViewH = scaleImage.size.height;
                    
                    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
                    [[SDImageCache sharedImageCache] storeImage:image imageImgCompress:imgCompress forKey:genID toDisk:YES toDocument:YES isSynchronized:YES];
                }
                
                if (image == nil) {
                    image = [UIImage imageNamed:@"photo_loading_failed.png"];
                }
                
                [self.promptLabel setHidden:YES];
                
                _signImageView.image = image;
                
                [self.imageIDArray addObject:genID];
                
            }];
        }
      
    }
}


- (void)reloadDataWithImageID:(NSString *)imageID {
    //理文新增，后台会返回imageID和url,用@拼接，用于回显服务器照片，如果本地有照片就直接显示，没有就去下载服务器的照片。
    NSArray *imageKeyArray = [imageID componentsSeparatedByString:@"@"];
    
    UIImage *image = nil;
    
    // TODO 需要使用 统一的下载方式 WSRequestHelper downloadImage
    if ([imageKeyArray count] > 1) {
        image = [[SDImageCache sharedImageCache] imageFromKey:[imageKeyArray firstObject] fromDisk:YES];
        if (image) {
            _signImageView.image = image;
        }else {
            [_signImageView sd_setImageWithURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[imageKeyArray lastObject]]] completed:nil];
        }
    }else {
        image = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
        _signImageView.image = image;
    }
    if (image) {
        [self.promptLabel setHidden:YES];
    } else {
        [self.promptLabel setHidden:NO];
    }
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];

    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        self.userInteractionEnabled = NO;
    }else
        self.userInteractionEnabled = YES;

}
- (NSString *)getBitmapPath{
//    MN-975 董宏
    if ([self.imageIDArray firstObject]) {
        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:[self.imageIDArray firstObject]];
        return filePath;
    }
    return @"";
}
@end
