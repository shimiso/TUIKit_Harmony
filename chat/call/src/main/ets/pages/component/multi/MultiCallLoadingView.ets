
@Entry
@ComponentV2
export struct MultiCallLoadingView {
  @Param loading: boolean = false
  @Local alphaA: number = 0.2;
  @Local alphaB: number = 0.6;
  @Local alphaC: number = 1.0;
  private loadingTaskId: number = -1

  aboutToAppear(): void {
    if (this.loading) {
      this.startLoading()
    } else {
      this.stopLoading()
    }
  }

  build() {
    Row() {
      createDotBuilder({ data: this.alphaA })
      Blank()
      createDotBuilder({ data: this.alphaB })
      Blank()
      createDotBuilder({ data: this.alphaC })
    }.width('60%').justifyContent(FlexAlign.SpaceBetween)
  }

  private startLoading() {
    if (this.loadingTaskId != -1) {
      clearInterval(this.loadingTaskId)
      this.loadingTaskId = -1
    }
    this.loadingTaskId = setInterval(() => {
      this.alphaA = this.setAlpha(this.alphaA)
      this.alphaB = this.setAlpha(this.alphaB)
      this.alphaC = this.setAlpha(this.alphaC)
    }, 1000);
  }

  private stopLoading() {
    clearInterval(this.loadingTaskId)
    this.loadingTaskId = -1
  }

  private setAlpha(alpha: number): number {
    if (alpha == 0.2) {
      alpha = 0.6
    } else if (alpha == 0.6) {
      alpha = 1.0
    } else if (alpha == 1.0) {
      alpha = 0.2
    }
    return alpha
  }
}

class InnerAlpha {
  data: number = 0.2;
}

@Builder
function createDotBuilder(alpha: InnerAlpha) {
  Circle()
    .width(12)
    .height(12)
    .fill(Color.White)
    .opacity(alpha.data)
    .animation({ duration: 1000, delay: 0, curve: Curve.Ease })

}