//
//  WSMessageDetailFileCell.m
//  WinSFA
//
//  Created by mac on 17/2/8.
//  Copyright © 2017年 WinChannel. All rights reserved.
//
#import "PureLayout.h"

#define CELL_HIGHT  44.0
#define SPACE  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 5 : 5)
#define LABLE_HEIGHT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15 : 15)
#define FONT_SIZE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 14)
#define TEXT_COLOR [UIColor colorWithHexString:@"#cbcbcb"]
#define FILENAME_COLOR [UIColor colorWithHexString:@"#646464"]
#define FONT_NAME @"Heiti SC"
#define TIME_FONT_NAME @"Arial"
#import "WSMessageDetailFileCell.h"
#import "WSMsgContentMediaView.h"
#import "WCDownLoadingAndShowingImageView.h"
#import "WSMsgContentMediaView.h"
#import "WSServiceDispatcher.h"
#import "WCBaseViewController.h"
#import "WSMsgsBean_Component_msg.h"
#import "NSString+ServerUrl.h"

@interface WSMessageDetailFileCell ()<WSWidgetDelegate,WCBaseViewControllerDelegate>

@property (nonatomic , strong) UILabel * fileNameLabel;
@property (nonatomic , strong) UILabel * sizeLable;
@property (nonatomic , strong) UILabel * downloadStatLable;
@property (nonatomic, strong) WSServiceDispatcher *serviceDispatcher;
@property (nonatomic , strong) NSLayoutConstraint * fileNameLabelTopConsteaint;

@end

@implementation WSMessageDetailFileCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showIndicatorImage = NO;
        [self setUpSubViews];
    }
    return self;
}

-(void)setUpSubViews{
   
    self.iconImgView = [[WSMsgContentMediaView alloc] initWithFrame:CGRectMake(0, 2 *SPACE, cell_Height_For_Row - 4*SPACE, cell_Height_For_Row - 4*SPACE)  msg:nil];
    self.iconImgView.delegate = self;
    
    self.fileNameLabel = [UILabel newAutoLayoutView];
    self.fileNameLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE];
    self.fileNameLabel.numberOfLines = 2;
    self.fileNameLabel.textColor =  FILENAME_COLOR ;
    self.sizeLable = [UILabel newAutoLayoutView];
    self.sizeLable.font = [UIFont fontWithName:TIME_FONT_NAME size:FONT_SIZE];
    self.sizeLable.textColor = TEXT_COLOR;
    self.downloadStatLable = [UILabel newAutoLayoutView];
    self.downloadStatLable.font = [UIFont systemFontOfSize:FONT_SIZE];
    self.downloadStatLable.textColor = TEXT_COLOR;
    self.downloadStatLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.fileNameLabel];
    [self.contentView addSubview:self.sizeLable];
    [self.contentView addSubview:self.downloadStatLable];

    self.fileNameLabelTopConsteaint =  [self.fileNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:SPACE];
    [self.fileNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.iconImgView withOffset:2*SPACE];
    [self.fileNameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:SPACE];
    
    [self.sizeLable autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.fileNameLabel];
    [self.sizeLable autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.fileNameLabel withOffset:SPACE];
    [self.sizeLable autoSetDimension:ALDimensionWidth toSize:60];
    [self.sizeLable autoSetDimension:ALDimensionHeight toSize:LABLE_HEIGHT];

    [self.downloadStatLable autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.sizeLable];
    [self.downloadStatLable autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:SPACE];
    [self.downloadStatLable autoSetDimension:ALDimensionWidth toSize:INTERFACE_IS_PHONE ? 100 : 120];
    [self.downloadStatLable autoSetDimension:ALDimensionHeight toSize:LABLE_HEIGHT];
}


-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    self.fileNameLabel.text = fileName;
    CGSize size ;
    CGSize textSize = CGSizeMake(self.width - 3* SPACE - (cell_Height_For_Row -4 * SPACE), 2000);
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    size =  [fileName boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]} context:nil].size;
#else
    size=[fileName sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
#endif

    if (size.height < 20) {
        [self.fileNameLabelTopConsteaint autoRemove];
        self.fileNameLabelTopConsteaint =  [self.fileNameLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.iconImgView withOffset:-(size.height + SPACE)/2];
    }
}

-(void)setComponent_Msg:(WSMsgsBean_Component_msg *)component_Msg{
    self.iconImgView.msgBean_msg = component_Msg;
    self.iconImgView.bgImage = [self setfileImg:component_Msg.fileUrl];
    [self.iconImgView loadDisplayContent:component_Msg];
    NSString * url = [component_Msg.fileUrl buildupUrl];
    WSMediaInfo *mediaInfo = [[WSMediaInfo alloc] init];

    mediaInfo = [self.iconImgView queryMediaInfoFromeDbWithEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID] fileId:url];
    if ([mediaInfo getMediaDownloadStatus]==2) {
        self.downloadStatLable.text = NSLocalizedString(@"downloaded", nil);
    }else{
        self.downloadStatLable.text = @"";
    }
    __weak typeof(self) weakSelf = self;
    
    self.iconImgView.downLoadFinish = ^(){
        weakSelf.downloadStatLable.text = NSLocalizedString(@"downloaded", nil);
    };
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    NSURLConnection * connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    [connection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    //通过响应头中的Content-Length取得整个响应的总长度
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
    long long totalLength = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    self.sizeLable.text = [self convertFileSize:totalLength];
    [connection cancel];
}

// 转换文件大小
-(NSString *)convertFileSize:(long long)size{
    long long kb = 1024;
    long long mb = kb * 1024;
    long long gb = mb * 1024;
    
    if (size >= gb) {
        return [NSString stringWithFormat:@"%.1f GB", (float) size / gb];
    } else if (size >= mb) {
        float f = (float) size / mb;
        NSString * format = f > 100 ? @"%.0f MB" : @"%.1f MB";
        return [NSString stringWithFormat:format,f];
    } else if (size >= kb) {
        float f = (float) size / kb;
        NSString * format = f > 100 ? @"%.0f KB" : @"%.1f KB";
        return [NSString stringWithFormat:format,f];
    } else
        return [NSString stringWithFormat:@"%lld B", size];
}
#pragma mark WSWidgetDelegate Method
-(void)executeAnyOperationWith:(WSInterAction *)interaction {
    if (interaction == nil) {
        return;
    }
    if ([interaction direct_type] == DIRECT_TYPE_SERVICE_METHOD) {
        _serviceDispatcher = [[WSServiceDispatcher alloc] init];
        [_serviceDispatcher executeDispatcher:interaction];
    } else if ([interaction direct_type] == DIRECT_TYPE_PRESENT) {
        WCBaseViewController  *execute_controller = [[NSClassFromString([interaction execute_class]) alloc] init];
        execute_controller.executeParam = interaction;
        execute_controller.wcBaseViewdelegate = self;
        [self.viewController.navigationController presentViewController:execute_controller animated:YES
                                              completion:nil];
    } else if ([interaction direct_type] == DIRECT_TYPE_PUSH) {
        WCBaseViewController  *execute_controller = [[NSClassFromString([interaction execute_class]) alloc] init];
        execute_controller.executeParam = interaction;
        execute_controller.wcBaseViewdelegate = self;
        [self.viewController.navigationController pushViewController:execute_controller animated:YES];
    }
}


-(UIImage * )setfileImg:(NSString *)urlStr{
    
    NSRange range = NSRangeFromString(urlStr);
    range.length = range.length - 3;
    
    NSString * message = [urlStr substringFromIndex:(urlStr.length - 3)];
//    _imageType = [NSString stringWithFormat:@"%@",message];
    if ([message isEqualToString:@"ocx"] || [message isEqualToString:@"doc"]) {
        return [UIImage imageNamed:@"icon_file_doc"];
    }
    else if ([message isEqualToString:@"pdf"]){
        return [UIImage imageNamed:@"icon_file_pdf"];
    }
    else if ([message isEqualToString:@"ppt"] || [message isEqualToString:@"ptx"]){
        return [UIImage imageNamed:@"icon_file_ppt"];
    }
    else if ([message isEqualToString:@"lsx"] || [message isEqualToString:@"xls"]){
        return [UIImage imageNamed:@"icon_file_xls"];
    }
    else if ([message isEqualToString:@"jpg"]  || [message isEqualToString:@"JPG"]){
        return [UIImage imageNamed:@"icon_file_jpg"];
    }else if ([message isEqualToString:@"jpeg"]  || [message isEqualToString:@"JPEG"]){
        return [UIImage imageNamed:@"icon_file_jpeg"];
    }else if ([message isEqualToString:@"png"] || [message isEqualToString:@"PNG"]){
        return [UIImage imageNamed:@"icon_file_png"];
    }else if ([message isEqualToString:@"gif"] || [message isEqualToString:@"GIF"]){
        return [UIImage imageNamed:@"icon_file_gif"];
    }else if ([message isEqualToString:@"bmp"] || [message isEqualToString:@"BMP"]){
        return [UIImage imageNamed:@"icon_file_bmp"];
    }else{
        
    }
    return nil;
}
@end
