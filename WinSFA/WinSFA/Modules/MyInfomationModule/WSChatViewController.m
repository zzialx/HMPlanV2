//
//  ChatViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSChatViewController.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
#import "WSMsgReceiver.h"
#import "WSMsgReceiversViewController.h"

@implementation WSChatViewController
@synthesize m_MSG = _m_MSG;
@synthesize m_receivers;
@synthesize m_selectReceivers;
@synthesize m_HUD;

#define SELECTRECEIVE       @"selectReceive"

#define CHATFILENAME        @"chatLog.xml"

#define TEXTFIELDTAG	100
#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
#define LOADINGVIEWTAG	400
#define SELFMSGNOTIFY       @"selfMsg"
#define ADDRECEIVER         @"addreceiver"




-(void)partnersCommentsFinished:(id)sender
{
    [self requestReceivers];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *NONetWorkString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NONetWorkString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else
    {
        [chatArray removeAllObjects];
                
        NSString *info = [[sender userInfo] objectForKey:DATAS];
        NSDictionary* l_info = [info objectFromJSONString];
        NSArray* l_msgreplies = [l_info objectForKey:@"msgreplies"];
        
        if(l_msgreplies != nil&& [l_msgreplies count]>0)
        {
            for(NSDictionary* content in l_msgreplies)
            {
             
               UIView *chatView = [self bubbleView:[NSString stringNotNilWithValue:[content objectForKey:@"rep"]]
                                              from:YES];
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                NSString *rep = [content objectForKey:@"rep"];
                [dictionary setObject:[NSString stringNotNilWithValue:rep] forKey:@"text"];
                [dictionary setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPNAME]] forKey:@"speaker"];
                [dictionary setObject:chatView forKey:@"view"];
                [chatArray addObject:dictionary];
            }
        }
        
        //NSLog(@"info is %@",info);
        UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
        [tableView reloadData];
    }
    return;
}

-(void)selfCommentFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SELFMSGNOTIFY object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    //NSString *info = [[sender userInfo] objectForKey:DATAS];
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
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:SendSuccessString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        if (INTERFACE_IS_PHONE) {
            hud.yOffset = [UIDevice isRetina4inch] ? -40.0f : -80.0f;
        }
        else
        {
            hud.yOffset = -100.0f;
        }
        
    }
}

-(void)uploadSelfComment:(NSString*)aComment
{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr uploadComment:aComment NotifyName:SELFMSGNOTIFY MSGID:self.m_MSG.Id Receiver:self.m_selectReceivers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selfCommentFinished:) name:SELFMSGNOTIFY object:nil];

}

-(void)getPartnersComments
{
    NSString *GetMString = NSLocalizedString(@"msg_obtaining",nil);
    self.m_HUD.labelText = GetMString;
    [self.m_HUD show:YES];
    
    // 避免键盘遮挡self.m_HUD
    UITextField *textField = (UITextField *)[self.view viewWithTag:TEXTFIELDTAG];
    [textField resignFirstResponder];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr getMSGWithId:self.m_MSG.Id NotifyName:PARTNERSMSG_NOTIFY];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(partnersCommentsFinished:) name:PARTNERSMSG_NOTIFY object:nil];

}

- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
	// build single chat bubble cell with given text
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
	returnView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:21 topCapHeight:14]];
    
	UIFont *font = [UIFont systemFontOfSize:12];

    
	CGSize size = [text ws_sizeWithFont:font constrainedToWidth:150.0f lineBreakMode:NSLineBreakByCharWrapping];
    
	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(21.0f, 14.0f, size.width+10, size.height+10)];
	bubbleText.backgroundColor = [UIColor clearColor];
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = NSLineBreakByCharWrapping;
	bubbleText.text = text;
	
	bubbleImageView.frame = CGRectMake(0.0f, 0.0f, 200.0f, size.height+40.0f);
	if(fromSelf)
		returnView.frame = CGRectMake(self.view.bounds.size.width - 200, 10.0f, 200.0f, size.height+50.0f);
	else
		returnView.frame = CGRectMake(0.0f, 10.0f, 200.0f, size.height+50.0f);
	
	[returnView addSubview:bubbleImageView];
	[returnView addSubview:bubbleText];
    
	return returnView;
}


-(id)init
{
    if(self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
        
        
	}
	
	return self;
}

-(id)initWithMSG:(WSMsgsBean_msg*)aMSG
{
    if(aMSG==nil)
        return nil;
    self.m_MSG = aMSG;
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

    chatArray = [[NSMutableArray alloc] initWithCapacity:0];
    isMySpeaking = YES;
    loadingLog = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    chatFile = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:CHATFILENAME]];
    
    currentString = [[NSMutableString alloc] initWithCapacity:0];
    currentChatInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSString *UpdateString = NSLocalizedString(@"refresh",nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithTitle:UpdateString 
                                               style:UIBarButtonItemStyleBordered 
                                               target:self
                                               action:@selector(getPartnersComments)];
    
    
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:chatFile])
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width - 60.0, 31.0f)];
    textfield.tag = TEXTFIELDTAG;
    textfield.delegate = self;
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.enablesReturnKeyAutomatically = YES;
    textfield.borderStyle = UITextBorderStyleRoundedRect;
    textfield.returnKeyType = UIReturnKeySend;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height - 44.0f, self.view.bounds.size.width, 44.0f)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    toolBar.tag = TOOLBARTAG;
    NSMutableArray* allitems = [[NSMutableArray alloc] init];
    [allitems addObject:[[UIBarButtonItem alloc] initWithCustomView:textfield]];
    
    if([self.m_receivers count] > 0) {
        UIButton* l_addPerson = [UIButton buttonWithType:UIButtonTypeContactAdd];
        l_addPerson.frame = CGRectMake(260.0f, 0.0f, 31.0f, 31.0f);
        [l_addPerson addTarget:self action:@selector(addPerson) forControlEvents:UIControlEventTouchUpInside];
        [allitems addObject:[[UIBarButtonItem alloc] initWithCustomView:l_addPerson]];
    } else {
        CGRect rect = textfield.frame;
        rect.size.width += 31.0f;
        textfield.frame = rect;
    }
    
    [toolBar setItems:allitems];
    [self.view addSubview:toolBar];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - 44.0f) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
    tableView.tag = TABLEVIEWTAG;
    [self.view addSubview:tableView];
    
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 372.0f)];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    loadingView.backgroundColor = [UIColor darkGrayColor];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
    [activityView startAnimating];
    [loadingView addSubview:activityView];
    loadingView.hidden = YES;
    loadingView.tag = LOADINGVIEWTAG;
    [self.view addSubview:loadingView];

    m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
    m_HUD.frame = CGRectMake(m_HUD.frame.origin.x, m_HUD.frame.origin.y - 40, m_HUD.frame.size.width,m_HUD.frame.size.height);
//    m_HUD.mode = MBProgressHUDModeText;
    [self.view addSubview:m_HUD];
    [self getPartnersComments];
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


#pragma mark text file methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// return NO to disallow editing.
	if(loadingLog)
		return NO;
    
//	self.navigationItem.rightBarButtonItem.title = @"hidde keyboard";
//	UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
//	toolbar.frame = CGRectMake(0.0f, 372-self.m_keyBoardHeight, 320.0f, 44.0f);
//	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
//	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 156.0f);
//	if([chatArray count])
//		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//	self.navigationItem.rightBarButtonItem.title = @"clear chat log";
	UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, self.view.bounds.size.height - 44.0f, self.view.bounds.size.width, 44.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - 44.0f);
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(self.m_selectReceivers==nil&&[self.m_receivers count] > 0&&[self.m_selectReceivers count]>0)
    {
        NSString *ChooseReceiverString = NSLocalizedString(@"no_receiver",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:ChooseReceiverString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return NO;
    }
	// called when 'return' key pressed. return NO to ignore.
	self.navigationItem.leftBarButtonItem.title = @"save chat log";
	self.navigationItem.leftBarButtonItem.enabled = YES;
	UIView *chatView = [self bubbleView:[NSString stringNotNilWithValue:textField.text] 
								   from:isMySpeaking];
	[chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"text", [WSAppData getObjectbyKey:APPDATA_EMPNAME], @"speaker", chatView, @"view", nil]];
//	isMySpeaking = !isMySpeaking;
    isMySpeaking = YES;
    //更新自己的评论
    [self uploadSelfComment:textField.text];
    
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	[tableView reloadData];
	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	textField.text = @"";
	return YES;
}

#pragma mark navigation button methods
- (BOOL) hideKeyboard {
	UITextField *textField = (UITextField *)[self.view viewWithTag:TEXTFIELDTAG];
	if(textField.editing) {
		textField.text = @"";
		[self.view endEditing:YES];
		
		return YES;
	}
	
	return NO;
}

- (void) clickOutOfTextField:(id)sender {
	[self hideKeyboard];
}

- (void) rightButtonAction {
	if(![self hideKeyboard]) {
        NSString *UpdateString = NSLocalizedString(@"refresh",nil);
        UIBarButtonItem *updata = [[UIBarButtonItem alloc]
                                   initWithTitle:UpdateString
                                   style: UIBarButtonItemStylePlain
                                   target:self 
                                   action:@selector(getPartnersComments)];
        
        self.navigationItem.leftBarButtonItem = updata;

	}
}

- (void) leftButtonAction {
	if([chatArray count]) {
		// save log
		NSMutableString *xmlString = [NSMutableString stringWithString:@"<?xml version='1.0' encoding='UTF-8'?>"];
		[xmlString appendString:@"<chats>"];
		for(NSDictionary *chatInfo in chatArray) {
			[xmlString appendFormat:@"<chat><speaker><![CDATA[%@]]></speaker><text><![CDATA[%@]]></text></chat>", [chatInfo objectForKey:@"speaker"], [chatInfo objectForKey:@"text"]];
		}
		[xmlString appendString:@"</chats>"];
        
		NSError *error;
		BOOL saveRes = [xmlString writeToFile:chatFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:saveRes?@"save ok":@"save failed" message:saveRes?[NSString stringWithFormat:@"save to file: %@", CHATFILENAME]:[NSString stringWithFormat:@"error code: %ld", (long)error.code]];
        [alert setCancelButtonWithTitle:@"confirm" block:nil];
        [alert show];
	} else {
		// load log
		loadingLog = YES;
		self.navigationItem.leftBarButtonItem.enabled = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		UIView *loadingView = (UIView *)[self.view viewWithTag:LOADINGVIEWTAG];
		loadingView.hidden = NO;
        
		[NSThread detachNewThreadSelector:@selector(loadThread:) toTarget:self withObject:chatFile];
	}
}

- (void) finshLoadFile {
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	[tableView reloadData];
    
	UIView *loadingView = (UIView *)[self.view viewWithTag:LOADINGVIEWTAG];
	loadingView.hidden = YES;
    
	loadingLog = NO;
	self.navigationItem.leftBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	NSDictionary *chatInfo = [chatArray lastObject];
	if([[chatInfo objectForKey:@"speaker"] isEqualToString:@"self"])
        isMySpeaking = NO;
	else
        isMySpeaking = YES;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIView *chatView = [[chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
	return chatView.frame.size.height+10.0f;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        
		cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Set up the cell...
	NSDictionary *chatInfo = [chatArray objectAtIndex:[indexPath row]];
	for(UIView *subview in [cell.contentView subviews])
		[subview removeFromSuperview];
	[cell.contentView addSubview:[chatInfo objectForKey:@"view"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideKeyboard];
}


- (void) keyboardWasShown:(NSNotification *) notif{ 
    NSDictionary *info = [notif userInfo]; 
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey]; 
    CGSize keyboardSize = [value CGRectValue].size; 
    //NSLog(@"keyBoard:%f", keyboardSize.height);  //216 
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        keyboardSize = CGSizeMake(keyboardSize.height, keyboardSize.width);
    }
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, self.view.bounds.size.height - 44.0f - keyboardSize.height, self.view.bounds.size.width, 44.0f);
    
    UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - 44 - keyboardSize.height);
    if([chatArray count])
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    ///keyboardWasShown = YES; 
} 
- (void) keyboardWasHidden:(NSNotification *) notif{ 
    //NSDictionary *info = [notif userInfo];
    
    //NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    //CGSize keyboardSize = [value CGRectValue].size;
    //NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height); 
    // keyboardWasShown = NO; 
    
}


-(void)addPerson
{
    if([self.m_receivers count] < 1)
        return;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectReceived:) name:SELECTRECEIVE object:nil];
    WSMsgReceiversViewController *mrvc = [[WSMsgReceiversViewController alloc]initWithDatasSources:self.m_receivers];
    [self.navigationController pushViewController:mrvc animated:YES];
}

-(void)requestReceivers
{

    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    NSMutableDictionary* l_dic = [[NSMutableDictionary alloc]init];
    [l_dic setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:@"empId"];
    [l_dic setObject:[NSString stringNotNilWithValue:self.m_MSG.Id] forKey:@"msgId"];
    [l_dic setObject:ADDRECEIVER forKey:NT_NAME];
    [uploadMgr requestMsgReceivers:l_dic];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestReceviersFinished:) name:ADDRECEIVER object:nil];
    
}

-(void)requestReceviersFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ADDRECEIVER object:nil];
    [m_HUD hide:YES afterDelay:1.5];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSArray* l_receivers = [[info objectFromJSONString]objectForKey:@"msgEmpList"];
    if([l_receivers count]>0&& self.m_receivers == nil)
    {
        m_receivers = [[NSMutableArray alloc]init];
        for(NSDictionary* f_dic in l_receivers)
        {
            WSMsgReceiver* f_receive = [[WSMsgReceiver alloc]initWithObject:f_dic];
            [self.m_receivers addObject:f_receive];
        }
    }

}

-(void)selectReceived:(id)sender
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SELECTRECEIVE object:nil];
    NSDictionary* l_dic =(NSDictionary*)[sender object];
    NSArray* l_receives = [l_dic allValues];
    if(self.m_selectReceivers == nil)
    {
        m_selectReceivers = [[NSMutableArray alloc]init];
        
    }else
    {
        [self.m_selectReceivers removeAllObjects];
    }
    for(NSString* f_name in l_receives)
    {
        NSDictionary* f_nameDic = [NSDictionary dictionaryWithObject:f_name forKey:@"empId"];
        [self.m_selectReceivers addObject:f_nameDic];
    }
}
@end
