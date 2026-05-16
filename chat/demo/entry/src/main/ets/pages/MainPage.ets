@Entry
@Component
struct SideBarOverlayClickClose {
  // 控制侧边栏显隐
  @State showSideBar: boolean = false

  build() {
    // 1. 设置为 Overlay 悬浮覆盖模式
    SideBarContainer(SideBarContainerType.Overlay) {

      // ==========================================
      // 【子组件 1】侧边栏区域（会浮在主内容上方）
      // ==========================================
      Column() {
        Text('侧边栏菜单').fontSize(20).fontWeight(FontWeight.Bold).margin(20)
        Text('功能 1').fontSize(16).margin(10)
        Text('功能 2').fontSize(16).margin(10)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      // 给侧边栏右侧加一个轻微阴影，视觉上产生层级感
      .shadow({ radius: 10, color: '#20000000', offsetX: 5 })

      // ==========================================
      // 【子组件 2】主内容区域（使用 Stack 层叠布局）
      // ==========================================
      Stack() {
        // 核心主内容
        Column() {
          // 自定义顶栏
          Row() {
            Image($r('app.media.app_icon')) // 替换为你的面包线图标
              .width(24)
              .height(24)
              .margin(16)
              .onClick(() => {
                animateTo({ duration: 250 }, () => {
                  this.showSideBar = !this.showSideBar
                })
              })
            Text('首页').fontSize(18).fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height(56)
          .backgroundColor('#F8F9FA')

          // 页面正文
          Column() {
            Text('这是主内容。当侧边栏展开时，点击这里的任意空白处，侧边栏都会收起。')
              .fontSize(14)
              .fontColor('#666666')
              .padding(30)
              .textAlign(TextAlign.Center)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height('100%')

        // 【关键防御层】：当侧边栏显示时，在主内容上方盖一层蒙版
        if (this.showSideBar) {
          Column()
            .width('100%')
            .height('100%')
            // 可以设为全透明 'rgba(0,0,0,0)'，或半透明的遮罩色 'rgba(0,0,0,0.2)'
            .backgroundColor('rgba(0,0,0,0.15)')
            .animation({ duration: 250 }) // 蒙版淡入淡出动画
            .onClick(() => {
              // 点击主内容区上的蒙版，关闭侧边栏
              animateTo({ duration: 250 }, () => {
                this.showSideBar = false
              })
            })
        }
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.TopStart)

    }
    .showSideBar(this.showSideBar)
    .sideBarWidth(260)              // 侧边栏宽度
    .showControlButton(false)        // 隐藏原生按钮
    .onChange((value: boolean) => {
      this.showSideBar = value
    })
  }
}