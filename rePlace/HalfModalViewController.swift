import UIKit
import MapKit
import RealmSwift

class HalfModalViewController: UIViewController {
    
    var mapView: MKMapView!
    var annotationPin:MKAnnotation!
    let realm=try! Realm()
    var resultHandler: ((Bool) -> Void)?
    var isDeleted:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
    
    @IBAction func deleteAnnnotation(){
        isDeleted=true
        if let handler = self.resultHandler {
            // 入力値を引数として渡された処理の実行
            handler(isDeleted)
        }
        let object=realm.objects(Image.self)
        try! realm.write() {
            realm.delete(object)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    }
    
    

