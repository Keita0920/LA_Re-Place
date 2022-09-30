//
//  tagListViewController.swift
//  rePlace
//
//  Created by K I on 2022/09/23.
//

import UIKit
import RealmSwift

class TagListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var table:UITableView!
    var tagNameArray=[String]()
    let realm=try! Realm()
    var receiveTagName:String?
    var indexNum:Int?
    var receiveColorNum:Int?
    var colorList=[UIColor]()
    let gray      = UIColor.gray
    let red       = UIColor.red
    let green     = UIColor.green
    let blue      = UIColor.blue
    let cyan      = UIColor.cyan
    let yellow    = UIColor.yellow
    let magenta   = UIColor.magenta
    let orange    = UIColor.orange
    let purple    = UIColor.purple
    let brown     = UIColor.brown
    var handleColor=[UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorList=[red,green,blue,cyan,yellow,magenta,orange,purple,brown,gray]
        table.delegate=self
        table.dataSource=self
        let tag=realm.objects(Tag.self)
        for i in 0..<tag.count{
            tagNameArray.append(tag[i].tagName)
            handleColor.append(colorList[tag[i].colorIndexNum])
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let receiveTagName = receiveTagName else{return}
        if receiveTagName == ""{
            return
        }
        if indexNum == nil{
            tagNameArray.append(receiveTagName)
            handleColor.append(colorList[receiveColorNum!])
            self.receiveTagName=nil
        }else{
            tagNameArray[indexNum!]=receiveTagName
            handleColor[indexNum!]=colorList[receiveColorNum!]
            indexNum=nil
        }
        table.reloadData()
    }
    
    //セルの数を決定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagNameArray.count
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text=tagNameArray[indexPath.row]
        cell?.backgroundColor=handleColor[indexPath.row]
        return cell!
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    //スワイプしたセルとそのデータを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            tagNameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
        }
        let tag = realm.objects(Tag.self)
        try! realm.write {
            realm.delete(tag[indexPath.row])
        }
    }
    //セルの編集
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagAddVC = storyboard?.instantiateViewController(withIdentifier: "TagAddViewController") as? TagAddViewController
        if let tagAddVC = tagAddVC {
            tagAddVC.receiveTagName = self.tagNameArray[indexPath.row]
            indexNum=indexPath.row
            let tag = realm.objects(Tag.self)
            tagAddVC.indexNum=tag[indexPath.row].colorIndexNum
        }
        // 遷移先のプロパティに処理ごと渡す
        tagAddVC?.resultHandler = { text in
        self.receiveTagName = text
        }
        // 遷移先のプロパティに処理ごと渡す
        tagAddVC?.resultColor = { num in
            self.receiveColorNum = num
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 別の画面に遷移
        self.navigationController?.pushViewController(tagAddVC!, animated: true)
    }
    //Tagの新規作成
    @IBAction func addTag(){
        let tagAddVC = storyboard?.instantiateViewController(withIdentifier: "TagAddViewController") as? TagAddViewController
        // 遷移先のプロパティに処理ごと渡す
        tagAddVC?.resultHandler = { text in
            self.receiveTagName = text
        }
        // 遷移先のプロパティに処理ごと渡す
        tagAddVC?.resultColor = { num in
            self.receiveColorNum = num
        }
        self.navigationController?.pushViewController(tagAddVC!, animated: true)
    }
}
