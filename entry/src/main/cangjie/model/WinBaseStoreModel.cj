/**
 * Created on 2025/9/4
 */
package ohos_app_cangjie_entry.model
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos.resource_manager.Number
import serialization.serialization.*
import encoding.json.*
import encoding.json.stream.JsonDeserializable
import encoding.json.stream.JsonReader
import encoding.json.stream.*
import net.http.ClientBuilder
import net.http.HttpHeaders
import net.http.HttpRequestBuilder
import net.tls.TlsClientConfig
import net.tls.CertificateVerifyMode
import ohos.hilog.Hilog
import std.collection.ArrayList
import std.io.ByteArrayStream
import std.time.Duration
import std.collection.HashMap
import ohos.state_macro_manage.Observed
import ohos.state_macro_manage.Publish
import ohos.state_manage.ObservedComplexAbstract
import ohos.state_manage.ObservedObject
import std.objectpool.ObjectPool

//public class WinBaseStore <: Serializable<WinBaseStore> {
//    var Id:String = "";
//    var name: Option<String> = None;
//    var empId: Option<String> = None;
//    var code: Option<String> = None;
//    var seq: Option<String> = None;
//    var styp: Option<String> = None;
//    var sv: Option<String> = None;
//    var plan: Option<String> = None;
//    var actionState: Option<String> = None;
//    var addr: Option<String> = None;
//    var longitude: Option<Float64> = None;
//    var latitude: Option<Float64> = None;
//    var noteName: Option<String> = None;
//    var drId: Option<String> = None;
//    var qrcode: Option<String> = None;
//    var biz_date: Option<String> = None;
//    var storeImg: Option<String> = None;
//    var local_ImageID: Option<String> = None;
//    var inTime: Option<String> = None;
//    var outTime: Option<String> = None;
//    var phone: Option<String> = None;
//    var time: Option<String> = None;
//    var attri: Option<String> = None;
//    var prepareState: Option<String> = None;
//    var storesFilter: Option<String> = None;
//    var state: Option<String> = None;
//    var last_man: Option<String> = None;
//    var last_date: Option<String> = None;
//    var distance: Option<String> = None;
//    var departmentId: Option<String> = None;
//    var actionStateSeq: Option<String> = None;
//    var ctyp: Option<String> = None;
//    var optName: Option<String> = None;
//    var answer: Option<String> = None;
//    var server_node: Option<String> = None;
//    public func serialize() :DataModel {
//        return DataModelStruct()
//        .add(field<String>('Id',Id))
//        .add(field<Option<String>>('name',name))
//    }
//    public static func deserialize(dm:DataModel) : WinBaseStore{
//        var dms = match (dm) {
//        	case data: DataModelStruct => data
//            case _ => throw Exception('this data is not DataModelStruct')
//        }
//        var result = WinBaseStore();
//        result.Id = String.deserialize(dms.get('Id'));
//        result.name = Option<String>.deserialize(dms.get('name'));
//        //浮点型的写法
//        result.longitude = Option<Float64>.deserialize(dms.get('longitude'))
//        return result;
//    }
//   init() {
//   	 AppLogUtil.info('WinBaseStore Class');
//   }
//}
//public struct  WinBaseStore <: JsonDeserializable<WinBaseStore> {
//    public let Id:String;
//    public let name: Option<String> ;
//    public let empId: Option<String> ;
//    public let code: Option<String> ;
//    public let seq: Option<String>;
//    public let styp: Option<String> ;
//    public let sv: Option<String> ;
//    public let plan: Option<String> ;
//    public let actionState: Option<String>;
//    public let addr: Option<String>;
//    public let longitude: Option<Float64> ;
//    public let latitude: Option<Float64> ;
//    public let noteName: Option<String> ;
//    public let drId: Option<String> ;
//    public let qrcode: Option<String> ;
//    public let biz_date: Option<String> ;
//    public let storeImg: Option<String> ;
//    public let local_ImageID: Option<String> ;
//    public let inTime: Option<String> ;
//    public let outTime: Option<String> ;
//    public let phone: Option<String> ;
//    public let time: Option<String> ;
//    public let attri: Option<String> ;
//    public let prepareState: Option<String> ;
//    public let storesFilter: Option<String> ;
//    public let state: Option<String>;
//    public let last_man: Option<String> ;
//    public let last_date: Option<String> ;
//    public let distance: Option<String> ;
//    public let departmentId: Option<String>;
//    public let actionStateSeq: Option<String> ;
//    public let ctyp: Option<String> ;
//    public let optName: Option<String> ;
//    public let answer: Option<String> ;
//    public let server_node: Option<String> ;
//    public init(Id:String,
//        name: Option<String>,
//        empId: Option<String>,
//        code: Option<String>,
//        seq: Option<String>,
//        styp: Option<String>,
//        sv: Option<String>,
//        plan: Option<String>,
//        actionState: Option<String>,
//        addr: Option<String>,
//        longitude: Option<Float64>,
//        latitude: Option<Float64>,
//        noteName: Option<String>,
//        drId: Option<String>,
//        qrcode: Option<String>,
//        biz_date: Option<String>,
//        storeImg: Option<String>,
//        local_ImageID: Option<String>,
//        inTime: Option<String>,
//        outTime: Option<String>,
//        phone: Option<String>,
//        time: Option<String>,
//        attri: Option<String>,
//        prepareState: Option<String>,
//        storesFilter: Option<String>,
//        state: Option<String>,
//        last_man: Option<String>,
//        last_date: Option<String>,
//        distance: Option<String>,
//        departmentId: Option<String>,
//        actionStateSeq: Option<String> ,
//        ctyp: Option<String>,
//        optName: Option<String>,
//        answer: Option<String>,
//        server_node: Option<String>
//        ) {
//    	this.Id = Id;
//        this.name = name;
//        this.empId = empId;
//        this.code = code;
//        this.seq = seq;
//        this.styp = styp;
//        this.sv =  sv;
//        this.plan =  plan;
//        this.actionState =  actionState;
//        this.addr = addr;
//        this.longitude =  longitude;
//        this.latitude =  latitude;
//        this.noteName =  noteName;
//        this.drId =  drId;
//        this.qrcode =  qrcode;
//        this.biz_date =  biz_date;
//        this.storeImg =  storeImg;
//        this.local_ImageID =  local_ImageID;
//        this.inTime =  inTime;
//        this.outTime =  outTime;
//        this.phone =  phone;
//        this.time =  time;
//        this.attri =  attri;
//        this.prepareState =  prepareState;
//        this.storesFilter =  storesFilter;
//        this.state =  state;
//        this.last_man =  last_man;
//        this.last_date =  last_date;
//        this.distance =  distance;
//        this.departmentId =  departmentId;
//        this.actionStateSeq =  actionStateSeq;
//        this.ctyp =  ctyp;
//        this.optName =  optName;
//        this.answer =  answer;
//        this.server_node =  server_node;
//    }
//    public static func fromJson(r: JsonReader): WinBaseStore {
//        var temp_id: String = ''
//        var temp_name: Option<String> = None;
//        var temp_empId: Option<String> = None;
//        var temp_code:Option<String> = None;
//        var seq: Option<String> = None;
//        var styp: Option<String> = None;
//        var sv: Option<String> = None;
//        var plan: Option<String> = None;
//        var actionState: Option<String> = None;
//        var addr: Option<String> = None;
//        var longitude: Option<Float64> = None;
//        var latitude: Option<Float64> = None;
//        var noteName: Option<String> = None;
//        var drId: Option<String> = None;
//        var qrcode: Option<String> = None;
//        var biz_date: Option<String> = None;
//        var storeImg: Option<String> = None;
//        var local_ImageID: Option<String> = None;
//        var inTime: Option<String> = None;
//        var outTime: Option<String> = None;
//        var phone: Option<String> = None;
//        var time: Option<String> = None;
//        var attri: Option<String> = None;
//        var prepareState: Option<String> = None;
//        var storesFilter: Option<String> = None;
//        var state: Option<String> = None;
//        var last_man: Option<String> = None;
//        var last_date: Option<String> = None;
//        var distance: Option<String> = None;
//        var departmentId: Option<String> = None;
//        var actionStateSeq: Option<String>  = None;
//        var ctyp: Option<String> = None;
//        var optName: Option<String> = None;
//        var answer: Option<String> = None;
//        var server_node: Option<String>  = None;
//        while (let Some(v) <- r.peek()) {
//            match(v) {
//                case BeginObject =>
//                    r.startObject()
//                    while(r.peek() != EndObject) {
//                        let n = r.readName()
//                        match (n) {
//                            case "Id" => temp_id = r.readValue<String>()
//                            case unknow => Hilog.error(0, "==AIChat", "unknow key ${unknow}")
//
//                        }
//                    }
//                    r.endObject()
//                    break
//                case _ => throw Exception("can't deserialize for ChatResponse")
//            }
//        }
//        return WinBaseStore(
//            temp_id,
//            temp_name,
//        )
//    }
//}
public struct WinBaseStore{
    
}