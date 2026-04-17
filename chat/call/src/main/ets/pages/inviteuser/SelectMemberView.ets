import { router } from '@kit.ArkUI';
import {
  V2TIMGroupMemberFilter,
  V2TIMGroupMemberInfo,
  V2TIMGroupMemberInfoResult,
  V2TIMManager
} from '@tencentcloud/imsdk';
import Logger from '../../common/Logger';
import json from '@ohos.util.json';
import { InviteUserInfo } from '../component/CallInviteUserButton';
import { CallManager } from '../../manager/CallManager';

const TAG: string = "SelectMemberView"

@Entry({ routeName: 'SelectMemberViewRoute' })
@ComponentV2
export struct SelectMemberView {
  @Local groupMemberList: Array<GroupMemberInfo> = new Array()
  private chatGroupId: string = ''
  private alreadySelectList: Array<string> = new Array()

  aboutToAppear() {
    const inviteUserInfo = router.getParams() as InviteUserInfo
    this.chatGroupId = inviteUserInfo.groupId
    this.alreadySelectList = Array.from(inviteUserInfo.selectMemberList)
    this.updateGroupUserList()
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r('app.media.callkit_ic_back')).width(16).height(16)
          .onClick(() => {
            router.back()
          })
        Blank()
        Text($r('app.string.callkit_group_title_add_user')).fontColor($r("app.color.callkit_color_black"))
          .fontSize(16).padding(12)
        Blank()
        Text($r('app.string.callkit_group_btn_ok')).fontColor($r("app.color.callkit_color_black"))
          .onClick(() => {
            this.inviteUser()
          })
          .fontSize(16).padding(12)
      }.width('100%')

      List() {
        ForEach(this.groupMemberList, (item: GroupMemberInfo) => {
          this.ItemViewHolder(item)
        }, (item: GroupMemberInfo) => item.userId)
      }.listDirection(Axis.Vertical).width('100%').height('100%')
    }.margin({ left: 20, right: 20 }).padding({ top: 60 })
  }

  @Builder
  private ItemViewHolder(user: GroupMemberInfo) {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Checkbox().select(user.isSelected).shape(CheckBoxShape.CIRCLE).enabled(!user.isSelected)
        .onChange((value: boolean) => {
          user.isSelected = this.alreadySelectList.includes(user.userId) ? true : value;
        })
      Image(user.avatar)
        .alt($r('app.media.callkit_ic_avatar'))
        .width(40)
        .height(40)
        .margin(4)
        .borderRadius(8)
      Text(user.userId).fontSize(16).fontColor($r("app.color.callkit_color_black")).padding(12)
    }.width('100%')
  }

  private updateGroupUserList() {
    let filter = V2TIMGroupMemberFilter.V2TIM_GROUP_MEMBER_FILTER_ALL
    V2TIMManager.getGroupManager().getGroupMemberList(this.chatGroupId, filter, 0)
      .then((infoResult: V2TIMGroupMemberInfoResult) => {
        const result: Array<V2TIMGroupMemberInfo> = infoResult.memberInfoList
        if (result?.length <= 0) {
          return
        }
        this.groupMemberList.length = 0
        for (let info of result) {
          let name = info.friendRemark?.length > 0 ? info.friendRemark : info.nickName
          let userInfo: GroupMemberInfo = {
            userId: info.userID,
            nickName: name,
            avatar: info.faceURL,
            isSelected: this.alreadySelectList.includes(info.userID)
          }
          this.groupMemberList.push(userInfo)
        }
      }).catch((error: Error) => {
      Logger.error(TAG, `updateGroupUserList failed, error: ${json.stringify(error)}`)
    });
  }

  private inviteUser() {
    let selectUser: string[] = new Array()
    for (const info of this.groupMemberList) {
      if (info?.userId.length <= 0) {
        continue
      }
      if (info.isSelected && !this.alreadySelectList.includes(info.userId)) {
        selectUser.push(info.userId)
      }
    }
    Logger.info(TAG, `inviteUser, selectUser: ${selectUser}`)
    if (selectUser.length > 0) {
      CallManager.getInstance().inviteUser(selectUser, null)
    }
    router.back()
  }
}

@ObservedV2
export declare class GroupMemberInfo {
  userId: string;
  @Trace nickName: string;
  @Trace avatar: string;
  @Trace isSelected: boolean;
}