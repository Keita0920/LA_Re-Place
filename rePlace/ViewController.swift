import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    var cameraImageView=UIImageView()
    var picture:UIImage!
    var resizedPicture:UIImage!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        self.mapView.delegate = self
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        // 地図の初期化
                initMap()
        
        // 位置情報の使用の許可を得る
                    locationManager.requestWhenInUseAuthorization()
                    if CLLocationManager.locationServicesEnabled() {
                        switch CLLocationManager.authorizationStatus() {
                        case .authorizedWhenInUse:
                            // 座標の表示
                            locationManager.startUpdatingLocation()
                            break
                        default:
                            break
                        }
                    }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateCurrentPos((locations.last?.coordinate)!)
        guard let loc = locations.last else { return }
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
            
            if let error = error {
                print("reverseGeocodeLocation Failed: \(error.localizedDescription)")
                return
            }
        })
        let cr = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
               mapView.setRegion(cr, animated: true)
               
               let pa = MKPointAnnotation()
               pa.title = "I'm here!"
               pa.coordinate = loc.coordinate
               mapView.removeAnnotations(mapView.annotations)
               mapView.addAnnotation(pa)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func initMap() {
            // 縮尺を設定
            var region:MKCoordinateRegion = mapView.region
            region.span.latitudeDelta = 0.02
            region.span.longitudeDelta = 0.02
            mapView.setRegion(region,animated:true)

            // 現在位置表示の有効化
            mapView.showsUserLocation = true
            // 現在位置設定（デバイスの動きとしてこの時の一回だけ中心位置が現在位置で更新される）
            mapView.userTrackingMode = .follow
        }
    
    func updateCurrentPos(_ coordinate:CLLocationCoordinate2D) {
        var region:MKCoordinateRegion = mapView.region
        region.center = coordinate
        mapView.setRegion(region,animated:true)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
          // ユーザの現在地の青丸マークは置き換えない
          return nil
        } else {
          // CustomAnnotationの場合に画像を配置
          let identifier = "Pin"
          var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
          if annotationView == nil {
            annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
          }
            
            annotationView?.image = resizedPicture // 任意の画像名
          annotationView?.annotation = annotation
          return annotationView
        }
      }
    @IBAction func takePhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let picker=UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate=self
            picker.allowsEditing=true
            present(picker,animated: true,completion: nil)
        }else{
            print("error")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraImageView.image=info[.editedImage]as?UIImage
        picture=cameraImageView.image
        resizedPicture = picture.resize(targetSize: CGSize(width: picture.size.width / 8, height: picture.size.height / 8))
        dismiss(animated: true,completion: nil)
    }
}

extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}
