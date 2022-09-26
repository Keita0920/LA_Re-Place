//
//  TagAddViewController.swift
//  rePlace
//
//  Created by K I on 2022/09/24.
//

import UIKit
import RealmSwift

class TagAddViewController: UIViewController ,UITableViewDataSource,UITextFieldDelegate, UITableViewDelegate{
    @IBOutlet var table:UITableView!
    @IBOutlet weak var tagName:UITextField!
    var tagNameArray=[String]()
    var color=[UIColor]()
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
    let realm=try! Realm()
    var receiveTagName:String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource=self
        table.delegate=self
        tagNameArray=["red","green","blue","cyan","yellow","magenta","orange","purple","brown","gray"]
        color=[red,green,blue,cyan,yellow,magenta,orange,purple,brown,gray]
        tagName.delegate=self
        if let receiveTagName = self.receiveTagName {
                self.tagName.text = receiveTagName
            }

        // Do any additional setup after loading the view.
    }
        
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text=tagNameArray[indexPath.row]
        cell?.backgroundColor=color[indexPath.row]
        // セルが選択された時の背景色を消す
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func save() {
        let tag=Tag()
        let tagListVC=storyboard?.instantiateViewController(withIdentifier: "TagListViewController") as! TagListViewController
        let tagListVCInstance=tagListVC.view
        print(tagListVCInstance!)
        tag.tagName=self.tagName.text!
        try! realm.write{realm.add(tag)}
        let tag2=realm.objects(Tag.self)
        
        tagListVC.tagNameArray.append(tag2[tag2.count-1].tagName)
        
        tagListVC.table.performBatchUpdates({
            tagListVC.table.reloadData()
        }) { (finished) in
            print("reload完了しました")
        }
        
        let alert:UIAlertController=UIAlertController(title: "OK", message: "メモの保存が完了しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: {action in self.navigationController?.popViewController(animated: true)}))
        present(alert,animated: true,completion: nil)
    }
    
    // セルが選択された時に呼び出される
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let cell = tableView.cellForRow(at:indexPath)

            // チェックマークを入れる
            cell?.accessoryType = .checkmark
        }

        // セルの選択が外れた時に呼び出される
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let cell = tableView.cellForRow(at:indexPath)

            // チェックマークを外す
            cell?.accessoryType = .none
        }
}
