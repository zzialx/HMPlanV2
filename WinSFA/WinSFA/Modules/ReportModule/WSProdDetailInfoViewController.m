//
//  WSProdDetailInfoViewController.m
//  WinSFA
//
//  Created by yang on 13-12-11.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSProdDetailInfoViewController.h"
#import "WCDownLoadingAndShowingImageView.h"
#import "WSRequestHelper.h"

#define kCellHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 30.0f : 40.0f)
#define kTableViewLeftGap ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 2.0f : 50.0f)
#define kImageViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 200.0f : 300.0f)

@interface WSProdDetailInfoViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy)NSString *imageURL;

@end

@implementation WSProdDetailInfoViewController

- (id)initWithImageURL:(NSString *)aUrl andProductInfo:(NSArray *)productInfo
{
    self = [super init];
    if (self) {
        // Initialization code
        if (aUrl) {
            self.imageURL = aUrl;
        }
        
        if (productInfo) {
            self.dataArray = productInfo;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"prod_info", nil);
    
    BOOL hasPhoto = NO;
    
    if (self.imageURL && [self.imageURL length] > 0) {
        hasPhoto = YES;
    }
    
    CGFloat y = 10;
    if (hasPhoto) {
        
//        WCDownLoadingAndShowingImageView *imageView = [[WCDownLoadingAndShowingImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, kImageViewHeight) withImageURL:self.imageURL withProductName:nil];
//        imageView.removeOnTouch = NO;
//        imageView.refreshLoadingOnTouch = YES;
//        imageView.isShowCloseButton = NO;
//        imageView.clipsToBounds = NO;
//        imageView.backgroundColor = [UIColor whiteColor];
        //Ipad版需要做适配
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, kImageViewHeight)];
        __weak __typeof(tmpImageView) weakTmpImageView = tmpImageView;
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:self.imageURL imageView:tmpImageView placeholderImage:[UIImage imageNamed:@"picture_loading"] progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            if(error){
                weakTmpImageView.image=[UIImage imageForName:@"picture_loading_failed"];
            }
        }];
        [self.view addSubview:tmpImageView];
        
        y += kImageViewHeight + 10;
    }

    CGFloat height = self.view.bounds.size.height - y - (IOS7_OR_LATER ? 64.0 : 44.0);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(kTableViewLeftGap, y, self.view.bounds.size.width - kTableViewLeftGap * 2, height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"productInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


@end
