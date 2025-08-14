//
//  TablePopOverViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

public class PopOverItemData {
    var imageName:String!
    var title:String!
    
    init(imageName: String!, title: String!) {
        self.imageName = imageName
        self.title = title
    }
}

protocol PopOverActionDelegate:AnyObject {
    func userSelectedPopOverRow(index:Int, title:String)
}

class TablePopOverViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
//    var tableData:[PopOverItemData] = [PopOverItemData(imageName: "JournalEntryAdd", title: "Add"),PopOverItemData(imageName: "JournalEntryEdit", title: "Edit"),PopOverItemData(imageName: "JournalEntryDelete", title: "Delete")]
    var tableData:[PopOverItemData] = [PopOverItemData(imageName: "JournalEntryAdd", title: "Add")]
    weak var tablePopOverDelegate:PopOverActionDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setUpTableView() {
        let nib = UINib(nibName: "JournalEntryPopOverTableCell", bundle: nil)
        // Register custom cell class
        tableView.register(nib, forCellReuseIdentifier: "JournalEntryPopOverTableCell")
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    

}

extension TablePopOverViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = tableData[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryPopOverTableCell", for: indexPath) as? JournalEntryPopOverTableCell else {
            return UITableViewCell()
        }
        cell.cellIconImage.image = UIImage(named: dataItem.imageName)
        cell.cellTitleLabel.text = dataItem.title
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection
        let dataItem = tableData[indexPath.row]
        tablePopOverDelegate?.userSelectedPopOverRow(index: indexPath.row, title: tableData[indexPath.row].title)
    }
}
