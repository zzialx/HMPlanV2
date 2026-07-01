#import "WSRouteStoreTableViewCell.h"
#import "WSRequestHelper.h"
#import "WSInoutStoreTable.h"
#import "WSImagePathTable.h"
#import "WSStoreTools.h"
#import "WSVerticalListView.h"
#import "WSAttanceViewModel.h"
#import "WSVisitStoreBtn.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSShowQstViewForStoreListCell.h"

#define k_RS_CELL_STANDARD_SPACE            10.0f       //标准间距
#define k_RS_CELL_SMALL_SPACE               5.0f        //小间距
#define k_RS_CELL_STANDARD_FONT_SIZE        14.0f       //标准文本尺寸
#define k_RS_CELL_SMALL_FONT_SIZE           12.0f       //小文本尺寸
#define k_RS_CELL_STORE_ICON_SIZE           68.0f       //门头照尺寸
#define k_RS_CELL_ICON_SIZE                 12.0f       //图标尺寸
#define k_RS_CELL_RIGHT_ELEMENT_WIDTH       97.0f       //右边元素宽度
#define k_RS_CELL_RIGHT_REGION_WIDTH        102.0f      //右边范围宽度
#define k_RS_CELL_ROLE_XSDB                 @"销售代表"  //销售代表

#define k_MIN_VALID_VISIT_DURATION (5 * 60)    // 5分钟有效拜访时长

//==========================================================================================================================================

#pragma mark - 路线门店表视图单元格 延展(内部)
@interface WSRouteStoreTableViewCell ()

@property (nonatomic, strong) UIImageView *storeFaceImg;                //门店封面
@property (nonatomic, strong) UILabel *storeNameLab;                    //门店名称
@property (nonatomic, strong) UIImageView *storeCodeIcon;               //门店code图标
@property (nonatomic, strong) UILabel *storeCodeLab;                    //门店code
@property (nonatomic, strong) UIStackView *storeAttributeView;          //门店属性视图
@property (nonatomic, strong) UIImageView *storeAddressIcon;            //门店地理位置图标
@property (nonatomic, strong) UILabel *storeAddressLab;                 //门店地理位置
@property (nonatomic, strong) UIImageView *storeRouteIcon;              //门店路线图标
@property (nonatomic, strong) UILabel *storeRouteLab;                   //门店路线
@property (nonatomic, strong) UIButton *foldBtn;                        //门店折叠按键
@property (nonatomic, strong) UIButton *storeInfoBtn;                   //门店信息卡按键
@property (nonatomic, strong) UIButton *storeNavButton;                 //门店导航按键
@property (nonatomic, strong) WSVerticalListView *storeVisitView;       //门店拜访状态列表
@property (nonatomic, strong) UIStackView *agreementView;               //门店协议视图
@property (nonatomic, strong) UIView *lineView;                         //分割线

@property (nonatomic, strong) WSStoreBean *store;                       //门店主数据
@property (nonatomic, strong) WSFuncsBean_opt *currentOpt;              //门店列表的菜单opt数据
@property (nonatomic, strong) WSBaseAcvtdisDBService *acvtdisService;   //回显服务器
@property (nonatomic, copy) NSString *acvtCode;                         //opt中的storeListAcvtCode
@property (nonatomic, copy) NSString *foldState;                        //折叠状态

@end
//==========================================================================================================================================

#pragma mark - 路线门店表视图单元格
@implementation WSRouteStoreTableViewCell

#pragma mark - 获取storeFaceImg方法(门头照)
- (UIImageView *)storeFaceImg {
    
    if (!_storeFaceImg) {
        
        _storeFaceImg = [[UIImageView alloc] init];
        _storeFaceImg.backgroundColor = [UIColor clearColor];
        _storeFaceImg.image = [UIImage imageNamed:@"shop_default@2x"];
        _storeFaceImg.contentMode = UIViewContentModeScaleAspectFill;
        _storeFaceImg.clipsToBounds = YES;
    }
    return _storeFaceImg;
}

#pragma mark - 获取storeNameLab方法(门店名称)
- (UILabel *)storeNameLab {
    
    if (!_storeNameLab) {
        
        _storeNameLab = [[UILabel alloc] init];
        _storeNameLab.backgroundColor = [UIColor clearColor];
        _storeNameLab.font = [UIFont systemFontOfSize:k_RS_CELL_STANDARD_FONT_SIZE];
        _storeNameLab.textColor = MAIN_TEXT_COLOR;
        _storeNameLab.numberOfLines = 0;
    }
    return _storeNameLab;
}

#pragma mark - 获取storeCodeIcon方法(门店编码图标)
- (UIImageView *)storeCodeIcon {
    
    if (!_storeCodeIcon) {
        
        _storeCodeIcon = [[UIImageView alloc] init];
        _storeCodeIcon.backgroundColor = [UIColor clearColor];
        _storeCodeIcon.image = [UIImage imageNamed:@"storeCode"];
        _storeCodeIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _storeCodeIcon;
}

#pragma mark - 获取storeCodeLab方法(门店编码)
- (UILabel *)storeCodeLab {
    
    if (!_storeCodeLab) {
        
        _storeCodeLab = [[UILabel alloc] init];
        _storeCodeLab.backgroundColor = [UIColor clearColor];
        _storeCodeLab.font = [UIFont systemFontOfSize:k_RS_CELL_SMALL_FONT_SIZE];
        _storeCodeLab.textColor = DETAIL_TEXT_COLOR;
    }
    return _storeCodeLab;
}

#pragma mark - 获取storeAttributeView方法(门店属性)
- (UIStackView *)storeAttributeView {
    
    if (!_storeAttributeView) {
        
        _storeAttributeView = [[UIStackView alloc] init];
        _storeAttributeView.backgroundColor = [UIColor clearColor];
        _storeAttributeView.distribution = UIStackViewDistributionFillEqually;
        _storeAttributeView.axis = UILayoutConstraintAxisHorizontal;
        _storeAttributeView.spacing = 1.0f;
    }
    return _storeAttributeView;
}

#pragma mark - 获取storeAddressIcon方法(门店地址图标)
- (UIImageView *)storeAddressIcon {
    
    if (!_storeAddressIcon) {
        
        _storeAddressIcon = [[UIImageView alloc] init];
        _storeAddressIcon.backgroundColor = [UIColor clearColor];
        _storeAddressIcon.image = [UIImage imageNamed:@"storeAddress"];
        _storeAddressIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _storeAddressIcon;
}

#pragma mark - 获取storeAddressLab方法(门店地址)
- (UILabel *)storeAddressLab {
    
    if (!_storeAddressLab) {
        
        _storeAddressLab = [[UILabel alloc] init];
        _storeAddressLab.backgroundColor = [UIColor clearColor];
        _storeAddressLab.font = [UIFont systemFontOfSize:k_RS_CELL_SMALL_FONT_SIZE];
        _storeAddressLab.textColor = DETAIL_TEXT_COLOR;
        _storeAddressLab.numberOfLines = 2;
    }
    return _storeAddressLab;
}

#pragma mark - 获取storeRouteIcon方法(门店路线图标)
- (UIImageView *)storeRouteIcon {
    
    if (!_storeRouteIcon) {
        
        _storeRouteIcon = [[UIImageView alloc] init];
        _storeRouteIcon.backgroundColor = [UIColor clearColor];
        _storeRouteIcon.image = [UIImage imageNamed:@"storeRoute"];
        _storeRouteIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _storeRouteIcon;
}

#pragma mark - 获取storeRouteLab方法(门店路线)
- (UILabel *)storeRouteLab {
    
    if (!_storeRouteLab) {
        
        _storeRouteLab = [[UILabel alloc] init];
        _storeRouteLab.backgroundColor = [UIColor clearColor];
        _storeRouteLab.font = [UIFont systemFontOfSize:k_RS_CELL_SMALL_FONT_SIZE];
        _storeRouteLab.textColor = DETAIL_TEXT_COLOR;
        _storeRouteLab.numberOfLines = 2;
    }
    return _storeRouteLab;
}

#pragma mark - 获取foldBtn方法
- (UIButton *)foldBtn {
    
    if (!_foldBtn) {
        
        _foldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_foldBtn setBackgroundImage:[UIImage imageNamed:@"icon_close_new"] forState:UIControlStateNormal];
        [_foldBtn setBackgroundImage:[UIImage imageNamed:@"expend"] forState:UIControlStateSelected];
        [_foldBtn addTarget:self action:@selector(foldAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _foldBtn;
}

#pragma mark - 获取storeInfoBtn方法
- (UIButton *)storeInfoBtn {
    
    if (!_storeInfoBtn) {
        
        _storeInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_storeInfoBtn setBackgroundColor:[UIColor colorWithRed:239 / 255.0f green:254 / 255.0f blue:229 / 255.0f alpha:1.0f]];
        [_storeInfoBtn setTitle:@"门店信息卡  >" forState:UIControlStateNormal];
        [_storeInfoBtn setTitleColor:[UIColor colorWithRed:123 / 255.0f green:177 / 255.0f blue:99 / 255.0f alpha:1] forState:UIControlStateNormal];
        _storeInfoBtn.titleLabel.font = [UIFont systemFontOfSize:k_RS_CELL_SMALL_FONT_SIZE];
        [_storeInfoBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        [_storeInfoBtn addTarget:self action:@selector(clickStoreInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _storeInfoBtn;
}

#pragma mark - 获取storeNavButton方法(导航按键)
- (UIButton *)storeNavButton {
    
    if (!_storeNavButton) {
        
        _storeNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _storeNavButton.backgroundColor = [UIColor clearColor];
        [_storeNavButton setImage:[UIImage imageNamed:@"icon_distance"] forState:UIControlStateNormal];
        [_storeNavButton setTitleColor:CELL_DETAIL_TEXTCOLOR forState:UIControlStateNormal];
        [_storeNavButton.titleLabel setFont:[UIFont systemFontOfSize:k_RS_CELL_SMALL_FONT_SIZE]];
        _storeNavButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -2.0f);
        [_storeNavButton addTarget:self action:@selector(navButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _storeNavButton;
}

#pragma mark - 获取storeVisitView方法(门店状态列表)
- (WSVerticalListView *)storeVisitView {
    
    if (!_storeVisitView) {
        
        _storeVisitView = [[WSVerticalListView alloc] initWithFrame:CGRectZero];
        _storeVisitView.backgroundColor = [UIColor clearColor];
    }
    return _storeVisitView;
}

#pragma mark - 获取agreementView方法(门店协议)
- (UIStackView *)agreementView {
    
    if (!_agreementView) {
        
        _agreementView = [[UIStackView alloc] init];
        _agreementView.backgroundColor = [UIColor clearColor];
        _agreementView.distribution = UIStackViewDistributionFillEqually;
        _agreementView.axis = UILayoutConstraintAxisVertical;
        _agreementView.spacing = 2.0f;
        _agreementView.hidden = YES;
    }
    return _agreementView;
}

#pragma mark - 获取lineView方法
- (UIView *)lineView {
    
    if (!_lineView) {
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithRed:254 / 255.0f green:254 / 255.0f blue:254 / 255.0f alpha:1.0f];
    }
    return _lineView;
}

#pragma mark - 获取acvtdisService方法
- (WSBaseAcvtdisDBService *)acvtdisService {
    
    if (!_acvtdisService) {
        
        _acvtdisService = [[WSBaseAcvtdisDBService alloc] init];
    }
    return _acvtdisService;
}

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
 
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.storeFaceImg];
        [self.contentView addSubview:self.storeNameLab];
        [self.contentView addSubview:self.storeCodeIcon];
        [self.contentView addSubview:self.storeCodeLab];
        [self.contentView addSubview:self.storeAttributeView];
        [self.contentView addSubview:self.storeAddressIcon];
        [self.contentView addSubview:self.storeAddressLab];
        [self.contentView addSubview:self.storeRouteIcon];
        [self.contentView addSubview:self.storeRouteLab];
        [self.contentView addSubview:self.foldBtn];
        [self.contentView addSubview:self.storeInfoBtn];
        [self.contentView addSubview:self.storeNavButton];
        [self.contentView addSubview:self.storeVisitView];
        [self.contentView addSubview:self.agreementView];
        [self.contentView addSubview:self.lineView];
        
        [self p_addMasonry];
    }
    
    return self;
}

#pragma mark - 添加布局方法
- (void)p_addMasonry {
        
    //门头照
    [self.storeFaceImg mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contentView.mas_top).offset(k_RS_CELL_STANDARD_SPACE);
        make.left.equalTo(self.contentView.mas_left).offset(k_RS_CELL_SMALL_SPACE);
        make.width.mas_equalTo(k_RS_CELL_STORE_ICON_SIZE);
        make.height.mas_equalTo(k_RS_CELL_STORE_ICON_SIZE);
    }];
    
    //门店名字
    [self.storeNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeFaceImg.mas_top);
        make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_RIGHT_REGION_WIDTH);
    }];
    
    //门店code图标
    [self.storeCodeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeNameLab.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
        make.left.equalTo(self.storeNameLab.mas_left);
        make.width.mas_equalTo(k_RS_CELL_ICON_SIZE);
        make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
    }];
    
    //门店code
    [self.storeCodeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeCodeIcon.mas_top);
        make.left.equalTo(self.storeCodeIcon.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.height.mas_greaterThanOrEqualTo(k_RS_CELL_ICON_SIZE);
    }];
    
    //门店标签
    [self.storeAttributeView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeCodeIcon.mas_top);
        make.left.equalTo(self.storeCodeLab.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
    }];
    
    //门店地理位置icon
    [self.storeAddressIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeCodeLab.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
        make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.width.mas_equalTo(k_RS_CELL_ICON_SIZE);
        make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
    }];
    
    //门店地理位置
    [self.storeAddressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeAddressIcon.mas_top);
        make.left.equalTo(self.storeAddressIcon.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_RIGHT_REGION_WIDTH);
        make.height.mas_greaterThanOrEqualTo(k_RS_CELL_ICON_SIZE);
    }];
    
    //门店路线icon
    [self.storeRouteIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeAddressLab.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
        make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.width.mas_equalTo(k_RS_CELL_ICON_SIZE);
        make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
    }];
    
    //门店路线
    [self.storeRouteLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeRouteIcon.mas_top);
        make.left.equalTo(self.storeRouteIcon.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_RIGHT_REGION_WIDTH);
        make.height.mas_greaterThanOrEqualTo(k_RS_CELL_ICON_SIZE);
    }];
    //门店信息卡
    [self.storeInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeRouteLab.mas_bottom).offset(30.0f);
        make.left.equalTo(self.foldBtn.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.height.mas_greaterThanOrEqualTo(22.0f);
    }];
    
    //门店折叠按钮
    [self.foldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.storeInfoBtn.mas_centerY);
        make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.width.mas_equalTo(22.0f);
        make.height.mas_equalTo(22.0f);
    }];
    
    //导航按键
    [self.storeNavButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contentView.mas_top).offset(k_RS_CELL_STANDARD_SPACE);
        make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_SMALL_SPACE);
        make.width.mas_equalTo(k_RS_CELL_RIGHT_ELEMENT_WIDTH);
    }];
    
    //门店拜访列表
    [self.storeVisitView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeNavButton.mas_bottom).offset(1.0f);
        make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_SMALL_SPACE);
        make.width.mas_equalTo(k_RS_CELL_RIGHT_ELEMENT_WIDTH);
    }];
    
    //协议视图
    [self.agreementView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeInfoBtn.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
        make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
        make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_RIGHT_REGION_WIDTH);
    }];
    
    //分割线
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.top.greaterThanOrEqualTo(self.agreementView.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
        make.top.greaterThanOrEqualTo(self.storeVisitView.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-0.5f);
        make.height.mas_equalTo(0.5f);
    }];
}

#pragma mark - 设置门店/opt/折叠数据方法
- (void)setStore:(WSStoreBean *)store withOpt:(WSFuncsBean_opt *)opt foldState:(NSString *)foldState {
    
    self.acvtCode = (opt.storeListAcvtCode.length > 0 ? opt.storeListAcvtCode : @"");
    self.foldState = foldState;
    self.currentOpt = opt;
    self.store = store;
}

#pragma mark - 设置store方法
- (void)setStore:(WSStoreBean *)model {
    
    if (!model) {
        return;
    }
    
    _store = model;
    
    [self p_setStoreIcon];
    [self p_setStoreName];
    [self p_setStoreCode];
    [self p_setStoreAttribute];
    [self p_setStoreAddress];
    [self p_setStoreRoute];
    [self p_setStoreNavButton];
    [self p_setStoreVisit];
    [self p_setStoreAgreement];
}

#pragma mark - 设置门头照方法
- (void)p_setStoreIcon {
    
    UIImage *defaultIcon = [UIImage imageForName:@"shop_default@2x"];
    
    if (self.store.storeImg.length > 0) {
        
        if ([self.store.storeImg rangeOfString:@"."].location != NSNotFound) {
            
            NSString *url = [WSHttpURLHelper getImageCompleteURL:self.store.storeImg];
            [[WSRequestHelper shareInstance] downloadImageWithUrl:url imageView:self.storeFaceImg placeholderImage:defaultIcon];
            return;
        }
        
        NSArray *imagePathArray = [[WSImagePathTable sharedTable] queryWithImageIDX:self.store.storeImg];
        if (imagePathArray.count) {
            
            WSImagePathObject *object = [imagePathArray lastObject];
            if ([object.img_path rangeOfString:@"@"].location != NSNotFound) {
                
                NSString *url = [[object.img_path componentsSeparatedByString:@"@"] lastObject];
                [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:url] imageView:self.storeFaceImg placeholderImage:defaultIcon];
                return;
            }
            
            UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
            self.storeFaceImg.image = (image ? image : defaultIcon);
            return;
        }
        
        self.storeFaceImg.image = defaultIcon;
        return;
    }
    
    NSString *local_image = [[WSInoutStoreTable sharedTable] getStoreLocalImageWithStore:self.store andOtherParam:nil andParamType:EParameterType_NULL];
    if (local_image && local_image.length > 0 && ![local_image isEqualToString:@"null"]) {
        
        UIImage *localImage = [[SDImageCache sharedImageCache] imageFromKey:local_image fromDisk:YES];
        self.storeFaceImg.image = localImage;
        return;
    }
    
    self.storeFaceImg.image = defaultIcon;
}

#pragma mark - 设置门店名称方法
- (void)p_setStoreName {
    
    NSString *storeName = self.store.name;
    if ([self.store.row_number length] > 0) {
        
        if (self.store.isShowMapCallout) {
            NSString *storeStyp = [NSString stringNotNilWithValue:self.store.styp];
            storeName = [NSString stringWithFormat:@"%@ %@ %@", self.store.row_number, storeStyp, self.store.name];
        }
        else {
            storeName = [NSString stringWithFormat:@"%@.%@", self.store.row_number, self.store.name];
        }
    }
    
    self.storeNameLab.text = ((storeName.length == 0) ? @"" : storeName);
}

#pragma mark - 设置门店编码方法
- (void)p_setStoreCode {
    
    self.storeCodeLab.text = ((self.store.code.length == 0) ? @"" : self.store.code);
}

#pragma mark - 设置门店属性方法
- (void)p_setStoreAttribute {
    
    [self.storeAttributeView removeAllSubviews];
    
    BOOL isAdd = NO;
    
    if (self.store.plan || (self.store.isRouteStore && ![self.store.isRouteStore isEqualToString:@"0"])) {
        
        isAdd = YES;
        
        UIImageView *storeIconImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        storeIconImg.backgroundColor = [UIColor clearColor];
        storeIconImg.image = [UIImage imageNamed:@"point_plan_icon@2x"];
        storeIconImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.storeAttributeView addArrangedSubview:storeIconImg];
        
        [storeIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(k_RS_CELL_ICON_SIZE);
            make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
        }];
    }
    
    NSArray *storeIconImgList = [self.store.attri componentsSeparatedByString:@","];
    for (int i = 0; i < storeIconImgList.count; i++) {
        
        isAdd = YES;
        
        UIImageView *storeIconImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        storeIconImg.backgroundColor = [UIColor clearColor];
        storeIconImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.storeAttributeView addArrangedSubview:storeIconImg];
        
        [storeIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(k_RS_CELL_ICON_SIZE);
            make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
        }];
        
        NSString *imgURLStr = [WSHttpURLHelper getImageCompleteURL:storeIconImgList[i]];
        if ([imgURLStr hasSuffix:@"png"] || [imgURLStr hasSuffix:@"jpg"]) {
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:imgURLStr imageView:storeIconImg completed:nil];
        }
        else {
            
            if ([storeIconImgList[i] containsString:@"icon"]) {
                storeIconImg.image = [UIImage imageNamed:storeIconImgList[i]];
            }
            else {
                storeIconImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", storeIconImgList[i]]];
            }
        }
    }
    
    if (!isAdd) {
        
        UIImageView *storeIconImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        storeIconImg.backgroundColor = [UIColor clearColor];
        [self.storeAttributeView addArrangedSubview:storeIconImg];
        
        [storeIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0.0f);
            make.height.mas_equalTo(0.0f);
        }];
    }
}

#pragma mark - 设置门店地址方法
- (void)p_setStoreAddress {
    
    self.storeAddressLab.text = ((self.store.addr.length == 0) ? @"" : self.store.addr);
}

#pragma mark - 设置路线方法
- (void)p_setStoreRoute {

    self.storeRouteIcon.image = ((self.store.routeName.length == 0) ? nil : [UIImage imageNamed:@"storeRoute"]);
    self.storeRouteLab.text = ((self.store.routeName.length == 0) ? @"" : self.store.routeName);
    self.storeRouteIcon.hidden = ((self.store.routeName.length == 0) ? YES : NO);
    self.storeRouteLab.hidden = ((self.store.routeName.length == 0) ? YES : NO);
    
    if (self.storeRouteIcon.hidden) {
        
        [self.storeRouteIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.storeAddressLab.mas_bottom);
            make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
            make.width.mas_equalTo(0.0f);
            make.height.mas_equalTo(0.0f);
        }];
        
        [self.storeRouteLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.storeAddressLab.mas_bottom);
            make.left.equalTo(self.storeRouteIcon.mas_right).offset(k_RS_CELL_SMALL_SPACE);
            make.width.mas_equalTo(0.0f);
            make.height.mas_equalTo(0.0f);
        }];
    }
    else {
        
        [self.storeRouteIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.storeAddressLab.mas_bottom).offset(k_RS_CELL_STANDARD_SPACE);
            make.left.equalTo(self.storeFaceImg.mas_right).offset(k_RS_CELL_SMALL_SPACE);
            make.width.mas_equalTo(k_RS_CELL_ICON_SIZE);
            make.height.mas_equalTo(k_RS_CELL_ICON_SIZE);
        }];
        
        [self.storeRouteLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.storeRouteIcon.mas_top);
            make.left.equalTo(self.storeRouteIcon.mas_right).offset(k_RS_CELL_SMALL_SPACE);
            make.right.equalTo(self.contentView.mas_right).offset(-k_RS_CELL_RIGHT_REGION_WIDTH);
            make.height.mas_greaterThanOrEqualTo(k_RS_CELL_ICON_SIZE);
        }];
    }
}

#pragma mark - 设置导航方法
- (void)p_setStoreNavButton {
    
    if (self.store.distance.length > 0) {
        
        self.store.distance = [WSStoreTools strChange:self.store.distance];
        
        NSString *unit = NSLocalizedString(@"loc_acc_unit", nil);
        NSString *unitkm = NSLocalizedString(@"loc_acc_unit_km", nil);
        if (!([self.store.distance rangeOfString:unit].location != NSNotFound || [self.store.distance rangeOfString:unitkm].location != NSNotFound)) {
            [self.storeNavButton setTitle:[WSLocationManager convertDistance:[self.store.distance doubleValue]] forState:UIControlStateNormal];
        }
        else {
            [self.storeNavButton setTitle:self.store.distance forState:UIControlStateNormal];
        }
    }
    
    self.storeNavButton.hidden = (self.store.distance > 0 ? NO : YES);
}

#pragma mark - 设置拜访状态方法
- (void)p_setStoreVisit {
    
    NSString *role = [WSAttanceViewModel getLoginUserRole];
    NSMutableArray *tempList = [NSMutableArray arrayWithArray:[self.store.optName componentsSeparatedByString:@","]];
    
    if ([tempList containsObject:Today_Visit_State_Title] && [tempList containsObject:Invalid_Visit_Sate]) {
        NSInteger index = [tempList indexOfObject:Today_Visit_State_Title];
        [tempList replaceObjectAtIndex:index withObject:Invalid_Visit_Sate];
    }
    
    if ([tempList containsObject:Today_Visit_State] && [tempList containsObject:Invalid_Visit_Sate]) {
        NSInteger index = [tempList indexOfObject:Today_Visit_State];
        [tempList replaceObjectAtIndex:index withObject:Invalid_Visit_Sate];
    }
   
    if ([self.store.actionState isEqualToString:ActionDone]) {
        // tempList数据是服务器下发的拜访状态列表，要以服务器状态为准，本地状态次之
        //代表角色
        if ([role isEqualToString:k_RS_CELL_ROLE_XSDB]) {
            
            if ([tempList containsObject:Invalid_Visit_Sate] || [tempList containsObject:Today_Visit_State_Title]) {
                // 已包含目标状态，无需处理
                LogDebug(@" 已包含目标状态，无需处理");
            } else {
                BOOL shouldAddTodayState = NO;
                BOOL shouldAddNotLeaveState = NO;
                BOOL shouldAddInvalidState = NO;
                
                if (self.store.inTime && self.store.outTime) {
                    double enterStoretime = [self.store.inTime doubleValue];
                    double outStoretime = [self.store.outTime doubleValue];
                    double inStoreTime = outStoretime - enterStoretime;
                    
                    if (outStoretime == 0 && enterStoretime > 0) {
                        shouldAddNotLeaveState = ![tempList containsObject:Visit_Sate_NotLeave];
                    } else {
                        if (inStoreTime < k_MIN_VALID_VISIT_DURATION) {
                            shouldAddInvalidState = ![tempList containsObject:Invalid_Visit_Sate];
                        } else {
                            shouldAddTodayState = ![tempList containsObject:Today_Visit_State];
                        }
                    }
                } else {
                    shouldAddTodayState = ![tempList containsObject:Today_Visit_State];
                }
                
                if (shouldAddNotLeaveState) [tempList addObject:Visit_Sate_NotLeave];
                if (shouldAddInvalidState) [tempList addObject:Invalid_Visit_Sate];
                if (shouldAddTodayState) [tempList addObject:Today_Visit_State];
            }
           
        }else {
            //其他角色
            if (![tempList containsObject:Today_Visit_State]) {
                [tempList addObject:Today_Visit_State];
            }
        }
        
    }else if ([self.store.actionState isEqualToString:ActionWorking]) {
        if ([tempList containsObject:Invalid_Visit_Sate]) {
            [tempList removeObject:Invalid_Visit_Sate];
        }
        if ([tempList containsObject:Today_Visit_State]) {
            [tempList removeObject:Today_Visit_State];
        }
        if (![tempList containsObject:Visit_Sate_NotLeave]) {
            [tempList addObject:Visit_Sate_NotLeave];
        }
        
    } else if ([self.store.actionState isEqualToString:ActionAlreadyFilledOut] 
               || self.store.actionState.length == 0 
               || [self.store.optName containsString:Today_Visit_State]
               || [self.store.optName containsString:Today_Visit_State_Title]) {
        
        if (![tempList containsObject:Today_Visit_State]) {
            [tempList addObject:Today_Visit_State];
        }
        
        if (![tempList containsObject:Today_Visit_State_Title]) {
            [tempList addObject:Today_Visit_State_Title];
        }
    }
    
    NSArray *allStateList = @[ HelpSales_Visit_State,Orange_Visit_State, Orange_Agreement_Store,
                              Visit_Paing_Store, Visit_Paid_Store, Visit_Store_MainShelf, Visited_Store_MainShelf, Orange_NoVisit_State, OTO_Visit_State, OTO_NoVisit_State, Orange_Agreement_Store_ONE,
                              Orange_Visit_Qualified, Orange_Visit_NoQualified,Month_Visit_State,Invalid_Visit_Sate, Today_Visit_State, Today_Visit_State_Title,Visit_Sate_NotLeave];
    if (![role isEqualToString:k_RS_CELL_ROLE_XSDB]) {
        allStateList = @[ Orange_Visit_State, Orange_Agreement_Store, Visit_Paing_Store,
                         Visit_Paid_Store, Visit_Store_MainShelf, Visited_Store_MainShelf,
                         Orange_NoVisit_State, OTO_Visit_State, OTO_NoVisit_State, Orange_Agreement_Store_ONE, Orange_Visit_Qualified,
                         Orange_Visit_NoQualified,Month_Visit_State,Today_Visit_State,Today_Visit_State_Title,Visit_Sate_NotLeave];
    }
    
    NSMutableArray *newAllStateList = [[NSMutableArray alloc] initWithArray:allStateList];
    if (self.store.routeVisitState.length > 0) {
        
        if ([self.store.routeVisitState isEqualToString:Visit_Route_State_1]) {
            
            [tempList addObject:self.store.routeVisitState];
            [newAllStateList addObject:self.store.routeVisitState];
        }
    }
    NSPredicate *filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@", tempList];
    NSMutableArray *visitStateList = [NSMutableArray arrayWithArray:[newAllStateList filteredArrayUsingPredicate:filterPredicate_same]];
    
    if (self.store.monthVisitNumber) {
        
        if (![visitStateList containsObject:self.store.monthVisitNumber]) {
            
            [visitStateList insertObject:self.store.monthVisitNumber atIndex:0];
        }
    }else{
        [visitStateList insertObject:@"" atIndex:0];
    }
    if (self.store.monthHelpVisitNumber) {
        if (![visitStateList containsObject:self.store.monthHelpVisitNumber]) {
            [visitStateList insertObject:self.store.monthHelpVisitNumber atIndex:1];
        }
    }

    
    [self.storeVisitView setVisitList:visitStateList];
}

#pragma mark - 设置协议方法
- (void)p_setStoreAgreement {
    
    [self.agreementView removeAllSubviews];
    self.foldBtn.selected = ([self.foldState isEqualToString:@"1"] ? YES : NO);
    
    NSArray *acvtdisArray = [self.acvtdisService queryAcvtDisWithStoreId:self.store.Id acvtCode:self.acvtCode qstType:@"T"];
    if (acvtdisArray.count == 0 || !self.foldBtn.selected) {
        
        self.agreementView.hidden = YES;
        [self.agreementView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.storeInfoBtn.mas_bottom);
        }];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        [self.agreementView addArrangedSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.agreementView.mas_width);
            make.height.mas_equalTo(0.0f);
        }];
        
        return;
    }
    
    self.agreementView.hidden = NO;
    [self.agreementView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.storeInfoBtn.mas_bottom).offset(10.0f);
    }];
    
    for (int i = 0; i < acvtdisArray.count; i++) {
        
        WSShowQstViewSingleLineModel *modelObj = [acvtdisArray objectAtIndex:i];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        [self.agreementView addArrangedSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.agreementView.mas_width);
            make.height.mas_greaterThanOrEqualTo(22.0f);
        }];
        
        UILabel *titleNameLab = [[UILabel alloc] init];
        titleNameLab.backgroundColor = [UIColor colorWithRed:244 / 255.0f green:244 / 255.0f blue:244 / 255.0f alpha:1.0f];
        titleNameLab.font = [UIFont systemFontOfSize:k_RS_CELL_SMALL_FONT_SIZE];
        titleNameLab.textColor = [UIColor colorWithRed:52 / 255.0f green:52 / 255.0f blue:52 / 255.0f alpha:1.0f];
        
        NSString *content = [NSString stringWithFormat:@"  %@：%@  ", modelObj.qstname, ISNULL(modelObj.qstanwser)];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineSpacing = 1.0;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, content.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x2A2A2A) range:NSMakeRange(0, content.length)];
        NSRange decollatorRange = [content rangeOfString:@"："];
        [attributedText addAttribute:NSForegroundColorAttributeName value:HColorFromHex(0x28A707)
                               range:NSMakeRange(decollatorRange.location + 1, content.length - decollatorRange.location - 1)];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, content.length)];
        
        titleNameLab.attributedText = attributedText;
        
        [bgView addSubview:titleNameLab];
        
        [titleNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView.mas_left);
            make.top.equalTo(bgView.mas_top);
            make.height.equalTo(bgView.mas_height);
        }];
    }
}

#pragma mark - 导航按键响应方法
- (void)navButtonClick:(id)sender {
    
    if (self.store.latitude && self.store.longitude) {
        
        [WSTLAlertManager addMapNavigationCustomAlertViewWithStorebean:self.store];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:NSLocalizedString(@"无门店经纬度!", nil) tapTarget:nil action:nil
                             type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
}

#pragma mark - 门店信息系按键响应方法
- (void)clickStoreInfoAction:(id)sender {
    
    if (self.jumpStoreInfoAction) {
        
        self.jumpStoreInfoAction(self.store, self);
    }
}

#pragma mark - 折叠按键响应方法
- (void)foldAction:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if (self.showStoreAgreementAction) {
        self.showStoreAgreementAction(self.store, button.selected, self);
    }
}

@end
//==========================================================================================================================================
