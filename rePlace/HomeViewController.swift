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
    var loc:CLLocationCoordinate2D? = nil
    var latitude:Double=0.0
    var longitude:Double=0.0
    var fileName2:String?
    var imageURLArray:[String]=[]
    var index:Int=0
    var isViewDidLoad:Bool=true
    var imagecount:Int?
    var annotationView:UIImage!
    var isDeleted:Bool=false
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let next = segue.destination
            if let sheet = next.sheetPresentationController {
                sheet.detents = [.medium()]
                //モーダル出現後も親ビュー操作可能にする
                sheet.largestUndimmedDetentIdentifier = .medium
                // 角丸の半径を変更する
                sheet.preferredCornerRadius = 20.0
            }
        if segue.identifier == "toHalfModal" {
            let secondView = segue.destination as! HalfModalViewController
            // 遷移先のプロパティに処理ごと渡す
            secondView.resultHandler = { bool in
                self.isDeleted = bool
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
    
    //addAnnotationしたときに呼ばれる
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
            }
            if let annotationView = annotationView {
                annotationView.canShowCallout = true
                annotationView.image = myAnnotation.image!
            }
            return annotationView
        }
    }
    
    //写真を撮る
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
        //Realmから読み込み
        let image = realm.objects(Image.self)
        print(image)
        imagecount=image.count
        let img = UIImage.getFromDocuments(filename: image[image.count-1].imageURL)
        let coordinate=CLLocationCoordinate2D(latitude: image[image.count-1].latitude, longitude: image[image.count-1].longitude)
        let annotationPin=AnnotationPin(image: img, coordinate: coordinate,object: image[image.count-1])
        mapView.addAnnotation(annotationPin)
    }
    
    //Realmに保存する関数の部分
    func save() {
        let filename = UUID.init().uuidString + ".jpg"
        fileName2=filename
        resizedPicture.saveToDocuments(filename: filename)
        let replace = Image()
        replace.imageURL = filename
        replace.latitude=self.latitude
        replace.longitude=self.longitude
        try! realm.write{realm.add(replace)}
    }
    
    func refresh(){
        mapView.removeAnnotations(mapView.annotations)
        //Realmから読み込み
        let image = realm.objects(Image.self)
        print(image)
        imagecount=image.count
        for i in 0..<image.count{
            let img = UIImage.getFromDocuments(filename: image[i].imageURL)
            let coordinate=CLLocationCoordinate2D(latitude: image[i].latitude, longitude: image[i].longitude)
            let annotationPin=AnnotationPin(image: img, coordinate: coordinate,object: image[i])
            mapView.addAnnotation(annotationPin)
        }
    }
    
    //ピンが選択されたら
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "toHalfModal", sender: nil)
        annotationView=view.image
        }
}

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    func saveToDocuments(filename:String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = self.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }
    static func getFromDocuments(filename: String) -> UIImage {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let data = try! Data(contentsOf: documentsDirectory.appendingPathComponent(filename))
        let image = UIImage(data: data)
        return image!
    }
}

class AnnotationPin:  NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let image: UIImage?
    let object:Image!
    init(title:String?=nil, subtitle: String?=nil, image: UIImage, coordinate: CLLocationCoordinate2D,object:Image) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = image
        self.object=object
        super.init()
    }}



