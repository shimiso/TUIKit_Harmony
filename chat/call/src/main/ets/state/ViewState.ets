
@ObservedV2
export class ViewState {
  @Trace isVirtualBackgroundOpened: boolean = false

  public reset() {
    this.isVirtualBackgroundOpened = false
  }
}