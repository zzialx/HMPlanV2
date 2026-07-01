import { relationalStore } from '@kit.ArkData';

export class DatabaseSqlUtil {
  /**
   * 数据库配置
   */
  public static STORE_CONFIG :relationalStore.StoreConfig= {
    name: 'WinSFA.db', // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
    encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
    customDir: 'winchannel' // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
  };
}