//
//  TagAddViewController.swift
//  rePlace
//
//  Created by K I on 2022/09/24.
//

import UIKit

class TagAddViewController: UIViewController ,UITableViewDataSource{
    @IBOutlet var table:UITableView!
    
    let black     = UIColor.black
    let darkGray  = UIColor.darkGray
    let lightGray = UIColor.lightGray
    let white     = UIColor.white
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
