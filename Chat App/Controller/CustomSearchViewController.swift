//
//  SearchViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/23/21.
//

import UIKit

class CustomSearchController : UITableViewController {

    
    lazy var searchField : UITextField = {
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 320, height: 70))
        field.layer.cornerRadius = 15
        field.backgroundColor = .white
        field.tintColor = .black

        field.placeholder = "Search"
        return field
    }()
        
    var currentSearchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = searchField
        searchField.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        
        filteredItems = items

    }
    
    let items : [Conversation] = Conversation.stubList
    var filteredItems : [Conversation] = []

    var isFiltering: Bool {
      return currentSearchText != ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredItems.count
        }

        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as UITableViewCell
        let converation: Conversation
        if isFiltering {
            converation = filteredItems[indexPath.row]
        } else {
            converation = items[indexPath.row]
        }
        cell.imageView?.image = converation.thumbnail
        cell.imageView?.frame = CGRect(x: 0,y: 0 ,width: 65, height: 65)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 30
        cell.imageView?.clipsToBounds = true

        cell.textLabel?.text = converation.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show chat view
        tableView.deselectRow(at: indexPath, animated: true)
        let msgVC = MessagesViewController()
        msgVC.messageList = filteredItems[indexPath.row].messages
        navigationController?.pushViewController(msgVC, animated: true)
    }


}

extension CustomSearchController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard let text = textField.text, text != "" else {
            return
        }
        print("search \(text)")
        let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        filterItemForSearchKey(trimText)

    }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // only update when it truly changes
            if cleanText != originalText{
                
                print("search \(cleanText)")
                
                filterItemForSearchKey(cleanText)
            }
        }
        return true
    }
    
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
      self.filteredItems = self.items.filter { (item: Conversation) -> Bool in
          return item.title.lowercased().contains(key.lowercased())
      }
      tableView.reloadData()
  }
}

