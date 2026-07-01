//
//  WCMsgContentViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 10/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSMsgContentViewController.h"
#import "WSServerIPController.h"
#import "WSServerIPList.h"
#import "WSMsgsBean_msg.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"
#import "WSFuncsBeanArray.h"
#import "FuncsBean+JSON.h"
#import "WSStoreBean.h"
#import "WSAcvtBean.h"
#import "GetMD5byStr.h"
#import "WSAppData.h"
#import "WSChatViewController.h"
#import "WSMsgReplyViewController.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WCDownLoadingAndShowingImageView.h"

#import "WSMsgsBean_Component_msg.h"
#import "WSBaseAcvtDBService.h"
#import "WSRequestHelper.h"
#import "NSString+ServerUrl.h"

#define WCSTATUSBARHEIGHT 20.0f
#define WCNAVIGATIONHEIGHT 44.0f
#define WCPADDING 20.0f
#define WCIMAGEVIEWSCALE 0.6f
#define WCIMAGEVIEW_HEIGHT_SCALE 0.6f
#define WCIMAGEVIEWSHOWINGSCALE 0.8f
#define PAGECONTROL_UNIT_WIDTH 35
#define PAGECONTROL_HEIGHT 15

#define WIDTH_MAX_SCALE  0.9
#define HEIGHT_MAX_SCALE 0.85

@interface WSMsgContentViewController ()

@property (nonatomic, strong) UIImageView *iImageView;
@property (nonatomic, strong) UITextView *iTextView;
@property (nonatomic, strong) UIScrollView *iScrollView;
@property (nonatomic, strong) UILabel *iLabel;
@property (nonatomic, strong) UIViewController *bowserContentImageVC;
@property (nonatomic, strong) NSArray *msgUrls;
@property (nonatomic, strong) NSMutableArray *msgImageViews;
@property (nonatomic, strong) UIPageControl *imagePageControl;
@property (nonatomic, assign) CGFloat imageViewHeight;
@property (nonatomic, assign) CGFloat imageViewWidth;
@property (nonatomic, assign) float height;

@property (nonatomic,strong) NSMutableArray *mediaViews;
/*
 下载ppt doc xsl格式文件所用的消息分发类
 */
@property (nonatomic, strong) WSServiceDispatcher *serviceDispatcher;

- (void)addComment;
- (void)markAsReaded;
- (void)sendReadedMessageRequest;

@end

@implementation WSMsgContentViewController
@synthesize iMsg = _iMsg;
@synthesize iImageView = _iImageView;
@synthesize iTextView = _iTextView;
@synthesize isShowingReply = _isShowingReply;
@synthesize iScrollView = _iScrollView;
@synthesize iLabel = _iLabel;
@synthesize bowserContentImageVC = _bowserContentImageVC;

- (id)init
{
    self = [super init];
    if (self) {
        
        WSMsgBeanArray *msgarray = [WSAppData getObjectbyKey:MSGS];
        if (msgarray) {
            WSMsgsBean *msgsbeen = [msgarray.msgArray lastObject];
            WSMsgsBean_msg *msg = [msgsbeen.msg objectAtIndex:0];
            if (msg) {
                _iMsg = msg;
                [self initDatas];
                if (_msgUrls == nil) {
                    _msgUrls = [[NSArray alloc] init];
                    _msgUrls = [_iMsg.url componentsSeparatedByString:@","];
                }
            }
        }
       
    }
    
    return self;
}

- (id)initWithMessage:(WSMsgsBean_msg *)aMsg
{
    self = [super init];
    if (self) {
        if (aMsg) {
            _iMsg = aMsg;
            [self initDatas];
            if (_msgUrls == nil) {
                _msgUrls = [[NSArray alloc] init];
                _msgUrls = [_iMsg.url componentsSeparatedByString:@","];
            }
        }
        
    }
    return self;
}

- (void)initDatas {
    _msgImageViews = [[NSMutableArray alloc] init];
    _mediaDic = [[NSMutableDictionary alloc] init];
    _mediaViews = [[NSMutableArray alloc] init];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




#pragma mark - view cycle

- (void)loadView
{
    LogInfo(@"Going to WSMsgContentViewController loadview");
    
   
    
    // self view
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    [view setUserInteractionEnabled:YES];
    self.view = view;
    
    CGRect scrollViewRect = CGRectZero;
    CGRect fullRect = [[UIScreen mainScreen] bounds];
    scrollViewRect.size.width = fullRect.size.width;
    scrollViewRect.size.height = fullRect.size.height - WCSTATUSBARHEIGHT - WCNAVIGATIONHEIGHT;
    self.iScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.iScrollView.delegate = self;
    self.iScrollView.pagingEnabled = YES;
    self.iScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.iScrollView];
    
    _imagePageControl=[[UIPageControl alloc]initWithFrame:CGRectZero];
    _imagePageControl.numberOfPages=[self.msgUrls count];
    _imagePageControl.currentPage=0;
    [_imagePageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    

    self.iLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.iLabel.numberOfLines = 0;
    self.iLabel.font = [UIFont systemFontOfSize:UI_Font];
    self.iLabel.backgroundColor = [UIColor clearColor];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
    [self.iLabel addGestureRecognizer:longPress];
    [self.iLabel setUserInteractionEnabled:YES];
    [self.iScrollView addSubview:self.iLabel];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.iMsg.title;
    self.view.backgroundColor = [UIColor whiteColor];
    // Replay
    NSString *noreplay = [WSAppData getObjectbyKey:APPDATA_NOREPLY];
    if (noreplay == nil || ![noreplay isEqualToString:@"1"]) {
        NSString *replayString = NSLocalizedString(@"topic_reply", nil);
        UIBarButtonItem *replayItem = [[UIBarButtonItem alloc] initWithTitle:replayString style:UIBarButtonItemStylePlain target:self action:@selector(addComment)];
        self.navigationItem.rightBarButtonItem = replayItem;
        
        
    }

//    [self markAsReaded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _height = 0;
    _imageViewHeight =0.0f;
    _imageViewWidth = 0;
    
    /**
     加载其他附件（xls,doc,pptx）
     */
    if ([self.mediaViews count] > 0) {
        for (NSInteger i = 0; i < [self.mediaViews count];i++) {
            _height += 10.0f;
            WSMsgContentMediaView *mediaView = [self.mediaViews objectAtIndex:i];
            _height += mediaView.size.height + WCPADDING;
        }
    }else {
        [self loadDownloadAttachmentView];
    }
    
    
    if ([self.iMsg.url length] > 0 && [self.msgUrls count] > 0) {
        for (NSInteger i = 0; i < [self.msgUrls count]; i++) {
            CGFloat  imageOrigin_Y_Offset = _height;
            __block CGRect scrollViewBounds = self.iScrollView.bounds;
            NSString *urlStr = [self.msgUrls objectAtIndex:i];
            __block UIImageView *tmpImageView = [[UIImageView alloc] init];
            UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
            [tmpImageView addGestureRecognizer:tap];
            tmpImageView.tag = i;
            tmpImageView.userInteractionEnabled=YES;
            
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[urlStr buildupUrl] imageView:tmpImageView placeholderImage:[UIImage imageNamed:@"picture_loading"] progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                if(error){
                    tmpImageView.image=[UIImage imageForName:@"picture_loading_failed"];
                } else {
                    [self computeImageWidthAndHeight:tmpImageView originY:imageOrigin_Y_Offset index:i  limitInRect:scrollViewBounds];
                }
            }];
            if (_imageViewWidth == 0 && _imageViewWidth == 0 ) {
                /*初始的宽高*/
                _imageViewWidth = WCIMAGEVIEWSCALE * scrollViewBounds.size.height;
                _imageViewHeight = WCIMAGEVIEW_HEIGHT_SCALE *scrollViewBounds.size.width;
                CGFloat yOffset =  self.iMsg.fileUrl ? _height :(_height + WCPADDING) ;
                tmpImageView.frame = CGRectMake((scrollViewBounds.size.width-_imageViewWidth)/2 + i*scrollViewBounds.size.width, yOffset, _imageViewWidth, _imageViewHeight);
                tmpImageView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
            }
            [self.msgImageViews addObject:tmpImageView];
            [self.iScrollView addSubview:tmpImageView];
        }
    }
   
    NSString *NOMsgString = NSLocalizedString(@"今日无消息",nil);
    self.iLabel.text = self.iMsg.cont ?: NOMsgString;
    if (self.iMsg.url && !self.iMsg.fileUrl) {
        _height += _imageViewHeight + 2*WCPADDING;
    } else if (!self.iMsg.url && self.iMsg.fileUrl) {
         _height += 0;
    }else if (!self.iMsg.url && !self.iMsg.fileUrl) {
        _height +=  WCPADDING;
    } else if (self.iMsg.url && self.iMsg.fileUrl) {
        _height +=  WCPADDING + _imageViewHeight;
    }
    
    
    // text size
    if (self.iLabel.text && [self.iLabel.text length] > 0) {
        CGRect scrollViewBounds = self.iScrollView.bounds;
        float constrainedWidth = scrollViewBounds.size.width - 2*WCPADDING;
        CGSize size = [self.iLabel.text ws_sizeWithFont:self.iLabel.font constrainedToWidth:constrainedWidth lineBreakMode:NSLineBreakByCharWrapping];
        
        self.iLabel.frame = CGRectMake(WCPADDING,_height, constrainedWidth, size.height);
        _height += (2*WCPADDING + size.height);
    }
    
    
    CGFloat contentWidth = [self.msgUrls count] > 0 ? (self.view.bounds.size.width * [self.msgUrls count]):self.view.bounds.size.width;
    self.iScrollView.contentSize = CGSizeMake(contentWidth, _height);
    CGFloat pageControlWidth =  PAGECONTROL_UNIT_WIDTH * [self.msgUrls  count];
    self.imagePageControl.frame = CGRectMake((self.view.bounds.size.width - pageControlWidth)/2, WCPADDING+_imageViewHeight - 2 * PAGECONTROL_HEIGHT,pageControlWidth, PAGECONTROL_HEIGHT);
    if([self.msgUrls count] > 1){
        [self.iScrollView addSubview:_imagePageControl];
    }else{
        self.imagePageControl = nil;
    }
    
    //Send request
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", self.iMsg.s, self.iMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    NSNumber *number = [dic objectForKey:key];
    if (number == nil || ![number boolValue]) {
        [self sendReadedMessageRequest];
    }
    [self markAsReaded];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    if (self.isHomePageSign && self.iMsg.url) {
        NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
        if ( projectName != nil && [projectName isEqualToString:@"SKSHU"]) {
            [self imageViewTap:nil];
        }
    }
}


- (void)computeImageWidthAndHeight:(UIImageView *)tmpImageView originY:(CGFloat)imageOrigin_Y_Offset index:(NSInteger)i limitInRect:(CGRect)scrollViewBounds {
    if(scrollViewBounds.size.width >scrollViewBounds.size.height){
        _imageViewWidth = WCIMAGEVIEWSCALE *scrollViewBounds.size.width;
        _imageViewHeight = WCIMAGEVIEW_HEIGHT_SCALE *scrollViewBounds.size.height;
    }else{
        /* 旧代码  以后删除
         imageViewWidth = WCIMAGEVIEWSCALE * scrollViewBounds.size.height;
         _imageViewHeight = WCIMAGEVIEW_HEIGHT_SCALE *scrollViewBounds.size.width;
         */
        /*
         缩略图最宽为屏幕的0.9 高最大值为屏幕0.85
         */
        CGFloat widthPercentage = tmpImageView.image.size.width/scrollViewBounds.size.width;
        CGFloat heightPercentage = tmpImageView.image.size.height/scrollViewBounds.size.height;
        if (widthPercentage <= WIDTH_MAX_SCALE  && heightPercentage <= HEIGHT_MAX_SCALE) {
            _imageViewWidth = tmpImageView.image.size.width;
            _imageViewHeight = tmpImageView.image.size.height;
        } else {
            if (widthPercentage >= heightPercentage) {
                if (tmpImageView.image.size.width >= WIDTH_MAX_SCALE*scrollViewBounds.size.width) {
                    _imageViewWidth = WIDTH_MAX_SCALE *scrollViewBounds.size.width;
                } else {
                    _imageViewWidth = scrollViewBounds.size.width;
                }
                _imageViewHeight = (_imageViewWidth/tmpImageView.image.size.width)*tmpImageView.image.size.height;
            } else {
                if (tmpImageView.image.size.height >= HEIGHT_MAX_SCALE*scrollViewBounds.size.height) {
                    _imageViewHeight = HEIGHT_MAX_SCALE *scrollViewBounds.size.height;
                    
                } else {
                    _imageViewHeight = tmpImageView.image.size.height;
                }
                _imageViewWidth = (_imageViewHeight/tmpImageView.image.size.height)*tmpImageView.image.size.width;
                
            }
        }
        
        CGFloat yOffset =  self.iMsg.fileUrl ? imageOrigin_Y_Offset :(imageOrigin_Y_Offset + WCPADDING) ;
        tmpImageView.frame = CGRectMake((scrollViewBounds.size.width-_imageViewWidth)/2 + i*scrollViewBounds.size.width, yOffset, _imageViewWidth, _imageViewHeight);
        tmpImageView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        
        if (i == 0) {
            //加载图片后重新设置提示label的位置, 若后续还有其他view 还需重置
            for (UIView *subView in self.iScrollView.subviews) {
                if ([subView isKindOfClass:[UILabel class]]) {
                    CGFloat imageOriginHeight = WCIMAGEVIEW_HEIGHT_SCALE *scrollViewBounds.size.width;
                    CGFloat extra = _imageViewHeight - imageOriginHeight;
                    [subView setFrame:CGRectMake(subView.origin.x, subView.origin.y + extra, subView.size.width, subView.size.height)];
                    
                }
            }
        }
    }
}

/*
 加载ppt xls,doc等附件
 */
- (void)loadDownloadAttachmentView {
    
    for (NSInteger i = 0; i < [self.iMsg.componentMsgs count]; i++) {
        WSMsgsBean_Component_msg *component_Msg = [self.iMsg.componentMsgs objectAtIndex:i];
        _height += 10.0f;
        CGFloat mediaViewWidth = INTERFACE_IS_PHONE ? 310 : 520;
        CGRect mediaRect = CGRectMake((self.iScrollView.width - mediaViewWidth)/2, _height, mediaViewWidth, 80);

        WSMsgContentMediaView *mediaView = [[WSMsgContentMediaView alloc] initWithFrame:mediaRect  msg:component_Msg];
        mediaView.delegate = self;
        [mediaView loadDisplayContent:component_Msg];
        mediaView.layer.cornerRadius = 5.0f;
        mediaView.backgroundColor = [UIColor colorWithRed:238/255.f green:237/255.0f blue:237/255.0f alpha:1.0];
        [self.mediaViews addObject:mediaView];
        [_mediaDic setObject:mediaView forKey:component_Msg.fileUrl];
        _height += mediaView.size.height + WCPADDING;
        [self.iScrollView addSubview:mediaView];
    }
}

#pragma mark WSWidgetDelegate Method
-(void)executeAnyOperationWith:(WSInterAction *)interaction {
    if (interaction == nil) {
        return;
    }
    if ([interaction direct_type] == DIRECT_TYPE_PRESENT) {
        WCBaseViewController  *execute_controller = [[NSClassFromString([interaction execute_class]) alloc] init];
        execute_controller.executeParam = interaction;
        execute_controller.wcBaseViewdelegate = self;
        [self.navigationController presentViewController:execute_controller animated:YES
                                              completion:nil];
    } else if ([interaction direct_type] == DIRECT_TYPE_PUSH) {
        WCBaseViewController  *execute_controller = [[NSClassFromString([interaction execute_class]) alloc] init];
        execute_controller.executeParam = interaction;
        execute_controller.wcBaseViewdelegate = self;
        [self.navigationController pushViewController:execute_controller animated:YES];
    }
}

-(void)imageViewTap:(UITapGestureRecognizer*)tap
{
  
    if([self.iMsg.url length] > 0 && [self.msgUrls count] > 0){
        NSInteger tapViewTag = tap.view.tag;
        NSString *tmpUrlStr = [self.msgUrls objectAtIndex:tapViewTag];
        UIImageView *tmpImageView = [self.msgImageViews objectAtIndex:tapViewTag];
        int iReadTime = 0;
        WCDownLoadingAndShowingImageView *view = nil;
        if (self.isHomePageSign) {
            self.isHomePageSign = NO;
            NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
            if (mobileHomeDic) {
                NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
                iReadTime = [readTimeStr intValue];
            }
        }
        
        view = [[WCDownLoadingAndShowingImageView alloc] initWithFrame:INTERFACE_IS_PAD ? CGRectMake(0, 0, BROWSERVC_WIDTH, BROWSERVC_HEIGNT) : self.view.bounds
                                                          withImageURL:[tmpUrlStr buildupUrl]
                                                             withImage:iReadTime > 0 ? nil : tmpImageView.image
                                                          withDuration:iReadTime
                                                       withProductName:nil];
        view.closeButton.hidden = YES;
        view.delegate = self;
        _bowserContentImageVC = [[UIViewController alloc]init];
        self.bowserContentImageVC.view.backgroundColor = [UIColor  blackColor];
        if (INTERFACE_IS_PAD) {
//            view.frame = CGRectMake((BROWSERVC_WIDTH - view.width)/2,(BROWSERVC_HEIGNT - view.size.height)/2, view.size.width, view.size.height);
        } else {
            view.frame = CGRectMake(view.origin.x,(self.bowserContentImageVC.view.height - view.size.height)/2, view.size.width, view.size.height);
        }
        
        [self.bowserContentImageVC.view addSubview:view];
        [self.navigationController presentViewController:self.bowserContentImageVC animated:YES completion:nil];
    }
}

#pragma mark UIPageControl Methods
-(void)changePage:(id)sender{
    if (self.imagePageControl) {
        NSInteger page=_imagePageControl.currentPage;
        [self.iScrollView setContentOffset:CGPointMake(self.iScrollView.size.width*page, 0) animated:YES];
    }

}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (self.imagePageControl) {
        CGFloat pageWidth =  self.iScrollView.size.width;
        int page = floor((self.iScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _imagePageControl.currentPage = page;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - button action
- (void)addComment
{
    NSRange range = [self.iMsg.acvtId rangeOfString:@"null" ];
    if ((self.iMsg.acvtId) && (range.location == NSNotFound ))
    {
        WSFuncsBeanArray *fArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *func = [fArray.funcsArray objectAtIndex:0];
        NSString *str = [func jsonFromFuncsBean];
        WSFuncsBean *tmpFunc = [[WSFuncsBean alloc] initFuncsWithObject:[str objectFromJSONString]];
        [tmpFunc setValue:@"tmpmsg" forKey:@"fv"];
        [tmpFunc setValue:@"tmpmsg" forKey:@"fc"];
        
        WSStoreBean *store = [[WSStoreBean alloc] init];
        [store setValue:@"tmpmsg" forKey:@"Id"];
        
        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
        WSAcvtBean *acvt = [baseAcvtDBService queryAcvtWithAcvtID:self.iMsg.acvtId];
        
        UIViewController *vc = nil;
        vc = [[WSMsgReplyViewController alloc]initWithAcvt:acvt Funcs:func Store:store];
        ((WSMsgReplyViewController*)vc).msg = self.iMsg;
        
        LogInfo(@"Going to class WSMsgReplyViewController");

        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIViewController *chatViewController = [[WSChatViewController alloc]initWithMSG:self.iMsg];
        if (chatViewController == nil) return;
        
        LogInfo(@"Going to class WSChatViewController");
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}

#pragma mark - private method
- (void)markAsReaded
{
    if (self.iMsg == nil || self.iMsg.s == nil || self.iMsg.Id == nil) {
        return;
    }
    
    NSNumber *value = [NSNumber numberWithBool:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", self.iMsg.s, self.iMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if (value) {
        [dicInfo setObject:value forKey:key];
    }
    
    if (dicInfo) {
        [user setObject:dicInfo forKey:kWSMessageDomainName];
    }
    
    [user synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

- (void)sendReadedMessageRequest{
    
    if (self.iMsg == nil || self.iMsg.s == nil || self.iMsg.Id == nil) {
        return;
    }
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *md5 = [NSString md5:[NSString stringWithFormat:@"%@%@%@%@",empId,bizDate,self.iMsg.s,self.iMsg.Id]];
    
    NSString  *strData = [WSJSONBuilder  buildSendRedMessageWithMsgId:self.iMsg.Id andNotifyName:notifyID andMD5:md5];
    // 先插入数据库
    [self insertUploadData:strData URL:URL_UPLOAD MD5:md5 IsPhoto:NO NotifyName:notifyID];
    
    // 再上传数据，后更新upload_flag
    WSRequestHelper *uploadHandler = [WSRequestHelper shareInstance];
    [uploadHandler sendReadedMessageRequestWithMsgId:self.iMsg.Id andNotifyName:notifyID andMD5:md5];
   
}

#pragma mark WCDownLoadingAndShowingImageViewDelegate Methods 
- (void)touchShowImageViewEnd:(UIView *)view {
    if (self.bowserContentImageVC) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - insert off line table
-(void) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    if (!aNotifyName) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为空");
        return;
    }
    if ([aNotifyName isKindOfClass:[NSNull class]]) {
        LogError(@"离线上传数据库插入未执行，原因：Notiy为NULL");
        return;
    }

    NSMutableArray* l_Values = [[NSMutableArray alloc]init];
    //person
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //date
    [l_Values addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //upload flag
    [l_Values addObject:@"0"];
    //upload data
    [l_Values addObject:aPostDate];
    //url
    [l_Values addObject:aUrl];
    //md5
    [l_Values addObject:aMd5];
    //isphoto
    if(aIsPhoto)
    {
        [l_Values addObject:@"1"];
        
    }else
        [l_Values addObject:@"0"];
    
    [l_Values addObject:aNotifyName];
    
    // 为保存向前兼容，不修改其它调用此方法的类，将之前使用此方法保存的数据都定为 D 类型
    [l_Values addObject:@"D"];
    
    //图片类型的存储图片路径，其他类型不需要使用，保持兼容，存个null
    [l_Values addObject:[NSNull null]];
    
    [[WSOffLineUploadTable sharedTable] insertWithArgumentsValue:l_Values];
}

#pragma mark - pasteboard method

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)recognizer{
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        [self showMenu:self.iLabel];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
//    NSLog(@"action:%@", NSStringFromSelector(action));
    
    if (action == @selector(cut:)) {
        return NO;
    } else if (action == @selector(copy:)) {
        return YES;
    } else if (action == @selector(paste:)) {
        return NO;
    } else if (action == @selector(select:)) {
        return NO;
    } else if (action == @selector(selectAll:)) {
        return NO;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

//显示菜单
- (void)showMenu:(id)view {
    [view becomeFirstResponder];

    UIMenuController * menu = [UIMenuController sharedMenuController];
    [menu setTargetRect: CGRectMake(5, 10, 1, 1) inView: view];
    [menu setMenuVisible: YES animated: YES];
}

- (void)copy:(id)sender {
    NSLog(@"copy:%@", self.iLabel.text);
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[[self iLabel]text]];
}

- (void)dealloc {
    if ([self.mediaViews count] > 0) {
        for (WSMsgContentMediaView *mediaView  in self.mediaViews) {
            NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
            NSString *fileId = [NSString stringNotNilWithValue:mediaView.downLoadFilePath];
            WSMediaInfo *mediaInfo = [mediaView queryMediaInfoFromeDbWithEmpId:empId fileId:fileId];
            if ([mediaInfo getMediaDownloadStatus] == 1) {
                // 页面disapper的时候 正在下载的取消
                [mediaView.downloadExecutor   excuterCancel];
            }
        }
    }

}

@end
