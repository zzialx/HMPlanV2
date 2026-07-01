/**
 * Created on 2025/8/28
 */
package ohos_app_cangjie_entry.constants

public class CommonRequestConstants{

    //切换环境
     public static let Base_Url_ImageIcon: String = 'https://sit.winsfa.com/gsk_otc3/';
      //test url
     public static let Base_Url: String = 'https://sit.winsfa.com/gsk_otc3/';

      // static readonly Base_Url_Uat: string = 'https://sfa-uat.corpnet5.com:7001/';
      //
      // static readonly Base_Url_Rel: string = 'https://sfa-otc3.haleon.cn/otc-mobile/';

     public static let Base_Url_Cookie: String = 'login.do?noresponsebody=1'

     public static let Request_Method = 'POST';
      //超时时间
     public static let TimeOut: Int64 = 5000;

      //method
     public static let QUERY_METHOD: String = 'mobile/get.do?method=dataInfo';

     public static let UPLOAD_METHOD:String = 'mobile/post.do?method=save'

     public static let CHANGE_PSW_METHOD:String = 'mobile/post.do?method=onChangePass'

     public static let Login_Method: String = 'mobile/get.do?method=login'

     public static let SAVE_IMAGE_Method: String = 'mobile/post.do?method=saveImg'


}