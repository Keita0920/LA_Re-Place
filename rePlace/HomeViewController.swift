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
    var imagePin:[AnnotationPin]=[]
    var path:URL? = nil
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
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
        let image = realm.objects(Image.self)
        print(image)
        if image.count == 0{
            return
        }
        
        
        for i in 0..<image.count{
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            for imageURL in directoryContents where imageURL.absoluteString == image[i].imageURL {
                if let img = UIImage(contentsOfFile: imageURL.path) {
                    print("test", img)
                    let coordinate=CLLocationCoordinate2D(latitude: image[i].latitude, longitude: image[i].longitude)
                    let annotationPin=AnnotationPin(image:img,coordinate: coordinate)
                    mapView.addAnnotation(annotationPin)
                    
                } else {
                   fatalError("Can't create image from file \(imageURL)")
                }
            }
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
            guard let myAnnotation = annotation as? AnnotationPin  else {
                    return nil
                }

                let annotationIdentifier = "AnnotationIdentifier"

                var annotationView: MKAnnotationView?
                if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                    annotationView = dequeuedAnnotationView
                    annotationView?.annotation = annotation
                }
                else {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                    annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }

                if let annotationView = annotationView {
                   
                    annotationView.canShowCallout = true
                    annotationView.image = myAnnotation.image
                }

                return annotationView
            
        }
        return nil
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
    func createLocalDataFile() -> URL?{
        // 作成するテキストファイルの名前
        let fileName = "\(UUID.init().uuidString).png"
        // DocumentディレクトリのfileURLを取得
        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        return documentDirectoryFileURL.appendingPathComponent(fileName)
        
    }
    
    //Realmに保存する関数の部分
    func save() {
        let path = createLocalDataFile()!
        //pngで保存する場合
        let pngImageData = resizedPicture.pngData()
        do {
            try path.saveImage(resizedPicture)
            let replace = Image()
            replace.imageURL = path.absoluteString
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

class AnnotationPin:  NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let image: UIImage?
    
    init(title:String?=nil, subtitle: String?=nil, image: UIImage, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = image
        super.init()
    }}

extension URL {
    func loadImage(_ image: inout UIImage?) {
        if let data = try? Data(contentsOf: self), let loaded = UIImage(data: data) {
            image = loaded
        } else {
            image = nil
        }
    }
    func saveImage(_ image: UIImage?) {
        if let image = image {
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: self)
            }
        } else {
            try? FileManager.default.removeItem(at: self)
        }
    }
}
