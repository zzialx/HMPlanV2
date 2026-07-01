import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { PhotoHelper } from "@pura/picker_utils";
import { BusinessError } from '@ohos.base';
import WinLog from "../../utils/WinLog";
import { AppUtil, FileUtil } from "@pura/harmony-utils";
import { CommonFileConstants } from "../constants/CommonFileConstants";
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';

type ImageFormat = '.jpg' | '.jpeg' | '.png' | '.gif' | '.webp' | '.bmp' | '.svg' | '.avif';
export class PhotoMgrTool{
  /*
   * 选择照片
   * */
  public static async selectSingleImage(): Promise<string[] | undefined> {
    const options: photoAccessHelper.PhotoSelectOptions = {
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE,
      maxSelectNumber: 1,
      isPhotoTakingSupported: false,
      isSearchSupported: false,
      isEditSupported: false,
      isOriginalSupported: true
    };

    try {
      const uris = await PhotoHelper.selectEasy(options);
      if (!uris || uris.length === 0) return undefined;
      //需要将路径转入沙盒缓存，否则无法上传，权限不足
      let uri = uris[0];
      const targetPath = await fileToSandbox(uris[0], '.png');
      WinLog.info('沙盒路径：' + targetPath);
      return [targetPath];

    } catch (error) {
      WinLog.error(JSON.stringify(error));
      return undefined;
    }
  }
}
/**
 * 将指定 URI 的图片文件复制并压缩后保存到应用沙箱缓存目录中
 *
 * @param uri - 图片文件的原始路径 URI
 * @param fileSuffix - 文件后缀名，表示图片格式，默认为 '.jpg'
 * @returns 返回新生成的文件名（不含路径）
 */
export const fileToSandbox = async (uri: string, fileSuffix: ImageFormat = '.jpg') => {
  // 获取应用状态管理的’context‘上下文
  const ctx = AppUtil.getContext();
  const fileName_new = util.generateRandomUUID() + fileSuffix
  const targetFilePath = ctx.cacheDir + '/user_file_cache/' + fileName_new

  const sourceFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
  const targetFile = fileIo.openSync(targetFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)

  // 【可对原始图片进行压缩处理】 使用 packing 压缩图片，二进制图片数据
  //  通过文件描述符创建图像源，用于后续压缩处理；
  const imageSource = image.createImageSource(sourceFile.fd)
  //  创建图像打包器，用于将图像数据打包为特定格式
  const imagePacker = image.createImagePacker()
  //  使用 packToData 方法将图像压缩为 JPEG 格式，质量设置为 70%
  const arrayBuffer = await imagePacker.packToData(imageSource, { format: 'image/jpeg', quality: 70 })

  // 【将压缩后的图像数据写入目标文件
  fileIo.writeSync(targetFile.fd, arrayBuffer)

  //关闭打开的【源文件｜目标文件】[文件必须关闭，可能会导致资源泄露/文件锁定]
  fileIo.closeSync(sourceFile.fd)
  fileIo.closeSync(targetFile.fd)

  return targetFilePath
}
/**
 * 将图片文件 拷贝/压缩 到沙箱环境
 *
 * 此函数用于将给定URI的文件复制到应用的沙箱目录中，在复制过程中可以保留原文件的格式
 * 它首先生成一个唯一的文件名，以避免文件重复，然后打开源文件，并在沙箱目录中创建一个新文件，
 * 最后将源文件内容复制到新文件中此函数支持常见的图片格式复制
 *
 * @param uri 文件的URI，指定要复制的文件路径
 * @param fileSuffix 文件后缀名，决定了复制后的文件格式，默认为'.jpg'，
 * 可选格式包括 '.jpg' | '.jpeg' | '.png' | '.gif' | '.webp' | '.bmp' | '.svg' | '.avif';
 * @returns 返回复制到沙箱后的文件名
 */
export const fileToSandbox1 = async (uri: string, fileSuffix: ImageFormat = '.jpg') => {
  // 获取应用状态管理的’context‘上下文
  const ctx = AppStorage.get<Context>('context')
  // 调用util工具模块生成唯一的文件名称
  const fileName_new = util.generateRandomUUID() + fileSuffix
  // 定义目标文件路径，存储拷贝后的文件（沙箱目录)
  const targetFilePath = getContext(ctx).cacheDir + '/' + fileName_new

  // 【只读模式】打开源文件
  const sourceFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
  // 【读写模式】创建目标文件
  const targetFile = fileIo.openSync(targetFilePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)

  // 【复制】将打开的文件同步复制到新构建文件路径
  fileIo.copyFileSync(sourceFile.fd, targetFile.fd)

  //关闭打开的【源文件｜目标文件】[文件必须关闭，可能会导致资源泄露/文件锁定]
  fileIo.closeSync(sourceFile.fd)
  fileIo.closeSync(targetFile.fd)

  return fileName_new
}