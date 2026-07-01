//
//  SearchPanel.m
//  LuckyBee
//
//  Created by 李 振杰 on 13-5-23.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import "WSSearchPanel.h"
#import "WidgetConstant.h"

#define GOLBAL_Y 5.0


#define BEGIN_WIDTH 77.0
#define OFFSET 100.0/2.0
#define DEFAULT_HIGHT 64.0/2.0
#define ANIMATION_OFFSET 57.0/2.0
@interface WSSearchPanel (private)

@end

@implementation WSSearchPanel


@synthesize frontview;
@synthesize backgroundview;
@synthesize front_cycleimg;

@synthesize back_cycleimg;
@synthesize backgroundimg;
@synthesize real_search;
@synthesize front_search;
@synthesize cancel_btn;
@synthesize inputcontent;
@synthesize cancel_style;
@synthesize delegate;
@synthesize isloading;
@synthesize selfsearch_rect;
@synthesize havesound;
@synthesize forall;



- (id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.cancel_style= style;
        
        self.isloading=NO;
        
        self.selfsearch_rect = WSRect(0.0, 10.0, self.frame.size.width-OFFSET, DEFAULT_HIGHT);
        
        backgroundimg =[[UIImageView alloc] initWithFrame:self.bounds];
        
        backgroundimg.image =  WSImg(@"searchbar_bg.png");  //[WCBundleUtil imagesNamedFromCustomBundle:@"searchbar_bg" imgtype:@"png" andBundleFile:@"searchbar.bundle"];
        

        [self addSubview:backgroundimg];
        

        [backgroundimg setAlpha:0.0];
        
    }
    return self;
    
}


-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style searchRect:(CGRect)searchrect{
    
    self=[self initWithFrame:frame style:style];
    if (self) {
        
        self.selfsearch_rect = searchrect;
        return self;
    }
    return nil;
}


-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style searchRect:(CGRect)searchrect soundsoundSearc:(BOOL)issound{
    self =[self initWithFrame:frame style:style searchRect:searchrect];
    if (self) {
        
        self.havesound=issound;
        
        return self;
    }
    return nil;
}


-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style searchRect:(CGRect)searchrect soundsoundSearc:(BOOL)issound isall:(BOOL)all{
    
    self=[self initWithFrame:frame style:style searchRect:searchrect soundsoundSearc:issound];
    if (self) {
        forall = all;
        return self;
    }
    return nil;
}
-(void)buildDisplayContent{
    
     
    [self buildFrontView];
    
    [self buildBackView];
 
    [self buildInputContent];
    
}
-(void)buildInputContent{
    
    if (forall) {
        inputcontent =[[UITextField alloc] initWithFrame:WSRect(self.selfsearch_rect.origin.x+10.0, 8.0, selfsearch_rect.size.width, 55.0/2.0)];
    }else
    {
        inputcontent =[[UITextField alloc] initWithFrame:WSRect(self.selfsearch_rect.origin.x+10.0, 8.0+3.0, selfsearch_rect.size.width, 55.0/2.0)];
    }
    
    [inputcontent addTarget:self action:@selector(changeTextProcess:) forControlEvents:UIControlEventEditingChanged];
    
    [inputcontent addTarget:self action:@selector(changeTextProcess:) forControlEvents:UIControlEventEditingDidEnd];
    
    [inputcontent setReturnKeyType:UIReturnKeySearch];
    
    [inputcontent setTextColor:[UIColor whiteColor]];
    
    [inputcontent setFont:[UIFont systemFontOfSize:12.0]];
    
    [inputcontent setDelegate:self];
    
    [self addSubview:inputcontent];
    
}

-(void)buildFrontView{
    
    
    frontview=[[UIView alloc] initWithFrame:self.bounds];
    
    front_cycleimg =[[UIImageView alloc] initWithFrame:WSRect(0.0, 0.0, 0.0,0.0)];
    
    UIImage *cycleimg= WSImg(@"searchbar_front.png");  //[WCBundleUtil imagesNamedFromCustomBundle:@"searchbar_front" imgtype:@"png" andBundleFile:@"searchbar.bundle"];
    
    front_cycleimg.image=[cycleimg stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    
    front_cycleimg.frame= self.selfsearch_rect;
    
    [frontview addSubview:front_cycleimg];
    
    
 
   
   
    front_search =[UIButton buttonWithType:UIButtonTypeCustom];
    
    if (forall) {
        
        [front_search setFrame:WSRect(self.selfsearch_rect.size.width+(122.0/2.0)-10.0,front_cycleimg.frame.origin.y, 122.0/2.0, 55.0/2.0)];
    }else{
        [front_search setFrame:WSRect((self.frame.size.width-(122.0/2.0))-OFFSET,front_cycleimg.frame.origin.y, 122.0/2.0, 55.0/2.0)];
        
    }
    
    
    UIImage *searchimg= WSImg(@"search.png");  //[WCBundleUtil imagesNamedFromCustomBundle:@"search" imgtype:@"png" andBundleFile:@"searchbar.bundle"];
    
    [front_search setImage:searchimg forState:UIControlStateNormal];
    
    [front_search addTarget:self action:@selector(showSearchInputView) forControlEvents:UIControlEventTouchUpInside];
    
    [frontview addSubview:front_search];
    
    [self addSubview:frontview];


    
}


-(void)buildBackView{
  
    
    backgroundview = [[UIView alloc] initWithFrame:self.bounds];
    
    back_cycleimg = [[UIImageView alloc] initWithFrame:WSRect(0.0,0.0, 0.0, 0.0)];
   
    
    
    UIImage *backcycle_img = WSImg(@"searchbar_background.png");
    
    
    back_cycleimg.image=[backcycle_img stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    
    back_cycleimg.frame=WSRect(front_cycleimg.frame.origin.x, front_cycleimg.frame.origin.y,front_cycleimg.frame.size.width,back_cycleimg.image.size.height);
    
    
    [backgroundview addSubview:back_cycleimg];
    
    
    real_search =[[UIButton alloc] initWithFrame:WSRect(front_cycleimg.frame.origin.x+front_cycleimg.frame.size.width-120.0/2.0-2.0
                                                         ,back_cycleimg.frame.origin.y+0.5,120.0/2.0,55.0/2.0)];
    
    UIImage *real_search_img= WSImg(@"searchbar_sound.png");
    if (self.havesound) {
     
    [real_search setImage:real_search_img forState:UIControlStateNormal];
        
    [real_search addTarget:self action:@selector(callSoundMachine) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        
        real_search_img= WSImg(@"search_content.png");
    [real_search setImage:real_search_img forState:UIControlStateNormal];
    
    [real_search addTarget:self action:@selector(executeSearch) forControlEvents:UIControlEventTouchUpInside];
    }
    [self buildCancelButton];
    
    [backgroundview addSubview:real_search];
    
    [self addSubview:backgroundview];
    
   
    
    [backgroundview setAlpha:0.0];
  
    
    
}


-(void)buildCancelButton{
    
    
    
    UIImage  *searchcancel;
 
    if (cancel_style == STYLE_X) {
        if (forall) {
            cancel_btn =[[UIButton alloc] initWithFrame:WSRect(2.0,7.0,25.0,25.0)];
            
            searchcancel=   WSImg(@"cancel_x.png") ;
            
            [cancel_btn setImage:searchcancel forState:UIControlStateNormal];
            
        }else
        {
            searchcancel=  WSImg(@"cancel_x.png");
            
            cancel_btn =[[UIButton alloc] initWithFrame:WSRect(back_cycleimg.frame.origin.x+back_cycleimg.frame.size.width+10.0, back_cycleimg.frame.origin.y-2.0, 66.0/2.0, 68.0/2.0)];
            
            [cancel_btn setImage:searchcancel forState:UIControlStateNormal];
        }
    
    }else{
      
        cancel_btn = [[UIButton alloc] initWithFrame:WSRect(back_cycleimg.frame.origin.x+back_cycleimg.frame.size.width,back_cycleimg.frame.origin.y-2.0, 91.0/2.0, 65.0/2.0)];
        
        searchcancel=   WSImg(@"cancel_cn.png");
        
        [cancel_btn setImage:searchcancel forState:UIControlStateNormal];
        
    }
    [cancel_btn addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    [backgroundview addSubview:cancel_btn];
    
    
}

-(void)showSearchInputView{
    
    if (!self.isloading) {
        
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        [frontview setAlpha:0.0];
        [backgroundview setAlpha:1.0];
        [backgroundimg setAlpha:1.0];
        CGRect rect = back_cycleimg.frame;
        CGRect rect2 = inputcontent.frame;
        
        if (self.selfsearch_rect.origin.x==0.0) {
            
            rect.origin.x=0.0;
            
            rect.size.width=self.frame.size.width-100.0/2.0;
            rect2.origin.x=self.selfsearch_rect.origin.x+10.0;
        
        }else{
            
            rect.origin.x=ANIMATION_OFFSET;
            
            rect.size.width=self.front_cycleimg.frame.size.width+(self.front_cycleimg.frame.origin.x - ANIMATION_OFFSET);
            rect2.origin.x=ANIMATION_OFFSET+10.0;
        }
        
        back_cycleimg.frame=rect;
        inputcontent.frame=rect2;
       
        [UIView commitAnimations];
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        [inputcontent setAlpha:1.0];
        [UIView commitAnimations];
        
        self.isloading=YES;
        if ([delegate respondsToSelector:@selector(searchBarBeginSearch:)]) {
            [delegate searchBarBeginSearch:self];
        }
    }
    
}


-(void) cancelSearch{
    
    
    [inputcontent resignFirstResponder];
    
    [UIView beginAnimations:@"animation" context:nil];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.selfsearch_rect;
    
    CGRect rect2 = inputcontent.frame;
    
    back_cycleimg.frame=rect;
    
    rect2.origin.x=self.selfsearch_rect.origin.x+10.0;
    
    inputcontent.frame=rect2;
    [inputcontent setAlpha:0.0];
    
    inputcontent.text =@"";
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(hiddenBackView) withObject:nil afterDelay:0.5];
    
    if ([delegate respondsToSelector:@selector(searchBarEndSearch:)]) {
        [delegate searchBarEndSearch:self];
    }
}

-(void) hiddenBackView{
    
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [frontview setAlpha:1.0];
    [cancel_btn setAlpha:0.0];
    [inputcontent setAlpha:1.0];
    [backgroundview setAlpha:0.0];
    [backgroundimg setAlpha:0.0];
    [UIView commitAnimations];
     [cancel_btn setAlpha:1.0];
    self.isloading=NO;
}

-(void) messageFromHomeView:(NSString *)string withIndex:(NSInteger)index
{
    
   
    [inputcontent becomeFirstResponder];
    
     [self doQuery:string];
}

- (void)keyback:(BOOL)key
{
    if (key) {
        [inputcontent resignFirstResponder];
    }else{
        [inputcontent becomeFirstResponder];
    }
}

-(void)executeSearch{
    
    [inputcontent resignFirstResponder];
    
    [self cancelSearch];
    
    NSString *searchcontent = [inputcontent text];
    
    [self doQuery:searchcontent];
}

-(void)callSoundMachine{
    
    if ([delegate respondsToSelector:@selector(callingSoundMachine:)]) {
        
        [delegate callingSoundMachine:self];
    }
    
}

#pragma mark -
#pragma mark UITextFieldDelegate method

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [self showSearchInputView];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    //[self cancelSearch];
    
    NSString *searchcontent=[textField text];
    
    [self doQuery:searchcontent];
    
    return YES;
}


-(void)doQuery:(NSString *)searchcontent{
    
    if (searchcontent!=nil && [searchcontent length]>0) {
        
        if ([delegate respondsToSelector:@selector(doSearchWithContent:withIndex:)]) {
            
            [delegate doSearchWithContent:searchcontent withIndex:-1];
            
        }
    }else{
        
        [self cancelSearch];
    }
}

-(void) setSearchPanelPlaceHolderText:(NSString *)holdertext{
    
    [inputcontent setPlaceholder:holdertext];
}

-(void) setSearchPanelTextFont:(UIFont *)textfont{
    
    [inputcontent setFont:textfont];
}

-(void) setSearchPanelTextColor:(UIColor *)textColor{
    
    [inputcontent setTextColor:textColor];

}

-(void) setSearchPanelTextAlignment:(NSTextAlignment)align{
    
    
    [inputcontent setTextAlignment:align];
    

}



-(void)changeTextProcess:(UITextField *)sender {
    
    if ([sender.text length]<=0) {
        
        if ([delegate respondsToSelector:@selector(allclearNotify)]) {
            
            [delegate allclearNotify];
            
            return;
        }
    }
    
    if ([delegate respondsToSelector:@selector(searchWithSensitive:)]) {
        
        [delegate searchWithSensitive:sender.text];
        
    }
    
}
@end
