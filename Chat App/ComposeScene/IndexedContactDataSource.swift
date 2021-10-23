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
    var items : [Friend] = Friend.stubList
    var sections = [Section]()
    
    override init() {
        super.init()
        setupOtherOption()
        self.sortByAlphabet()
    }
    
    private func setupOtherOption(){
        // options like New contact, Create group chat etc
        var options = [OtherOptions]()
        options.append(OtherOptions(title: "New contact", image: UIImage.new_contact))
        options.append(OtherOptions(title: "New group chat", image: UIImage.new_group_chat))
        sections.append(Section(letter: nil, items: options, type: .options))
    }
}
extension IndexedContactDataSource : SearchItemDataSource {
    
    func getItem(at index: IndexPath) -> Friend{
        return sections[index.section].items[index.row] as! Friend
    }
}

extension IndexedContactDataSource : UITableViewDataSource{
    
    func sortByAlphabet(){
        let groupedDictionary = Dictionary(grouping: items, by: {String($0.firstName.prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections += keys.map{ Section(letter: $0, items: groupedDictionary[$0]!) }
    }
    
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
            cell.titleLabel.text = item.getKeyword()
            cell.thumbnail.backgroundColor = UIColor.babyBlue
            cell.thumbnail.image = option.image?.resizedImage(size: CGSize(width: 33, height: 33))
            cell.thumbnail.contentMode = .center
            return cell
        }
        
        // usual contact list sorted by alphabet
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        cell.configure(friend: item as! Friend)
        
        return cell
    }
    
}
