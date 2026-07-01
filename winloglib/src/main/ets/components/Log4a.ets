import { Logger, LogManager } from '@pie/log4a';

export class Log4a {

  private logger: Logger;

  constructor(prefix: string = 'MyApp') {
    this.logger = LogManager.getLogger(prefix)
  }

  debug(args: string): void {
    this.logger.debug(args)
  }
  info(args: string): void {
    this.logger.info(args)
  }
  error(args: string): void {
    this.logger.error(args)
  }
}