import util from '@ohos.util'
import resourceManager from '@ohos.resourceManager'
import { Place } from '../model/PlaceData'

interface RawHours {
  openingTime?: string
  closingTime?: string
  boxOfficeClosingTime?: string

}

interface RawOpenClose {
  regular?: RawHours
  night?: RawHours
}

interface RawContact {
  email?: string
  phone_1?: string
  phone_2?: string
}

interface RawPlace {
  id?: string
  name?: string
  type?: string
  shortDescription?: string
  shortDesc?: string
  fullDescription?: string
  fullDesc?: string
  address?: string
  latitude?: number
  longitude?: number
  openCloseHours?: RawOpenClose
  imageUrl?: string
  officialWebsite?: string
  ticketPurchaseLink?: string
  contact?: RawContact
}

export class CategoryViewModel {
  selectedTab: number = 0
  places: Place[] = []
  readonly tabs: string[] = ['All', 'Museum', 'Monument', 'Mosque', 'Fortress', 'Palace']

  constructor() {
    this.loadData()
  }

  loadData(): void {
    const mgr = AppStorage.get<resourceManager.ResourceManager>('resmgr')
    if (!mgr) {
      return
    }
    const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
    const items: Place[] = []

    for (let i = 0; i < 14; i++) {
      try {
        const data: Uint8Array = mgr.getRawFileContentSync(`${i}.json`)
        const text: string = decoder.decodeToString(data)
        const raw: RawPlace = JSON.parse(text) as RawPlace
        const place = new Place()
        place.id = raw.id ?? ''
        place.audioIndex = i
        place.name = raw.name ?? ''
        place.type = raw.type ?? ''
        place.shortDescription = raw.shortDescription ?? raw.shortDesc ?? raw.shortDescription ?? ''
        place.fullDescription = raw.fullDescription ?? raw.fullDesc ?? raw.fullDescription ?? ''
        place.address = raw.address ?? ''
        place.latitude = raw.latitude ?? 0
        place.longitude = raw.longitude ?? 0
        const hours = raw.openCloseHours ?? raw.openCloseHours
        place.openingTime = hours?.regular?.openingTime ?? hours?.regular?.openingTime ?? ''
        place.closingTime = hours?.regular?.closingTime ?? hours?.regular?.closingTime ?? ''
        place.boxOfficeClosingTime = hours?.regular?.boxOfficeClosingTime ?? hours?.regular?.boxOfficeClosingTime ?? ''
        place.nightOpeningTime = hours?.night?.openingTime ?? hours?.night?.openingTime ?? ''
        place.nightClosingTime = hours?.night?.closingTime ?? hours?.night?.closingTime ?? ''
        place.imageUrl = raw.imageUrl ?? raw.imageUrl ?? ''
        place.officialWebsite = raw.officialWebsite ?? raw.officialWebsite ?? ''
        place.ticketPurchaseLink = raw.ticketPurchaseLink ?? raw.ticketPurchaseLink ?? ''
        place.contactEmail = raw.contact?.email ?? ''
        place.contactPhone1 = raw.contact?.phone_1 ?? ''
        place.contactPhone2 = raw.contact?.phone_2 ?? ''
        items.push(place)
      } catch (e) {
        console.error(`CategoryViewModel: failed to load ${i}.json`)
      }
    }

    this.places = items
  }

  selectTab(idx: number): void {
    this.selectedTab = idx
  }

  getFilteredPlaces(): Place[] {
    if (this.selectedTab === 0) {
      return this.places
    }
    const tabName: string = this.tabs[this.selectedTab]
    return this.places.filter((p: Place): boolean => p.type === tabName)
  }
}
