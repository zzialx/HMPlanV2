//
//  SearchPanel.h
//  LuckyBee
//
//  Created by 李 振杰 on 13-5-23.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GlobalConstant.h"
//#import "GlobalFunction.h"

@class WSSearchPanel;

@protocol WSSearchPanelDelegate <NSObject>

@optional
-(void)doSearchWithContent:(NSString *)content withIndex:(NSInteger)index;


-(void)searchBarBeginSearch:(WSSearchPanel *)panel;

-(void)searchBarEndSearch:(WSSearchPanel *)panel;

-(void)callingSoundMachine:(WSSearchPanel *)panel;

-(void)searchWithSensitive:(NSString *)content;

-(void)allclearNotify;

@end

typedef enum{
    STYLE_X,
    STYLE_CN,
}SearchPanel_style;

@interface WSSearchPanel : UIView <UITextFieldDelegate>{
    
    
    UIView   *frontview;
    UIImageView   *front_cycleimg;
    
    
    UIView   *backgroundview;
    UIImageView   *back_cycleimg;

    UIImageView  *backgroundimg;
    
    UIButton   *front_search;
    
    UIButton   *real_search;
    
    UIButton   *cancel_btn;
    
    UITextField   *inputcontent;
    
    int cancel_style;
    
    __weak id<WSSearchPanelDelegate> delegate;
    
    BOOL isloading;
    
    CGRect    selfsearch_rect;
    
    BOOL havesound;
    
    BOOL forall;
}

@property (nonatomic,retain) UIView   *frontview;

@property (nonatomic,retain) UIImageView   *front_cycleimg;

@property (nonatomic,retain) UIImageView   *backgroundimg;

@property (nonatomic,retain) UIView   *backgroundview;

@property (nonatomic,retain) UIImageView   *back_cycleimg;

@property (nonatomic,retain)  UIButton   *front_search;

@property (nonatomic,retain)  UIButton   *real_search;

@property (nonatomic,retain)  UIButton   *cancel_btn;

@property (nonatomic,retain)  UITextField   *inputcontent;

@property (nonatomic,assign)  int cancel_style;

@property (nonatomic,weak)  id<WSSearchPanelDelegate>   delegate;

@property (nonatomic,assign)  BOOL    isloading;

@property (nonatomic,assign)  CGRect    selfsearch_rect;

@property (nonatomic,assign) BOOL havesound;

@property (nonatomic,assign) BOOL forall;


-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style;

-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style searchRect:(CGRect)searchrect;



-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style searchRect:(CGRect)searchrect soundsoundSearc:(BOOL)issound;


-(id)initWithFrame:(CGRect)frame style:(SearchPanel_style)style searchRect:(CGRect)searchrect soundsoundSearc:(BOOL)issound isall:(BOOL)all;

-(void)buildDisplayContent;

-(void) setSearchPanelPlaceHolderText:(NSString *)holdertext;

-(void) setSearchPanelTextFont:(UIFont *)textfont;

-(void) setSearchPanelTextColor:(UIColor *)textColor;

-(void) setSearchPanelTextAlignment:(NSTextAlignment)align;

-(void) messageFromHomeView:(NSString *)string withIndex:(NSInteger)index;

- (void)keyback:(BOOL)key;

@end
