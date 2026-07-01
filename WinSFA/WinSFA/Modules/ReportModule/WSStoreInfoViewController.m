//
//  StoreInfoViewController.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-4.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "WSStoreInfoViewController.h"
#import "WinSFA.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
//#import "ConfigFileController.h"

static const CGFloat  kCellLabelExtraWidth  = 20.0f;

#define QrCodeWidth 260
#define QrCodeCellHeight 260
#define QrCodeSpaceHeight 20

@interface WSStoreInfoViewController ()
{
    NSMutableArray *_addressAllLanguagesStrMArray;
}
@property (nonatomic,copy) NSArray *qrcodeArray;
- (void)startGetStoreInfo;
- (void)storeInfoHasArrived:(id)sender;
@end

@implementation WSStoreInfoViewController
@synthesize datas;
@synthesize titles;
//@synthesize inplan, outplan;
@synthesize _store;
@synthesize linkman = linkman_;
@synthesize linktel = linktel_;
@synthesize linkAddress = linkAddress_;

- (void)viewDidUnload
{
    datas = nil;
    self.linkman = nil;
    self.linktel = nil;
    self.linkAddress = nil;
    [super viewDidUnload];
    
}
- (id)initWithStoreInfo:(id)store{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        
        // 添加门店地址的四种语言释义字符串到数组，后期可扩展
        _addressAllLanguagesStrMArray = [NSMutableArray arrayWithObjects:@"门店地址", @"Address", @"住所", @"Domicilio", nil];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.sectionHeaderHeight = 50;
        self.tableView.scrollEnabled = YES;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.showsVerticalScrollIndicator = NO;
        
        if (INTERFACE_IS_PHONE) {
            UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
            [backBtn setBackgroundColor:[UIColor clearColor]];
            [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
            self.navigationItem.leftBarButtonItem=homeButtonItem;
        }
        
        
        //        NSString *UpdateString = NSLocalizedString(@"refresh",nil);
        //        UIBarButtonItem *update = [[UIBarButtonItem alloc]
        //                                      initWithTitle:UpdateString
        //                                      style: UIBarButtonItemStylePlain
        //                                      target:self
        //                                   action:@selector(startGetStoreInfo)];
        
        // MSTD-5969 刷新按钮更改文字为图标
        UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshButton.frame = CGRectMake(0, 0, 24, 24);
        [refreshButton setImage:[UIImage imageNamed:@"refurbish_icon"] forState:UIControlStateNormal];
        [refreshButton addTarget:self action:@selector(startGetStoreInfo) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *update = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
        
        self.navigationItem.rightBarButtonItem = update;
        
      
        
        NSString *storeNameString = NSLocalizedString(@"storename",nil);
        NSString *storeIDString = NSLocalizedString(@"store_code",nil);

        self.titles = [NSMutableArray arrayWithObjects:storeNameString,
                           storeIDString,
                           nil];
        
        self._store = store;
        NSMutableArray *mudata = [[NSMutableArray alloc] init];
        self.datas = mudata;
        if (store) {
            [self startGetStoreInfo];
        }
        
        [self getQrCodeArrayFromQrCode];
    }
    
    return self;
}

- (id)initWithStoreInfo:(id)store withSubempStore:(WSSubempstoreBean *)subempStore{
    
    self = [self initWithStoreInfo:store];
    if (self) {
        self.subempStore = subempStore;
        if (store == nil) {
            NSString *customerName = [NSString stringNotNilWithValue:self.subempStore.name];
            NSString *customerCode = [NSString stringNotNilWithValue:self.subempStore.cod];
            self.datas = [NSMutableArray arrayWithObjects:customerName,customerCode, nil];
            self.titles = [NSMutableArray arrayWithObjects:@"客户名称",
                           @"客户编码",
                           nil];
        }
    }
    return self;
}
//SFA-24038、SFA-24040 赵丹阳
#pragma mark 获取二维码图片数组
- (void) getQrCodeArrayFromQrCode{
    
    if (self.qrcodeArray == nil) {
        self.qrcodeArray = [[NSArray alloc] init];
    }
    if ([self._store.qrcode rangeOfString:@","].location != NSNotFound){
        
        NSArray *tempArray =[self._store.qrcode componentsSeparatedByString:@","];
        self.qrcodeArray = tempArray;
        
    }
    else{
        if (self._store.qrcode.length > 0) {
            
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
            
            [tempArray addObject:self._store.qrcode];
            
            self.qrcodeArray = tempArray;
        }
    }
}
- (void)backAction{

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)startGetStoreInfo{
    //add By wangdongyan 2012-02-23 for 禁用btn
    self.navigationController.navigationBar.userInteractionEnabled=NO;
    
    
    
    //sid = self._store.Id;
    [self.datas removeAllObjects];
    if (self._store.name) {
        [self.datas addObject:self._store.name];
    }
    if ([self._store isKindOfClass:[WSStoreBean class] ])
    {
        if (self._store.code == nil)
        {
            self._store.code = @"";
        }
        [self.datas addObject:self._store.code];
    }
    
    
    [self.titles removeAllObjects];
    
    NSString *storeNameString = NSLocalizedString(@"storename",nil);
    NSString *storeIDString = NSLocalizedString(@"store_code",nil);
    [self.titles addObject:storeNameString];
    [self.titles addObject:storeIDString];
    
    [self.tableView reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeInfoHasArrived:)
                                                 name:NOTIFY_STOREINFO 
                                               object:nil];

    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_prompt", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    
    [[WSRequestHelper shareInstance] appGetStoreInfobyStoreId:self._store.Id notifyName:NOTIFY_STOREINFO styp:self._store.styp];
}

- (void)storeInfoHasArrived:(id)sender{
    
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    
    //add by 王东艳 2012-02-23 for 解开禁用的按钮
    self.navigationController.navigationBar.userInteractionEnabled=YES;
     
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self name:NOTIFY_STOREINFO object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];

    if (error) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else
    {
        NSDictionary *responsedic = [info objectFromJSONString];
        
        NSString *objIdString = STOREINFO_UPDATE;
        
        NSArray *sInfo = [responsedic objectForKey:objIdString];
        NSDictionary *dic = [sInfo objectAtIndex:0];
            
        int i = 0;
        NSMutableArray *storeInfoArr = [dic objectForKey:@"storeInfo"];
        for (NSDictionary *infoDic in storeInfoArr)
        {
            NSString *col1 = [infoDic objectForKey:@"col1"];
            if ([col1 respondsToSelector:@selector(isEqualToString:)] && ![col1 isEqualToString:@"null"])
            {
                [self.titles addObject:[NSString stringWithFormat:@"%@", col1]];
                NSString *col2 = [infoDic objectForKey:@"col2"];
                if ([col2 respondsToSelector:@selector(isEqualToString:)] && ![col2 isEqualToString:@"null"])
                {
                    [self.datas addObject:col2];
                    if (i == 1) { // link phone number
                        self.linktel = [NSMutableString stringWithString:col2];
                    }else if( i == 2) // link address
                    {
                        self.linkAddress = [NSMutableString stringWithString:col2];
                    }
                }
                else 
                {
                    [self.datas addObject:@""];
                    if (i == 1) { // link phone number
                        self.linktel = [NSMutableString stringWithString:@""];
                    }else if( i == 2) // link address
                    {
                        self.linkAddress = [NSMutableString stringWithString:@""];
                    }
                }
            }
            i++;
        }
        NSString *qrcode = dic[@"qrcode"];
        if (qrcode.length > 0) {
            self._store.qrcode = qrcode;
            [self getQrCodeArrayFromQrCode];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableString *contact = [[NSMutableString alloc] initWithCapacity:64];
    self.linkman = contact;
    
    NSMutableString *phone = [[NSMutableString alloc] initWithCapacity:64];
    self.linktel = phone;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
#endif
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
    if (self.qrcodeArray.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.qrcodeArray.count;
    }
    return [self.titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreInfoVC";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView removeAllSubviews];
    
    if (indexPath.section == 1) {
        UIImageView *qrCodeImageView = [[UIImageView alloc] init];
        [cell.contentView addSubview:qrCodeImageView];
        
        //SFA-23834  添加一个随机数，用于重新生成图片
        //SFA 立白-iOS手机端-门店二维码后台已更新，但是手机端未更新
        NSDate *datenow = [NSDate date];
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        NSString * ranString = [NSString stringWithFormat:@"?t=%@",timeSp];
        NSString *newUrl = [self.qrcodeArray[indexPath.row] stringByAppendingString:ranString];
        [qrCodeImageView sd_setImageWithURL:[NSURL URLWithString:newUrl] placeholderImage:nil];

        [qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(cell.contentView.mas_centerX);
            make.top.mas_equalTo(cell.contentView.mas_top).mas_offset(QrCodeSpaceHeight);
            make.width.equalTo(QrCodeWidth);
            make.height.equalTo(QrCodeWidth);
        }];
        
        if(indexPath.row < self.qrcodeArray.count - 1){
            UIImageView *dashLineImageView = [[UIImageView alloc] init];
            dashLineImageView.image = [UIImage imageNamed:@"line"];
            [cell.contentView addSubview:dashLineImageView];
            
            [dashLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(cell.contentView.mas_bottom);
                make.width.mas_equalTo(cell.contentView.mas_width);
                make.height.equalTo(5);
                make.centerX.mas_equalTo(cell.contentView.mas_centerX);
            }];
        }
        return cell;
    }
    
    CGFloat width=((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 90.0f : 180.0f);
    CGFloat left=((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0f : 20.0f);
    CGSize currentCellSize = cell.frame.size;
    
    UILabel *lable_title = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, width, currentCellSize.height)];
    lable_title.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    NSString *contentStr  = [self.titles objectAtIndex:[indexPath row]];
    
    lable_title.text =  NSLocalizedString(contentStr, nil);
    lable_title.numberOfLines = 0;
    lable_title.lineBreakMode = NSLineBreakByCharWrapping;
    lable_title.font = [UIFont systemFontOfSize:UI_Font];
    
    CGSize newSize = [contentStr ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:cell.frame.size.width*3/5 lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect rect = lable_title.frame;
    rect.size.width = (newSize.width + kCellLabelExtraWidth);
    lable_title.frame = rect;
    [cell.contentView addSubview:lable_title];
    
    
    
    if ([self.datas count] == 0)
    {
        UIActivityIndicatorView *wait = [[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [wait setFrame:CGRectMake(170, 15, wait.frame.size.width, wait.frame.size.height)];
        [wait startAnimating];
        wait.hidesWhenStopped = YES;
        [cell.contentView addSubview:wait];
    }
    else
    {
        cell.autoresizesSubviews = YES;
//        MSTD-6698 xuhan
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(left + lable_title.width, 5, currentCellSize.width- 2*left - lable_title.size.width, currentCellSize.height)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        textView.textAlignment = NSTextAlignmentRight ;
        [textView setFont:[UIFont systemFontOfSize:UI_Font]];
        [textView setText:[self.datas objectAtIndex:[indexPath row]]];
        textView.textColor = [UIColor lightGrayColor];

        [textView setDataDetectorTypes:UIDataDetectorTypeAll];
        
        // MMSH-1666 地址内容去掉地图链接
        BOOL isContainsAddressStr = NO;
        
        for (NSString *addressStr in _addressAllLanguagesStrMArray) {
            if ([contentStr rangeOfString:addressStr].location != NSNotFound) {
                isContainsAddressStr = YES;
            }
        }
        
        if (isContainsAddressStr) {
            [textView setDataDetectorTypes:UIDataDetectorTypeNone];
        }
        
        //MSTD-5389门店信息中门店地址不显示为蓝色
//        if ([contentStr rangeOfString:NSLocalizedString(@"store_addr", nil)].location != NSNotFound) {
//            [textView setDataDetectorTypes:UIDataDetectorTypeNone];
//        }
        if (indexPath.row == 1) {
            [textView setDataDetectorTypes:UIDataDetectorTypeNone];
        }
        [textView setEditable: NO];
        textView.scrollEnabled = NO;
        for (id indicator in [cell.contentView subviews]) {
            if ([indicator isKindOfClass:[UIActivityIndicatorView class]]) {
                [(UIActivityIndicatorView *)indicator stopAnimating];
            }
        }
        
        [cell.contentView addSubview:textView];
    }
    
    
    UIView *line = [cell.contentView viewWithTag:1088];
    if (!line) {
        line = [[UIView alloc] initWithFrame:CGRectZero];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        line.backgroundColor = [UIColor colorWithHexString:@"#dcdcdc"];
        line.tag = 1088;
        [cell.contentView addSubview:line];
    }
    
    NSInteger totalCount = [self.datas count];
    
    CGFloat xOffset = 15;
    if (indexPath.row == totalCount - 1) {
        xOffset = 0;
    }
    
    line.frame = CGRectMake(xOffset, cell.contentView.height - 1, cell.contentView.width, 1);
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return QrCodeCellHeight + 2*QrCodeSpaceHeight;
    }
    //计算rightTextViewWidth
    CGFloat left=((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0f : 20.0f);
    CGSize currentCellSize = self.tableView.frame.size;;
     NSString *contentStr  = [self.titles objectAtIndex:[indexPath row]];
     CGSize newSize = [contentStr ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:currentCellSize.width *3/5 lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat leftLabelwidth = newSize.width + kCellLabelExtraWidth;
    CGFloat rightTextViewWidth = currentCellSize.width - 3*left - leftLabelwidth;
    
    
    if ([self.datas count] == 0)
    {
        return 44;
    }
    else
    {
        
        UIFont *font = [UIFont systemFontOfSize:UI_Font];
        
        NSString *content = [self.datas objectAtIndex:[indexPath row]];
        if ([content length] == 0 ) {
            return 44;
        }
        
        CGSize size;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:UI_Font]};
            size = [content boundingRectWithSize:CGSizeMake(rightTextViewWidth, 1000) options: NSStringDrawingUsesLineFragmentOrigin   attributes:attribute context:nil].size;
        }else{
            size = [content ws_sizeWithFont:font constrainedToWidth:rightTextViewWidth lineBreakMode:NSLineBreakByCharWrapping];
        }
        CGSize cellAppend = [content ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
        //        MSTD-6698 xuhan
        float height = (size.height + cellAppend.height) >= 44.0f?(size.height + cellAppend.height):44.0f;
        return height;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001f;
}

@end
