import { photoAccessHelper, PickerColorMode } from '@kit.MediaLibraryKit'
import WinLog from '../utils/WinLog'
import { HMRouter } from '@hadss/hmrouter';
import { PhotoHelper, PickerUtil } from '@pura/picker_utils';
import { BusinessError } from '@ohos.base';
import { Permissions } from '@kit.AbilityKit';
import { PermissionUtil, ToastUtil } from '@pura/harmony-utils';

@HMRouter({ pageUrl: 'WinPhotoSelectorPage', lifecycle: 'PageDurationLifecycle', animator: 'pageAnimator' })
@ComponentV2
export  struct WinPhotoSelectorPage {
  aboutToAppear(): void {

  }
  selectMoreAction(){
    //如果使用系统自带相册选择，就不要申请权限
    let options: photoAccessHelper.PhotoSelectOptions = {
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE,
      maxSelectNumber:9,
      isPhotoTakingSupported:false,
      isSearchSupported:false,
      isEditSupported:false,
      isOriginalSupported:true
    }
    PhotoHelper.selectEasy(options).then((uris)=>{

    }).catch((error: BusinessError)=>{

    })
  }

  async takePictureAction(){
    let p:Permissions = 'ohos.permission.CAMERA';
    let isSuccess = await PermissionUtil.checkPermissions(p);
    if (!isSuccess) {
      ToastUtil.showToast('请授权 App 允许拍照');
    }
    PickerUtil.cameraEasy().then((uri)=>{
      WinLog.info('拍照完成');
    }).catch((error: BusinessError)=>{
      WinLog.error('调用相机异常' + JSON.stringify(error));
    })
  }
  build() {
    Column({space:10}){
      Text('相册')
        .onClick(()=>{
          this.selectMoreAction()
        })
      Text('系统自带相机')
        .onClick(()=>{
          this.takePictureAction()
        })
      Text('自定义相机')
        .onClick(()=>{
          this.takePictureAction()
        })
    }
  }
}