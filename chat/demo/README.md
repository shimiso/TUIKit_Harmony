# Chat Demo - HarmonyOS IM

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-API%209+-blue.svg)](https://developer.harmonyos.com/)
[![ArkTS](https://img.shields.io/badge/Language-ArkTS-orange.svg)](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-get-started-0000001504769321)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

完整的即时通讯应用示例,展示如何使用 `@tencentcloud/atomicx` 和 `@tencentcloud/atomicxcore` 构建生产级 IM 应用。

## 📚 目录

- [项目简介](#-项目简介)
- [项目架构](#-项目架构)
- [核心特性](#-核心特性)
- [快速开始](#-快速开始)
- [架构设计](#-架构设计)
- [页面说明](#-页面说明)
- [最佳实践](#-最佳实践)
- [常见问题](#-常见问题)

## 📱 项目简介

这是一个基于 HarmonyOS 的完整即时通讯应用示例,演示了:

- ✅ **完整的 IM 功能**: 消息收发、会话管理、联系人管理
- ✅ **统一状态管理**: Store 模式的集中式数据管理
- ✅ **事件驱动架构**: 回调机制实现组件解耦
- ✅ **响应式 UI**: @State/@ObjectLink 实现自动更新
- ✅ **Dialog 管理**: 统一的弹窗管理和导航
- ✅ **主题系统**: 支持亮色/暗色主题切换

## 🏗 项目架构

```
chat/demo/
├── entry/                              # 应用入口模块
│   ├── src/main/ets/
│   │   ├── pages/
│   │   │   ├── HomePage.ets           # 主页 - 顶层控制器 ⭐
│   │   │   ├── SettingsPage.ets       # 设置页
│   │   │   └── Index.ets              # 页面导出
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets       # 应用入口
│   │   └── resources/                  # 资源文件
│   ├── build-profile.json5
│   └── oh-package.json5
└── uikit/                              # UI Kit 封装层
    ├── src/main/ets/
    │   ├── pages/
    │   │   ├── ConversationsPage.ets  # 会话列表页 🔄
    │   │   ├── ContactsPage.ets       # 联系人页 👥
    │   │   ├── ChatDialog.ets         # 聊天对话框 💬
    │   │   └── Index.ets
    │   └── resources/
    └── oh-package.json5

依赖关系:
entry (HomePage)
  ↓ 使用
uikit (封装的页面组件)
  ↓ 使用
atomic_x (基础 UI 组件库)
  ↓ 使用
atomicxcore (IM SDK & 状态管理)
```

## ✨ 核心特性

### 1. 三层架构

```
┌─────────────────────────────────────────┐
│  HomePage (顶层控制器)                    │
│  • 管理所有 Store                        │
│  • 处理所有 Dialog                       │
│  • 协调页面导航                          │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│  ConversationsPage / ContactsPage       │
│  (中间层 - UIKit)                        │
│  • 接收 Store 传递                       │
│  • 转发用户事件                          │
│  • 提供页面级 UI                         │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│  ConversationList / ContactList         │
│  (UI 组件 - atomic_x)                    │
│  • 纯 UI 展示                           │
│  • 触发回调事件                          │
│  • 无导航逻辑                            │
└─────────────────────────────────────────┘
```

### 2. 统一 Store 管理

```typescript
// HomePage - 唯一的数据源
@State contactListStore: ContactListStore = ContactListStore.create()
@State conversationListStore: ConversationListStore = ConversationListStore.create()

// 向下传递
ContactsPage({ contactListStore: this.contactListStore })
ConversationsPage({ conversationListStore: this.conversationListStore })
```

### 3. Dialog 集中管理

```typescript
// HomePage 统一管理所有 Dialog
private chatDialogController?: CustomDialogController
private groupSettingDialogController?: CustomDialogController
private newContactsDialogController?: CustomDialogController
// ... 更多 Dialog

// 统一的 Dialog 管理方法
private showContactManagementDialog(type: 'newContacts' | 'newGroups' | ...) {
  // 关闭旧 Dialog
  // 创建新 Dialog
  // 打开 Dialog
}
```

### 4. 事件驱动通信

```typescript
// 组件触发事件
ContactList({
  onContactClick: (contact) => { /* ... */ },
  onNewFriendsClick: () => { /* ... */ }
})

// HomePage 处理事件
onNewFriendsClick: () => {
  this.showNewContactsDialog()  // 显示好友申请
}
```

## 🚀 快速开始

### 1. 环境要求

- **HarmonyOS DevEco Studio**: 4.0 或更高版本
- **API Level**: 9 或更高
- **ArkTS**: 支持最新语法
- **Node.js**: 14.0 或更高 (用于包管理)

### 2. 安装依赖

```bash
# 在项目根目录
cd chat/demo
ohpm install

# 或者使用 npm
npm install
```

### 3. 配置 IM SDK

```typescript
// 在 EntryAbility.ets 中配置
import { IMManager } from '@tencentcloud/atomicxcore'

onCreate(want: Want) {
  IMManager.getInstance().init({
    sdkAppID: YOUR_SDK_APP_ID,
    logLevel: LogLevel.Debug
  })
}
```

### 4. 运行应用

1. 在 DevEco Studio 中打开项目
2. 连接 HarmonyOS 设备或启动模拟器
3. 点击 Run 按钮或按 `Shift + F10`

### 5. 登录测试

```typescript
// 使用测试账号登录
IMManager.getInstance().login({
  userID: 'test_user_001',
  userSig: 'YOUR_USER_SIG'
})
```

## 📐 架构设计

### 数据流设计

```mermaid
graph TB
    subgraph "HomePage - 数据源"
        HS[contactListStore]
        CS[conversationListStore]
    end
    
    subgraph "Middle Layer - UIKit"
        CP[ContactsPage]
        CVP[ConversationsPage]
    end
    
    subgraph "UI Layer - Components"
        CL[ContactList]
        CVL[ConversationList]
    end
    
    HS -->|@ObjectLink| CP
    CS -->|@ObjectLink| CVP
    CP -->|@ObjectLink| CL
    CVP -->|@ObjectLink| CVL
    
    CL -.->|onClick事件| CP
    CP -.->|转发回调| HS
    CVL -.->|onClick事件| CVP
    CVP -.->|转发回调| CS
```

### Store 生命周期

```typescript
// 1. 创建 (HomePage.aboutToAppear)
@State contactListStore: ContactListStore = ContactListStore.create()

// 2. 初始化数据
aboutToAppear() {
  this.contactListStore.fetchFriendList()
  this.contactListStore.fetchFriendApplicationList()
}

// 3. 传递给子组件
ContactsPage({ contactListStore: this.contactListStore })

// 4. 自动同步更新
@ObjectLink contactListStore  // 子组件中自动响应变化
```

### Dialog 管理模式

```typescript
// 优化后的统一管理方法
private showContactManagementDialog(
  type: 'newContacts' | 'newGroups' | 'myGroups' | 'blackList'
): void {
  // 1. 根据 type 选择 controller 和 builder
  const { controller, builder, setter } = this.getDialogConfig(type)
  
  // 2. 关闭已存在的 Dialog
  controller?.close()
  
  // 3. 创建新 Dialog (统一配置)
  const newController = new CustomDialogController({
    builder: builder,
    // ... 统一的动画和样式配置
  })
  
  // 4. 打开 Dialog
  setter(newController)
  newController.open()
}
```

## 📄 页面说明

### HomePage.ets - 主页面

**职责**: 顶层控制器,统一管理状态和导航

**核心功能**:
- ✅ 管理 `contactListStore` 和 `conversationListStore`
- ✅ 管理所有 Dialog (Chat, GroupSetting, NewContacts, etc.)
- ✅ 实现 Tab 导航 (消息、联系人、设置)
- ✅ 处理所有回调事件
- ✅ 管理 Badge 计数

**关键代码**:

```typescript
@Entry
@Component
struct HomePage {
  // Store 管理
  @State private contactListStore: ContactListStore = ContactListStore.create()
  @State private conversationListStore: ConversationListStore = 
    ConversationListStore.create()
  
  // Dialog 管理
  private chatDialogController?: CustomDialogController
  private newContactsDialogController?: CustomDialogController
  // ...
  
  // 统一 Dialog 管理
  private showContactManagementDialog(
    type: 'newContacts' | 'newGroups' | 'myGroups' | 'blackList'
  ) {
    // 统一的 Dialog 创建和管理逻辑
  }
  
  build() {
    Tabs() {
      TabContent() {
        ConversationsPage({
          onConversationClick: (item) => this.handleConversationClick(item)
        })
      }
      
      TabContent() {
        ContactsPage({
          contactListStore: this.contactListStore,
          onContactClick: (contact) => this.handleContactClick(contact),
          onNewFriendsClick: () => this.showNewContactsDialog()
        })
      }
    }
  }
}
```

### ConversationsPage.ets - 会话列表页

**职责**: 会话列表的中间层封装

**核心功能**:
- ✅ 提供大标题 "Messages"
- ✅ 集成搜索框 (可选)
- ✅ 包含 ConversationList 组件
- ✅ 转发事件到 HomePage

**特点**:
- 无内部状态管理
- 纯 UI 容器角色
- 事件透传

### ContactsPage.ets - 联系人页

**职责**: 联系人列表的中间层封装

**核心功能**:
- ✅ 提供大标题 "Contacts"
- ✅ 添加联系人按钮
- ✅ 包含 ContactList 组件
- ✅ 接收并传递 `contactListStore`
- ✅ 转发所有回调事件

**关键代码**:

```typescript
@Component
export struct ContactsPage {
  @ObjectLink contactListStore: ContactListStore  // 接收 store
  onContactClick?: (contact: ContactInfo) => void
  onNewFriendsClick?: () => void
  // ... 更多回调
  
  build() {
    Column() {
      this.LargeTitleBuilder()  // "Contacts" 标题
      
      ContactList({
        contactListStore: this.contactListStore,  // 传递 store
        onContactClick: this.onContactClick,      // 转发回调
        onNewFriendsClick: this.onNewFriendsClick
      })
    }
  }
}
```

### ChatDialog.ets - 聊天对话框

**职责**: 完整的聊天界面

**核心功能**:
- ✅ 消息列表 (MessageList)
- ✅ 消息输入框 (MessageInput)
- ✅ 导航栏和返回按钮
- ✅ 用户头像点击处理
- ✅ 群聊设置入口

**特点**:
- 全屏 Dialog 形式
- 自动加载历史消息
- 支持多媒体消息

## 🎯 最佳实践

### 1. Store 管理 ✅

**DO**: 在顶层创建,向下传递

```typescript
// HomePage.ets
@State contactListStore: ContactListStore = ContactListStore.create()

ContactsPage({ 
  contactListStore: this.contactListStore  // ✅ 传递引用
})
```

**DON'T**: 在多处创建实例

```typescript
// ❌ 每个组件各自创建 - 数据不同步!
@State myStore: ContactListStore = ContactListStore.create()
```

### 2. 事件处理 ✅

**DO**: 回调在顶层实现

```typescript
// HomePage 实现具体逻辑
onNewFriendsClick: () => {
  console.info('[HomePage] New friends clicked')
  this.showNewContactsDialog()  // ✅ 顶层控制导航
}
```

**DON'T**: 组件内部处理导航

```typescript
// ContactList 内部 ❌
onClick: () => {
  router.pushUrl({ url: 'pages/NewFriends' })  // 紧耦合!
}
```

### 3. Dialog 管理 ✅

**DO**: 统一管理方法

```typescript
// ✅ 一个方法处理多种 Dialog
private showContactManagementDialog(
  type: 'newContacts' | 'newGroups' | ...
) {
  // 统一的创建逻辑
}
```

**DON'T**: 重复的 Dialog 代码

```typescript
// ❌ 每个 Dialog 都写一遍相同的代码
private showDialog1() { /* 40 行代码 */ }
private showDialog2() { /* 40 行相同代码 */ }
```

### 4. 类型安全 ✅

**DO**: 使用强类型

```typescript
// ✅ 类型明确
@ObjectLink contactListStore: ContactListStore
onContactClick?: (contact: ContactInfo) => void
```

**DON'T**: 使用 any

```typescript
// ❌ 失去类型检查
store: any
onClick?: (data: any) => void
```

### 5. 资源清理 ✅

**DO**: 及时清理资源

```typescript
aboutToDisappear() {
  this.dialogController?.close()
  this.dialogController = undefined  // ✅ 释放引用
  this.unregisterListeners()
}
```

## 🔧 关键代码片段

### 1. 统一的 Dialog 管理

```typescript
// HomePage.ets
private showContactManagementDialog(
  type: 'newContacts' | 'newGroups' | 'myGroups' | 'blackList'
): void {
  try {
    let controller: CustomDialogController | undefined
    let builder: () => void
    let controllerSetter: (ctrl: CustomDialogController | undefined) => void

    // 根据 type 选择配置
    switch (type) {
      case 'newContacts':
        controller = this.newContactsDialogController
        builder = this.NewContactsDialogBuilder.bind(this)
        controllerSetter = (ctrl) => { this.newContactsDialogController = ctrl }
        break
      // ... 其他 cases
    }

    // 关闭旧 Dialog
    if (controller) {
      controller.close()
      controllerSetter(undefined)
    }

    // 创建新 Dialog
    const newController = new CustomDialogController({
      builder: builder,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      // ... 统一配置
    })

    controllerSetter(newController)
    newController.open()
  } catch (error) {
    console.error(`[HomePage] Dialog error:`, error)
  }
}
```

### 2. Tab Badge 更新

```typescript
// HomePage.ets
@Watch('onApplicationUnreadCountChanged')
@State private contactListState: ContactListState = this.contactListStore.state

onApplicationUnreadCountChanged() {
  this.updateTabBadge(
    HomePage.TAB_CONTACT,
    this.contactListState.friendApplicationUnreadCount + 
    this.contactListState.groupApplicationUnreadCount
  )
}
```

### 3. 用户交互处理

```typescript
// HomePage.ets
private handleContactClick(contact: ContactInfo): void {
  console.info(`[HomePage] Contact clicked: ${contact.contactID}`)
  
  if (contact.contactID) {
    this.showChatDialog(
      `c2c_${contact.contactID}`,
      contact.title || contact.contactID,
      contact.avatarURL
    )
  }
}
```

## 🐛 常见问题

### Q1: Dialog 显示后立即关闭?

**原因**: Dialog controller 没有保持引用

```typescript
// ❌ 错误
showDialog() {
  const controller = new CustomDialogController({ ... })
  controller.open()  // 方法结束后 controller 被回收
}

// ✅ 正确
private dialogController?: CustomDialogController

showDialog() {
  this.dialogController = new CustomDialogController({ ... })
  this.dialogController.open()  // 保持引用
}
```

### Q2: Store 数据不更新?

**原因**: 使用了 `@Prop` 而不是 `@ObjectLink`

```typescript
// ❌ 不响应变化
@Prop contactListStore: ContactListStore

// ✅ 自动响应变化
@ObjectLink contactListStore: ContactListStore
```

### Q3: 回调函数 undefined?

**原因**: 箭头函数 this 绑定问题

```typescript
// ❌ this 指向错误
builder: this.DialogBuilder

// ✅ 绑定 this
builder: this.DialogBuilder.bind(this)
```

### Q4: 多个 Store 实例数据不同步?

**解决**: 确保在顶层创建唯一实例

```typescript
// HomePage - 创建唯一实例
@State contactListStore: ContactListStore = ContactListStore.create()

// 所有子组件共享这个实例
ContactsPage({ contactListStore: this.contactListStore })
```

## 📚 学习资源

### 官方文档
- [HarmonyOS 开发文档](https://developer.harmonyos.com/)
- [ArkTS 语法参考](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-get-started-0000001504769321)
- [腾讯云 IM 文档](https://cloud.tencent.com/document/product/269)

### 相关项目
- [atomic_x 组件库](../../atomic_x/README.md)
- [atomicxcore SDK](../../../core/README.md)

### 代码示例
- [HomePage 完整示例](./entry/src/main/ets/pages/HomePage.ets)
- [ContactsPage 示例](./uikit/src/main/ets/pages/ContactsPage.ets)
- [ChatDialog 示例](./uikit/src/main/ets/pages/ChatDialog.ets)

## 🔄 版本历史

### v2.0.0 (当前版本)

**🎯 架构重构**
- ✅ 统一 Store 管理模式
- ✅ 事件驱动的组件通信
- ✅ Dialog 集中管理
- ✅ 优化代码复用 (减少 80+ 行重复代码)

**🎨 UI 优化**
- ✅ 使用 atomic_x 组件库
- ✅ 支持亮色/暗色主题
- ✅ 响应式布局

**⚡ 性能提升**
- ✅ 懒加载消息列表
- ✅ 内存优化
- ✅ 减少不必要的重渲染

### v1.0.0

- 基础功能实现
- 独立组件架构

## 📝 开发规范

### 命名规范

```typescript
// 组件命名: PascalCase
export struct ContactList { }

// 变量命名: camelCase
private contactListStore: ContactListStore

// 常量命名: UPPER_SNAKE_CASE
private static readonly TAB_MESSAGE: number = 0

// 回调命名: on + 动作
onContactClick?: (contact: ContactInfo) => void
```

### 注释规范

```typescript
// 顶层说明
/**
 * ContactsPage - 联系人列表页面
 * 
 * @description 负责显示联系人列表,转发用户交互事件
 * @requires contactListStore - 联系人数据 Store
 */

// 方法说明
/**
 * Show new contacts dialog
 * 
 * @description 显示新的好友申请列表
 */
private showNewContactsDialog(): void { }
```

## 🤝 贡献指南

欢迎贡献代码!请遵循以下流程:

1. Fork 本仓库
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'Add amazing feature'`
4. 推送分支: `git push origin feature/amazing-feature`
5. 提交 Pull Request

## 📄 许可证

本项目基于 MIT 许可证 - 详见 [LICENSE](./LICENSE) 文件

## 💬 技术支持

- **问题反馈**: [GitHub Issues](https://github.com/tencentcloud/imsdk/issues)
- **技术文档**: [腾讯云 IM 文档中心](https://cloud.tencent.com/document/product/269)
- **开发者社区**: [HarmonyOS 开发者论坛](https://developer.huawei.com/consumer/cn/forum/)

---

**Built with ❤️ by Tencent Cloud IM Team**
