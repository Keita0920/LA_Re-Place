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
    // 遷移元から処理を受け取るクロージャのプロパティを用意
        var resultHandler: ((String) -> Void)?
    

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
    
    override func viewWillAppear(_ animated: Bool) {
        guard receiveTagName != nil else{return}
        tagName.text=receiveTagName
        receiveTagName=nil
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
        tag.tagName=self.tagName.text!
        try! realm.write{realm.add(tag)}
        // nilチェック
                guard let text = self.tagName.text else { return }
        // 用意したクロージャに関数がセットされているか確認する
                if let handler = self.resultHandler {
                    // 入力値を引数として渡された処理の実行
                    handler(text)
                }
        navigationController?.popViewController(animated: true)
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
