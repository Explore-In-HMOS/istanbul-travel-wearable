export class Place {
  id: string = ''
  audioIndex: number = -1
  name: string = ''
  type: string = ''
  shortDescription: string = ''
  fullDescription: string = ''
  address: string = ''
  latitude: number = 0
  longitude: number = 0
  openingTime: string = ''
  closingTime: string = ''
  boxOfficeClosingTime: string = ''
  nightOpeningTime: string = ''
  nightClosingTime: string = ''
  imageUrl: string = ''
  officialWebsite: string = ''
  ticketPurchaseLink: string = ''
  contactEmail: string = ''
  contactPhone1: string = ''
  contactPhone2: string = ''
}

export class PlaceDetailParam {
  place: Place = new Place()
  similarPlaces: Place[] = []
}
