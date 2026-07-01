//
//  WSDisplayDoc.m
//  WinSFA
//
//  Created by winchannel on 15/4/27.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDisplayDoc.h"
#import "WSMappingObject.h"
#import "NSString+ServerUrl.h"
#import "WSDocDownLoadVController.h"
#import "WSDownloadFileTable.h"
#define TABLEVIEW_ROW_HEIGHT 44
#define TEXT_COLOR [UIColor colorWithHexString:@"666666"]
@interface WSDisplayDoc ()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
{
    UITableView * _tableView;
    NSMutableArray * _datasource;

}

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation WSDisplayDoc


-(void)widgetWillAppear{
    [super widgetWillAppear];
    [self getdatasourceWith:(WSAcvtBean_qst*) xbuildInfo];
    [_tableView reloadData];

}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    return nil;
    
}

- (void)dealloc {
    _tableView.delegate = nil;
}

-(void)buildDisplayContent{
    [super buildDisplayContent];
    
    WSAcvtBean_qst * buildInfo = (WSAcvtBean_qst*) xbuildInfo;
    [self getdatasourceWith:buildInfo];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, _datasource.count * TABLEVIEW_ROW_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:_tableView];
    [self setFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, _datasource.count * TABLEVIEW_ROW_HEIGHT)];
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    
}
// 获取需要下载的文档资源
-(void)getdatasourceWith:(WSAcvtBean_qst *)buildInfo{
    _datasource = [[NSMutableArray alloc]initWithCapacity:0];

    NSString * defaultValue = buildInfo.defaultValue;
    NSArray * sourceArray = nil;
    if (defaultValue && defaultValue.length > 0) {
        sourceArray = [defaultValue componentsSeparatedByString:@","];
        if (sourceArray.count > 0) {
            for (NSString * fileUrl in sourceArray) {
                WSDownloadFileObject *object = [[WSDownloadFileObject alloc]init];
                
                if ([fileUrl hasPrefix:@"/"]){
                    object.file_name = [[fileUrl componentsSeparatedByString:@"/"] lastObject];
                } else if ([fileUrl hasPrefix:@"\\"]) {
                    object.file_name = [[fileUrl componentsSeparatedByString:@"\\"] lastObject];
                }
                
                object.file_url = [WSHttpURLHelper getImageCompleteURL:fileUrl];
                
                NSArray * array =   [[WSDownloadFileTable sharedTable] queryWithFileURL:object.file_url];
                if (array  &&  array.count == 0) {
                    object.file_download_status = @"1";
               
                    [[WSDownloadFileTable sharedTable] insertWithFileURL:object.file_url status:@"1" file_szie:@0 downloadSize:@0 fileName:object.file_name];
                    
                }else{
                    object = [array firstObject];
                }
                [_datasource addObject:object];
                
            }
        }
    }


}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString * reuserId = @"WSDisplayDocTableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserId];
    }
    WSDownloadFileObject *object =  _datasource[indexPath.row];
    cell.textLabel.text = object.file_name;
    cell.textLabel.textColor = TEXT_COLOR;
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    if ([object.file_download_status isEqualToString:@"4"]) { // 如果数据库中的文件下载状态为4 则显示文件大小 点击直接打开
        cell.detailTextLabel.text = [self convertFileSize:object.file_length.longLongValue];
    }else{
        cell.detailTextLabel.text =@"";

    }
    cell.detailTextLabel.textColor = TEXT_COLOR;
    
    UIImage *icon =[self getFileImageWith:object.file_name];
    //设置imageView的大小宽、高
    CGSize itemSize = CGSizeMake(32, 36);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.accessoryView  =  [[UIImageView alloc]initWithImage:[UIImage scaledImageForName:@"arrow_right" ofType:@"png"]];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datasource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return TABLEVIEW_ROW_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WSDownloadFileObject * object =  _datasource[indexPath.row];
    
    if ([object.file_download_status isEqualToString:@"4"]) {
        [self playActionWith:object];
    }else{
        WSDocDownLoadVController * control = [[WSDocDownLoadVController alloc] init];
        control.downLoadFileObject = object;
        control.back = ^(){
            [self getdatasourceWith:(WSAcvtBean_qst*) xbuildInfo];
            [_tableView reloadData];
        };
        [self.viewController.navigationController pushViewController:control animated:YES];

    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IOS7_OR_LATER) {
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
}
// 播放文件
-(void)playActionWith:(WSDownloadFileObject *)object{
    
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filepath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"downloadfile"]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filepath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    
    NSString * _filePath = [NSString stringWithFormat:@"%@/%@",filepath,object.file_name];
    NSURL * fileUrl =  [[NSURL alloc]initFileURLWithPath:_filePath];

    if (fileUrl) {
        // MSTD-6964
        [[UINavigationBar appearance] setTranslucent:YES];
        
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
        
        [self.documentInteractionController setDelegate:self];
        
        [self.documentInteractionController presentPreviewAnimated:YES];
        
    }
    
}

#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self.viewController;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [[UINavigationBar appearance] setTranslucent:NO];
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

// 获取文件类型的图片
-(UIImage * )getFileImageWith:(NSString *)fileName{
    NSString * fileType = [[fileName componentsSeparatedByString:@"."] lastObject];
    UIImage * image ;
    if ([fileType hasPrefix:@"ppt"]) {
        image = [UIImage scaledImageForName:@"icon_file_ppt" ofType:@"png"];
    }else if ([fileType hasPrefix:@"doc"]){
        image = [UIImage scaledImageForName:@"icon_file_doc" ofType:@"png"];
        
    }else if ([fileType hasPrefix:@"xls"]){
        image = [UIImage scaledImageForName:@"icon_file_xls" ofType:@"png"];
        
    }else if ([fileType hasPrefix:@"pdf"]){
        image = [UIImage scaledImageForName:@"icon_file_pdf" ofType:@"png"];
        
    }else if ([fileType hasPrefix:@"mp4"]){
        image = [UIImage scaledImageForName:@"mp4" ofType:@"png"];
        
    }else{
        image = [UIImage imageNamed:@"file.png"];
        
    }
    return  image;
    
}
@end
