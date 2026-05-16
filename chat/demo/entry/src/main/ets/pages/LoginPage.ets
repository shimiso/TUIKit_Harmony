import { FlutterBoost } from 'flutter_boost';
import { window } from '@kit.ArkUI';
import { XToastUtils } from '../utils/XToastUtils';

@Entry
@Component
struct LoginPage {
  @State agreementChecked: boolean = false;
  private videoController: VideoController = new VideoController();

  aboutToAppear(): void {
    this.enableImmersiveStatusBar();
  }

  aboutToDisappear(): void {
    this.videoController.pause();
    XToastUtils.close();
    this.disableImmersiveStatusBar();
  }

  private async enableImmersiveStatusBar(): Promise<void> {
    try {
      const win = await window.getLastWindow(getContext(this));
      await win.setWindowLayoutFullScreen(true);
      await win.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: '#FF131212',
        navigationBarColor: '#00000000',
        navigationBarContentColor: '#FF131212',
      });
    } catch (_) {
    }
  }

  private async disableImmersiveStatusBar(): Promise<void> {
    try {
      const win = await window.getLastWindow(getContext(this));
      await win.setWindowLayoutFullScreen(false);
      await win.setWindowSystemBarProperties({
        statusBarColor: '#FFFFFFFF',
        statusBarContentColor: '#FF131212',
        navigationBarColor: '#FFFFFFFF',
        navigationBarContentColor: '#FF131212',
      });
    } catch (_) {
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Video({
        src: $rawfile('welcome.mp4'),
        controller: this.videoController
      })
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .autoPlay(true)
        .loop(true)
        .controls(false)
        .muted(true)
        .hitTestBehavior(HitTestMode.None)

      this.buildBottomPanel()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildBottomPanel() {
    Column() {
      Button($r('app.string.login_phone_button'), { type: ButtonType.Normal, stateEffect: true })
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.hs_color_black'))
        .backgroundColor($r('app.color.hs_color_brand'))
        .borderRadius(24)
        .onClick(() => {
          this.onPhoneLoginClick();
        })

      Row({ space: 40 }) {
        this.buildSocialButton($r('app.media.login_icon_wechat'))
        this.buildSocialButton($r('app.media.login_icon_alipay'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 28 })

      this.buildAgreementRow()
    }
    .width('100%')
    .constraintSize({ minHeight: '34%' })
    .padding({
      left: 16,
      right: 16,
      top: 28,
      bottom: 24
    })
    .backgroundColor($r('app.color.hs_color_white'))
  }

  @Builder
  buildSocialButton(icon: Resource) {
    Row() {
      Image(icon)
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
    }
    .width(40)
    .height(40)
    .borderRadius(20)
    // .borderWidth(1)
    .borderColor($r('app.color.hs_color_border_gray'))
    .backgroundColor($r('app.color.hs_color_white'))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      XToastUtils.toast($r('app.string.login_third_party_coming_soon'), this.getUIContext());
    })
  }

  @Builder
  buildAgreementRow() {
    Row() {
      Image(this.agreementChecked ? $r('app.media.login_checkbox_checked') :
        $r('app.media.login_checkbox_unchecked'))
        .width(16)
        .height(16)
        .margin({ top: 2 })
        .onClick(() => {
          this.agreementChecked = !this.agreementChecked;
        })

      Text() {
        Span($r('app.string.login_agreement_prefix'))
          .fontSize(12)
          .fontColor($r('app.color.hs_color_text_secondary'))
        Span($r('app.string.login_user_agreement'))
          .fontSize(12)
          .fontColor($r('app.color.hs_color_brand_link'))
        Span($r('app.string.login_agreement_and'))
          .fontSize(12)
          .fontColor($r('app.color.hs_color_text_secondary'))
        Span($r('app.string.login_privacy_policy'))
          .fontSize(12)
          .fontColor($r('app.color.hs_color_brand_link'))
        Span($r('app.string.login_agreement_and'))
          .fontSize(12)
          .fontColor($r('app.color.hs_color_text_secondary'))
        Span($r('app.string.login_operator_terms'))
          .fontSize(12)
          .fontColor($r('app.color.hs_color_brand_link'))
      }
      .lineHeight(16)
      .layoutWeight(1)
      .margin({ left: 8 })
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .margin({ top: 20 })
  }

  private onPhoneLoginClick(): void {
    if (!this.agreementChecked) {
      XToastUtils.toast($r('app.string.login_agreement_required'), this.getUIContext());
      return;
    }
    FlutterBoost.getInstance().open('/login/smsLogin', {} as Record<string, Object>, true);
  }
}
