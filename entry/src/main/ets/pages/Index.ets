import { Place, PlaceDetailParam } from '../model/PlaceData'
import { CategoryViewModel } from '../viewmodel/CategoryViewModel'
import { PlaceDetail } from './PlaceDetail'

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()
  private categoryVm: CategoryViewModel = new CategoryViewModel()
  @State private selectedTab: number = 0

  @Builder
  PlaceItemBuilder(place: Place) {
    Row() {
      if (place.imageUrl.length > 0) {
        Image(place.imageUrl)
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
          .flexShrink(0)
      }
      Text(place.name)
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
    .onClick(() => {
      const param = new PlaceDetailParam()
      param.place = place
      param.similarPlaces = this.categoryVm.places.filter(
        (p: Place) => p.type === place.type && p.id !== place.id
      )
      this.pathStack.pushPathByName('PlaceDetail', param)
    })
  }

  // Full-screen NavDestination for the category filter + place list view
  @Builder
  CategoryListPage() {
    NavDestination() {
      Column() {
        Column() {
          Text('Museum Tour')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
            .margin({ bottom: 6 })

          Scroll() {
            Row() {
              ForEach(this.categoryVm.tabs, (tab: string) => {
                Button(tab)
                  .height(20)
                  .padding({ left: 8, right: 8 })
                  .backgroundColor(this.selectedTab === this.categoryVm.tabs.indexOf(tab) ? '#C0392B' : '#EEEEEE')
                  .fontColor(this.selectedTab === this.categoryVm.tabs.indexOf(tab) ? Color.White : '#777777')
                  .fontSize(9)
                  .borderRadius(10)
                  .margin({ right: 4 })
                  .onClick(() => { this.selectedTab = this.categoryVm.tabs.indexOf(tab) })
              }, (tab: string) => tab)
            }
            .padding({ left: 20, right: 20 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 10, bottom: 8 })
        .backgroundColor('#FAF8F5')

        Scroll() {
          Column() {
            ForEach(this.getFilteredPlaces(), (place: Place) => {
              this.PlaceItemBuilder(place)
            }, (place: Place) => place.id)
          }
          .padding({ left: 14, right: 14, bottom: 14 })
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor('#FAF8F5')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAF8F5')
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.selectedTab = 0
    })
  }

  private getFilteredPlaces(): Place[] {
    if (this.selectedTab === 0) {
      return this.categoryVm.places
    }
    const type = this.categoryVm.tabs[this.selectedTab]
    return this.categoryVm.places.filter((p: Place) => p.type === type)
  }

  // Maps named NavDestination routes to their builder functions
  @Builder
  pageMap(name: string) {
    if (name === 'CategoryList') {
      this.CategoryListPage()
    } else if (name === 'PlaceDetail') {
      PlaceDetail()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Column() {
          Row() {
            Column().width(3).height(16).backgroundColor('#C0392B')
            Column().width(3).height(16).backgroundColor('#C0392B').margin({ left: 4 })
            Column().width(3).height(16).backgroundColor('#C0392B').margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Bottom)

          Row().width(26).height(4).backgroundColor('#C0392B').borderRadius(1)
          Row().width(32).height(3).backgroundColor('#A93226').borderRadius(1).margin({ top: 1 })
        }
        .height(30)
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 10 })

        Text('Istanbul Guide')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
          .margin({ bottom: 4 })

        Button('Explore')
          .width(90)
          .height(26)
          .backgroundColor('#C0392B')
          .fontColor(Color.White)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 10 })
          .borderRadius(13)
          .onClick(() => {
            this.pathStack.pushPathByName('CategoryList', null)
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FAF8F5')
      .padding({ left: 20, right: 20 })
    }
    .navDestination(this.pageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
  }
}
