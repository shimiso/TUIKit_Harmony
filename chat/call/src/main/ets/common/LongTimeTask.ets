import { common, WantAgent, wantAgent } from '@kit.AbilityKit';
import Logger from './Logger';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'LongTermTask';

export class LongTimeTask {
  // context must be UIAbility
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;

  public startLongTask(): void {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      let mode = ['audioPlayback', 'voip']
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
        backgroundTaskManager.startBackgroundRunning(this.context, mode, wantAgentObj).then(() => {
          Logger.info(TAG, `startBackgroundRunning succeeded`);
        }).catch((error: BusinessError) => {
          Logger.error(TAG,
            `startBackgroundRunning failed. code: ${error.code}, message: ${error.message}`);
        });
      });
    } catch (error) {
      Logger.error(TAG, `getWantAgent failed. error: ${JSON.stringify(error)} `);
    }
  }

  public stopLongTask(): void {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      Logger.info(TAG, `stopBackgroundRunning succeeded`);
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `stopBackgroundRunning failed. error: ${JSON.stringify(error)} `);
    });
  }
}

export default new LongTimeTask()