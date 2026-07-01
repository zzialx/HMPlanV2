//
//  ProdListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSProdListViewController.h"
#import "WSDictBean.h"
#import "WSDictBrand.h"
#import "WSProdBean.h"
#import "WSAppData.h"
#import "AsyncImageView.h"
//#import "ConfigFileController.h"
#import "WSServerIPController.h"
#import "WSServerIPList.h"
#import "WSRequestHelper.h"
#import "UIImageView+WebCache.h"
#import "WSProdDetailInfoViewController.h"
#import "NSString+ServerUrl.h"
#import "WSSearchBar.h"
#import "WSRequestHelper.h"

#define BACKVIEWTAG                 100
#define IMAGETAG                    101
#define NOTIFY_PRODUCTINFO          @"productInfo"
#define PRODSHOWTYPE_INFO           @"info"
#define PRODSHOWTYPE_PIC            @"pic"

@interface WSProdListViewController()
{
    UIActivityIndicatorView *aiv;
    UIAlertView *serverAlert;
    
    // search
    WSSearchBar *searchBar;
    UISearchDisplayController *searchDC;
    NSArray *searchResultArray;
    UITableView *tableview;
}

@end

@implementation WSProdListViewController

@synthesize  dataArray = _dataArray;
@synthesize  ownParenetViewController = _ownParenetViewController;
@synthesize  tableView = tableView_;


@synthesize prodPicUrl = _prodPicUrl;



-(id)initWithArray:(NSArray*)array
{
    if(array == nil || [array count]==0)
        return nil;
    self = [super init];
    if(self != nil) {
    NSMutableArray* list = [[NSMutableArray alloc]initWithArray:array];
    self.dataArray = list;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



-(void) loadView
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.autoresizesSubviews = YES;
    self.view = view;
    
    tableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableview.backgroundColor = [UIColor whiteColor];
    tableview.backgroundView = nil;
    tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView = tableview;
    
    searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44) isResetTextField:NO isResetBackgroundColor:YES];
    self.tableView.tableHeaderView = searchBar;
    searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar.searchBar contentsController:self] ;
    searchDC.searchResultsDataSource = self;
    searchDC.searchResultsDelegate = self;
    searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == tableview)
    {
        return [self.dataArray count];
    }
    else 
    {
        if (searchBar && searchBar.searchBar.text.length > 0 && self.dataArray.count > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.name contains[cd] %@) or (SELF.cod contains[cd] %@)", searchBar.searchBar.text, searchBar.searchBar.text];
            
            if([[self.dataArray firstObject] isKindOfClass:[WSDictBrand class]]) {
                predicate = [NSPredicate predicateWithFormat:@"(SELF.dictBean.name contains[cd] %@) or (SELF.dictBean.cod contains[cd] %@)", searchBar.searchBar.text, searchBar.searchBar.text];
            }
            searchResultArray = [self.dataArray filteredArrayUsingPredicate:predicate];
        }
        
        if (searchResultArray) {
            return [searchResultArray count];
        }
        return 0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    id object = nil;
    if (tableView == tableview)
    {
        object = [self.dataArray objectAtIndex:indexPath.row];
    }
    else 
    {
        object = [searchResultArray objectAtIndex:indexPath.row];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    if([object isKindOfClass:[WSProdBean class]])
    {
        WSProdBean* pb = (WSProdBean*)object;
                cell.textLabel.text = pb.name;
    }
    
    if([object isKindOfClass:[WSDictBrand class]])
    {
        WSDictBrand* db = (WSDictBrand*)object;
        cell.textLabel.text = db.dictBean.name;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSProdListViewController* lvc;
    id object = nil;
    if (tableView == tableview)
    { 
        object = [self.dataArray objectAtIndex:indexPath.row];
    }
    else
    {
        object = [searchResultArray objectAtIndex:indexPath.row];
    }
    if([object isKindOfClass:[WSDictBrand class]])
    {
        WSDictBrand* db = (WSDictBrand*)object;
        lvc = [[WSProdListViewController alloc]initWithArray:db.subDictBrandsArray];
        lvc.ownParenetViewController = self.ownParenetViewController;
    }else
    {
        if([object isKindOfClass:[WSProdBean class]])
        {
            //  根据配置prods中配置的url来确定产品信息是否要显示图片
            WSProdBean* i_pb = (WSProdBean*)object;
            self.prodPicUrl = i_pb.url;
            
            NSString *LoginfailString = NSLocalizedString(@"querying_message",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:LoginfailString  tips:nil tapTarget:self action:nil];
            
            [self startGetProductInfoByProductId:i_pb.Id];
            
            /* 产品信息只显示图片(以前显示产品信息的一种方式,另一种方式是图片文字都显示)
             WSProdBean* i_pb = (WSProdBean*)object;
             if(i_pb.url == nil|| [i_pb.url length] < 1)
             return;
             
             WSServerIPList *serverIpArr=[WSAppData getObjectbyKey:SERVERURL];
             WSServerIPController *serverIP=[serverIpArr.serverIPArray objectAtIndex:0];
             
             NSString *s1 = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)i_pb.url, NULL,(CFStringRef) @"!*'();:@&=+$,%#[]", kCFStringEncodingUTF8));
             
             NSString* i_url = [NSString stringWithFormat:@"%@%@",serverIP.ServerIPString,s1];
             
             [self performSelector:@selector(addBackView)];
             [self performSelector:@selector(addImageView:) withObject:i_url];
             */
        }
        return;
    }
    
    if(lvc==nil)
    {
        WSDictBrand* db = (WSDictBrand*)object;
        lvc = [[WSProdListViewController alloc]initWithArray:db.prodArray];
        lvc.ownParenetViewController = self.ownParenetViewController;
    }
        
    LogInfo(@"Going to class WSProdListViewController");
    self.ownParenetViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParenetViewController.navigationController pushViewController:lvc animated:YES];
}

- (void)startGetProductInfoByProductId:(NSString *)sid
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ProductInfoHasArrived:)
                                                 name:NOTIFY_PRODUCTINFO 
                                               object:nil];
    
    [[WSRequestHelper shareInstance] appGetProductInfobyProductId:sid notifyName:NOTIFY_PRODUCTINFO];
}

- (void)ProductInfoHasArrived:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];

    [[NSNotificationCenter defaultCenter] 
     removeObserver:self name:NOTIFY_PRODUCTINFO object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
 
    if (error) 
    {
        LogError(@"\n\n[ LogError %@ ]\n\n",[error localizedDescription]);
    }
    else
    {
        NSDictionary *senderDic = [info objectFromJSONString];
        
        NSArray *sInfo = [senderDic objectForKey:@"proddetailinfo"];
        NSDictionary *dic = [sInfo objectAtIndex:0];
        
        NSString *content = [dic objectForKey:@"name"];
        NSString *url = [dic objectForKey:@"url"];
        NSArray *array = [content componentsSeparatedByString:@"@"];

        // 此处url 用prod
        NSString *fullUrl;
        if ( url  && ![url isKindOfClass:[NSNull class]] &&
                              ![url isEqualToString:@""] &&
                              ![url isEqualToString:@"null"]) {
            // 图片的url实时请求获取
            fullUrl = [url buildupUrl];
        }else{
            // 如果 url 不存在 则用self.prodPicUrl
            if ( self.prodPicUrl && ![self.prodPicUrl isKindOfClass:[NSNull class]] &&
                                             ![self.prodPicUrl isEqualToString:@""] &&
                                         ![self.prodPicUrl isEqualToString:@"null"] ) {
                fullUrl =[self.prodPicUrl buildupUrl];
            }
        }
        LogInfo(@"url:%@",fullUrl);
        LogInfo(@"Going to class WSProdDetailInfoViewController");
        WSProdDetailInfoViewController *controller = [[WSProdDetailInfoViewController alloc] initWithImageURL:fullUrl andProductInfo:array];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)disMissBackView
{
    self.tableView.scrollEnabled=YES;
    [UIView beginAnimations:@"dismissImage" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.3f];
  
    UIView* l_view = [self.view viewWithTag:BACKVIEWTAG];
    [l_view removeFromSuperview];
    UIView* l_imageView = [self.view viewWithTag:IMAGETAG];
    [l_imageView removeFromSuperview];
    
    [UIView commitAnimations];
}

-(void)addBackView
{
    self.tableView.scrollEnabled=NO;
    UIView* l_view = [[UIView alloc]initWithFrame:self.view.frame];
    l_view.tag = BACKVIEWTAG;
    l_view.backgroundColor = [UIColor blackColor];
    l_view.alpha = 0.5f;
    
    UIButton* l_button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    l_button.frame = CGRectMake(290.0f, 0.0, 30.0f, 30.0f);    
    [l_button addTarget:self action:@selector(disMissBackView) forControlEvents:UIControlEventTouchUpInside];
    [l_view addSubview:l_button];
    [self.view addSubview:l_view];
    
}

-(void)addImageView:(NSString*)aUrl
{
    [UIView beginAnimations:@"showProd" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3f];
    
    CGRect frame;
    frame.size.width=220;
    frame.size.height=300; 
    frame.origin.x=50; 
    frame.origin.y=0;
        
//    NSURL *url = [NSURL URLWithString:aUrl];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.center = self.view.center;
    imageView.tag = IMAGETAG;
    
//    __block ProdListViewController *tvself = self;

    [[WSRequestHelper shareInstance] downloadImageWithUrl:aUrl imageView:imageView];
    
    [self.view addSubview:imageView];
    [UIView commitAnimations];
}

@end
