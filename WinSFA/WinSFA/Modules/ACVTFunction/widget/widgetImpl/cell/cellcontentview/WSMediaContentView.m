//
//  WSMediaContentView.m
//  WinSFA
//
//  Created by winchannel on 15/4/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMediaContentView.h"
#import "WSConstant.h"
#import "I_W_Cell.h"
#import "I_W_BuildInfo.h"
#import "IAttachment.h"
#import "WSInterAction.h"
#import "NSString+Util.h"
#import "WSInterActionForTableCell.h"
#import "WSMediaInfo.h"

#import "WSApplicationContext.h"

@interface WSMediaContentView (private)

-(void)doDownload;

-(void)doPlay;
@end

@implementation WSMediaContentView

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        interactiondict =[[NSMutableDictionary alloc] init];
        
        self.leftView =(WSWidget *)[[UIImageView alloc] initWithFrame:WSRect(5, 5, 60 , 60)];
        
        [self addSubview:self.leftView];
        
        self.mainView = (WSWidget *)[[UILabel alloc] initWithFrame:WSRect(self.leftView.frame.origin.x+self.leftView.frame.size.width+3.0,self.leftView.frame.origin.y,self.frame.size.width-150,30.0)];
        
        [self addSubview:self.mainView];
        
        self.assisantView =(WSWidget *)[[UILabel alloc] initWithFrame:WSRect(self.mainView.frame.origin.x, self.mainView.frame.origin.y+self.self.mainView.frame.size.height+5.0, 200.0,20.0)];
        
        [self addSubview:self.assisantView];
        
        self.rightView = (WSWidget *)[UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.rightView setUserInteractionEnabled:NO];
        
        self.rightView.frame = WSRect(self.mainView.frame.origin.x+self.mainView.frame.size.width+10.0,self.mainView.frame.origin.y,50,50);
        
        [self addSubview:self.rightView];
        
        [self setFrame:WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 70)];
        
        downloadIndView =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        [downloadIndView setFrame:WSRect(self.rightView.frame.origin.x, self.rightView.frame.origin.y+self.rightView.frame.size.height+2.0, self.rightView.frame.size.width, 10.0)];
        
        [downloadIndView setHidden:YES];
        
        [self addSubview:downloadIndView];

        return self;
    }
    return nil;
}


-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    
}

-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    
}

-(void)clearContent{
    
    [(UILabel *)self.mainView  setText:@""];
    
    [(UILabel *)self.assisantView setText:@""];
    
    [(UIImageView *)self.leftView setImage:nil];
    
}

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)content{
    
    self.contentArray = (NSMutableArray *)[content getCellContentArray];
    
    NSObject<I_W_BuildInfo> *mainBuildInfo = [self getBuildInfoByType:1]; //主标题
    
    [(UILabel *)self.mainView setText:[mainBuildInfo getQuestName]];
    
    NSObject<I_W_BuildInfo> *assistantBuildInfo = [self getBuildInfoByType:2]; //副标题
    
    [(UILabel *)self.assisantView setText:[assistantBuildInfo getQuestName]];
    
    NSObject<I_W_BuildInfo> *rightBuildInfo = [self getBuildInfoByType:4];//右标题
    
    NSString *path  =[rightBuildInfo getDefaultValue];
    
    NSInteger index = [path indexOfString:@"."];
    
    NSString  *prefix =[path substringFromIndex:index+1];
    
    NSString  *icon_img_name = [NSString stringWithFormat:@"%@.png",prefix];
    
    mediaType = prefix;
    
    [(UIImageView *)self.leftView setImage:[UIImage imageNamed:icon_img_name]];
    
    NSObject<IAttachment> *mediaInfo = [rightBuildInfo getMediaInfo]; //获取媒体信息
    
    if([mediaInfo getMediaDownloadStatus]==2){
        dowloadedAttachment =mediaInfo;
    }
    
    [self setImageBtnStatusAndEvent:mediaInfo];
    
}

-(void)setImageBtnStatusAndEvent:(NSObject<IAttachment> *)mediaInfo{
    NSString *status_png_name;
    

    
    [(UIButton *)self.rightView removeTarget:self action:@selector(doDownload) forControlEvents:UIControlEventTouchUpInside];
    [(UIButton *)self.rightView removeTarget:self action:@selector(doPlay) forControlEvents:UIControlEventTouchUpInside];
    
    if (mediaInfo==nil) {
        
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"needdownload"];
        
        [downloadIndView setHidden:YES];
        
        [(UIButton *)self.rightView setImage:[UIImage imageNamed:status_png_name] forState:UIControlStateNormal];
        
        [(UIButton *)self.rightView addTarget:self action:@selector(doDownload) forControlEvents:UIControlEventTouchUpInside];
        
        return;
    }
    

    if ([mediaInfo getMediaDownloadStatus]==0) {  //未下载
        
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"needdownload"];
        [downloadIndView setHidden:YES];
        
        [(UIButton *)self.rightView addTarget:self action:@selector(doDownload) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([mediaInfo getMediaDownloadStatus]==1) { //正在下载
        
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"download"];
        
        [downloadIndView setHidden:NO];
    }
    if ([mediaInfo getMediaDownloadStatus]==2) { //下载成功
        
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"playbtn"];
        [downloadIndView setHidden:YES];
        
        [(UIButton *)self.rightView addTarget:self action:@selector(doPlay) forControlEvents:UIControlEventTouchUpInside];
        
        [(UIButton *)self.rightView setUserInteractionEnabled:YES];
        
    }
    if ([mediaInfo getMediaDownloadStatus]==3) { //下载失败
        
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"needdownload"];
        
        [downloadIndView setHidden:YES];
        
        [(UIButton *)self.rightView setUserInteractionEnabled:YES];
        
        [(UIButton *)self.rightView addTarget:self action:@selector(doDownload) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    [(UIButton *)self.rightView setImage:[UIImage imageNamed:status_png_name] forState:UIControlStateNormal];
}


// override the super class method

-(void)updateContent:(NSObject *)content{
 
    WSInterActionForTableCell  *interaction = (WSInterActionForTableCell *)content;
    
    NSObject<I_W_BuildInfo> *buildInfo = (NSObject<I_W_BuildInfo> *)[interaction execute_result];
            
    NSObject<IAttachment> *attachment = [buildInfo getMediaInfo];
    
    [downloadIndView setHidden:NO];
            
    [downloadIndView setProgress:[attachment getDownloadPercent]];
            
    if ([attachment getDownloadPercent]==1.0 && [attachment getMediaDownloadStatus]==2) {
                
                [downloadIndView setHidden:YES];
                
                [downloadIndView setProgress:0.0];
                
        
                
    }
    
    dowloadedAttachment = attachment;
            
    [self setImageBtnStatusAndEvent:attachment];
    
}


#pragma mark -
#pragma mark private method

-(void)doDownload{
    
    WSInterActionForTableCell *interaction =[self getDownloadInterActionWith:@"WSDownloaderService" andMethodname:@"executeFileDownload:"];
    
    currentInterAction = interaction;
    
    [interactiondict setObject:interaction forKey:[interaction subacvtId]];
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
    
    [(UIButton *)self.rightView setUserInteractionEnabled:NO];
    
    [(UIButton *)self.rightView removeTarget:self action:@selector(doDownload) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)doPlay{
    
    WSInterActionForTableCell  *interaction =[[WSInterActionForTableCell alloc] init];
    
    currentInterAction = interaction;
    
    NSObject<I_W_BuildInfo> *rightBuildInfo = [self getBuildInfoByType:4];
    
    [interaction setSubacvtId:[rightBuildInfo getAcvtQstId]];
    
    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    
    [interaction setExecute_class:@"WSMediaViewController"];
    
    [interaction setExecute_class_param:dowloadedAttachment];
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
    
}

-(void)resetViewContent{
    
    [self.rightView setUserInteractionEnabled:YES];
    
    
}


-(void)onChangeEvent{
    
    WSInterActionForTableCell *interaction =[self getDownloadInterActionWith:@"WSDownloaderService" andMethodname:@"executeGetFileStatus:"];
    
    currentInterAction = interaction;
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
}

-(WSInterActionForTableCell *)getDownloadInterActionWith:(NSString *)classname andMethodname:(NSString *)methodname{
    
    
    WSInterActionForTableCell  *interaction =[[WSInterActionForTableCell alloc] init];
    
    NSObject<I_W_BuildInfo> *rightBuildInfo = [self getBuildInfoByType:4];
    
    [interaction setSubacvtId:[rightBuildInfo getAcvtQstId]];
    
    [interaction setDirect_type:DIRECT_TYPE_SERVICE_METHOD];
    
    [interaction setViewId:self.assignedViewId];
    
    [interaction setExecute_class:classname];
    
    [interaction  setExecute_method_ns:methodname];
    
    NSObject<IAttachment>  *mediaInfo =[rightBuildInfo getMediaInfo];
    
    if (mediaInfo==nil) {
        
        WSMediaInfo *mediaInfo =[[WSMediaInfo alloc] init];
        
        NSString  *subpath = [[rightBuildInfo getDefaultValue] stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        
        NSString *downloadFilePath =[NSString stringWithFormat:@"%@%@",[WSApplicationContext getServerIp],subpath];
        
        [mediaInfo setMedia_file_id:downloadFilePath];
        
        [mediaInfo setMedia_file_type:mediaType];
        
        [mediaInfo setMedia_file_url:downloadFilePath];
        
        [mediaInfo setForce_read_time_for_page:@"10"];
        
        NSObject<I_W_BuildInfo> *mainBuildInfo = [self getBuildInfoByType:1]; //主标题
        
        [mediaInfo setMedia_file_name:[mainBuildInfo getQuestName]];
     
        [rightBuildInfo setI_Media_Info:mediaInfo];
        
    }
    
    [interaction setInner_param:rightBuildInfo];
    
    [interaction setExecute_method_param:interaction];
    
    return interaction;
}

- (id)copyWithZone:(NSZone *)zone{
    
    WSMediaContentView  *copyobj = self;
    
    return copyobj;
}


@end

