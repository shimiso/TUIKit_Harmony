/**
 * 通话控制按钮组件
 * 对应Flutter的ControlsButton
 */
import { CallColors } from '../common/CallColors';

@Component
export struct ControlsButton {
  // 按钮图标资源
  imgUrl: Resource | null = null;
  // 按钮提示文字
  tips: string = '';
  // 图标尺寸
  imgHeight: number = 52;
  // 文字颜色
  textColor: string = CallColors.colorG7;
  // 是否禁用
  isDisabled: boolean = false;
  // 点击回调
  onBtnTap: (() => void) | null = null;

  build() {
    if (!this.isDisabled) {
      Column() {
        if (this.imgUrl) {
          Image(this.imgUrl)
            .width(this.imgHeight)
            .height(this.imgHeight)
            .objectFit(ImageFit.Contain)
        }

        Text(this.tips)
          .fontSize(12)
          .fontColor(this.textColor)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .width(100)
          .height(15)
          .margin({ top: 10 })
      }
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.onBtnTap) {
          this.onBtnTap();
        }
      })
    }
  }
}
