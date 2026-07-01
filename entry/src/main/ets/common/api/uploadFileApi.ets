import  { UploadFile} from "../../utils/AxiosClient";
import { HttpRequest } from "../../utils/HttpRequest";
import { LXPostFileModel } from "../bean/LXPostFileResp";
import CommonReqConstants from "../constants/CommonReqConstants";
import HttpUtil from "../../utils/LXHttpRequestUtil";

const LOG_UPLOAD_PATH = '/log/diagnostic/upload';
const FILE_UPLOAD_PATH = '/file/upload';

export  type UploadType = 'log' | 'image' | 'imageUri';

// //1.单文件上传
// export const uploadLogMine = (file:UploadFile,logType:string):
//   Promise<LXPostFileModel> => HttpRequest.uploadLogFile(CommonReqConstants.Base_Url + LOG_UPLOAD_PATH,logType,file.uri)
//
// //2.上传照片
// export const uploadSingleImage = (filePath:string):
//   Promise<LXPostFileModel> => HttpRequest.uploadImage(CommonReqConstants.Base_Url + FILE_UPLOAD_PATH,[filePath])
//
// //3.上传照片（uri方式）
// export const uploadSingleImageUri = (fileUri:string):
//   Promise<LXPostFileModel> => HttpRequest.uploadImageUri(CommonReqConstants.Base_Url + FILE_UPLOAD_PATH,fileUri)

// 2. 统一上传函数
export const uploadResource = (
  type: UploadType,
  payload: UploadFile | string,
  logType?: string
): Promise<LXPostFileModel> => {
  const baseUrl = CommonReqConstants.Base_Url;
  switch (type) {
    case 'log':
      return HttpUtil.uploadLogFile(`${baseUrl}${LOG_UPLOAD_PATH}`, logType!, (payload as UploadFile).uri);
    case 'image':
      return HttpUtil.uploadImage(`${baseUrl}${FILE_UPLOAD_PATH}`, [payload as string]);
    case 'imageUri':
      return HttpUtil.uploadImageUri(`${baseUrl}${FILE_UPLOAD_PATH}`, payload as string);
    default:
      throw new Error(`[上传错误] 不支持的类型：${type}`);
  }
};
