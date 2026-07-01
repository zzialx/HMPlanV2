//
//  WCPrizerEvaluateView.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/3/13.
//
//

#import "WCPrizerEvaluateView.h"
#import "WSSpbaInfoBean.h"

@interface WCPrizerEvaluateView()

@property (nonatomic, strong)WSSpbaInfoBean *iSpbaInfoBean;

@end

@implementation WCPrizerEvaluateView
@synthesize iDelegate = _iDelegate;
@synthesize iSpbaInfoBean = _iSpbaInfoBean;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSpbaInfoBean:(WSSpbaInfoBean *)aBean withEvaluatePerson:(NSDictionary *)aEvaluateDic
{
    self = [super initWithFrame:frame];
    if (self) {
        _iSpbaInfoBean = aBean;
        // isMustRequire
        BOOL bMust = NO;
        NSNumber *isMust = [aEvaluateDic objectForKey:@"isMustRequried"];
        if (isMust != nil) {
            bMust = [isMust boolValue];
        }
        
        // Add checkbox
        UIButton *checkboxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkboxBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
//        [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-pressed.png"] forState:UIControlStateHighlighted];
        [checkboxBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
        if (bMust) {
            checkboxBtn.selected = bMust;
        }
        [checkboxBtn addTarget:self action:@selector(checkboxPressed:) forControlEvents:UIControlEventTouchUpInside];
        checkboxBtn.frame = CGRectMake(0, 0, 40, 40);
        [self addSubview:checkboxBtn];
        
        // Addd name
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 200, 29)];
        UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
        nameLable.font = labelFont;
        nameLable.text = aBean.name;
        [self addSubview:nameLable];
        
        UIButton *btnEvaluate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnEvaluate.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        [btnEvaluate setTitle:@"评估" forState:UIControlStateNormal];
        [btnEvaluate addTarget:self action:@selector(evaluateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btnEvaluate.frame = CGRectMake(0, 45, 70, 38);
        [self addSubview:btnEvaluate];
    }
    return self;    
}

- (id)initWithFrame:(CGRect)frame withSpbaInfoBean:(WSSpbaInfoBean *)aBean
{
    self = [super initWithFrame:frame];
    if (self) {
        _iSpbaInfoBean = aBean;
        // Add checkbox
        UIButton *checkboxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkboxBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
//        [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-pressed.png"] forState:UIControlStateHighlighted];
        [checkboxBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
        [checkboxBtn addTarget:self action:@selector(checkboxPressed:) forControlEvents:UIControlEventTouchUpInside];
        checkboxBtn.frame = CGRectMake(0, 0, 40, 40);
        [self addSubview:checkboxBtn];
        
        // Addd name
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 200, 29)];
        UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
        nameLable.font = labelFont;
        nameLable.text = aBean.name;
        [self addSubview:nameLable];
        
        UIButton *btnEvaluate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnEvaluate.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        [btnEvaluate setTitle:@"评估" forState:UIControlStateNormal];
        [btnEvaluate addTarget:self action:@selector(evaluateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btnEvaluate.frame = CGRectMake(0, 45, 70, 38);
        [self addSubview:btnEvaluate];
    }
    return self;    
}

- (id)initWithFrame:(CGRect)frame withName:(NSString *)aName
{
    self = [super initWithFrame:frame];
    if (self) {
        // Add checkbox
        UIButton *checkboxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-unchecked.png"] forState:UIControlStateNormal];
//        [checkboxBtn setImage:[UIImage imageNamed:@"checkbox-pressed.png"] forState:UIControlStateHighlighted];
        [checkboxBtn addTarget:self action:@selector(checkboxPressed:) forControlEvents:UIControlEventTouchUpInside];
        checkboxBtn.frame = CGRectMake(0, 0, 40, 40);
        [self addSubview:checkboxBtn];
        
        // Addd name
        UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 200, 29)];
        UIFont *labelFont = [UIFont systemFontOfSize:UI_Font];
        nameLable.font = labelFont;
        nameLable.text = aName;
        [self addSubview:nameLable];
        
        UIButton *btnEvaluate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnEvaluate.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        [btnEvaluate setTitle:@"评估" forState:UIControlStateNormal];
        [btnEvaluate addTarget:self action:@selector(evaluateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btnEvaluate.frame = CGRectMake(0, 45, 70, 40);
        [self addSubview:btnEvaluate];
    }
    return self;
}


- (void)checkboxPressed:(id)sender
{
    if (self.iDelegate != nil && [self.iDelegate respondsToSelector:@selector(evaluateView:checkboxClicked:withSpbaInfoBean:)]) {
        [self.iDelegate evaluateView:self checkboxClicked:sender withSpbaInfoBean:self.iSpbaInfoBean];
    }
}

- (void)evaluateBtnClick:(id)sender
{
    if (self.iDelegate != nil && [self.iDelegate respondsToSelector:@selector(evaluateView:evaluateButtonClicked:withSpbaInfoBean:)]) {
        [self.iDelegate evaluateView:self evaluateButtonClicked:sender withSpbaInfoBean:self.iSpbaInfoBean];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




@end
