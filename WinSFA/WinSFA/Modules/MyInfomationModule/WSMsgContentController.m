//
//  MsgContentController.m
//  WinChannelIPhone
//
//  Created by winchannel on 11-10-21.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "WSMsgContentController.h"
#import "WSChatViewController.h"
#import "AsyncImageView.h"
//#import "ConfigFileController.h"
#import "WSServerIPController.h"
#import "WSAppData.h"
#import "WSServerIPList.h"

@interface WSMsgContentController()

@property (nonatomic, strong)NSURLConnection *iURLConnection;

- (void)markAsReaded;

@end

@implementation WSMsgContentController
@synthesize textviewContent=_textviewContent;
@synthesize contentString = _contentString;
@synthesize m_Msg = _m_Msg;
@synthesize prodImageView;
@synthesize imageData = _imageData;
@synthesize alert;
@synthesize activity;
@synthesize iURLConnection = _iURLConnection;

- (id)initWithNibName:(NSString *)nibNameOrNil MSG:(WSMsgsBean_msg *)aMsg
{
    if(aMsg==nil)
        return nil;
    self = [self initWithNibName:nibNameOrNil bundle:nil];
    if(self != nil)
    {
        if(aMsg.cont==nil)
        {
            NSString *NOMsgString = NSLocalizedString(@"今日无消息",nil);
            self.contentString = NOMsgString;

        }
        else
            self.contentString = [NSString stringWithString:aMsg.cont];
        self.m_Msg = aMsg;
        return self;
    }
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableData *)imageData
{
    if (!_imageData) {
        _imageData = [[NSMutableData alloc] init];
    }
    return _imageData;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


-(void)addComment
{
    WSChatViewController* l_chatViewController = [[WSChatViewController alloc]initWithMSG:self.m_Msg];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:l_chatViewController animated:YES];
}

//add 图片的问题 at 2012－03－26 by yanguoshuai
-(void)getPic
{
    self.view.frame = CGRectMake(0, 0, 320, 376);
    if (self.m_Msg.url==nil||[self.m_Msg.url isEqualToString:@"null"]||[self.m_Msg.url length]<=0||[self.m_Msg.url isEqualToString:@"<null>"]) 
    {
        self.textviewContent.frame=CGRectMake(0, 0, 320, 374);
    }else
    {
        self.textviewContent.frame=CGRectMake(0, 90,320,286);
        self.activity=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.activity setFrame:CGRectMake(150, 40, 20, 20)];
        [self.activity startAnimating];
        [self.view addSubview:self.activity];
        
        if (self.prodImageView.image!=nil) 
        {
            self.prodImageView.image=nil;
        }else 
        {

            WSServerIPList *serverIpArr=[WSAppData getObjectbyKey:SERVERURL];

            if (!serverIpArr || !serverIpArr.serverIPArray || ![serverIpArr.serverIPArray count] )
            {
                [self.activity stopAnimating];
                [self.activity removeFromSuperview];
                return;
            }
            
            WSServerIPController *serverIP=[serverIpArr.serverIPArray objectAtIndex:0];
            
            NSString *tmpStr=[self.m_Msg.url stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
            
            NSString *urlString=[tmpStr stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            
            NSString *s1 = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)urlString, NULL,(CFStringRef) @"!*'();:@&=+$,%#[]", kCFStringEncodingUTF8));
            
            NSString *url=[[NSString alloc]initWithFormat:@"%@%@",serverIP.ServerIPString,s1];
            
            self.imageData = nil;
            NSURL *picURL=[NSURL URLWithString:url];
            NSURLRequest *urlRequest=[NSURLRequest requestWithURL:picURL];
            
            [self.iURLConnection cancel];
            self.iURLConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        }

    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [connection cancel];
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
    self.prodImageView.image = [UIImage imageNamed:@"downloadimage_failed.png"];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
    if (self.imageData) {
        self.prodImageView.image=[UIImage imageWithData:self.imageData];
    }else{
        self.prodImageView.image = [UIImage imageNamed:@"downloadimage_failed.png"];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self getPic];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.iURLConnection cancel];
    [self.activity removeFromSuperview];
    [self.activity stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //modity 可以上下翻页和和不可编辑 by yanguoshuai at 2012－03－23
    self.textviewContent.dataDetectorTypes = UIDataDetectorTypeNone;
    self.textviewContent.scrollEnabled =YES;
    self.textviewContent.editable = NO;
    // Do any additional setup after loading the view from its nib.
    if(self.contentString==nil)
        self.textviewContent.text = @"";
    else
        self.textviewContent.text = self.contentString;
    NSString *replyString = NSLocalizedString(@"topic_reply",nil);
    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
                               initWithTitle:replyString 
                               style: UIBarButtonItemStylePlain
                               target:self 
                               action:@selector(addComment)];
    self.navigationItem.rightBarButtonItem = updata;
    
    
    
    // set access flag
    [self markAsReaded];
    
    // get picture
    [self getPic];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)markAsReaded
{
    NSNumber *value = [NSNumber numberWithBool:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@", self.m_Msg.s, self.m_Msg.Id];
    if (value) {
        [user setObject:value forKey:key];
    }
    [user synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)dealloc
{
    [self.iURLConnection cancel];
}

@end
