//
//  WSPfizerEtripModifyStoreInfoViewController.m
//  WinSFA
//
//  Created by yang on 14-5-9.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPfizerEtripModifyStoreInfoViewController.h"
#import "WSDatePickerLabel.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSOffLineUploadTable.h"
#import "WSStoreInfoViewController.h"

#define kUIViewTagBase 1000
#define kLabelLeftSpace (INTERFACE_IS_PHONE ? 10 : 20)
#define kTextFieldLeftSpace (INTERFACE_IS_PHONE ? 10 : 20)

#define kTelephoneNumberRegEx @"^\\([0]\\d{2,3}\\)\\d{5,8}|\\([0]\\d{2,3}\\)\\d{5,8}-\\d{1,6}$"   //电话号
#define kMobilePhoneNumberRegEx @"^[1]+\\d{10}$"   //手机号
#define kSingleBitDecimalsRegEx  @"^\\d*|\\d+(\\.\\d?)?$"  //一位小数

@interface WSPfizerEtripModifyStoreInfoViewController ()<UITextFieldDelegate,WSDatePickerLabelDelegate>
{
    BOOL hasViewLoaded;
}

@property (nonatomic, strong) NSDictionary *storeInfoDic;

//@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) NSMutableDictionary *dataDic;

@property (nonatomic, strong) UITextField *currentInputTextField;

@end

@implementation WSPfizerEtripModifyStoreInfoViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs store:(WSStoreBean*)store storeInfoDic:(NSDictionary *)storeInfoDic
{
    self = [super initWithFuncs:funcs Store:store];
    
    if (self) {
        self.storeInfoDic = storeInfoDic;
        self.dataDic = [NSMutableDictionary dictionary];
        hasViewLoaded = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [self.storeInfoDic objectForKey:@"name"];

    NSArray *offlineDataArray = [[WSOffLineUploadTable sharedTable] queryWithImg_idx:self.md5];
    WSOffLineUploadObject *object = [offlineDataArray lastObject];
    if (object) {
        NSString *postDataString = object.upload_data;
        NSDictionary *postDataDic = [postDataString objectFromJSONString];
        NSDictionary *jsonDataDic = [postDataDic objectForKey:@"jsonData"];
        if (jsonDataDic) {
            self.dataDic = [NSMutableDictionary dictionaryWithDictionary:jsonDataDic];
        }
    }
    
    if (self.currentStore.styp) {
        [self.dataDic setObject:self.currentStore.styp forKey:@"dataType"];
    }
    
}

-(NSDictionary*)md5Param
{
    //辉瑞定制化页面，暂时不加module_fc
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[super md5Param]];
    NSString* fc=@"PFIZER_ETRIP_UPDATE_STORE_INFO_FC";
    if(fc){
        [dic setObject:fc forKey:FUNCS_FC];
    }
    return dic;
}

- (void)initView
{
    if (hasViewLoaded) {
        return;
    }
    
    NSArray *storeInfoArray = [self.storeInfoDic objectForKey:@"storeInfo"];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.contentScrollView];
    
    float yPositon = INTERFACE_IS_PHONE ? 5 : 10;
    
    //col1 是属性名称  col2 是属性值，col3是是否只读 col4是输入类型，col5是排序 col6是对应实体类的名称，后台用的，原封不动的传回来即可
    //col4输入类型：t,tp,n,np,s,tm,d
    for (int i = 0; i < [storeInfoArray count] ; i++)
    {
        NSDictionary *qstDic = [storeInfoArray objectAtIndex:i];
        NSString *qstName = [NSString stringWithValue:[qstDic objectForKey:@"col1"]];
        NSString *qstValue = [NSString stringWithValue:[qstDic objectForKey:@"col2"]];
        NSString *isReadOnly = [NSString stringWithValue:[qstDic objectForKey:@"col3"]];
        NSString *inputType = [NSString stringWithValue:[qstDic objectForKey:@"col4"]];
        //        NSString *orderNum = [NSString stringWithValue:[qstDic objectForKey:@"col5"]];
        NSString *qstKeyName = [NSString stringWithValue:[qstDic objectForKey:@"col6"]];
        
        if ([inputType isEqualToString:@"t"] || [inputType isEqualToString:@"tp"] || [inputType isEqualToString:@"n"] || [inputType isEqualToString:@"np"] || [inputType isEqualToString:@"tm"])
        {
            
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            CGSize size = [qstName ws_sizeWithFont:font constrainedToWidth:self.view.bounds.size.width lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(kLabelLeftSpace, yPositon, self.contentScrollView.bounds.size.width - kTextFieldLeftSpace * 2, size.height)];
            lable.font = font;
            lable.backgroundColor = kCLEAR_COLOR_value;
            lable.text = qstName;
            lable.numberOfLines = 0;
            [self.contentScrollView addSubview:lable];
            yPositon += (lable.frame.size.height + 10);
            
            float tHeight = 35;
            WSHTextField* textField = [[WSHTextField alloc]initWithFrame:CGRectMake(kTextFieldLeftSpace, yPositon, self.contentScrollView.bounds.size.width - kTextFieldLeftSpace * 2, tHeight)];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            NSString *input = NSLocalizedString(@"please_fill_in", nil);
            textField.placeholder = input;
            
            textField.font = font;
            textField.textAlignment = NSTextAlignmentCenter;
            textField.backgroundColor = [UIColor whiteColor];
            [textField setBorderStyle:UITextBorderStyleNone];
            textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            textField.layer.borderWidth = 1.0;
            textField.layer.cornerRadius = 5;
            textField.delegate = self;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, textField.height)];
            textField.leftView = view;
            textField.leftViewMode = UITextFieldViewModeAlways;
            textField.tag = kUIViewTagBase + i;
            if ([isReadOnly intValue]) {
                textField.enabled = NO;
                textField.textColor = [UIColor grayColor];
                textField.placeholder = @"";
            }
            
            if (qstValue && [qstValue length] > 0) {
                textField.text = qstValue;
                if (qstKeyName) {
                    [self.dataDic setObject:qstValue forKey:qstKeyName];
                }
            }
            else
            {
                if (qstKeyName) {
                    NSString *dbValue = [self.dataDic objectForKey:qstKeyName];
                    if (dbValue && [dbValue length] > 0) {
                        textField.text = dbValue;
                    }
                }
            }
            
            if ([inputType isEqualToString:@"n"] || [inputType isEqualToString:@"tm"]) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }else if ([inputType isEqualToString:@"np"])
            {
                textField.keyboardType = UIKeyboardTypeDecimalPad;
            }
            
            [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
            
            [self.contentScrollView addSubview:textField];
            yPositon += textField.frame.size.height+ 15;
        }
        else if ([inputType isEqualToString:@"s"])
        {
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            CGSize size = [qstName ws_sizeWithFont:font constrainedToWidth:self.view.bounds.size.width lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(kLabelLeftSpace, yPositon, self.contentScrollView.bounds.size.width - kTextFieldLeftSpace * 2, size.height)];
            lable.font = font;
            lable.backgroundColor = kCLEAR_COLOR_value;
            lable.text = qstName;
            lable.numberOfLines = 0;
            [self.contentScrollView addSubview:lable];
            yPositon += (lable.frame.size.height + 10);
            
            // 遍历ab_qst对象的所有选项option    - Nemo
            for (int optionIndex = 0; optionIndex < 2; optionIndex++ )
            {
                // 选项名字 ...   TODO 这些代码应该封装  先完成测试后在重构    - Nemo
                NSString *optName = (optionIndex == 0 ? @"post_quit_no" : @"post_quit_yes");
                
                UILabel *optionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLabelLeftSpace, yPositon, self.contentScrollView.bounds.size.width - kTextFieldLeftSpace * 2, 30)];
                optionNameLabel.font = [UIFont systemFontOfSize:UI_Font];
                optionNameLabel.adjustsFontSizeToFitWidth = YES;
                [optionNameLabel setTextColor:[UIColor blackColor]];
                [optionNameLabel setBackgroundColor:[UIColor clearColor]];
                [optionNameLabel setText:optName];
                optionNameLabel.numberOfLines = 0;
                optionNameLabel.lineBreakMode  =NSLineBreakByWordWrapping;
                [optionNameLabel sizeToFit];
                
                
                // 选项按钮 ...
                UIButton    *option_btn = [UIButton buttonWithType:UIButtonTypeCustom];
                // 目前 使用按钮的tag来索引ab_qst_index和选项index
                // 用的时候 ab_qst_index = tag/100;   optionIndex = tag%100;
                [option_btn setTag: kUIViewTagBase + i*1000 + optionIndex];
                [option_btn addTarget:self action:@selector(option_btn_clicked:) forControlEvents:UIControlEventTouchUpInside];
                
                // img
                NSString    *normal_img_name = @"selected_no_radio";
                NSString    *seleted_img_name = @"selected_yes_radio";
                
                //Note： 只读，不可点击状态
                if ([isReadOnly intValue]) {
                    normal_img_name = @"selected_no_radio_disabled";
                    seleted_img_name = @"selected_yes_radio_disabled";
                    [optionNameLabel setTextColor:[UIColor grayColor]];
                }
                
                // 此处只保留一个图片的对象指针 因为下面要用其获取尺寸
                UIImage *normal_img = [UIImage scaledImageForName:normal_img_name ofType:@"png"];
                [option_btn setImage:normal_img forState:UIControlStateNormal];
                [option_btn setImage:[UIImage scaledImageForName:seleted_img_name ofType:@"png"] forState:UIControlStateSelected];
                float y_offset;
                float buttonLeft=60.0f;
                if( [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad){
                    buttonLeft=80.0f;
                }
                y_offset = 4;
                option_btn.frame = CGRectMake(self.contentScrollView.bounds.size.width - buttonLeft, 40/2-normal_img.size.height/2+ yPositon + y_offset, normal_img.size.width, normal_img.size.height);
                option_btn.centerY = yPositon + optionNameLabel.frame.size.height/2;
                
                [self.contentScrollView addSubview:optionNameLabel];
                [self.contentScrollView addSubview:option_btn];
                
                yPositon += 40;
                
                NSString *dbValue = [self.dataDic objectForKey:qstKeyName];
                if (dbValue && [dbValue length] > 0) {
                    if (qstKeyName) {
                        if ([dbValue intValue] == optionIndex) {
                            [option_btn setSelected:YES];
                        }
                    }
                }
                else
                {
                    if (qstValue && [qstValue length] > 0) {
                        if ([qstValue intValue] == optionIndex) {
                            [option_btn setSelected:YES];
                            if (qstKeyName) {
                                [self.dataDic setObject:optionIndex == 0 ? @"0" : @"1" forKey:qstKeyName];
                            }
                        }
                    }
                }
                
                if ([isReadOnly intValue]) {
                    [option_btn setUserInteractionEnabled:NO];
                }
                
            }
            // 使当前的位置与以后要添加的UI 保持10距离
            yPositon += 10;
        }
        else if ([inputType isEqualToString:@"d"])
        {
            UIFont *font = [UIFont systemFontOfSize:UI_Font];
            CGSize size = [qstName ws_sizeWithFont:font constrainedToWidth:self.view.bounds.size.width lineBreakMode:NSLineBreakByWordWrapping];
            UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(kLabelLeftSpace, yPositon, self.contentScrollView.bounds.size.width - kTextFieldLeftSpace * 2, size.height)];
            lable.font = font;
            lable.backgroundColor = kCLEAR_COLOR_value;
            lable.text = qstName;
            lable.numberOfLines = 0;
            [self.contentScrollView addSubview:lable];
            yPositon += (lable.frame.size.height + 10);
            
            WSDatePickerLabel *view = [[WSDatePickerLabel alloc] initWithFrame:CGRectMake(kLabelLeftSpace, yPositon, self.contentScrollView.bounds.size.width - kTextFieldLeftSpace * 2, 35)];
            view.delegate = self;
            [self.contentScrollView addSubview:view];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            view.layer.borderWidth = 1.0;
            view.layer.cornerRadius = 5;
            view.tag = kUIViewTagBase + i;
            yPositon += 35 + 15;
            
            NSString *dbValue = [self.dataDic objectForKey:qstKeyName];
            if (dbValue && [dbValue length] > 0) {
                view.text = dbValue;
            }
        }
    }
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.width, yPositon);
    
    hasViewLoaded = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.originalViewYPosition = [NSNumber numberWithFloat:self.view.frame.origin.y];
    
    [self addToolBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.storeInfoDic) {
        [self initView];
    }
    else
    {
        [self startGetStoreInfoBySotre:self.currentStore];
    }
}

- (void)textWatcher:(id)sender {
    
}

- (void)startGetStoreInfoBySotre:(WSStoreBean *)store
{
    [self querying_messageTips];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeInfoHasArrived:)
                                                 name:NOTIFY_STOREINFO
                                               object:nil];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringNotNilWithValue:store.sid] forKey:WSREQUEST_STOREID];
    [dictionary setObject:@"1" forKey:@"compress"];
    [dictionary setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [dictionary setObject:@"updateStoreInfo" forKey:APPDATA_OBJID];
    if (self.currentStore.styp) {
        [dictionary setObject:self.currentStore.styp forKey:@"storeType"];
    }
    //[uploadMgr appGetStoreInfobyStoreId:store.sid notifyName:NOTIFY_STOREINFO];
    [[WSRequestHelper shareInstance] postRequestData:dictionary notifyName:NOTIFY_STOREINFO];
}

- (void)storeInfoHasArrived:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTIFY_STOREINFO
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    self.navigationController.navigationBar.userInteractionEnabled=YES;
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:NOTIFY_STOREINFO object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    if (error) {
        if (error.code != 0) {
            NSString *tmpString = NSLocalizedString(@"network_failure",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            [self backToParent];
        }
    }else{
        NSDictionary *infoDic = [info objectFromJSONString];
        NSArray *storeInfoArr = [infoDic objectForKey:@"updateStoreInfo"];
        NSDictionary *storeInfoDic = nil;
        if ([storeInfoArr count] > 0) {
            storeInfoDic = [storeInfoArr objectAtIndex:0];
        }
        
        self.storeInfoDic = storeInfoDic;
        [self initView];
    }
}


- (BOOL)checkUploadData
{
    BOOL isValid = YES;
    NSArray *storeInfoArray = [self.storeInfoDic objectForKey:@"storeInfo"];
    NSMutableArray *invalidQstNameArray = [NSMutableArray array];
    for (int i = 0; i < [storeInfoArray count]; i++)
    {
        NSDictionary *qstDic = [storeInfoArray objectAtIndex:i];
        NSString *qstName = [NSString stringWithValue:[qstDic objectForKey:@"col1"]];
        NSString *inputType = [NSString stringWithValue:[qstDic objectForKey:@"col4"]];
        //        NSString *orderNum = [NSString stringWithValue:[qstDic objectForKey:@"col5"]];
        NSString *qstKeyName = [NSString stringWithValue:[qstDic objectForKey:@"col6"]];
        
        NSString *realValue = [self.dataDic objectForKey:qstKeyName];
        
        if (realValue) {
            
            //校验规则：
            //tp:(区号)电话号-分机号，区号：用()括起来的以0开头的3-4位数，电话号：7-8位，分机号3-4位，分机号可以不写
            //tm:手机号，已1开头的11位数
            //np:小数，小数点后面最多一位(莎莎说还有总位数限制，但是找Android查了，没有总位数限制)
            
            if ([inputType isEqualToString:@"tp"]) {
                NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kTelephoneNumberRegEx];
                if (![regex evaluateWithObject:realValue]) {
                    isValid = NO;
                    [invalidQstNameArray addObject:qstName];
                }
            }
            else if ([inputType isEqualToString:@"tm"])
            {
                NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kMobilePhoneNumberRegEx];
                if (![regex evaluateWithObject:realValue]) {
                    isValid = NO;
                    [invalidQstNameArray addObject:qstName];
                }
            }
            else if ([inputType isEqualToString:@"np"])
            {
                NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kSingleBitDecimalsRegEx];
                if (![regex evaluateWithObject:realValue]) {
                    isValid = NO;
                    [invalidQstNameArray addObject:qstName];
                }
            }
        }
    }
    
    if ([invalidQstNameArray count] > 0) {
        NSString *tip = [NSString stringWithFormat:@"%@ 校验不合格", [invalidQstNameArray componentsJoinedByString:@","]];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
    return isValid;
}

- (void)upload
{
    [self dismissCurrentTextfield];
    
    BOOL result = [self checkUploadData];
    
    if (result) {
        
        [super uploadVisitAction];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:@"1" forKey:@"compress"];
        [dictionary setObject:self.md5 forKey:@"id"];
        [dictionary setObject:[WSCurrentTime getDateString] forKey:@"syncDate"];
        [dictionary setObject:@"etrip" forKey:@"project"];
//        [dictioanry setObject:[NSNumber numberWithInteger:32] forKey:@"db_id"];
        [dictionary setObject:@"SPE_ETRIP_STORE_UPDATE" forKey:@"method"];
        if ([WSAppData getObjectbyKey:APPDATA_EMPID]) {
            [dictionary setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"account"];
        }
        if ([self.storeInfoDic objectForKey:@"id"]) {
            [dictionary setObject:[self.storeInfoDic objectForKey:@"id"] forKey:@"storeId"];
        }
        if (self.dataDic) {
            [dictionary setObject:self.dataDic forKey:@"jsonData"];
        }
        
        NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];

        NSString *postData = [dictionary JSONString];
        [[WSRequestHelper shareInstance] uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyID md5:self.md5 isUpload:YES];
        
        [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:NO NotifyName:notifyID];
        
        NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        [self backToParent];
        
    }
}

- (void)dismissCurrentTextfield
{
    if (self.currentInputTextField) {
        if ([self.currentInputTextField isFirstResponder]) {
            [self.currentInputTextField resignFirstResponder];
        }
    }
}

-(BOOL)backToParent
{
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

#pragma mark actions
//
//选项按钮点击处理函数
// 目前 使用按钮的tag来索引ab_qst_index和选项index
// ab_qst_index = tag/100;   optionIndex = tag%100;
- (void)option_btn_clicked:(UIButton*)optionBtn
{
    if (![optionBtn isSelected]) {
        // 反选
        [optionBtn setSelected:YES];
        // 根据tag 获取数据索引：ab_qst_index 和 选项索引：optionIndex
        NSInteger ab_qst_index = (optionBtn.tag - kUIViewTagBase)/1000;
        NSInteger optionIndex = (optionBtn.tag - kUIViewTagBase)%1000;
        
        UIButton *button = (UIButton *)[self.contentScrollView viewWithTag:(optionBtn.tag - optionIndex + (optionIndex == 0 ? 1 : 0))];
        if ([button isKindOfClass:[UIButton class]]) {
            [button setSelected:NO];
        }
        
        NSArray *storeInfoArray = [self.storeInfoDic objectForKey:@"storeInfo"];
        if ([storeInfoArray count] > ab_qst_index) {
            NSDictionary *qstDic = [storeInfoArray objectAtIndex:ab_qst_index];
            NSString *qstKeyName = [NSString stringWithValue:[qstDic objectForKey:@"col6"]];
            if (qstKeyName) {
                [self.dataDic setObject:optionIndex == 0 ? @"0" : @"1" forKey:qstKeyName];
            }
        }
    }
    
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
{
    self.currentInputTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentInputTextField = nil;
    NSInteger qstIndex = textField.tag - kUIViewTagBase;
    NSArray *storeInfoArray = [self.storeInfoDic objectForKey:@"storeInfo"];
    if ([storeInfoArray count] > qstIndex) {
        NSDictionary *qstDic = [storeInfoArray objectAtIndex:qstIndex];
        NSString *qstKeyName = [NSString stringWithValue:[qstDic objectForKey:@"col6"]];
        if (qstKeyName) {
            if (textField.text && [textField.text length] > 0) {
                [self.dataDic setObject:textField.text forKey:qstKeyName];
            }
            else
            {
                [self.dataDic removeObjectForKey:qstKeyName];
            }
        }
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //删除符号
    if ([string length] == 0) {
        return YES;
    }
    
    NSInteger qstIndex = textField.tag - kUIViewTagBase;
    NSArray *storeInfoArray = [self.storeInfoDic objectForKey:@"storeInfo"];
    if ([storeInfoArray count] > qstIndex) {
        NSDictionary *qstDic = [storeInfoArray objectAtIndex:qstIndex];
        NSString *inputType = [NSString stringWithValue:[qstDic objectForKey:@"col4"]];
        
        if ([inputType isEqualToString:@"np"]) {
            NSString *valueString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kSingleBitDecimalsRegEx];
            if ([regex evaluateWithObject:valueString]) {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        else if ([inputType isEqualToString:@"tm"] || [inputType isEqualToString:@"n"])
        {
            NSRange range = [string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
            if (range.location != NSNotFound) {
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
    
    return YES;
}

#pragma mark - WSDatePickerLabelDelegate

- (void)datePickerLabel:(WSDatePickerLabel *)datePickerLabel valueChanged:(NSString *)value
{
    NSInteger qstIndex = datePickerLabel.tag - kUIViewTagBase;
    NSArray *storeInfoArray = [self.storeInfoDic objectForKey:@"storeInfo"];
    if ([storeInfoArray count] > qstIndex) {
        NSDictionary *qstDic = [storeInfoArray objectAtIndex:qstIndex];
        NSString *qstKeyName = [NSString stringWithValue:[qstDic objectForKey:@"col6"]];
        if (qstKeyName) {
            if (value && [value length] > 0) {
                [self.dataDic setObject:value forKey:qstKeyName];
            }
            else
            {
                [self.dataDic removeObjectForKey:qstKeyName];
            }
        }
        
    }
}


@end
