//
//  WSRevertViewController.m
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "WSRevertViewController.h"
#import "WSRevertTableViewCell.h"
#import "RevertArrayModel.h"
//#import "UIView+Extension.h"
#import "WSRequestHelper.h"
#import "WSMsgReceiver.h"
#import "UIViewController+ESSeparatorInset.h"
#import "NSString+Additions.h"
#import "WSMJProgressHeader.h"

#define BG_COLOR  [UIColor colorFromHexCode:@"#E9EFEF"]

static const CGFloat kViewHeight = 56;
static const CGFloat kMaxTextViewHeight = 80;

static const NSInteger KMaxTextNum = 200;

@interface WSRevertViewController ()

@property(nonatomic,strong)UIView * textfiledView;
@property(nonatomic,strong) RevertArrayModel * revertModel;
@property(nonatomic,assign) BOOL isOutNumber;  //回复的数组是否超过10条
@property(nonatomic,strong) UIButton *sendButton;
@property(nonatomic,strong) UITextView *msgTextView;
@property(nonatomic,strong) UIView *backgroundView;
@property(nonatomic,strong) UILabel *placeHolder;
@end

@implementation WSRevertViewController

-(NSArray *)inputStr{

    if (!_inputStr) {
        _inputStr = [NSArray array];
    }

    return _inputStr;
}


// 把cell对应的数据模型传进来

-(id)initWithMSG:(WSMsgsBean_msg*)aMSG
{
    if(aMSG==nil)
        return nil;
    self.m_MSG = aMSG;
    return [self init];
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = nil;
    [super viewDidLoad];
    // 去除 分割线
    CGRect rect = self.view.bounds;
    rect.size.height -= kViewHeight;
    self.tableView = [[UITableView alloc] initWithFrame:rect];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = BG_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.tableView];
    WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingTarget:self refreshingAction:@selector(updataReplyInfo)];
    header.automaticallyChangeAlpha = YES;
    self.tableView.mj_header = header;

    UIEdgeInsets insets = UIEdgeInsetsMake(0, MAIN_CELL_PADDING, 0, 0);
    [self setSeparatorInsetWithTableView:self.tableView inset:insets];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self addBackgroudView];
    [self addCustomInputStr];
 
}

-(void)updataReplyInfo{
    // 请求回复数组的数据
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr getMSGWithId:self.m_MSG.Id NotifyName:PARTNERSMSG_NOTIFY];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(partnersCommentsFinished:) name:PARTNERSMSG_NOTIFY object:nil];
}

-(void)partnersCommentsFinished:(id)sender
{
    [self.tableView.mj_header endRefreshing];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PARTNERSMSG_NOTIFY object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
        if (error.code != 0) {
        NSString *NONetWorkString = NSLocalizedString(@"网络无法连接，请检查网络",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NONetWorkString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
        else
    {
        NSString *info = [[sender userInfo] objectForKey:DATAS];
        NSDictionary* l_info = [info objectFromJSONString];
        NSArray* l_msgreplies = [l_info objectForKey:@"msgreplies"];

        if(l_msgreplies != nil&& [l_msgreplies count]>0)
        {
            NSMutableArray * aryM = [NSMutableArray array];
            for(NSDictionary* content in l_msgreplies)
            {
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                NSString *rep = [content objectForKey:@"rep"];
                NSArray * ary = [rep componentsSeparatedByString:@":"];
                // 后台会多返回一个空格，后台暂不调整，所以手机端处理
                NSString * revertMsg = [rep substringFromIndex:[ary[0] length] + 2];
                [dict setValue:[NSString stringNotNilWithValue:ary[0]] forKey:@"userName"];
                [dict setValue:[NSString stringNotNilWithValue:revertMsg]  forKey:@"revertMsg"];
                NSString * reply_time = [content objectForKey:@"UPLOAD_DATE"];
                if (reply_time.length == 0) {
                    reply_time = [content objectForKey:@"reply_time"];
                }
                [dict setValue:[NSString stringNotNilWithValue:reply_time] forKey:@"reply_time"];
                RevertArrayModel * model = [RevertArrayModel cellWithDict:dict];
                [aryM addObject:model];
            }
           
            self.inputStr = aryM.copy;
            self.title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"回复", nil), (unsigned long)aryM.count];

            [self.tableView reloadData];
            
            NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults] objectForKey:LastReplyCount] mutableCopy];
            if (!dict) {
                dict = [[NSMutableDictionary alloc]init];
            }
            NSString * keyString = [NSString stringWithFormat:@"%@_%@",[WSAppData getObjectbyKey:APPDATA_EMPID],self.m_MSG.Id];
            [dict setObject:@(aryM.count) forKey:keyString];
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:LastReplyCount];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    }
}
- (void)addBackgroudView {
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.backgroundView setBackgroundColor:POP_WINDOW_BG_COLOR];
    [self.backgroundView setHidden:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.backgroundView];
}

// 添加自定义输入框
-(void)addCustomInputStr{
    
    UIView * revertView = [[UIView alloc] init];
    revertView.frame = CGRectMake(0, self.view.height - kViewHeight, self.view.width, kViewHeight);
//    revertView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
      revertView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [revertView setBackgroundColor:[UIColor whiteColor]];
    
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0, 0, revertView.frame.size.width, 1);
    TopBorder.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [revertView.layer addSublayer:TopBorder];
  
    CGFloat sendWidth = 50;
    
    // 添加回复的输入框
    CGFloat textHeight = 33;
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(MAIN_PADDING, (kViewHeight - textHeight) / 2, self.view.width - sendWidth - MAIN_PADDING, textHeight)];
    
    textView.delegate = self;
    textView.backgroundColor = [UIColor colorWithRed:250.0f/255 green:250.0f/255 blue:250.0f/255 alpha:1.0f] ;
    textView.returnKeyType = UIReturnKeySend;
    textView.font = [UIFont systemFontOfSize:14];
    
    textView.layer.borderColor = BG_COLOR.CGColor;
    textView.layer.borderWidth = 0.5;
    [revertView addSubview:textView];
    self.msgTextView = textView;
    
    [self setupPlaceHolder];
    
    self.textfiledView = revertView;
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textView.frame), 0, sendWidth, kViewHeight)];
    [self.sendButton setTitle:NSLocalizedString(@"send_lable", nil) forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.sendButton setTitleColor:MAIN_TINT_COLOR forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[MAIN_TINT_COLOR colorWithAlphaComponent:ALPHA_DISABLED] forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [revertView addSubview:self.sendButton];

    
    [self.textfiledView setTranslatesAutoresizingMaskIntoConstraints:NO];
    // SFA-18581 navigationController 上添加编辑框会导致和 IQKeyboardManager 的处理冲突，而且只能设置忽略 self.navigationController.view
//    [self.navigationController.view addSubview:revertView];
    [self.view addSubview:revertView];
}

- (void)setupPlaceHolder {
    UILabel *placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.msgTextView.width - 10, self.msgTextView.height)];
    self.placeHolder = placeHolder;
    
    placeHolder.font = self.msgTextView.font;
    placeHolder.text = NSLocalizedString(@"please_enter_reply_content", nil);
    placeHolder.textColor = [UIColor lightGrayColor];
    [self.msgTextView addSubview:placeHolder];
}



-(void)viewWillDisappear:(BOOL)animated{
  [self.textfiledView removeFromSuperview];
}


#pragma -mark  UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

      return self.inputStr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RevertArrayModel * model = self.inputStr[indexPath.row];
    self.revertModel = model;
    WSRevertTableViewCell * cell = [WSRevertTableViewCell cellWithTableView:tableView];
    cell.model = model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RevertArrayModel * model = self.inputStr[indexPath.row];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentJustified;
    paraStyle.lineSpacing = 5; //设置行间距
    
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:UI_Font], NSParagraphStyleAttributeName:paraStyle,
                          };
    
    CGSize size = [model.revertMsg boundingRectWithSize:CGSizeMake(tableView.width - 2 * MAIN_CELL_PADDING, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;

//    CGSize size = [model.revertMsg ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToWidth:tableView.width - 2 * MAIN_CELL_PADDING];
    return size.height + kTitleHeight + MAIN_CELL_PADDING * 0.5 + 2 * MAIN_CELL_PADDING;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.textfiledView endEditing:YES];

}
#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    if (!self.textfiledView.isFirstResponder) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextfiledView:) name: UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextfiledView:) name: UIKeyboardWillHideNotification object:nil];
//    }
    
    return YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self.backgroundView setHidden:NO];

}
-(void)textViewDidEndEditing:(UITextView *)textView {
//    self.textfiledView.y = self.view.height - self.textfiledView.height;
//     winSFA MSTD-4305 iPad 分屏显示时信息列表的收索框会影响键盘的通知
    [self.backgroundView setHidden:YES];
//    if (!self.textfiledView.isFirstResponder) {
//
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length != 0) {
        [self.placeHolder setHidden:YES];
    } else {
        [self.placeHolder setHidden:NO];
    }
    
    NSString *inputStr = textView.text;
    if (inputStr.length >0 && ([self caculateStringByte:inputStr] > KMaxTextNum)) {
        [textView resignFirstResponder];
        //安卓是超过200不能继续输入
//        NSString *title = NSLocalizedString(@"text_exceed_max_length", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        textView.text = [self getStringFromTextString:inputStr];
    }
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize textSize = [textView sizeThatFits:constraintSize];

    if (textSize.height >= kMaxTextViewHeight) {
        textSize.height = kMaxTextViewHeight;
        textView.scrollEnabled = YES;
    } else {
        textView.scrollEnabled = NO;
    }

    CGRect viewFrame = self.textfiledView.frame;
    CGFloat diffHeight = textSize.height - frame.size.height;
    self.textfiledView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y - diffHeight, viewFrame.size.width, diffHeight + viewFrame.size.height);
    
    self.sendButton.frame = CGRectMake(CGRectGetMaxX(textView.frame), 0, self.sendButton.size.width, diffHeight + viewFrame.size.height);
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, textSize.height);
}

// 计算字符串的实际长度
-(NSInteger)caculateStringByte:(NSString *)string{
    
    NSInteger count = 0;
    NSInteger count1 =0;
    for (int i =0; i < string.length; i++)
         {
             unichar c = [string characterAtIndex:i];
             if (c >=0x4E00 && c <=0x9FA5)
             {
                 count ++;
                 
             }
             else
             {
                 count1 ++;
                 
             }
         }
         
    NSLog(@"汉字%ld字母%ld",(long)count,(long)count1);
    return (count * 2 + count1);
}

// 获取字符串长度为200时的真正使用的字符串
-(NSString *)getStringFromTextString:(NSString *)string{
    NSInteger count = 0;
    for (int i =0; i < string.length; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (c >=0x4E00 && c <=0x9FA5)
        {
            count += 2 ;
            
        }
        else
        {
            count += 1;
            
        }
        
        if (count > 200) {
            return [string substringToIndex:i-1];
        }
    }
    
    return nil;
}

// SFA-18581 IQKeyboard 处理偏移问题屏蔽此处功能
//-(void)changeTextfiledView:(NSNotification *)noti{
//
//    //从userInfo里面取出来键盘最终的位置
//    NSValue *rectValue = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
//    CGRect rect = [rectValue CGRectValue];
//
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && INTERFACE_IS_PAD) {
//        rect = CGRectMake(rect.origin.y , rect.origin.x, rect.size.width, rect.size.height);
//    }
//
//    [UIView animateWithDuration:0.25 animations:^{
//        self.textfiledView.y = rect.origin.y - self.textfiledView.height;
//    }];
//}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [self sendTextWithTextView:textView];
        return NO;
    }

    if (IOS7_OR_LATER) {
        if ([[textView textInputMode].primaryLanguage isEqualToString:@"emoji"] || [self stringContainsEmoji:text] ) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return [self stringContainsEmoji:text];
    }
}

- (void)backgroundViewTapped:(UITapGestureRecognizer *)recognizer {
    [self.backgroundView setHidden:YES];
    
    [self.textfiledView endEditing:YES];
}



/*#####################################################  添加回复功能  ###############################################################################*/
- (void)send:(UIButton *)sender {
    [self sendTextWithTextView:self.msgTextView];
}

- (void)sendTextWithTextView:(UITextView *)textView {
    [self.sendButton setEnabled:NO];
    //            MSTD-7386 董宏标准产品修改
    [self.backgroundView setHidden:YES];
    [self.textfiledView endEditing:YES];
    if (textView.text.length && ![self isEmpty:textView.text]) {
//
//        
//        RevertArrayModel * revertModel = [RevertArrayModel new];
//        revertModel.revertMsg = textView.text;
//        if (self.inputStr.count > 0) {
//            revertModel.userName = [WSAppData getObjectbyKey:EMPNAME];
//            revertModel.reply_time = [WSCurrentTime getDateTime];
//            
////            revertModel.reply_time = [self getEn_USString];
//        } else{
//            revertModel.userName = [WSAppData getObjectbyKey:EMPNAME];
//            revertModel.reply_time = [WSCurrentTime getDateTime];  // winSFA MSTD-3560 以@"yyyy-MM-dd HH:mm:ss"标准，如果有其他样式的回复时间，让后台改
////            revertModel.reply_time = [self getEn_USString];
//
//        }
//        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.inputStr];
//        [tempArray insertObject:revertModel atIndex:0];
    

        //更新自己的评论
        [self uploadSelfComment:textView.text];
        
//        // 这里日后可能还需要优化回复条数的问题，安卓现在为 下发多少条就显示多少条。
//        NSString *totalStr = [NSString stringWithFormat:NSLocalizedString(@"%zd", nil),tempArray.count];
//        self.title = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topic_reply", nil),totalStr];
//        self.inputStr = tempArray;
//        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
    }else{
        NSString *title = NSLocalizedString(@"bulletin_detail_reply_no_content", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        [self.sendButton setEnabled:YES];

    }
    
    [self textViewDidChange:textView];
}

-(NSString *)getEn_USString{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    return [formatter stringFromDate:currentDate];
}
-(void)uploadSelfComment:(NSString*)aComment
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selfCommentFinished:) name:SELFMSGNOTIFY object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr uploadComment:aComment NotifyName:SELFMSGNOTIFY MSGID:self.m_MSG.Id Receiver:nil];
}

-(void)selfCommentFinished:(id)sender
{
    [self.sendButton setEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SELFMSGNOTIFY object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *responseDictonary = [info objectFromJSONString];

    NSString *result = [responseDictonary objectForKey:@"result"];

    //NSLog(@"info is %@",info);
    if (error.code != 0) {
        NSString *NONetWorkString = NSLocalizedString(@"network_failure",nil);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NONetWorkString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        if (INTERFACE_IS_PHONE) {
            hud.yOffset = [UIDevice isRetina4inch] ? -40.0f : -80.0f;
        }
        else
        {
            hud.yOffset = -100.0f;
        }
        
        return;
    }else{
        
        NSString *SendSuccessString = NSLocalizedString(@"errcode_success",nil);
        MBProgressHUDMessageType type = MBProgressHUDMessageTypeDone;
        if ([result isEqualToString:@"0"]) {        //失败
            SendSuccessString = NSLocalizedString(@"fail_upload",nil);
            type = MBProgressHUDMessageTypeFailed;
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:SendSuccessString tips:nil tapTarget:nil action:nil type:type];
        // 回复数据传成功后 发通知去修改详情界面的回复条数
           // NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        
            //[dict setValue:self.inputStr forKey:@"RevertArray"];
        
           // [[NSNotificationCenter defaultCenter] postNotificationName:@"RevertArray" object:nil userInfo:dict];
        if (INTERFACE_IS_PHONE) {
            hud.yOffset = [UIDevice isRetina4inch] ? -40.0f : -80.0f;
        }
        else
        {
            hud.yOffset = -100.0f;
        }
        
        if (type == MBProgressHUDMessageTypeFailed) {
            return;
        }
        
        // 应该上传成功后才更新列表。
        [self.backgroundView setHidden:YES];
        [self.textfiledView endEditing:YES];
        if (self.msgTextView.text.length && ![self isEmpty:self.msgTextView.text]) {
            
            
            RevertArrayModel * revertModel = [RevertArrayModel new];
            revertModel.revertMsg = self.msgTextView.text;
            if (self.inputStr.count > 0) {
                revertModel.userName = [WSAppData getObjectbyKey:EMPNAME];
                revertModel.reply_time = [WSCurrentTime getDateTime];
                
                //            revertModel.reply_time = [self getEn_USString];
            } else{
                revertModel.userName = [WSAppData getObjectbyKey:EMPNAME];
                revertModel.reply_time = [WSCurrentTime getDateTime];  // winSFA MSTD-3560 以@"yyyy-MM-dd HH:mm:ss"标准，如果有其他样式的回复时间，让后台改
                //            revertModel.reply_time = [self getEn_USString];
                
            }
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.inputStr];
            [tempArray insertObject:revertModel atIndex:0];
            
            // 这里日后可能还需要优化回复条数的问题，安卓现在为 下发多少条就显示多少条。
            NSString *totalStr = [NSString stringWithFormat:NSLocalizedString(@"%zd", nil),tempArray.count];
            self.title = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topic_reply", nil),totalStr];
            self.inputStr = tempArray;
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            self.msgTextView.text = @"";
            [self textViewDidChange:self.msgTextView];

        }
        
        
        
       // 每次回复一条之后，都同步一次回复的条数
        NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults] objectForKey:LastReplyCount] mutableCopy];
        NSInteger replyCount = 0;
        if (!dict) {
            dict = [[NSMutableDictionary alloc]init];
        }
        NSString * keyString = [NSString stringWithFormat:@"%@_%@",[WSAppData getObjectbyKey:APPDATA_EMPID],self.m_MSG.Id];
        replyCount = [dict[keyString] integerValue];

        [dict setObject:@(replyCount + 1) forKey:keyString];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:LastReplyCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    

}
//判断内容是否全部为空格  yes 全部为空格  no 不是
- (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}


//是否含有表情
- (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    // 这里是后期补充的内容:九宫格判断
    if (!isMatch) {
        NSString *other = @"➋➌➍➎➏➐➑➒";
        unsigned long len=string.length;
        for(int i=0;i<len;i++)
        {
            unichar a=[string characterAtIndex:i];
            if(!((isalpha(a))
                 ||(isalnum(a))
                 ||((a=='_') || (a == '-'))
                 ||((a >= 0x4e00 && a <= 0x9fa6))
                 ||([other rangeOfString:string].location != NSNotFound)
                 )){
            }else{
                return NO;
            }
        }
        
    }
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

-(void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
/*#####################################################  添加回复功能  ###############################################################################*/

@end

