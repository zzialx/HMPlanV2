/*
 * Copyright 2024 Tingjin Guo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import {
  ConsoleAppender, FileAppender, Level,
  LogManager,
  PatternLayout,
} from '@pie/log4a';

export function LogExit() {
  LogManager.terminate();
}
export function InitializeAllLoggers(logFilePath: string) {

  LogManager.setLogFilePath(logFilePath);
  // LogManager.getLogger('Log4a');
    // .addFileAppender('Wlog.log', 'mainAppender', Level.INFO, {
    //   maxCacheCount: 10,
    //   maxFileSize: 10,
    //   expireTime: 5,
    //   useWorker: true
    // })
  const fileAppender_a = new FileAppender('Wlog.log', 'main', Level.ALL, {
    useWorker: true,
    maxFileSize: 3000,
    maxCacheCount: 5
  });
  LogManager.bindAppenderGlobally(fileAppender_a)
}
export function GetLogFilePath() {
  return LogManager.getLogFilePath()
}