import { Place } from '../model/PlaceData'

@Component
export struct PlaceItem {
  place: Place = new Place()

  build() {
    Row() {
      if (this.place.imageUrl.length > 0) {
        Image(this.place.imageUrl)
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
          .flexShrink(0)
      }

      Text(this.place.name)
        .fontSize(11)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .padding({ right: 10 })
    }
    .width('100%')
    .height(60)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 4 })
    .clip(true)
    .alignItems(VerticalAlign.Center)
  }
}
