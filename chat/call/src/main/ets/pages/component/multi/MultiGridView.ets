const TAG: string = "MultiGridView"

@ComponentV2
export struct MultiGridView {
  @BuilderParam builder: () => void = this.doNothingBuilder;
  @Param showLargeViewIndex: number = -1; // TODO : 监听 index 变化时，放大或缩小视图
  sizeResult: SizeResult = {
    width: 0,
    height: 0
  };
  private startMargin: number = 0
  private changeArray: Array<Layoutable> = new Array()

  @Builder
  doNothingBuilder() {
  };

  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Array<Measurable>, constraint: ConstraintSizeOptions) {
    let width = Math.min(selfLayoutInfo.width, selfLayoutInfo.height)
    let length = children.length
    children.forEach((child, index) => {
      let size = this.getMeasureSize(index, length, width)
      child.measure({
        minHeight: size,
        minWidth: size,
        maxWidth: size,
        maxHeight: size
      })
    })
    let height = (this.showLargeViewIndex < 0 && length <= 2) ? (width / 2) : width
    this.sizeResult.width = width
    this.sizeResult.height = width
    return this.sizeResult;
  }

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>, constraint: ConstraintSizeOptions) {
    let length = children.length
    let position: Position[] = this.getLocation(length, selfLayoutInfo.width)

    if (this.showLargeViewIndex >= 0 && length <= 4) {
      for (let i = 0; i < length; i++) {
        let child = children[i]
        if (i != this.showLargeViewIndex) {
          this.changeArray.push(child)
        } else {
          this.changeArray.unshift(child)
        }
      }

      for (let i = 0; i < this.changeArray.length; i++) {
        let child = this.changeArray[i]
        let pos: Position = position[i]
        child.layout({ x: pos.x, y: pos.y })
      }
      this.changeArray.length = 0
      return
    }

    for (let i = 0; i < length; i++) {
      let child = children[i]
      let pos: Position = position[i]
      child.layout({ x: pos.x, y: pos.y })
    }
  }

  build() {
    this.builder()
  }

  private getMeasureSize(index: number, count: number, windowWidth: number): number {
    let width = windowWidth / 3
    if (count <= 4 && this.showLargeViewIndex == index) {
      width = windowWidth
    } else if (count <= 4 && this.showLargeViewIndex < 0) {
      width = windowWidth / 2
    } else if (count > 4 && this.showLargeViewIndex == index) {
      width = windowWidth / 3 * 2
    }
    return width
  }

  private getLocation(count: number, windowWidth: number): Position[] {
    const width = windowWidth / 3;
    const height = windowWidth / 3;

    let currentIndex = 0;
    let lastFrame = 0;
    let segment: SegmentStyle = this.getSegment(count, currentIndex);

    const list: Position[] = [];
    while (currentIndex < count) {
      switch (segment) {
        case SegmentStyle.FULL_WIDTH:
          list.push(this.fullWidth(this.startMargin, lastFrame, width, height));
          lastFrame += height * 3;
          currentIndex += 1;
          break;
        case SegmentStyle.FIFTY_FIFTY:
          list.push(...this.fiftyFifty(this.startMargin, lastFrame, width, height));
          lastFrame += height * 3;
          currentIndex += 4;
          break;
        case SegmentStyle.THREE_ONE_THIRDS:
          list.push(...this.threeOneThird(this.startMargin, lastFrame, width, height));
          lastFrame += height;
          currentIndex += 3;
          break;
        case SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER:
          list.push(...this.twoThirdsOneThirdCenter(this.startMargin, lastFrame, width, height));
          lastFrame += height * 2;
          currentIndex += 3;
          break;
        case SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT:
          list.push(...this.twoThirdsOneThirdRight(this.startMargin, lastFrame, width, height));
          lastFrame += height * 2;
          currentIndex += 3;
          break;
        case SegmentStyle.ONE_THIRD_TWO_THIRDS:
          list.push(...this.oneThirdTwoThirds(this.startMargin, lastFrame, width, height));
          lastFrame += height * 2;
          currentIndex += 3;
          break;
        case SegmentStyle.ONE_THIRD:
          list.push(...this.oneThird(this.startMargin, lastFrame, width, height));
          lastFrame += height * 3;
          currentIndex += 3;
          break;
        default:
          break;
      }
      segment = this.getSegment(count, currentIndex);
    }
    return list;
  }

  private getSegment(count: number, currentIndex: number): SegmentStyle {
    let segment: SegmentStyle = SegmentStyle.THREE_ONE_THIRDS;
    if (currentIndex === 0) {
      if (count === 1) {
        segment = SegmentStyle.FULL_WIDTH;
      } else if (count == 2 || count == 4) {
        segment = this.showLargeViewIndex >= 0 ? SegmentStyle.FULL_WIDTH : SegmentStyle.FIFTY_FIFTY;
      } else if (count == 3) {
        segment = this.showLargeViewIndex >= 0 ? SegmentStyle.FULL_WIDTH : SegmentStyle.ONE_THIRD;
      } else if (this.showLargeViewIndex == 0) {
        segment = SegmentStyle.ONE_THIRD_TWO_THIRDS
      } else if (this.showLargeViewIndex == 1) {
        segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER
      } else if (this.showLargeViewIndex == 2) {
        segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT
      }
      return segment;
    }

    switch (count - currentIndex) {
      case 1:
        if (count === 3) {
          segment = SegmentStyle.ONE_THIRD;
        } else if (count > 4 && this.showLargeViewIndex === count - 1) {
          segment = SegmentStyle.ONE_THIRD_TWO_THIRDS;
        } else if (count === 4) {
          segment = SegmentStyle.FIFTY_FIFTY;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex) {
          segment = SegmentStyle.ONE_THIRD_TWO_THIRDS;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex + 1) {
          segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex + 2) {
          segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT;
        } else {
          segment = SegmentStyle.THREE_ONE_THIRDS;
        }
        break;
      case 2:
        if (count === 4) {
          segment = SegmentStyle.FIFTY_FIFTY;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex) {
          segment = SegmentStyle.ONE_THIRD_TWO_THIRDS;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex + 1) {
          segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex + 2) {
          segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT;
        } else {
          segment = SegmentStyle.THREE_ONE_THIRDS;
        }
        break;
      default:
        if (count > 4 && this.showLargeViewIndex === currentIndex) {
          segment = SegmentStyle.ONE_THIRD_TWO_THIRDS;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex + 1) {
          segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_CENTER;
        } else if (count > 4 && this.showLargeViewIndex === currentIndex + 2) {
          segment = SegmentStyle.TWO_THIRDS_ONE_THIRD_RIGHT;
        } else {
          segment = SegmentStyle.THREE_ONE_THIRDS;
        }
    }
    return segment;
  }

  private oneThirdTwoThirds(x: number, y: number, width: number, height: number): Array<Position> {
    return [
      new Position(x, y, width * 2, height * 2),
      new Position(x + width * 2, y, width, height),
      new Position(x + width * 2, y + height, width, height)
    ]
  }

  private threeOneThird(x: number, y: number, width: number, height: number): Array<Position> {
    return [
      new Position(x, y, width, height),
      new Position(x + width, y, width, height),
      new Position(x + width * 2, y, width, height)
    ]
  }

  private fullWidth(x: number, y: number, width: number, height: number): Position {
    return new Position(x, y, width * 3, height * 3);
  }

  private twoThirdsOneThirdCenter(x: number, y: number, width: number, height: number): Array<Position> {
    return [
      new Position(x, y, width, height),
      new Position(x + width, y, width * 2, height * 2),
      new Position(x, y + height, width, height)
    ]
  }

  private twoThirdsOneThirdRight(x: number, y: number, width: number, height: number): Array<Position> {
    return [
      new Position(x, y, width, height),
      new Position(x, y + height, width, height),
      new Position(x + width, y, width * 2, height * 2)
    ]
  }

  private fiftyFifty(x: number, y: number, childWidth: number, childHeight: number): Array<Position> {
    const width = childWidth * 3 / 2;
    const height = childHeight * 3 / 2;
    return [
      new Position(x, y, width, height),
      new Position(x + width, y, width, height),
      new Position(x, y + height, width, height),
      new Position(x + width, y + height, width, height)
    ]
  }

  private oneThird(x: number, y: number, childWidth: number, childHeight: number): Array<Position> {
    const width = childWidth * 3 / 2;
    const height = childHeight * 3 / 2;
    return [
      new Position(x, y, width, height),
      new Position(x + width, y, width, height),
      new Position(x + width / 2, y + height, width, height)
    ]
  }
}

enum SegmentStyle {
  FULL_WIDTH,
  ONE_THIRD,
  FIFTY_FIFTY,
  THREE_ONE_THIRDS,
  ONE_THIRD_TWO_THIRDS,
  TWO_THIRDS_ONE_THIRD_CENTER,
  TWO_THIRDS_ONE_THIRD_RIGHT
}

class Position {
  x: number;
  y: number;
  width: number;
  height: number;

  constructor(x: number, y: number, width: number, height: number) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
}