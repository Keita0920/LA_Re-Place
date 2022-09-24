//
//  tagListViewController.swift
//  rePlace
//
//  Created by K I on 2022/09/23.
//

import UIKit
import RealmSwift

class TagListViewController: UIViewController,UITableViewDataSource {
    @IBOutlet var table:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource=self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text="テスト"
        return cell!
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
