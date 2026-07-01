//
//  WSRoutingPlanAnnotationView.m
//  WinSFA
//
//  Created by zhiqing on 16/8/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRoutingPlanAnnotationView.h"
#import "WSStoreAnnotation.h"
@implementation WSRoutingPlanAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
//        WSStoreAnnotation * storeAnnotation = (WSStoreAnnotation*)annotation;
//        self.image = [UIImage imageForName:@"weizhi1.png"];

        _label = [[UILabel alloc]initWithFrame:CGRectMake(2, 3, 15, 10)];
//        _label.text = storeAnnotation.store.visitPlanMapOrder;
        _label.font = [UIFont systemFontOfSize:8];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

@end
