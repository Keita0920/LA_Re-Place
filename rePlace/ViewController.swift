import UIKit
import CoreLocation
import MapKit
import RealmSwift


class ViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    var picture:UIImage!
    var resizedPicture:UIImage!
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    var annotationView: MKAnnotationView?
    var loc:CLLocation? = nil
    var latitude:Double=0.0
    var longitude:Double=0.0
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // ドキュメントディレクトリの「パス」（String型）定義
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報の使用の許可を得る
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                // 座標の表示
                locationManager.startUpdatingLocation()
                break
            default:
                locationManager.requestAlwaysAuthorization()
            }
        }
        // 地図の初期化
        initMap()
        
        let tableData = realm.objects(Replace.self)
        print(tableData)
        if tableData.count == 0{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateCurrentPos((locations.last?.coordinate)!)
        guard let loc = locations.last else { return }
        self.loc=loc
        self.latitude=Double(String(locations.first?.coordinate.latitude))!
        self.longitude=Double(String(locations.first?.coordinate.longitude))!
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
            if let error = error {
                print("reverseGeocodeLocation Failed: \(error.localizedDescription)")
                return
            }
        })
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
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            // ユーザの現在地の青丸マークは置き換えない
            return nil
        } else {
            // CustomAnnotationの場合に画像を配置
            let identifier = "Pin"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
            }
            let tableData = realm.objects(Replace.self)
            if tableData.count == 0{
                return nil
            }
            //URL型にキャスト
            let fileURL = URL(string: tableData[0].imageURL)
            //パス型に変換
            let filePath = fileURL?.path
            annotationView?.image = UIImage(contentsOfFile: filePath!)
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
        let pa = MKPointAnnotation()
        pa.title = "I'm here!"
        guard let loc=self.loc else{
            return
        }
        pa.coordinate = loc.coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pa)
        
        let table = Replace()
        table.latitude=self.latitude
        table.longitude=self.longitude
        try! realm.write{realm.add(table)}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picture=info[.editedImage]as?UIImage
        resizedPicture = picture.resize(targetSize: CGSize(width: picture.size.width / 10, height: picture.size.height / 10))
        saveImage()
        dismiss(animated: true,completion: nil)
    }
    //保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "\(NSUUID().uuidString).png"
        // DocumentディレクトリのfileURLを取得
        if documentDirectoryFileURL != nil {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let path = documentDirectoryFileURL.appendingPathComponent(fileName)
            documentDirectoryFileURL = path
        }
    }
    
    //画像を保存する関数の部分
    func saveImage() {
        createLocalDataFile()
        //pngで保存する場合
        let pngImageData = resizedPicture.pngData()
        do {
            try pngImageData!.write(to: documentDirectoryFileURL)
            let table = Replace()
            table.imageURL = documentDirectoryFileURL.absoluteString
            try! realm.write{realm.add(table)}
        } catch {
            //エラー処理
            print("エラー")
        }
    }
}

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
}
