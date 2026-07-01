import { Log4a } from 'winloglib/src/main/ets/components/Log4a';

class WinLog {

  private static TAG: string = 'WinChannel---->'
  private logger: Log4a;

  constructor(prefix: string = 'MyApp') {
    this.logger = new Log4a(prefix)
  }

  debug(args: string): void {
    if (args.length > 1000){
      args = args.substring(0,1000)
    }
    this.logger.debug(WinLog.TAG + args)
  }
  info(args: string): void {
    if (args.length > 1000){
      args = args.substring(0,1000)
    }
    this.logger.info(WinLog.TAG + args)
  }
  warn(args: string): void {
    this.logger.warn(WinLog.TAG + args)
  }
  error(args: string): void {
    this.logger.error(WinLog.TAG + args)
  }
}
export default new WinLog('Index')