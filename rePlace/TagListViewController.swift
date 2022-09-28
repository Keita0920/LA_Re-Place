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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate=self
        table.dataSource=self
        let tag=realm.objects(Tag.self)
        for i in 0..<tag.count{
            tagNameArray.append(tag[i].tagName)
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
            self.receiveTagName=nil
            print(tagNameArray)
        }else{
            tagNameArray[indexNum!]=receiveTagName
            indexNum=nil
            print(tagNameArray)
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
        }
        tagAddVC?.indexNum=indexPath.row
        // 遷移先のプロパティに処理ごと渡す
        tagAddVC?.resultHandler = { text in
        // 引数を使ってoutputLabelの値を更新する処理
        self.receiveTagName = text
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
            // 引数を使ってoutputLabelの値を更新する処理
            self.receiveTagName = text
        }
        self.navigationController?.pushViewController(tagAddVC!, animated: true)
    }
}
