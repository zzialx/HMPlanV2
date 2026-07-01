//
//  WSPersonnalImageViewController.m
//  WinSFA
//
//  Created by winchannel on 2017/5/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSPersonnalImageViewController.h"
#import "WSViewForWebImage.h"
#import "WSJSONBuilder.h"

@interface WSPersonnalImageViewController ()<UIActionSheetDelegate>

@property (nonatomic,strong)NSString *imageID;
@property (nonatomic,strong)UIButton  *moreButton;
@property (nonatomic,strong)UIBarButtonItem *moreBarItem;

@end

@implementation WSPersonnalImageViewController

- (id)initWithImageID:(NSString *)imageIDStr{
    
    self = [super init];
    if (self) {
        self.imageID = imageIDStr;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated{
    
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.view.bounds];
    }
    
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_contentView setBackgroundColor:[UIColor blackColor]];
    
    [self loadScrollViewWithImageID:_imageID];
    
    [self.view addSubview:_contentView];
}

- (void)loadScrollViewWithImageID:(NSString *)aImageID
{
    
    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:0];
    scaleImageView.tag = 100;
    NSArray *imageKeyArray ;
    if (aImageID.length > 0) {
        imageKeyArray = [aImageID componentsSeparatedByString:@"@"];
    }
    UIImage *image = nil;
    
    UIImage *placeholderImage = [UIImage scaledImageForName:@"headportraitbig_normal" ofType:@"png"];
    if ([imageKeyArray count] > 0) {
        image = [[SDImageCache sharedImageCache] imageFromKey:[imageKeyArray firstObject] fromDisk:YES];
        if (image) {
            scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil placeholderImage:placeholderImage];
        }else {
            scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:nil andUrl:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[imageKeyArray lastObject]]] placeholderImage:placeholderImage];
        }
        
    }else {
        image = [[SDImageCache sharedImageCache] imageFromKey:aImageID fromDisk:YES];
        scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil placeholderImage:placeholderImage];
        
    }
    [_contentView addSubview:scaleImageView];
    
}


-(WSViewForWebImage *)createScaleImageViewWithPage:(NSInteger)aPage{
    CGRect bounds = _contentView.frame;
    bounds.origin.x = self.view.size.width * aPage;
    bounds.origin.y = 0;
    
    if(INTERFACE_IS_PHONE){
        if([UIScreen mainScreen].bounds.size.height>480){
            bounds.size.height=[UIScreen mainScreen].bounds.size.height-64.0f;
        }
    }
    WSViewForWebImage *s = [[WSViewForWebImage alloc] initWithFrame:bounds];
    s.backgroundColor = [UIColor blackColor];
    s.contentSize = CGSizeMake(bounds.size.width, bounds.size.height);
    s.delegate = self;
    s.minimumZoomScale = 1.f;
    s.maximumZoomScale = 3.f;
    [s setZoomScale:1.f];
    s.userInteractionEnabled = YES;
    s.showsVerticalScrollIndicator = NO;
    s.showsHorizontalScrollIndicator = NO;
    return s;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"head_image", nil);
    [self addToolBar];
}

- (void)addToolBar{
    
    NSMutableArray *rightBarArray = [NSMutableArray array];
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn addTarget:self action:@selector(showAlertView) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [moreBtn setImage:[UIImage scaledImageForName:@"more_button" ofType:@"png"] forState:UIControlStateNormal];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    self.moreButton = moreBtn;
    [rightBarArray addObject:moreItem];
    self.moreBarItem = moreItem;
    self.navigationItem.rightBarButtonItems = rightBarArray;
}

- (void)showAlertView{

    if (IOS8_OR_LATER) {
        //初始化提示框
        UIAlertController *alert =self.alartVC=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if (INTERFACE_IS_PAD) {
            UIPopoverPresentationController *popover = alert.popoverPresentationController;
            popover.sourceView = self.moreButton;
            popover.sourceRect = self.moreButton.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        //按钮：从相册选择，类型：UIAlertActionStyleDefault
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"select_from_album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //初始化UIImagePickerController
            UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
            //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
            //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
            //获取方法3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
            PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //允许编辑，即放大裁剪
            PickerImage.allowsEditing = YES;
            //自代理
            PickerImage.delegate = self;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            if (INTERFACE_IS_PAD) {
                UIPopoverController *pop = [[UIPopoverController alloc]initWithContentViewController:PickerImage];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [pop presentPopoverFromBarButtonItem:self.moreBarItem permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
                }];
            }else{
                [self presentViewController:PickerImage animated:YES completion:nil];
            }
        }]];
        //按钮：拍照，类型：UIAlertActionStyleDefault
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"camera_capture", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
            PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
            PickerImage.allowsEditing = YES;
            PickerImage.delegate = self;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self presentViewController:PickerImage animated:YES completion:nil];
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else if (IOS7_OR_LATER){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_label", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"select_from_album", nil),NSLocalizedString(@"camera_capture", nil), nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        if (INTERFACE_IS_PAD) {
            [actionSheet showFromBarButtonItem:self.moreBarItem animated:YES];
        }else{
            [actionSheet showInView:self.view];
        }
        
        
    }

}


#pragma mark - UIActionSheetDelegate实现代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
        //初始化UIImagePickerController
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        PickerImage.allowsEditing = YES;
        PickerImage.delegate = self;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        if (INTERFACE_IS_PAD) {
            UIPopoverController *pop = [[UIPopoverController alloc]initWithContentViewController:PickerImage];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [pop presentPopoverFromBarButtonItem:self.moreBarItem permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
            }];
        }else{
           [self presentViewController:PickerImage animated:YES completion:nil];
        }
    }else if (buttonIndex == 1){
        
        //初始化UIImagePickerController
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        PickerImage.allowsEditing = YES;
        PickerImage.delegate = self;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        if (INTERFACE_IS_PAD) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:PickerImage animated:YES completion:nil];
            }];
        }else{
            [self presentViewController:PickerImage animated:YES completion:nil];
        }

    }else if (buttonIndex == 2){
    
        
    }
        
}

#pragma mark
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (newPhoto == nil) {
        return;
    }
    NSString *imageID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
    LogInfo(@"imageID:%@",imageID);
    
    if (imageID == nil) {
        return;
    }
    
    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
    [[SDImageCache sharedImageCache] storeImage:newPhoto imageImgCompress:imgCompress forKey:imageID toDisk:YES toDocument:YES isSynchronized:YES];
    
    self.imageID = imageID;
    
    [self.contentView removeAllSubviews];
     [self loadScrollViewWithImageID:imageID];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:NO  withAnimation:UIStatusBarAnimationSlide];
        LogInfo(@"Picker viewDidDisappear!");
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO  withAnimation:UIStatusBarAnimationSlide];
    }];

}


- (void)showPersonnalImageControllerToViewController:(UIViewController *)parentViewController
                                           withBlock:(ImageIDsBlock)aBlock{
    
    self.imageIDsBlock = aBlock;
    [parentViewController.navigationController pushViewController:self animated:YES];
}

- (void)backAction{
    
    [super backAction];
    if (self.imageIDsBlock) {
        self.imageIDsBlock(self.imageID);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
