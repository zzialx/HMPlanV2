//
//  WSPhotoTypeView.m
//  WinSFA
//
//  Created by yang on 13-12-10.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSPhotoTypeView.h"
#import "WSPhotoTypeItem.h"
#import "WSPhotoGalleryViewController.h"
#import "WSPhotoTypeArrayItem.h"

#define kCellHeight 40.0

@interface WSPhotoTypeView ()<UITableViewDataSource,UITableViewDelegate,PhotoGalleryViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation WSPhotoTypeView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andPhotoTypeArrayItem:nil];
}

- (id)initWithFrame:(CGRect)frame andPhotoTypeArrayItem:(WSPhotoTypeArrayItem *)item
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if (item) {
            self.photoTypeArrayItem = item;
            
            self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            self.tableView.backgroundView = nil;
            self.tableView.backgroundColor = [UIColor clearColor];
            self.tableView.delegate = self;
            self.tableView.dataSource =self;
            
            self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, frame.size.height);
            self.tableView.scrollEnabled = NO;
            
            [self addSubview:self.tableView];
        }
        
    }
    return self;
}

+ (CGFloat)getViewHeightWithItemCount:(NSInteger)count
{
    return kCellHeight * count;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LogTrace();
    LogInfo(@"[self className]----%@",[self className]);
    return [self.photoTypeArrayItem.photoTypeItemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTrace();
    static NSString *identify = @"photoTypeTableView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
//        view.tag = 4444;
//        view.backgroundColor = [UIColor blackColor];
//        [cell.contentView addSubview:view];
    }
    
    WSPhotoTypeItem *item = [self.photoTypeArrayItem.photoTypeItemArray objectAtIndex:indexPath.row];
    cell.textLabel.text = item.typeName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu 张", (unsigned long)[item.photoIDArray count]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    WSPhotoTypeItem *item = [self.photoTypeArrayItem.photoTypeItemArray objectAtIndex:indexPath.row];
    
    WSPhotoGalleryViewController *pgVc = [[WSPhotoGalleryViewController alloc] initWithImageIDArray:item.photoIDArray];
    pgVc.storeName = self.currentStore.name;
    pgVc.delegate = self;
    if (self.viewController) {
        [self.viewController.navigationController pushViewController:pgVc animated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoTypeView:didSelectedIndex:)]) {
        [self.delegate photoTypeView:self didSelectedIndex:indexPath.row];
    }
}

#pragma mark - PhotoGalleryViewControllerDelegate

- (void)photoGalleryDeletePhoto:(WSPhotoGalleryViewController *)photoGallery
{
    LogTrace();
    _isValueChange = YES;
    [self.tableView reloadData];
}

- (void)photoGallery:(WSPhotoGalleryViewController *)photoGallery addImage:(NSString *)imageID
{
    LogTrace();
    _isValueChange = YES;
    [self.tableView reloadData];
}

@end
