import { AsyncCallback, emitter } from "@kit.BasicServicesKit";
import WinLog from "../utils/WinLog";

export  type WinEmitterCommonType = string | Map<string,string>

export class WinEmitterMgrTool{
  /*
   * 发送事件
   * */
  static  sendEmitter(emitterId:number,content:WinEmitterCommonType){
    let event: emitter.InnerEvent = {
      eventId: emitterId,
      priority: emitter.EventPriority.LOW
    };
    let eventData: emitter.EventData = {
      data: {
        content:content,
        id: emitterId,
        isEmpty: false
      }
    };
    emitter.emit(event, eventData);
  }

  /*
   *持续订阅事件
   **/
 static  onEmitterEvent(emitterId:number,onCallBack?:AsyncCallback<WinEmitterCommonType>){
   WinEmitterMgrTool.cancelEmitterEvent(emitterId);
    let event: emitter.InnerEvent = {
      eventId: emitterId
    };
    let callback = (eventData: emitter.EventData): void => {
      let json = JSON.stringify(eventData);
      let content:WinEmitterCommonType = JSON.parse(json)['data']['content'];
      if (content&&onCallBack) {
        onCallBack(undefined,content)
      }else {
        WinLog.error('no data or no call back')
      }
    };
    emitter.on(event, callback);
  }

  /*
  *单次订阅事件
  **/
  static onceEmitterEvent(emitterId:number,onCallBack?:AsyncCallback<WinEmitterCommonType>){
    let event: emitter.InnerEvent = {
      eventId: emitterId
    };
    let callback = (eventData: emitter.EventData): void => {
      let json = JSON.stringify(eventData);
      let content:WinEmitterCommonType = JSON.parse(json)['data']['content'];
      if (content&&onCallBack) {
        onCallBack(undefined,content)
      }else {
        WinLog.error('no data or no call back')
      }
    };
    emitter.once(event, callback);
  }
  /*
   *取消订阅事件
   **/
  static cancelEmitterEvent(emitterId:number){
    emitter.off(emitterId);
  }
}