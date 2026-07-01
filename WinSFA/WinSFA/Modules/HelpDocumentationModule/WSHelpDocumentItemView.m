//
//  WSHelpDocumentItemView.m
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import "WSHelpDocumentItemView.h"
#import "NSString+ServerUrl.h"

@interface WSHelpDocumentItemView()

@end

@implementation WSHelpDocumentItemView

@synthesize itemImageView = _itemImageView;
@synthesize documentItem = _documentItem;
@synthesize itemViewDelegate = _itemViewDelegate;
@synthesize descriptLabel = _descriptLabel;
@synthesize showDescript = _showDescript;

- (id)initWithFrame:(CGRect)frame item:(WSHelpDocumentItem *)item showDescript:(BOOL)des;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.documentItem = item;
        self.showDescript = des;
        [self createSubViewsWith:item];
    }
    return self;
}

- (void)createSubViewsWith:(WSHelpDocumentItem *)item {
    if (!item) {
        return;
    }
    CGSize size = self.frame.size;
    if (self.showDescript) {
        _itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake(size.width/10, 0, size.width*4/5,(self.frame.size.height)*0.8)];
    } else {
        _itemImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    
    NSString *fullUrl;
    if (item.url) {
        fullUrl = [item.url buildupUrl];
    }

    // 添加等待UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 异步获取数据
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fullUrl]];
        // 更新主线程UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data!=nil){
                _itemImageView.image = [[UIImage alloc]initWithData:data];
            } else {
                _itemImageView.image =[UIImage imageNamed:@"Default.png"];
            }
            // 取消等待UI
        });
    });

    [self addSubview:_itemImageView];
    if (self.showDescript) {
        UILabel *decriptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,size.height*4/5, size.width, size.height/5)];
        decriptLabel.font = [UIFont systemFontOfSize: 14.0f];
        decriptLabel.numberOfLines = 0;
        decriptLabel.lineBreakMode = NSLineBreakByCharWrapping;
        decriptLabel.textAlignment = NSTextAlignmentCenter;
        decriptLabel.text = item.descript;
        decriptLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:decriptLabel];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_itemViewDelegate && [_itemViewDelegate respondsToSelector:@selector(helpDocumentItemViewCicked:)]) {
        [_itemViewDelegate helpDocumentItemViewCicked:self];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
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
