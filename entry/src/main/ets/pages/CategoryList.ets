import { Place, PlaceDetailParam } from '../model/PlaceData'
import { CategoryViewModel } from '../viewmodel/CategoryViewModel'
import { PlaceItem } from '../components/PlaceItem'

@Component
export struct CategoryList {
  private vm: CategoryViewModel = new CategoryViewModel()
  @State private selectedTab: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  build() {
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
              ForEach(this.vm.tabs, (tab: string) => {
                Button(tab)
                  .height(20)
                  .padding({ left: 8, right: 8 })
                  .backgroundColor(this.selectedTab === this.vm.tabs.indexOf(tab) ? '#C0392B' : '#EEEEEE')
                  .fontColor(this.selectedTab === this.vm.tabs.indexOf(tab) ? Color.White : '#777777')
                  .fontSize(9)
                  .borderRadius(10)
                  .margin({ right: 4 })
                  .onClick(() => { this.selectedTab = this.vm.tabs.indexOf(tab) })
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
              PlaceItem({ place: place })
                .onClick(() => {
                  const param = new PlaceDetailParam()
                  param.place = place
                  param.similarPlaces = this.vm.places.filter(
                    (p: Place) => p.type === place.type && p.id !== place.id
                  )
                  this.pathStack.pushPathByName('PlaceDetail', param)
                })
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
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
  }

  private getFilteredPlaces(): Place[] {
    if (this.selectedTab === 0) {
      return this.vm.places
    }
    const type = this.vm.tabs[this.selectedTab]
    return this.vm.places.filter((p: Place) => p.type === type)
  }
}
