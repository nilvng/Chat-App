//
//  ComposeMessageDataSource.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/16/21.
//

import UIKit

enum SectionType{
    case contacts
    case options
}

protocol Searchable {
    func getKeyword() -> String
}

struct OtherOptions : Searchable {
    func getKeyword() -> String{
        return title
    }
    
    var title : String
    var image : UIImage?
}

struct Section {
    let letter : String?
    let items : [Searchable]
    var type : SectionType = .contacts
}

class IndexedContactDataSource: NSObject {
    var items: [Friend]! {
        didSet {
            filteredItems = items
        }
    }
    private var filteredItems : [Friend] = []
    var sections = [Section]()
    
    override init() {
        super.init()
        self.sortByAlphabet()
    }
    
    private func setupOtherOption(){
        // options like New contact, Create group chat etc
        var options = [OtherOptions]()
        options.append(OtherOptions(title: "New contact", image: UIImage.new_contact))
        options.append(OtherOptions(title: "New group chat", image: UIImage.new_group_chat))
        sections.append(Section(letter: nil, items: options, type: .options))
    }
    
    func sortByAlphabet(){
        sections = []
        setupOtherOption()
        let groupedDictionary = Dictionary(grouping: filteredItems, by: {String($0.firstName.prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections += keys.map{ Section(letter: $0, items: groupedDictionary[$0]!) }
    }

}
extension IndexedContactDataSource : SearchItemDataSource {
    
    func getItem(at index: IndexPath) -> Friend{
        return sections[index.section].items[index.row] as! Friend
    }
    func setupData(friends: [Friend]){
        self.items = friends
        self.sortByAlphabet()
    }
    func setupData(friendContacts: [FriendContact]){
        self.items = friendContacts.compactMap { Friend(friendContact: $0)}
        self.sortByAlphabet()
    }
    func filterItemBy(key: String){
        guard key != "" else {
            self.clearSearch()
            return
        }
        self.filteredItems = self.items.filter { item in
            return item.fullName.lowercased().contains(key.lowercased())
        }
        
        // update data source
        sortByAlphabet()
    }
    
    func clearSearch(){
        print(filteredItems)
        filteredItems = items
        sortByAlphabet()
    }

}

extension IndexedContactDataSource : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        let indexedList = sections.filter{$0.letter != nil}
        
        return indexedList.map{ $0.letter! }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].letter
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sections.firstIndex(where: {$0.letter == title } )!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first row when user have not searched for any friend : add new contact
        let item = sections[indexPath.section].items[indexPath.row]
        
        // special options for creating new contact, or group chat etc
        if sections[indexPath.section].type != .contacts{
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
            
            let option = item as! OtherOptions
            cell.configure(option: option)
            return cell
        }
        
        // usual contact list sorted by alphabet
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        cell.avatarView.backgroundColor = UIColor.clear
        cell.configure(friend: item as! Friend)
        
        return cell
    }
    
}
