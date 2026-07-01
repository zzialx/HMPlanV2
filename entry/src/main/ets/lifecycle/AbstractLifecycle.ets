/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMLifecycleContext, IHMLifecycle } from '@hadss/hmrouter'
import { HMLifecycleAction } from './HMLifecycleAction'
import { HMLifecycleState } from '@hadss/hmrouter'

export abstract class AbstractLifecycle implements IHMLifecycle {
  observerMap: Map<HMLifecycleState, Array<(ctx: HMLifecycleContext) => HMLifecycleAction>> = new Map()

  onPrepare(ctx: HMLifecycleContext): HMLifecycleAction {
    return HMLifecycleAction.DO_NEXT()
  }

  onAppear(ctx: HMLifecycleContext): HMLifecycleAction {
    return HMLifecycleAction.DO_NEXT()
  }

  onDisAppear(ctx: HMLifecycleContext): HMLifecycleAction {
    return this.runObserver(HMLifecycleState.onDisAppear, ctx)
  }

  onShown(ctx: HMLifecycleContext): HMLifecycleAction {
    return this.runObserver(HMLifecycleState.onShown, ctx)
  }

  onHidden(ctx: HMLifecycleContext): HMLifecycleAction {
    return this.runObserver(HMLifecycleState.onHidden, ctx)
  }

  onWillAppear(ctx: HMLifecycleContext): HMLifecycleAction {
    return HMLifecycleAction.DO_NEXT()
  }

  onWillDisappear(ctx: HMLifecycleContext): HMLifecycleAction {
    return this.runObserver(HMLifecycleState.onWillDisappear, ctx)
  }

  onWillShow(ctx: HMLifecycleContext): HMLifecycleAction {
    return this.runObserver(HMLifecycleState.onWillShow, ctx)
	}

  onWillHide(ctx: HMLifecycleContext): HMLifecycleAction {
    return this.runObserver(HMLifecycleState.onWillHide, ctx)
  }

  onReady(ctx: HMLifecycleContext): HMLifecycleAction {
    return HMLifecycleAction.DO_NEXT()
  }

  onBackPressed(ctx: HMLifecycleContext): boolean {
    return this.runObserver(HMLifecycleState.onBackPressed, ctx).value
  }

  addObserver(state: HMLifecycleState, callback: (ctx: HMLifecycleContext) => HMLifecycleAction): void {
    let callbackArr: undefined | Array<(ctx: HMLifecycleContext) => HMLifecycleAction> =
      this.observerMap.get(state);
    if (callbackArr) {
      callbackArr.push(callback);
    } else {
      this.observerMap.set(state, [callback]);
    }
  }

  runObserver(state: HMLifecycleState, ctx: HMLifecycleContext): HMLifecycleAction {
    if (this.observerMap.has(state)) {
      let observerArray = this.observerMap.get(state)
      let action: HMLifecycleAction
      for (let i = 0; i < observerArray!.length; i++) {
        action = observerArray![i](ctx)
        if (action.action === 'DO_BREAK') {
          break;
        }
      }
      return action!
    }
    return HMLifecycleAction.DO_NEXT().returnValue(false)
  }
}
