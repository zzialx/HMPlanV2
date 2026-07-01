package ohos_app_cangjie_entry

internal import ohos.base.AppLog
internal import ohos.ability.AbilityStage
internal import ohos.ability.LaunchReason
internal import cj_res_entry.app
import ohos.ability.AbilityContext
import ohos.ark_interop_helper.StageContext
internal import ohos.ability.getStageContext
import ohos_app_cangjie_entry.database.DatabaseHelper

var globalAbilityContext: Option<AbilityContext> = Option<AbilityContext>.None

class MainAbility <: Ability {
    public init() {
        super()
        registerSelf()
    }
    public override func onCreate(want: Want, launchParam: LaunchParam): Unit {
        AppLog.info("MainAbility OnCreated.${want.abilityName}")
        globalAbilityContext = Option<AbilityContext>.Some(this.context);
        match (launchParam.launchReason) {
            case LaunchReason.START_ABILITY => AppLog.info("START_ABILITY")
            case _ => ()
        }
    }

    public override func onWindowStageCreate(windowStage: WindowStage): Unit {
        AppLog.info("MainAbility onWindowStageCreate.")
        let appStageContext = getStageContext(globalAbilityContext.getOrThrow());
        DatabaseHelper(appStageContext)
        windowStage.loadContent("EntryView")
    }
}
func createAbility(): MainAbility {
    MainAbility()
}

let ABILITY_REGISTER_RESULT = Ability.registerCreator("CangjieAbility", createAbility)

//全局的context
public func get_context(): AbilityContext {
    match (globalAbilityContext) {
        case Some(context) =>
            context
        case _ =>
            throw Exception("get globalAbilityContext failed")
    }
}
public func get_app_Context(): CPointer<Unit> {
    return getStageContext(globalAbilityContext.getOrThrow())
}
