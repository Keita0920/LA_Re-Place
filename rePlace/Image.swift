//
//  Image.swift
//  rePlace
//
//  Created by K I on 2022/09/23.
//

import Foundation
import RealmSwift

class Image: Object{
    @objc dynamic var longitude:Double=0.0
    @objc dynamic var latitude:Double=0.0
    @objc dynamic var imageURL:String=""
    @objc dynamic var colorIndexNum:Int=0
    @objc dynamic var tagName:String=""
}
