//
//  WSPeopleContentView.m
//  WinSFA
//
//  Created by zhangke on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPeopleContentView.h"
#import "WSInterAction.h"
#import "I_W_BuildInfo.h"
#import "WSAcvtQstDisItem.h"
#import "WSAcvtListDataItem.h"

@interface WSPeopleContentView (){
    WSAcvtListDataItem *acvtItem;
    WSAcvtQstDisItem *qstObject;
}

@end

@implementation WSPeopleContentView
@synthesize showAction;

-(id)initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    
    if (self) {
        
        [self buildDisplayContent];
        
        return self;
        
    }
    return nil;
}


-(void)buildDisplayContent{
    


}

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)content
{
    UIImageView* imageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    imageView.image=[UIImage imageNamed:@"touxiang.png"];
    [self addSubview:imageView];
    
    self.leftView=imageView;
    
    UILabel* mainLabel=[[UILabel alloc] initWithFrame:CGRectMake(imageView.right+10, 0, 200, 20)];
    [self addSubview:mainLabel];
    
    self.mainView=mainLabel;
    
    UILabel* assisantLabel=[[UILabel alloc] initWithFrame:CGRectMake(imageView.right+10, 20, 200, 20)];
    assisantLabel.font=[UIFont systemFontOfSize:13.0];
    assisantLabel.textColor=[UIColor grayColor];
    [self addSubview:assisantLabel];
    self.assisantView=assisantLabel;
    
    self.actionButton=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image=[UIImage imageForName:@"eaxm"];
    
    self.actionButton.frame=CGRectMake(self.width- (INTERFACE_IS_PAD? 100 :50), 0, 40, 40);
    [self.actionButton setImage:image forState:UIControlStateNormal];

    [self addSubview:self.actionButton];
    
    self.actionButton.hidden=YES;
    
    
    
    [self.actionButton addTarget:self action:@selector(executeAction) forControlEvents:UIControlEventTouchUpInside];
    

    
    self.rightView=(WSWidget*)[[UILabel alloc] initWithFrame:CGRectMake(self.width- (INTERFACE_IS_PAD? 250 :150), 0, 200, 40)];
    
    [self addSubview:self.rightView];

    
//    NSDictionary* dic=(NSDictionary*)content;
//    
//    dataDic=content;
    
    acvtItem = (WSAcvtListDataItem *)content;
    
    for(WSAcvtQstDisItem *object in acvtItem.qstDisArray){
    
        if([object.isacvtname isEqualToString:@"1"]){
            mainLabel.text = object.acvtanswer;
        }else if([object.isacvtname isEqualToString:@"2"]){
            assisantLabel.text=object.acvtanswer;
        }else if ([object.isacvtname isEqualToString:@"8"]){
            [self.actionButton setTitle:object.acvtanswer forState:UIControlStateNormal];
            qstObject=object;
        }else if([object.isacvtname isEqualToString:@"6"]){
            
            UILabel* label = (UILabel *)self.rightView;
            
            NSString *value= object.acvtanswer == nil ? @"" : object.acvtanswer;
            
            label.text=[NSString stringWithFormat:@"正确率: %@",[value isEqualToString:@"-1"] ? @"" : value];
            
            if(![object.acvtanswer isEqualToString:@"-1"] ){
                
                self.actionButton.hidden=YES;
            }
            if (([object.acvtanswer isEqualToString:@"-1"] && (self.showAction==YES)) ) {
               
                self.actionButton.hidden=NO;
                
            }
            
            if(!object.acvtanswer && (self.showAction==YES)){
                
                self.actionButton.hidden=NO;
            }
            
          
                
            
            
        }
    }
    
    
}

- (void)loadMediaInfo:(NSObject *)mediaInfo {
    
}

-(void)executeAction
{
    if ([self.contentViewDelegate respondsToSelector:@selector(generateURL:)]) {
        [self.contentViewDelegate generateURL:self];
    }
}

- (void)pushWebControllerWithURL:(NSString*)url
{
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    NSString *genid = acvtItem.genID;
    
    interaction.execute_method_param = genid; //gen_id
    if (url) {
        interaction.execute_class_param = [NSString stringWithFormat:@"%@%@",qstObject.acvtanswer,url];
    }else{
        interaction.execute_class_param = qstObject.acvtanswer;
    }
    NSLog(@"interaction.execute_class_param = %@" ,interaction.execute_class_param);
    interaction.execute_class=@"WSHttpWebViewController";
    
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

-(void)clearContent{
    
    [self removeAllSubviews];
    
}
@end
