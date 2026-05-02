import media from '@ohos.multimedia.media'
import resourceManager from '@ohos.resourceManager'
import { Place, PlaceDetailParam } from '../model/PlaceData'
import { AudioManager } from '../model/AudioManager'

@Component
export struct PlaceDetail {
  @State place: Place = new Place()
  @State similarPlaces: Place[] = []
  @State speedIndex: number = 0
  @StorageProp('bgIsPlaying') bgIsPlaying: boolean = false
  @StorageProp('bgPlayerAudioIndex') bgAudioIndex: number = -1
  @StorageProp('bgPlayerReady') bgPlayerReady: boolean = false
  @StorageProp('bgCurrentTime') bgCurrentTime: number = 0
  @StorageProp('bgDuration') bgDuration: number = 0
  private pathStack: NavPathStack = new NavPathStack()

  private isActive(): boolean {
    return this.bgAudioIndex === this.place.audioIndex
  }

  private isPlaying(): boolean {
    return this.isActive() && this.bgIsPlaying
  }

  private isReady(): boolean {
    return this.isActive() && this.bgPlayerReady
  }

  // Lock play button while another audio is playing
  private isLocked(): boolean {
    return this.bgIsPlaying && !this.isActive()
  }

  private currentTime(): number {
    return this.isActive() ? this.bgCurrentTime : 0
  }

  private duration(): number {
    return this.isActive() ? this.bgDuration : 0
  }

  getSpeedLabel(): string {
    const labels: string[] = ['1.0x', '1.25x', '1.50x', '2.0x', '0.75x']
    return labels[this.speedIndex]
  }

  getPlaybackSpeed(): media.PlaybackSpeed {
    if (this.speedIndex === 1) { return media.PlaybackSpeed.SPEED_FORWARD_1_25_X }
    if (this.speedIndex === 2) { return media.PlaybackSpeed.SPEED_FORWARD_1_50_X }
    if (this.speedIndex === 3) { return media.PlaybackSpeed.SPEED_FORWARD_2_00_X }
    if (this.speedIndex === 4) { return media.PlaybackSpeed.SPEED_FORWARD_0_75_X }
    return media.PlaybackSpeed.SPEED_FORWARD_1_00_X
  }

  formatTime(ms: number): string {
    const totalSec: number = Math.floor(ms / 1000)
    const min: number = Math.floor(totalSec / 60)
    const sec: number = totalSec % 60
    return `${min}:${sec < 10 ? '0' : ''}${sec}`
  }

  async initAudioPlayer(): Promise<void> {
    // Skip loading if another audio is already playing — user must stop it first
    if (this.bgIsPlaying && !this.isActive()) { return }

    const mgr = AppStorage.get<resourceManager.ResourceManager>('resmgr')
    if (!mgr) { return }
    await AudioManager.load(mgr, this.place.audioIndex)
  }

  async togglePlay(): Promise<void> {
    if (this.isPlaying()) {
      await AudioManager.pause()
      return
    }

    const mgr = AppStorage.get<resourceManager.ResourceManager>('resmgr')
    if (!mgr) { return }

    if (!this.isActive()) {
      await AudioManager.load(mgr, this.place.audioIndex, true)
      return
    }

    if (!this.bgPlayerReady) { return }
    await AudioManager.play()
  }

  cycleSpeed(): void {
    if (!this.isReady()) { return }
    this.speedIndex = (this.speedIndex + 1) % 5
    AudioManager.setSpeed(this.getPlaybackSpeed())
  }

  aboutToDisappear(): void {

  }

  getTypeColor(type: string): string {
    if (type === 'Museum') { return '#2E86AB' }
    if (type === 'Monument') { return '#8B5CF6' }
    if (type === 'Mosque') { return '#059669' }
    if (type === 'Fortress') { return '#D97706' }
    if (type === 'Palace') { return '#B45309' }
    return '#888888'
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.place.imageUrl.length > 0) {
            Image(this.place.imageUrl)
              .width('100%')
              .height(90)
              .objectFit(ImageFit.Cover)
          }

          Column() {
            Row() {
              Text(this.place.type)
                .fontSize(7)
                .fontColor(Color.White)
                .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                .backgroundColor(this.getTypeColor(this.place.type))
                .borderRadius(4)
            }
            .width('100%')
            .margin({ bottom: 5 })

            Text(this.place.name)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A2E')
              .width('100%')
              .margin({ bottom: 8 })

            if (this.place.fullDescription.length > 0) {
              Text('About')
                .fontSize(9)
                .fontWeight(FontWeight.Bold)
                .fontColor('#C0392B')
                .width('100%')
                .margin({ bottom: 3 })
              Text(this.place.fullDescription)
                .fontSize(8)
                .fontColor('#444444')
                .width('100%')
                .lineHeight(13)
                .margin({ bottom: 10 })
            }

            Divider()
              .color('#E0DDD8')
              .margin({ bottom: 8 })

            // Audio guide player: play/pause, speed cycle, progress bar
            Text('Audio Guide')
              .fontSize(9)
              .fontWeight(FontWeight.Bold)
              .fontColor('#C0392B')
              .width('100%')
              .margin({ bottom: 6 })

            Column() {
              Row() {
                Row() {
                  SymbolGlyph(this.isPlaying()
                    ? $r('sys.symbol.pause_fill')
                    : $r('sys.symbol.play_fill'))
                    .fontSize(14)
                    .fontColor([Color.White])
                }
                .width(28)
                .height(28)
                .borderRadius(14)
                .backgroundColor('#C0392B')
                .justifyContent(FlexAlign.Center)
                .onClick(() => { this.togglePlay() })

                Row() {
                  Text(this.getSpeedLabel())
                    .fontSize(9)
                    .fontColor(this.isReady() ? '#C0392B' : '#CCCCCC')
                    .fontWeight(FontWeight.Bold)
                }
                .height(28)
                .padding({ left: 8, right: 8 })
                .borderRadius(14)
                .border({ width: 1.5, color: this.isReady() ? '#C0392B' : '#CCCCCC' })
                .justifyContent(FlexAlign.Center)
                .margin({ left: 6 })
                .onClick(() => { this.cycleSpeed() })
              }
              .width('100%')
              .margin({ bottom: 6 })

              Row() {
                Row()
                  .height(3)
                  .layoutWeight(this.currentTime())
                  .backgroundColor('#C0392B')
                  .borderRadius(2)
                Row()
                  .height(3)
                  .layoutWeight(Math.max(this.duration() - this.currentTime(), 1))
                  .backgroundColor('#E0DDD8')
                  .borderRadius(2)
              }
              .width('100%')

              Row() {
                Text(this.formatTime(this.currentTime()))
                  .fontSize(7)
                  .fontColor('#888888')
                Text(this.formatTime(this.duration()))
                  .fontSize(7)
                  .fontColor('#888888')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ top: 3, bottom: 10 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            if (this.place.ticketPurchaseLink.length > 0) {
              Divider()
                .color('#E0DDD8')
                .margin({ bottom: 8 })

              Text('Buy Ticket')
                .fontSize(9)
                .fontWeight(FontWeight.Bold)
                .fontColor('#C0392B')
                .width('100%')
                .margin({ bottom: 6 })

              Column() {
                QRCode(this.place.ticketPurchaseLink)
                  .width(72)
                  .height(72)
                  .color('#1A1A2E')
                  .backgroundColor(Color.White)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .padding({ bottom: 10 })
            }

            // Similar places horizontal scroll list
            if (this.similarPlaces.length > 0) {
              Divider()
                .color('#E0DDD8')
                .margin({ bottom: 8 })

              Text('Similar Places')
                .fontSize(9)
                .fontWeight(FontWeight.Bold)
                .fontColor('#C0392B')
                .width('100%')
                .margin({ bottom: 6 })

              Scroll() {
                Row() {
                  ForEach(this.similarPlaces, (item: Place) => {
                    Column() {
                      if (item.imageUrl.length > 0) {
                        Image(item.imageUrl)
                          .width(64)
                          .height(48)
                          .objectFit(ImageFit.Cover)
                          .borderRadius({ topLeft: 6, topRight: 6 })
                      } else {
                        Row()
                          .width(64)
                          .height(48)
                          .backgroundColor('#E0DDD8')
                          .borderRadius({ topLeft: 6, topRight: 6 })
                      }
                      Text(item.name)
                        .fontSize(7)
                        .fontColor('#1A1A2E')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width(64)
                        .padding({ left: 4, right: 4, top: 4, bottom: 4 })
                    }
                    .width(64)
                    .backgroundColor(Color.White)
                    .borderRadius(6)
                    .margin({ right: 6 })
                    .clip(true)
                    .onClick(() => {
                      const param = new PlaceDetailParam()
                      param.place = item
                      param.similarPlaces = this.similarPlaces.filter(
                        (p: Place) => p.id !== item.id
                      )
                      this.pathStack.pushPathByName('PlaceDetail', param)
                    })
                  }, (item: Place) => item.id)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .margin({ bottom: 10 })
            }
          }
          .padding({ left: 12, right: 12, top: 10, bottom: 20 })
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor('#FAF8F5')
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      const param = ctx.pathInfo.param as PlaceDetailParam
      if (param && param.place) {
        this.place = param.place
        this.similarPlaces = param.similarPlaces ?? []
        this.initAudioPlayer()
      }
    })
  }
}
