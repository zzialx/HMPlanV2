//
//  WSDetailFileDownLoadView.m
//  WinSFA
//
//  Created by mac on 17/2/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDetailFileDownLoadView.h"
#import "WSMsgContentMediaView.h"
@interface WSDetailFileDownLoadView ()
@property(nonatomic,strong)NSArray * fileArray;
@property(nonatomic,strong)NSArray * fileNameArray;

@end

@implementation WSDetailFileDownLoadView

-(instancetype)initWithFrame:(CGRect)frame withFiles:(NSArray *)Files addFileNames:(NSArray *)fileNames{
    if (self = [super initWithFrame:frame]) {
        _fileArray = Files;
        _fileNameArray = fileNames;
        UITableView * tableView = [[UITableView alloc]initWithFrame:self.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
    }
    return self;
}


#pragma mark -   UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 防止数据不同导致崩溃
    return _fileArray.count > _fileNameArray.count ? _fileNameArray.count :_fileArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return cell_Height_For_Row;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserId = @"fileTableViewCell";
    WSMessageDetailFileCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (!cell) {
        cell = [[WSMessageDetailFileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }
    if (_fileArray.count > indexPath.row) {
        cell.fileName = _fileNameArray[indexPath.row];
    }
    cell.component_Msg = _fileArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WSMessageDetailFileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.iconImgView.downloadButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
@end
