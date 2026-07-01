//
//  WSAddStoreView.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/19.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSAddStoreView.h"

static CGFloat const kAddStoreViewX      = 10;
static CGFloat const kAddStoreViewY      = 10;
static CGFloat const kAddStoreViewLabelH    = 15;




@interface WSAddStoreView ()
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addLabel;
@property (nonatomic, strong) UIView *linLableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation WSAddStoreView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)addControls {
    
    [self setBackgroundColor:[UIColor whiteColor]];

    UIButton* addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"addStoreBtn"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addBtnDown) forControlEvents:UIControlEventTouchUpInside];
    
    
  
    
    UILabel *codeLabel = [[UILabel alloc] init];
    codeLabel.font = [UIFont systemFontOfSize:15];
    codeLabel.textColor = [UIColor blackColor];
    codeLabel.text =  @"6666666";
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text =  @"路线：15";
    
    UILabel *addLabel = [[UILabel alloc] init];
    addLabel.font =  [UIFont systemFontOfSize:15];
    addLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [addLabel setText:@"地址：12"];
    
    UIView *linLableView = [[UIView alloc] init];
    linLableView.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    
    
    UIButton*deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    deleteButton.titleLabel.tintColor = [UIColor whiteColor];
    deleteButton.tintColor = [UIColor whiteColor];

    deleteButton.backgroundColor = [UIColor redColor];
    [deleteButton addTarget:self action:@selector(deleteBtnDown) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.hidden = YES;
    
    [self addSubview:addButton];
    [self addSubview:codeLabel];
    [self addSubview:nameLabel];
    [self addSubview:addLabel];
    [self addSubview:linLableView];
    [self addSubview:deleteButton];

    
    self.addButton = addButton;
    self.nameLabel = nameLabel;
    self.addLabel = addLabel;
    self.codeLabel = codeLabel;
    self.linLableView = linLableView;
    self.deleteButton = deleteButton;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat paddingX = kAddStoreViewX;
    CGFloat paddingY = kAddStoreViewY;
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    
    self.addButton.frame = CGRectMake(paddingX, (viewHeight - 2*kAddStoreViewLabelH)/2,2*kAddStoreViewLabelH, 2*kAddStoreViewLabelH);

    
    self.codeLabel.frame = CGRectMake(2 * paddingX + 2*kAddStoreViewLabelH, paddingY, viewWidth - 3 * kAddStoreViewLabelH , kAddStoreViewLabelH);
    
    self.nameLabel.frame = CGRectMake(2 * paddingX + 2*kAddStoreViewLabelH, CGRectGetMaxY(self.codeLabel.frame) + paddingY, viewWidth - 3 * kAddStoreViewLabelH, kAddStoreViewLabelH);
    
    self.addLabel.frame = CGRectMake(2 * paddingX + 2*kAddStoreViewLabelH, CGRectGetMaxY(self.nameLabel.frame) + paddingY, viewWidth - 3 * kAddStoreViewLabelH, kAddStoreViewLabelH);
    
    self.deleteButton.frame = CGRectMake(viewWidth - 70, 0,70, viewHeight);
    
//    self.linLableView.frame = CGRectMake(0,  0, viewWidth - paddingX, 1);
    
}

- (void)addBtnDown
{
    self.addButton.selected =  !self.addButton.selected;
    if (self.addButton.selected) {
        self.deleteButton.hidden = NO;
        [UIView animateWithDuration:1 animations:^{
            self.addButton.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];        
    }else{
        self.deleteButton.hidden = YES;
        [UIView animateWithDuration:1 animations:^{
            self.addButton.imageView.transform = CGAffineTransformIdentity;
        }];
    }
}
- (void)deleteBtnDown
{
    self.addButton.selected = NO;
    self.deleteButton.hidden = YES;
    [UIView animateWithDuration:1 animations:^{
        self.addButton.imageView.transform = CGAffineTransformIdentity;
    }];
    
    [self.addStoreViewDelegate deleteStore];
    NSLog(@"删除");
}
- (void)setWithCode:(NSString*)code andName:(NSString*)name andAddr:(NSString*)addr
{
    self.codeLabel.text = code;
    self.nameLabel.text = name;
    self.addLabel.text = addr;

}

@end

