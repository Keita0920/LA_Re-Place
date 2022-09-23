import UIKit
import CoreLocation
import MapKit
import RealmSwift


class HomeViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    var picture:UIImage!
    var resizedPicture:UIImage!
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    var annotationView: MKAnnotationView?
    var loc:CLLocationCoordinate2D? = nil
    var latitude:Double=0.0
    var longitude:Double=0.0
    var tableview:UITableView!
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
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // 地図の初期化
        initMap()
        //Realmから読み込み
        let replace = realm.objects(Image.self)
        print(replace)
        if replace.count == 0{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateCurrentPos((locations.last?.coordinate)!)
        guard let loc: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(loc.latitude) \(loc.longitude)")
        latitude=loc.latitude
        longitude=loc.longitude
        self.loc=loc
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
            let tableData = realm.objects(Image.self)
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
        
    }
    
    //撮った写真をリサイズ
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picture=info[.editedImage]as?UIImage
        resizedPicture = picture.resize(targetSize: CGSize(width: picture.size.width / 10, height: picture.size.height / 10))
        save()
        dismiss(animated: true,completion: nil)
        let pa = MKPointAnnotation()
        guard let loc=self.loc else{
            return
        }
        pa.coordinate = loc
        print(pa.coordinate)
        mapView.addAnnotation(pa)
    }
    
    //保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "\(NSUUID().uuidString).png"
        // DocumentディレクトリのfileURLを取得
        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let path = documentDirectoryFileURL.appendingPathComponent(fileName)
        documentDirectoryFileURL = path
        
    }
    
    //Realmに保存する関数の部分
    func save() {
        createLocalDataFile()
        //pngで保存する場合
        let pngImageData = resizedPicture.pngData()
        do {
            try pngImageData!.write(to: documentDirectoryFileURL)
            let replace = Image()
            replace.imageURL = documentDirectoryFileURL.absoluteString
            replace.latitude=self.latitude
            replace.longitude=self.longitude
            try! realm.write{realm.add(replace)}
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
