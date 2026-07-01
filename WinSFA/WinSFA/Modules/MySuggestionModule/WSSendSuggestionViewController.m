//
//  SendSuggestionViewController.m
//  Suggestion
//
//  Created by winchannel on 12-2-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSendSuggestionViewController.h"
#import "WSRequestHelper.h"
#import "WSPostCardViewController.h"
#import "WSSugBean.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
#import "WSReplyPostCardViewController.h"
#import "WSNavigationBar.h"
#import "GetMD5byStr.h"

#define CELL_HEIGHT             35
#define TEXTFIELD_START_INDEX   100
#define TEXTVIEW_INDEX          200
#define ADD_BUTTON_INDEX        300
#define POSTSUGGESTION          @"postSuggestion"

// 内容最大输入字数
#define MAXCHARACTERS           100

// 主题最大输入字数
#define THEME_MAXCHARACTERS     16


@interface WSSendSuggestionViewController()

@property (nonatomic, strong) NSMutableArray    *m_CellHeightArray;

@end


@implementation WSSendSuggestionViewController
@synthesize m_tableView = _m_tableView;
@synthesize m_TextFields = _m_TextFields;
@synthesize m_receivers = _m_receivers;
@synthesize m_HUD;
@synthesize m_titles;
@synthesize m_sugReplyBeanArray;
@synthesize m_currentMsgId;


-(void)closeKeyboard
{
    for(UITextField* f in self.m_TextFields)
    {
        [f resignFirstResponder];
    }
    for(UIView* view in self.view.subviews)
    {
        if([view isKindOfClass:[UITextView class]])
        {
            UITextView* l_tv = (UITextView*)view;
            [l_tv resignFirstResponder];
        }
    }
}
-(void)addPostCard:(id)sender
{
    if(self.currentFuncs != nil)
    {
        WSPostCardViewController* l_postCardViewController =[[WSPostCardViewController alloc]initWithStyle:UITableViewStylePlain];
        
        [self.ownParentViewController.navigationController pushViewController:l_postCardViewController animated:YES];
    }else
    {
        WSReplyPostCardViewController* rpcvc = [[WSReplyPostCardViewController alloc]initWithOptArray:self.m_sugReplyBeanArray.optArray];
        rpcvc.m_isReceiver = YES;
        
        [self.ownParentViewController.navigationController pushViewController:rpcvc animated:YES];
    }
    
}

-(void)receivePostcard:(id)sender
{
    NSDictionary* l_receivePostCard = [sender object];
    UITextField* l_receiver = (UITextField*)[self.view viewWithTag:TEXTFIELD_START_INDEX];
    self.m_receivers = [l_receivePostCard allValues];
    NSMutableString* receiverNames = [[NSMutableString alloc]init];
    for(WSSugBean* sug in self.m_receivers)
    {
        [receiverNames appendString:sug.m_name];
        [receiverNames appendString:@","];
    }
    l_receiver.text = receiverNames;
    
}
////add 发送完成后跳转页面   by yanguoshuai at 2012－03－26
//-(void)jumpSuggestListVC
//{
//    for (UIView * view in self.m_parentController.view.subviews) {
//        if ([view isKindOfClass:[UISegmentedControl class]]) {
//            UISegmentedControl *segmented=(UISegmentedControl *)view;
//            [segmented sendActionsForControlEvents:UIControlEventValueChanged];
//            [segmented setSelectedSegmentIndex:1];
//        }
//    }
//}
-(void)uploadFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:POSTSUGGESTION
                                                  object:nil];
    
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *errorString = NSLocalizedString(@"网络错误!",nil);
        m_HUD.labelText = errorString;
        [m_HUD hide:YES afterDelay:1.5];
        return;
    }else{
        NSString *SendSuccessString = NSLocalizedString(@"errcode_success",nil);
        m_HUD.labelText = SendSuccessString;
        [m_HUD hide:YES afterDelay:1.5];
        
        
        
        //添加发送成功后把收件人，主题和内容赋值为空 at 2012－04－01 by yanguoshuai
        for(UITextField* f in self.m_TextFields)
        {
            f.text=nil;
        }
        for(UIView* view in self.view.subviews)
        {
            if([view isKindOfClass:[UITextView class]])
            {
                UITextView* l_tv = (UITextView*)view;
                l_tv.text=nil;
            }
        }
        self.m_receivers=nil;
        
    }
    [self.m_tableView reloadData];
    
    
}
-(void)sendMessage
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:POSTSUGGESTION
                                               object:nil];
    //modity by yanguoshuai at 2012-02-23 加如果收件人为空的话要提示。
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (self.m_receivers==nil||self.m_receivers.count==0) {
        NSString *SelectReceiverString = NSLocalizedString(@"please_select_sentto",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:SelectReceiverString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if(self.currentFuncs != nil)
    {
        NSString *SuggestionString = NSLocalizedString(@"suggest_sending",nil);
        m_HUD.labelText = SuggestionString;
        [m_HUD show:YES];
        
        UITextField* l_textField = (UITextField*)[self.view viewWithTag:TEXTFIELD_START_INDEX+1];
        NSString* l_title = l_textField.text;
        UITextView* l_textView = (UITextView*)[self.view viewWithTag:TEXTVIEW_INDEX];
        NSString* l_content = l_textView.text;
        
        
        
        
        
        NSMutableDictionary* l_sendSuggestionDic = [[NSMutableDictionary alloc]init];
        if(self.m_receivers != nil)
            [l_sendSuggestionDic setObject:self.m_receivers forKey:@"receiver"];
        if(l_title != nil)
            [l_sendSuggestionDic setObject:l_title forKey:@"title"];
        else
            return;
        if(l_content != nil)
            [l_sendSuggestionDic setObject:l_content forKey:@"content"];
        else
            return;
        
        NSString* l_md5 = [NSString md5:[NSString
                                         stringWithFormat:@"%@%@%@%@",
                                         [WSAppData getObjectbyKey:APPDATA_EMPID],
                                         [WSCurrentTime getTimeMillisString],
                                         [WSAppData getObjectbyKey:APPDATA_BIZDATE],
                                         self.currentFuncs.fc
                                         ]];
        
        [l_sendSuggestionDic setObject:l_md5 forKey:@"suggestionMd5"];
        [l_sendSuggestionDic setObject:self.currentFuncs.fc forKey:@"suggestionFc"];
        
        
        WSRequestHelper * upload = [WSRequestHelper shareInstance];
        //发送建议
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadFinished:)
                                                     name:POSTSUGGESTION
                                                   object:nil];
        [upload uploadSendSuggestion:l_sendSuggestionDic Notify:POSTSUGGESTION];
    }else
    {
        NSString *ReplyString = NSLocalizedString(@"reply_sending",nil);
        m_HUD.labelText = ReplyString;
        [m_HUD show:YES];
        UITextView* l_textView = (UITextView*)[self.view viewWithTag:TEXTVIEW_INDEX];
        NSString* l_content = l_textView.text;
        
        
        NSMutableDictionary* l_sendSuggestionDic = [[NSMutableDictionary alloc]init];
        if(self.m_receivers != nil)
            [l_sendSuggestionDic setObject:self.m_receivers forKey:@"receiver"];
        
        
        if(l_content != nil)
            [l_sendSuggestionDic setObject:l_content forKey:@"content"];
        else
            return;
        
        [l_sendSuggestionDic setObject:self.m_currentMsgId forKey:@"suggestionMd5"];
        
        
        WSRequestHelper * upload = [WSRequestHelper shareInstance];
        //发送建议
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(uploadFinished:)
                                                     name:POSTSUGGESTION
                                                   object:nil];
        [upload postSuggestionReply:l_sendSuggestionDic Notify:POSTSUGGESTION SUGs:self.m_sugReplyBeanArray];
    }
    
    [self closeKeyboard];
    
}

-(id)initWithFuncs:(WSFuncsBean *)funcs Titles:(NSArray*)aTitles
{
    if(funcs==nil||[aTitles count]<1)
        return nil;
    
    self = [super initWithFuncs:funcs];
    if(self != nil)
    {
        m_titles = [NSArray arrayWithArray:aTitles];
        return self;
    }
    return nil;
}

-(id)initWithTitles:(NSArray*)aTitles
{
    if([aTitles count] < 1)
    {
        return nil;
    }
    
    self = [super init];
    if(self != nil)
    {
        m_titles = [NSArray arrayWithArray:aTitles];
        return self;
    }
    return nil;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receivePostcard:)
                                                name:POSTCARDRECEIVE
                                              object:nil];
    
    m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:m_HUD];
    
    _m_CellHeightArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:CELL_HEIGHT], [NSNumber numberWithFloat:60.0], nil];
    float tableViewHeight = 0.0;
    
    for (NSNumber *num in _m_CellHeightArray) {
        tableViewHeight += [num floatValue];
    }
    
    UITableView* l_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, tableViewHeight) style:UITableViewStylePlain];
    l_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    l_tableView.delegate = self;
    l_tableView.dataSource = self;
    self.m_tableView = l_tableView;
    [self.view addSubview:self.m_tableView];
    
    UITextView* l_textView = [[UITextView alloc]initWithFrame:CGRectMake(0, tableViewHeight, self.view.bounds.size.width, 165)];
    l_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    l_textView.tag = TEXTVIEW_INDEX;
    l_textView.delegate = self;
    UIFont* l_textViewFont = [UIFont fontWithName:@"Arial" size:18.0];
    [l_textView becomeFirstResponder];
    l_textView.font = l_textViewFont;
    [self.view addSubview:l_textView];
    
    _m_TextFields = [[NSMutableArray alloc]initWithCapacity:[self.m_titles count]];
    for(int i = 0; i < [self.m_titles count] ; i++)
    {
        if(i == 0){
            UITextField *textField = [[UITextField alloc] init];
            textField.frame = CGRectMake(80, 0, SCREEN_WIDTH - 80 - 40, 35.0);
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.tag = TEXTFIELD_START_INDEX+i;
            textField.enabled = NO;
            [self.m_TextFields addObject:textField];
        }else if (i == 1){
            UITextView *textView = [[UITextView alloc] init];
            textView.font = [UIFont systemFontOfSize:15];
            textView.frame = CGRectMake(65, 5, SCREEN_WIDTH - 75, 60.0);
            textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textView.tag = TEXTFIELD_START_INDEX+i;
            textView.delegate = self;
        
            [self.m_TextFields addObject:textView];
        }
        
//        UITextView *textView = [[UITextView alloc] init];
//        textView.scrollEnabled = NO;
//        textView.font = [UIFont systemFontOfSize:16.0];
//        textView.frame = CGRectMake(80, 0, textViewWidth, 35.0);
//        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        textView.tag = TEXTFIELD_START_INDEX+i;
//        textView.delegate = self;
//        
//        [self.m_TextFields addObject:textView];
    }
    
    
    
    if(self.currentFuncs == nil)
    {
        self.view.frame = CGRectMake(0, 0, 320, 436);
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self addToolBar];
    
}

- (void)addToolBar{
    
    NSString *SendString = NSLocalizedString(@"send_lable",nil);
    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
                               initWithTitle:SendString
                               style: UIBarButtonItemStylePlain
                               target:self
                               action:@selector(sendMessage)];
    if(self.currentFuncs != nil)
        self.ownParentViewController.navigationItem.rightBarButtonItem = updata;
    else
        self.navigationItem.rightBarButtonItem = updata;
    
    //add By wangdongyan 2012-03-01 for 左边的恢复按钮改为返回按钮
    //    NSString *BackString = NSLocalizedString(@"back_label",nil);
    //    UIBarButtonItem *backBtn=[[UIBarButtonItem alloc]initWithTitle:BackString style:UIBarButtonItemStylePlain target:self action:@selector(returnTofrontView)];
    //    self.navigationItem.leftBarButtonItem=backBtn;
    
    if (self.navigationController.viewControllers.count>1) {
        //        UIFont *font = nil;
        //        CGFloat fontWidth = 0;
        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        //            font = [UIFont systemFontOfSize:18];
        //            fontWidth = 17;
        //        }else {
        //            font = [UIFont systemFontOfSize:16];
        //            fontWidth = 8;
        //        }
        //
        //        CGSize titleSize = [BackString sizeWithFont:font forWidth:TITLE_MAX_WIDTH - fontWidth - 10 lineBreakMode:NSLineBreakByCharWrapping];
        //        [self leftItemImage:@"nav_back_btn.png" target:self action:@selector(backAction) title:BackString font:font buttonWidth:titleSize.width + fontWidth + 10 fontLeftWith:fontWidth];
        //        [self backItemAction:@selector(backAction) target:self];
        [self initializationBackItemAction];
    }
    
}
-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:nil target:nil];
    }
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (void) backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


//add By wangdongyan 2012-03-01 for 当点击返回按钮时，回到上一个界面
-(void)returnTofrontView{
    [self.navigationController popViewControllerAnimated:YES];
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma tableview delegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio{
    return [self.m_titles count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: SimpleTableIdentifier];
    }
    
    NSString* l_cellLable = [self.m_titles objectAtIndex:indexPath.row];
    
    NSString *SubjectString = NSLocalizedString(@"theme",nil);
    if(![l_cellLable isEqualToString:SubjectString])
    {
        UITextView* l_textView = [self.m_TextFields objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.m_titles objectAtIndex:indexPath.row];
        [cell.contentView addSubview:l_textView];
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addButton.frame = CGRectMake(108.0, 112.0, 29.0, 29.0);
        [addButton addTarget:self action:@selector(addPostCard:) forControlEvents:UIControlEventTouchUpInside];
        addButton.tag = ADD_BUTTON_INDEX + indexPath.row;
        cell.accessoryView = addButton;
    }else
    {
        UITextView* l_textField = [self.m_TextFields objectAtIndex:indexPath.row];
        cell.textLabel.text = [self.m_titles objectAtIndex:indexPath.row];
        [cell.contentView addSubview:l_textField];
        
    }
    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [[_m_CellHeightArray objectAtIndex:indexPath.row] floatValue];
}


#pragma textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
}

#pragma textviewdelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if (textView.tag == TEXTVIEW_INDEX) {
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
        //获取高亮部分内容
        //NSString * selectedtext = [textView textInRange:selectedRange];
        
        //如果有高亮且当前字数开始位置小于最大限制时允许输入
        if (selectedRange && pos) {
            NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
            NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
            NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
            
            if (offsetRange.location < MAXCHARACTERS) {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        
        
        NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        NSInteger caninputlen = MAXCHARACTERS - comcatstr.length;
        
        if (caninputlen >= 0)
        {
            return YES;
        }
        else
        {
            NSInteger len = text.length + caninputlen;
            //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
            NSRange rg = {0,MAX(len,0)};
            
            if (rg.length > 0)
            {
                NSString *s = @"";
                //判断是否只普通的字符或asc码(对于中文和表情返回NO)
                BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
                if (asc) {
                    s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
                }
                else
                {
                    __block NSInteger idx = 0;
                    __block NSString  *trimString = @"";//截取出的字串
                    //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                             options:NSStringEnumerationByComposedCharacterSequences
                                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                              
                                              if (idx >= rg.length) {
                                                  *stop = YES; //取出所需要就break，提高效率
                                                  return ;
                                              }
                                              
                                              trimString = [trimString stringByAppendingString:substring];
                                              
                                              idx++;
                                          }];
                    
                    s = trimString;
                }
                //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
                [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            }
            return NO;
        }
        
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.tag == TEXTVIEW_INDEX) {
        
        [self verifyIfTextNumsOverMaxNum:MAXCHARACTERS WithTextView:textView];
        
    }else if (textView.tag == TEXTFIELD_START_INDEX + 1) {
        
        [self verifyIfTextNumsOverMaxNum:THEME_MAXCHARACTERS WithTextView:textView];
        
    }
    
}

- (void)verifyIfTextNumsOverMaxNum:(NSInteger)maxNum WithTextView:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > maxNum)
    {
        [textView resignFirstResponder];
        
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *title = NSLocalizedString(@"text_max_length_100", nil);
        
        if (maxNum != 100) {
            title = [NSString stringWithFormat:@"字符个数不能大于%ld", (long)maxNum];
        }
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
        NSString *s = [nsTextContent substringToIndex:maxNum];
        
        [textView setText:s];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self closeKeyboard];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self closeKeyboard];
}
@end
