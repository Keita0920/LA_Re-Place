import Foundation
import MapKit

class CustomAnnotation:NSObject, MKAnnotation {
  public var coordinate: CLLocationCoordinate2D
  public var title: String?
  public var subtitle: String?

  init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle

    super.init()
  }
}
