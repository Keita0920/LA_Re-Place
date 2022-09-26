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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagAddVC = storyboard?.instantiateViewController(withIdentifier: "TagAddViewController") as? TagAddViewController
        if let tagAddVC = tagAddVC {
            tagAddVC.receiveTagName = self.tagNameArray[(self.table.indexPathForSelectedRow?.row)!]
            tagAddVC.tagName.text=tagAddVC.receiveTagName
        }
            // セルの選択を解除
            tableView.deselectRow(at: indexPath, animated: true)
            // 別の画面に遷移
            performSegue(withIdentifier: "editTag", sender: nil)
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
