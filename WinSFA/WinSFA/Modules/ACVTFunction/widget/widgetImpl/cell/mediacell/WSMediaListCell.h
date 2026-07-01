//
//  WSMediaPanel.h
//  WinSFA
//
//  Created by winchannel on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"

#import <UIKit/UIKit.h>
#import "WSTableViewCell.h"

@class WSMediaContentView;

@protocol I_Media_Info;



typedef enum {
    
    MEDIA_STATU_DOWNLOADED,   //下载
    
    MEDIA_STATU_UNDOWLOADED,  //未下载
    
    MEDIA_STATU_DOWNLOAD_IN_PROGRESS, //下载中

}MEDIA_STATU;

@interface WSMediaListCell : WSTableViewCell{

    WSMediaContentView  *media_content_view;
    
}

@property (nonatomic,strong) WSMediaContentView  *media_content_view;


-(void)clearContent;



@end
