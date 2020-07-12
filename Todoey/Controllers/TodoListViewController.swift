//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © Patrick Huang. All rights reserved.
//


import UIKit
import RealmSwift
import ChameleonFramework

//learn: how to throw fatal error:
// guard let a = b.c else {fatalError("Error does occurred.")}

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var itemArray : Results<Item>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.rowHeight = 70.0
        
        searchBar.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color{
            
            //title here refer to the title of navigation bar
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else{fatalError("Navigation controller does not exist.")}
            
            if let navbarColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = navbarColor
                
                navBar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
                
                searchBar.barTintColor = navbarColor
                self.view.backgroundColor = navbarColor

                //self.title = "This is multiline"+"\n"+" title for navigation bar"
//                navBar.largeTitleTextAttributes = [
//                    NSAttributedString.Key.foregroundColor: ContrastColorOf(navbarColor, returnFlat: true),
//                    NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .largeTitle)
 //                                               ]

                //navBar.titleTextAttributes
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navbarColor, returnFlat: true)]
                
                
//                for navItem in(navBar.subviews) {
//                     for itemSubView in navItem.subviews {
//                         if let largeLabel = itemSubView as? UILabel {
//                             largeLabel.text = self.title
//                             largeLabel.numberOfLines = 0
//                             largeLabel.lineBreakMode = .byWordWrapping
//                            largeLabel.minimumScaleFactor = 0.4
//                         }
//                     }
//                }
                
            }
            
           
            
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }


    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray!.count)){
                cell.backgroundColor = color
                
                let textColor = ContrastColorOf(color, returnFlat: true)
                cell.textLabel?.textColor = textColor
                cell.tintColor = textColor
            }

            
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Item Added"
            cell.accessoryType = .none
        }
    
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        
        //click on one cell, it will turn grey and then come back
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        let delete_action = UIAlertAction(title: "Cancel", style: .default) { (_) in}
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(delete_action)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func loadItems(){
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }

    override func updateModel(_ indexPath:IndexPath) {
        if let itemForDeletion = itemArray?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error deleting items \(error)")
            }
        }
    }
    
}


//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate{
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(request)
//    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count==0){
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }else{
            itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
    
}

