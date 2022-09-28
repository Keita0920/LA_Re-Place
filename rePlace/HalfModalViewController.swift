//
//  HalfModalViewController.swift
//  rePlace
//
//  Created by K I on 2022/09/28.
//

import UIKit
import MapKit

class HalfModalViewController: UIViewController {
    var mapView: MKMapView!
    var annotationPin:MKAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteAnnnotation(){
        mapView.removeAnnotation(annotationPin)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
