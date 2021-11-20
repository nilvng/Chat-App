//
//  SearchViewController.swift
//  Chat App
//
//  Created by LAP11353 on 20/11/2021.
//

import UIKit

class SearchViewController: UITableViewController{

    let searchField : UITextField = {
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: 340, height: 50))
        tf.placeholder = "Search..."
        return tf
    }()
    
    var items : [Conversation]! {
        didSet{
            print("wy not call me")
            filteredItems = items
        }
    }
    var filteredItems : [Conversation] = []
    var currentSearchText : String = ""

    var isFiltering: Bool {
      return currentSearchText != ""
    }
    
    fileprivate func setupTableView() {
        // Do any additional setup after loading the view.
        
        tableView.register(SearchContactCell.self, forCellReuseIdentifier: SearchContactCell.identifier)
        tableView.separatorStyle  = .none
        tableView.rowHeight = 84
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        items = ChatManager.shared.chatList
        navigationItem.titleView = searchField
        searchField.delegate = self
        
        setupTableView()
    }
    
}

extension SearchViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("search \(cleanText)")
            // only update when it truly changes
            if cleanText != currentSearchText{
                filterItemForSearchKey(cleanText)
            }
        }
        return true
    }
    
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
        
        if key == "" {
            self.filteredItems = items
        } else{
            self.filteredItems = self.items.filter { item in
                return item.title.lowercased().contains(key.lowercased())
            }
        }
        
        tableView.reloadData()
  }
}

extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return filteredItems.count
        }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first row when user have not searched for any friend : add new contact

        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell

        let conv = filteredItems[indexPath.row]
        cell.thumbnail.update(url: conv.thumbnail, text: conv.title)
        cell.titleLabel.text = conv.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selected = self.filteredItems[indexPath.row]
        let msgController = MessagesViewController()
        
        msgController.configure(conversation: selected)
        navigationController?.pushViewController(msgController, animated: true)
    }
}
