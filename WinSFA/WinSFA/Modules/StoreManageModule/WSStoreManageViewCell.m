//
//  WSStoreManageViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreManageViewCell.h"
#import "WSStoreManageDataModel.h"
#import "WSAttanceViewModel.h"
//==================================================================================================================================================

@interface WSStoreManageViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;   //名称标签
@property (nonatomic, strong) UILabel *statusLabel; //状态标签
@property (nonatomic, strong) UILabel *addLabel;    //地址标签
@property (nonatomic, strong) UILabel *timeLabel;   //时间标签
@property (nonatomic, strong) UILabel *typeLabel;   //类型标签
@property (nonatomic, strong) UILabel *whyLabel;    //拒绝标签
@property (nonatomic, strong) UIButton *modifyBtn;  //修改按键
@property (nonatomic, strong) UIButton *undoBtn;    //撤销按键
@property (nonatomic, strong) UIView *linView;      //分割线

@end
//==================================================================================================================================================

@implementation WSStoreManageViewCell

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addControls];
    }
    return self;
}

#pragma mark - 添加控件方法
- (void)addControls {
        
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15.0f];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.numberOfLines = 0;
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    UILabel *addLabel = [[UILabel alloc] init];
    addLabel.font = [UIFont systemFontOfSize:15.0f];
    addLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    addLabel.numberOfLines = 0;
    [self.contentView addSubview:addLabel];
    self.addLabel = addLabel;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:15.0f];
    timeLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    timeLabel.numberOfLines = 0;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.font = [UIFont systemFontOfSize:15];
    typeLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    typeLabel.numberOfLines = 0;
    [self.contentView addSubview:typeLabel];
    self.typeLabel = typeLabel;
    
    UILabel *whyLabel = [[UILabel alloc] init];
    whyLabel.font = [UIFont systemFontOfSize:15.0f];
    whyLabel.textColor = [UIColor redColor];
    whyLabel.numberOfLines = 0;
    [self.contentView addSubview:whyLabel];
    self.whyLabel = whyLabel;
    
    UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [modifyBtn setTitle:@"修改" forState:UIControlStateNormal];
    [modifyBtn setTintColor:[UIColor orangeColor]];
    modifyBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    modifyBtn.layer.cornerRadius = 4.0;
    modifyBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    modifyBtn.layer.borderWidth = 1.0f;
    [modifyBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:modifyBtn];
    self.modifyBtn = modifyBtn;
    
    UIButton *undoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [undoBtn setTitle:@"撤销" forState:UIControlStateNormal];
    [undoBtn setTintColor:[UIColor colorWithHexString:@"c4c4c4"]];
    undoBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    undoBtn.layer.cornerRadius = 4.0;
    undoBtn.layer.borderColor = [UIColor colorWithHexString:@"c4c4c4"].CGColor;
    undoBtn.layer.borderWidth = 1.0f;
    [undoBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:undoBtn];
    self.undoBtn = undoBtn;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    [self.contentView addSubview:view];
    self.linView = view;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutControls];
}

#pragma mark - 布局控件方法
- (void)layoutControls {
        
    //参数设定
    CGSize statusSize = [WSStoreManageViewCell measureStrSizeWithStr:[WSStoreManageViewCell statusCode:_model.status] font:[UIFont systemFontOfSize:13.0f]];
    CGFloat leftMaxWidth = CGRectGetWidth(self.contentView.frame) - statusSize.width - 30.0f;
    
    //名称
    NSString *nameStr = _model.storeName;
    CGSize nameSize = [WSStoreManageViewCell measureStrSizeWithStr:nameStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    self.nameLabel.frame = CGRectMake(10.0f, 10.0f, leftMaxWidth, nameSize.height);
    
    //状态
    self.statusLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 10.0f - statusSize.width , 10.0f, statusSize.width, statusSize.height);
    
    //地址
    NSString *adStr = [NSString stringWithFormat:@"地址:%@", _model.storeAddr];
    CGSize addSize = [WSStoreManageViewCell measureStrSizeWithStr:adStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    self.addLabel.frame = CGRectMake(10.0f, CGRectGetMaxY(self.nameLabel.frame) + 10.0f, leftMaxWidth, addSize.height);
    
    //时间
    NSString *timeStr = [NSString stringWithFormat:@"申请时间:%@", _model.applyTime];
    CGSize timeSize = [WSStoreManageViewCell measureStrSizeWithStr:timeStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    self.timeLabel.frame = CGRectMake(10.0f, CGRectGetMaxY(self.addLabel.frame) + 10.0f, leftMaxWidth, timeSize.height);
    
    //变更类型
    NSString *typeStr = [NSString stringWithFormat:@"变更类型:%@", _model.changeType];
    CGSize typeSize = [WSStoreManageViewCell measureStrSizeWithStr:typeStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    self.typeLabel.frame = CGRectMake(10.0f, CGRectGetMaxY(self.timeLabel.frame) + 10.0f, leftMaxWidth, typeSize.height);
    
    //拒绝原因
    CGFloat offY = CGRectGetMaxY(self.typeLabel.frame) + 10.0f;
    if (_model.refuseReason && _model.refuseReason.length > 0) {
        NSString *str = [NSString stringWithFormat:@"拒绝原因:%@", _model.refuseReason];
        CGSize size = [WSStoreManageViewCell measureStrSizeWithStr:str font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
        self.whyLabel.frame = CGRectMake(10.0f, offY, leftMaxWidth, size.height);
        offY += size.height + 10.0f;
    }
    else {
        self.whyLabel.frame = CGRectZero;
    }
    
    //交互(排列 修改-撤销)
    if ([_model.changeFlage isEqualToString:@"1"]) {
        self.undoBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 10.0f - 50.0f, offY, 50.0f, 25.0f);
        self.modifyBtn.frame = CGRectMake(CGRectGetMinX(self.undoBtn.frame) - 10.0f - 50.0f, offY, 50.0f, 25.0f);
        offY += 25.0f + 10.0f;
    }
    else if ([_model.changeFlage isEqualToString:@"2"]) {
        self.undoBtn.frame = CGRectZero;
        self.modifyBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 10.0f - 50.0f, offY, 50.0f, 25.0f);
        offY += 25.0f + 10.0f;
    }
    else {
        self.undoBtn.frame = CGRectZero;
        self.modifyBtn.frame = CGRectZero;
    }
    
    //线
    self.linView.frame = CGRectMake(0.0f, offY, CGRectGetWidth(self.contentView.frame), 1.0f);
}

#pragma mark - 获取高度方法
+ (CGFloat)getStoreManageViewCellHeightWithModel:(WSStoreManageDataInfoModel *)model maxWidth:(CGFloat)maxWidth {
        
    //参数设定
    CGSize statusSize = [WSStoreManageViewCell measureStrSizeWithStr:[WSStoreManageViewCell statusCode:model.status] font:[UIFont systemFontOfSize:13.0f]];
    CGFloat leftMaxWidth = maxWidth - statusSize.width - 30.0f;
    
    //名称
    NSString *nameStr = model.storeName;
    CGFloat offY = 10.0f;
    CGSize nameSize = [WSStoreManageViewCell measureStrSizeWithStr:nameStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    offY += nameSize.height + 10.0f;
    
    //地址
    NSString *adStr = [NSString stringWithFormat:@"地址:%@", model.storeAddr];
    CGSize addSize = [WSStoreManageViewCell measureStrSizeWithStr:adStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    offY += addSize.height + 10.0f;
    
    //时间
    NSString *timeStr = [NSString stringWithFormat:@"申请时间:%@", model.applyTime];
    CGSize timeSize = [WSStoreManageViewCell measureStrSizeWithStr:timeStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    offY += timeSize.height + 10.0f;
    
    //变更类型
    NSString *typeStr = [NSString stringWithFormat:@"变更类型:%@", model.changeType];
    CGSize typeSize = [WSStoreManageViewCell measureStrSizeWithStr:typeStr font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
    offY += typeSize.height + 10.0f;

    //拒绝原因
    if (model.refuseReason && model.refuseReason.length > 0) {
        
        NSString *str = [NSString stringWithFormat:@"拒绝原因:%@", model.refuseReason];
        CGSize size = [WSStoreManageViewCell measureStrSizeWithStr:str font:[UIFont systemFontOfSize:15.0f] lineSpacing:1.0f drawWidth:leftMaxWidth];
        offY += size.height + 10.0f;
    }
    
    //交互区域
    if ([model.changeFlage isEqualToString:@"1"] || [model.changeFlage isEqualToString:@"2"]) {
        offY += 25.0f + 10.0f;
    }
    
    //分割线
    offY += 1.0f;
    
    return offY;
}

#pragma mark - 设置model方法
- (void)setModel:(WSStoreManageDataInfoModel *)model {
    
    _model = model;
    
    self.statusLabel.text = [WSStoreManageViewCell statusCode:_model.status];
    self.nameLabel.text = _model.storeName;
    self.addLabel.text = [NSString stringWithFormat:@"地址:%@", _model.storeAddr];
    self.timeLabel.text = [NSString stringWithFormat:@"申请时间:%@", _model.applyTime];
    self.typeLabel.text = [NSString stringWithFormat:@"变更类型:%@", _model.changeType];
    
    if (_model.refuseReason && _model.refuseReason.length > 0) {
        self.whyLabel.hidden = NO;
        self.whyLabel.text = [NSString stringWithFormat:@"拒绝原因:%@", _model.refuseReason];
    }
    else {
        self.whyLabel.hidden = YES;
    }
    
    if ([_model.changeFlage isEqualToString:@"1"]) {
        self.undoBtn.hidden = NO;
        self.modifyBtn.hidden = NO;
    }
    else if ([_model.changeFlage isEqualToString:@"2"]) {
        self.undoBtn.hidden = YES;
        self.modifyBtn.hidden = NO;
    }
    else {
        self.undoBtn.hidden = YES;
        self.modifyBtn.hidden = YES;
    }
}

#pragma mark - 交互按键响应方法
- (void)btnDown:(UIButton *)btn {
    
    if (btn == self.modifyBtn) {
        
        [self.storeManageViewCellDelegate btnDownStoreManageViewCell:1 andModel:_model];
        return;
    }
    else if (btn == self.undoBtn) {
        
        __weak typeof(self) weakSelf = self;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要撤销客户信息？"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.storeManageViewCellDelegate btnDownStoreManageViewCell:2 andModel:_model];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
}

#pragma mark - 测量字符串尺寸方法(单行)
+ (CGSize)measureStrSizeWithStr:(NSString *)str font:(UIFont *)font {
    
    if (!str) {
        str = @"";
    }
    NSDictionary *dic = @{NSFontAttributeName : font};
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str attributes:dic];
    return [attributedStr size];
}

#pragma mark - 测量字符串尺寸方法(多行)
+ (CGSize)measureStrSizeWithStr:(NSString *)str font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing drawWidth:(CGFloat)drawWidth {
    
    if (!str) {
        str = @"";
    }
    NSDictionary *dic = @{NSFontAttributeName : font};
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str attributes:dic];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    CGSize rangeSize = [attributedStr boundingRectWithSize:CGSizeMake(drawWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return rangeSize;
}

+ (NSString *)statusCode:(NSInteger)code {
    
    NSString *role = [WSAttanceViewModel getLoginUserRole];
    NSString *codeStr = @"";
    
    switch (code) {
            
        case 0: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM审批拒绝" : @"已拒绝");
        }
            break;
        case 1: {
            codeStr = ([role isEqualToString:@"SR"] ? @"已提交" : @"已提交");
        }
            break;
        case 2: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM已通过" : @"已通过");
        }
            break;
        case 3: {
            codeStr = ([role isEqualToString:@"SR"] ? @"已撤销" : @"已撤销");
        }
            break;
        case 4: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM入库待审批" : @"确认中");
        }
            break;
        case 5: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM待申诉" : @"MDM通过");
        }
            break;
        case 6: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM校验未通过" : @"MDM拒绝");
        }
            break;
        case 7: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM校验已通过" : @"");
        }
            break;
        case 8: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM入库失败" : @"");
        }
            break;
        case 9: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM待验证" : @"");
        }
            break;
        case 11: {
            codeStr = ([role isEqualToString:@"SR"] ? @"MDM已撤销" : @"");
        }
            break;
        default:
            break;
    }
    return codeStr;
}

- (NSString *)changeType:(NSInteger)changeType {
    
    switch (changeType) {
        case 0: {
            return @"倒闭";
        }
            break;
        case 1: {
            return @"合并";
        }
            break;
        case 2: {
            return @"更新/转正";
        }
            break;
        case 3: {
            return @"新增";
        }
            break;
        default:
            break;
    }
    return @"";
}

@end
//==================================================================================================================================================
