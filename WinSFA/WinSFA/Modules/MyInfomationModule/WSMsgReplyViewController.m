//
//  MsgReplyViewController.m
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 11/7/12.
//
//
#define SELFMSGNOTIFY       @"selfMsg"

#import "WSMsgReplyViewController.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSCurrentTime.h"
#import "WSMsgsBean_msg.h"
//#import "ConfigFileController.h"

@interface WSMsgReplyViewController ()

@end

@implementation WSMsgReplyViewController
@synthesize msg = _msg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//！！！旧acvt代码都已删除，此页面与新acvt代码不兼容，目前不知道使用场景，遇见使用此页面时，应该根据新acvt代码重构。

/*
-(void)upload
{
    NSString *acvtData = [WSJSONBuilder buildActivitybyFuncs:self.currentFuncs
                                                      acvt:self.m_currentAcvt
                                                   isPhoto:NO
                                                     Store:self.currentStore
                                               subempStore:self.currentSubEmpStore
                                                     cells:self.markDictionary
                                                       md5:self.md5
                                                    Others:self.m_othersDic];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr uploadComment:@"" NotifyName:SELFMSGNOTIFY MSGID:self.msg.Id Receiver:nil AcvtData:acvtData Md5:self.md5];
    [self inserTable]; 
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initView
{
    self.m_othersDic = [[NSMutableDictionary alloc]init];
    // SPACEHEIGTH == 5
    UITableView* tv = [[UITableView alloc]initWithFrame:CGRectMake(0, self.y_point-5, 320, 480-20-88) style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    self.tableView = tv;
    
    [self.view addSubview:self.tableView];
    int height = 10 ;
    int count = [self.QstForTextArray count];
    if(count >0)
    {
        UIView* l_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0)];
        l_view.tag = 105;
        for(WSAcvtBean_qst* ab_qst in self.QstForTextArray)
        {
            if([ab_qst.qstType isEqualToString:QST_TYPE_GG])
            {
                [self locationMe];
            }
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_GF])
            {
                [self addGpsView];
            }
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_L])
            {
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 300, 20)];
                float fontHeight = lable.font.capHeight;
                [lable adjustsFontSizeToFitWidth];
                lable.text = ab_qst.qstName;
                lable.backgroundColor =kCLEAR_COLOR_value;
                
                NSString* l_dis = [self getAcvtDisByQst:ab_qst];
                if(l_dis != nil)
                {
                    lable.text = [NSString stringWithFormat:@"%@%@",ab_qst.qstName,l_dis];
                }
                [l_view addSubview:lable];
                height += (fontHeight+10);
                
            }
            if(
               [ab_qst.qstType isEqualToString:QST_TYPE_T])
            {
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 150, 30)];
                [lable adjustsFontSizeToFitWidth];
                lable.text = ab_qst.qstName;
                lable.backgroundColor = kCLEAR_COLOR_value;
                [lable sizeToFit];
                [l_view addSubview:lable];
                int i_xPosition = 150;
                if(lable.frame.size.width > 150)
                {
                    i_xPosition = 150;
                    height += lable.frame.size.height;
                }
                UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(i_xPosition, height, 150, 100)];
                textView.textAlignment = NSTextAlignmentRight;
                textView.backgroundColor = [UIColor whiteColor];
                textView.delegate = self;
                textView.font = [UIFont systemFontOfSize:17];
                textView.tag = [ab_qst.acvtQstId intValue];
                //查询
                if([self.markDictionary objectForKey:ab_qst.acvtQstId])
                {
                    textView.text = [self.markDictionary objectForKey:ab_qst.acvtQstId];
                }
                [l_view addSubview:textView];
                height += 110;
                [self addCancellOKButton:textView];
            }

            if([ab_qst.qstType isEqualToString:QST_TYPE_N]
               )
            {
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 150, 30)];
                [lable adjustsFontSizeToFitWidth];
                lable.text = ab_qst.qstName;
                lable.backgroundColor = kCLEAR_COLOR_value;
                [lable sizeToFit];
                [l_view addSubview:lable];
                int i_xPosition = 150;
                if(lable.frame.size.width > 150)
                {
                    i_xPosition = 150;
                    height += lable.frame.size.height;
                }
                WSHTextField* textField = [[WSHTextField alloc]initWithFrame:CGRectMake(i_xPosition, height, 150, 30) Qst:ab_qst];
                textField.currentFuncs=self.currentFuncs;

                // fuck requirement
                textField.textAlignment = NSTextAlignmentRight;
                textField.backgroundColor = [UIColor whiteColor];
                [textField setBorderStyle:UITextBorderStyleBezel];
                textField.delegate = self;
                textField.tag = [ab_qst.acvtQstId intValue];
                if([ab_qst.qstType isEqualToString:QST_TYPE_N])
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                else
                    textField.keyboardType = UIKeyboardTypeDefault;
                [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingDidBegin];
 
                
                //查询
                if([self.markDictionary objectForKey:ab_qst.acvtQstId])
                {
                    textField.text = [self.markDictionary objectForKey:ab_qst.acvtQstId];
                }
                
                [l_view addSubview:textField];
                height += 40;
                
                //店acvt回显
                //textField.placeholder = [self getAcvtDisKindOfTextFieldByQstId:ab_qst.acvtQstId];
                
                NSString *input = NSLocalizedString(@"please_fill_in", nil);
                textField.placeholder = input;
                
            }
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_W])
            {
                UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(10, height, 150, 30)];
                lable.text = [WSCurrentTime getDateTime];
                [lable sizeToFit];
                lable.backgroundColor = kCLEAR_COLOR_value;
                [l_view addSubview:lable];
                height += 40;
            }
            if([ab_qst.qstType isEqualToString:QST_TYPE_P])
            {
                
                [self addPictureWithSupperLocalPicture:ab_qst.isSupperLocalPhoto == 1
                                   withMaxPhotoNnumber:ab_qst.maxPhoto];
            }
            
            if([ab_qst.qstType isEqualToString:QST_TYPE_V])
            {
                UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(Record)];
                if(self.m_ParentViewController != nil)
                    self.m_ParentViewController.navigationItem.rightBarButtonItem = barButtonItem;
                else
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                
                
                
                if ([self respondsToSelector:@selector(readLocalVedio:)]) {
                    [self performSelector:@selector(readLocalVedio:) withObject:ab_qst.acvtQstId afterDelay:1];
                }
            }
            
            if ([ab_qst.qstType isEqualToString:QST_TYPE_D])
            {
                
                UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(10, height, 150, 30)];
                [lable adjustsFontSizeToFitWidth];
                lable.text = ab_qst.qstName;
                lable.backgroundColor = kCLEAR_COLOR_value;
                [lable sizeToFit];
                [l_view addSubview:lable];
                
                int i_xPosition = 150;
                if(lable.frame.size.width > 150)
                {
                    i_xPosition = 150;
                    height += lable.frame.size.height;
                }
                
                WSHTextField* textField = [[WSHTextField alloc] initWithFrame:CGRectMake(i_xPosition, height, 150, 30) Qst:ab_qst];
                textField.currentFuncs=self.currentFuncs;
                textField.textAlignment = NSTextAlignmentRight;
                textField.backgroundColor = [UIColor whiteColor];
                [textField setBorderStyle:UITextBorderStyleBezel];
                textField.delegate = self;
                textField.tag = [ab_qst.acvtQstId intValue];
                [l_view addSubview:textField];
                height += 40;
                NSString *input = NSLocalizedString(@"please_fill_in", nil);
                textField.placeholder = input;
            }
        }
        
        if(height > l_view.frame.size.height)
        {
            l_view.frame = CGRectMake(0, 0, 320, height);
            self.m_height = height;
        }
        
        self.tableView.tableFooterView = l_view;
        l_view = nil;
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addToolBar];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.m_CurrentInputView = textView;
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.m_CurrentInputView = textView;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString* qstId =[NSString stringWithFormat:@"%d",textView.tag];
    if (textView.text) {
        [self.markDictionary setObject:textView.text forKey:qstId];
    }
}
 */
@end
