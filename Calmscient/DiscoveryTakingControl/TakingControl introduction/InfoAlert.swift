import UIKit

protocol InfoAlertViewActionProtocol: AnyObject {
    
    func didClickOnCancelButton()
}

class InfoAlert: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var infotableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var alertActionDelegate: InfoAlertViewActionProtocol?
    
    // Sample data for the table view
    var infoItems: [String] =  ["AUDIT","DUST-10","CAGE"]
    var infoAlertCaptionKeys: [String] = ["ialrt_cap_1", "ialrt_cap_2", "ialrt_cap_3"]
    
    let infoAlertDetailKeys = ["ialrt_desc_1", "ialrt_desc_2", "ialrt_desc_3"]

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "InfoAlert")
        setupTableView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "InfoAlert")
        setupTableView()
    }
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 0.9)
        addSubview(view)
    }
    
    private func setupTableView() {
        infotableView.delegate = self
        infotableView.dataSource = self
        //        infotableView.register(UITableViewCell.self, forCellReuseIdentifier: "InfoAlertCell")
        infotableView.register(UINib(nibName: "InfoAlertCell", bundle: nil), forCellReuseIdentifier: "InfoAlertCell")
    }
    
    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoAlertCell", for: indexPath) as! InfoAlertCell
        cell.name_label?.text = infoItems[indexPath.row]
        cell.caption_label.text = infoAlertCaptionKeys[indexPath.row].localized
        cell.description_label.text = infoAlertDetailKeys[indexPath.row].localized
        cell.selectionStyle = .none
        
        return cell
    }
    
    // UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected \(infoItems[indexPath.row])")
    }
    
    @IBAction func didClickOnCancelButton(_ sender: UIButton) {
        alertActionDelegate?.didClickOnCancelButton()
       
        self.removeFromSuperview()
    }
    
    
}
