// JsonUtils.ets
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { WinBottomTabBean } from '../bean/WinBottomTabBean';
import { AppUtil } from '@pura/harmony-utils';

export class WinJsonUtils {

  /**
   * 从rawfile读取JSON文件并解析为对象数组
   * @param fileName 文件名（如：tabbar.json）
   * @returns Promise<WinBottomTabBean[]>
   */
  static async readJsonFromRawFile(fileName: string): Promise<WinBottomTabBean[]> {
    try {
      // 获取上下文
      const context = AppUtil.getContext();
      if (!context) {
        throw new Error('无法获取上下文');
      }

      // 异步读取文件内容
      const uint8Array = await context.resourceManager.getRawFileContent(fileName);

      // 将Uint8Array转换为字符串
      const jsonString = WinJsonUtils.uint8ArrayToString(uint8Array);

      // 解析JSON字符串
      const jsonArray = JSON.parse(jsonString) as WinBottomTabBean[];
      return jsonArray;

    } catch (error) {
      const err = error as BusinessError;
      console.error(`读取JSON文件失败: code=${err.code}, message=${err.message}`);
      return []
    }
  }

  /**
   * 同步方式读取JSON文件
   * @param fileName 文件名
   * @returns WinBottomTabBean[]
   */
  static readJsonFromRawFileSync(fileName: string): WinBottomTabBean[] {
    try {
      const context = AppUtil.getContext();
      if (!context) {
        throw new Error('无法获取上下文');
      }

      // 同步读取文件内容
      const uint8Array = context.resourceManager.getRawFileContentSync(fileName);

      // 将Uint8Array转换为字符串
      const jsonString = WinJsonUtils.uint8ArrayToString(uint8Array);

      // 解析JSON字符串
      const jsonArray = JSON.parse(jsonString) as WinBottomTabBean[];

      // 转换为WinBottomTabBean对象数组
      return jsonArray;

    } catch (error) {
      const err = error as BusinessError;
      console.error(`同步读取JSON文件失败: code=${err.code}, message=${err.message}`);
      return [];
    }
  }

  /**
   * 将Uint8Array转换为字符串
   * @param array Uint8Array数据
   * @returns 字符串
   */
  private static uint8ArrayToString(array: Uint8Array): string {
    const textDecoderOptions: util.TextDecoderOptions = {
      ignoreBOM: true  // 忽略BOM标记
    };

    const textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
    return textDecoder.decodeToString(array, { stream: false });
  }
}