//
//  WSXLSXMediaPanel.m
//  WinSFA
//
//  Created by heju on 15/10/27.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSXLSXMediaPanel.h"
#import <QuickLook/QuickLook.h>

@interface WSXLSXMediaPanel ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property (nonatomic, strong) QLPreviewController *previewController;

@end

@implementation WSXLSXMediaPanel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}


-(void)buildDisplayContent{
    
    _previewController = [[QLPreviewController alloc] init];
    _previewController.dataSource = self;
    _previewController.delegate = self;
    
    _previewController.currentPreviewItemIndex = 0;
    [_previewController setTitle:@""];
}


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSInteger numToPreview = 1;
    
    return numToPreview;
}


- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx{
    NSString *fillPath = [media_info getMediaFileSavePath];
    if (@available(iOS 14.0, *)) {
            NSURL *fileURL  = [NSURL fileURLWithPath:fillPath];
            return fileURL;
        }

    NSURL *fileURL  = [[NSURL alloc] initFileURLWithPath:fillPath isDirectory:YES];
    
    return fileURL;
}


- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    if ([delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
        
        [delegate executeAnyOperationWith:currentInterAction];
        
    }
}


//执行媒体播放
-(void)playTheMeida{
    [self.parentViewController  presentViewController:_previewController animated:YES completion:nil];
}

@end
