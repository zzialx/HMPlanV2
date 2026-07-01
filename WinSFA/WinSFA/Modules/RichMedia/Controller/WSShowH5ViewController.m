//
//  WSShowH5ViewController.m
//  WinSFA
//
//  Created by mac on 16/9/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSShowH5ViewController.h"
#import "WSRichMediaTable.h"
#import "PureLayout.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "QRCodeGenerator.h"
#import "WSRichMediaTemplateTable.h"
#import "WSRichMediaTemplate.h"
#import <WebKit/WebKit.h>

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@interface WSShowH5ViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) WKWebView *webView;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic , strong)UIView * QRView;

@property(nonatomic,strong) UIButton * shareButton;

@property(nonatomic,strong) UIImageView * imageview;

@property(nonatomic,strong) UIView *jingQingQiDai;

@property(nonatomic,assign) BOOL isShow;

@property(nonatomic,strong) WSRichItemModel *richItem;

@property(nonatomic,strong) UIButton *shouChang;
@end

@implementation WSShowH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)itemClickCallH5WithItemModel:(WSRichItemModel *)item{
    UIButton * closeBtn = [[UIButton alloc] init];
    //    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(clickedCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.closeBtn = closeBtn;
    _QRView = [[UIView alloc]init];
    _QRView.backgroundColor = [UIColor whiteColor];
    _imageview = [[UIImageView alloc]init];
    
    _isShow = NO;
    
    if (item.share_url && item.share_url.length > 0) {
        _shareButton = [[UIButton alloc]init];
        [_shareButton setImage:[UIImage imageNamed:@"fenxiang.png"] forState:UIControlStateNormal];
//        _shareButton.backgroundColor = [UIColor colorWithHexString:@"008000"];
//        _shareButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_shareButton addTarget:self action:@selector(showQRImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.richItem = item;
    NSRange l_range = [item.h5_add rangeOfString:@"."];
 
    if (!item.h5_add || [item.h5_add isEqualToString:@""] || l_range.location != NSNotFound) {
        
        _jingQingQiDai = [[UIView alloc]init];
        _jingQingQiDai.backgroundColor = [UIColor redColor];
        [self.view addSubview:_jingQingQiDai];
        UIImageView * bgImageView = [[UIImageView alloc]init];
        bgImageView.image = [UIImage imageNamed:@"jqqd"];
        
        [_jingQingQiDai addSubview:bgImageView];
        
        [bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        
        [_jingQingQiDai autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
        [_jingQingQiDai addSubview:self.closeBtn];
        
        [self.closeBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.closeBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
        [self.closeBtn autoSetDimension:ALDimensionWidth toSize:44];
        [self.closeBtn autoSetDimension:ALDimensionHeight toSize:44];
        
        [_jingQingQiDai addSubview:_shareButton];
        
        [_shareButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
        if (self.shouChang) {
            [_shareButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.shouChang withOffset:10.0];
        }else{
            [_shareButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.closeBtn withOffset:10.0];
        }
        [_shareButton autoSetDimension:ALDimensionWidth toSize:44];
        [_shareButton autoSetDimension:ALDimensionHeight toSize:44];
        
    }else{
        
        _webView = [[WKWebView alloc] init];
        [self.view addSubview:_webView];
        [_webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(isHiddenQRImage)];
        recognizer.delegate = self;
        [_webView addGestureRecognizer:recognizer];
        [_webView addSubview:self.closeBtn];
        [self.closeBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.closeBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
        [self.closeBtn autoSetDimension:ALDimensionWidth toSize:44];
        [self.closeBtn autoSetDimension:ALDimensionHeight toSize:44];
        if ([self.filterName isEqualToString:@"渠道方案"] || [self.filterName isEqualToString:@"灵感菜谱"] ||[self.filterName isEqualToString:@"我的收藏"]) {
            
            self.shouChang = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.shouChang setImage :[UIImage imageNamed:@"shouchang_kong"] forState:UIControlStateNormal];
            [self.shouChang setImage :[UIImage imageNamed:@"shouchang_quan"] forState:UIControlStateSelected];
            NSArray * array = [[WSRichMediaTemplateTable sharedTable ]queryAndReturnInfosBySql:[NSString stringWithFormat:@"select * from spe_richMedia_template where sid = '%@' and type = 'bookmark'",self.richItem.ID] andClassName:@"WSRichMediaDemoList"];
            if (array.count > 0) {
                self.shouChang.selected = YES;
            }else{
                self.shouChang.selected = NO;
            }
            [self.shouChang addTarget:self action:@selector(shouchangOrNot:) forControlEvents:UIControlEventTouchUpInside];
            [_webView addSubview:self.shouChang];
            [self.shouChang autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.closeBtn withOffset:10.0];
            [self.shouChang autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
            [self.shouChang autoSetDimension:ALDimensionWidth toSize:44];
            [self.shouChang autoSetDimension:ALDimensionHeight toSize:44];
        }
        
        
        
        [_webView addSubview:_shareButton];
        [_shareButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
        if (self.shouChang) {
            [_shareButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.shouChang withOffset:10.0];
        }else{
            [_shareButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.closeBtn withOffset:10.0];
        }
        
        [_shareButton autoSetDimension:ALDimensionWidth toSize:44];
        [_shareButton autoSetDimension:ALDimensionHeight toSize:44];
        
        
        
        NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@/index.html",CACHE_DIR,item.h5_add];
        NSURL *url = [NSURL URLWithString:imgStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
        
    }


}
-(void)clickedCloseBtn:(UIButton *)sender
{
    
//    [self.closeBtn removeFromSuperview];
//    if (self.webView != nil) {
//        [self.webView removeFromSuperview];
//    }
//    
//    if (self.jingQingQiDai != nil) {
//        [self.jingQingQiDai removeFromSuperview];
//    }
//    
//    if (self.shouChang != nil) {
//        [self.shouChang removeFromSuperview];
//    }
//    
//    if (self.shareButton != nil) {
//        [self.shareButton removeFromSuperview];
//    }
//    
//    if (self.QRView != nil) {
//        [self.QRView removeFromSuperview];
//    }
    
    [[WSRichMediaTable sharedTable] updateWithNames:@[@"isread"] values:@[@"1"] whereName:@[@"ID"] whereValue:@[self.richItem.ID]];
    
    if (self.reloadBlock) {
        self.reloadBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)showQRImage{
    if (self.richItem.share_url.length > 0) {
        if (_jingQingQiDai != nil ) {
            [_jingQingQiDai addSubview:_QRView];
        }else{
            [_webView addSubview:_QRView];
        }
    }else{
        return;
    }
    [_QRView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:54];
    [_QRView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_shareButton];
    [_QRView autoSetDimension:ALDimensionWidth toSize:140];
    [_QRView autoSetDimension:ALDimensionHeight toSize:140];
    _QRView.hidden = _isShow;
    _isShow = !_isShow;
    
    [_QRView addSubview:_imageview];
    [_imageview autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    NSString * serverurl ;
    WSServerIPList *svip = [WSAppData getObjectbyKey:SERVERURL];
    if (svip && svip.serverIPArray && [svip.serverIPArray count]) {
        WSServerIPController *serverIP = [svip.serverIPArray objectAtIndex:0];
        serverurl = serverIP.ServerIPString;
    }
    NSString * qrUrl ;
    if ([self.richItem.share_url containsString:@"http"]) {
        qrUrl = self.richItem.share_url;
    }else{
        qrUrl = [NSString stringWithFormat:@"%@%@",serverurl,self.richItem.share_url];
    }
    _imageview.image = [QRCodeGenerator qrImageForString:qrUrl imageSize:130];
}

-(void)isHiddenQRImage{
    
    _QRView.hidden = YES;
    _isShow = NO;
}

-(void)shouchangOrNot:(UIButton *)sender{
    
    BOOL isSelect  = !sender.selected;
    [self shouchangOrNotByDB:isSelect];
}

-(void)shouchangOrNotByDB:(BOOL)insertOrDelete{
    
    NSArray * countArray = [[WSRichMediaTemplateTable sharedTable ]queryAndReturnInfosBySql:[NSString stringWithFormat:@"select * from spe_richMedia_template where type = 'bookmark'"] andClassName:@"WSRichMediaDemoList"];
    if (insertOrDelete) { // 收藏
        
        
        if (countArray.count > 60) {
            NSString *title = NSLocalizedString(@"书签数量已达上限", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }else{
            self.shouChang.selected = insertOrDelete;
            [[WSRichMediaTemplateTable sharedTable ] insertWithSqls:@[[NSString stringWithFormat:@"insert into spe_richMedia_template (type,sid) values('bookmark','%@')",self.richItem.ID]]];
        }
    }else{ // 删除
        if (countArray.count != 0) {
            
            self.shouChang.selected = insertOrDelete;
            [[WSRichMediaTemplateTable sharedTable ] deleteProdstWithSqls:@[[NSString stringWithFormat:@"delete from spe_richMedia_template where type = 'bookmark' and sid = '%@'",self.richItem.ID]]];
        }
        
    }
    
}
#pragma mark UIGestureRecognizerClick

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer

{
    
    return YES;
    
}

@end
