//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Fengpeng Huang on 2020-06-12.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
    }
    
    public static var darkModeColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.white
                } else {
                    return UIColor.black
                }
            }
        } else {
            return UIColor.black
        }
    }()
    
    //change the background color of navigation bar
    override func viewWillAppear(_ animated: Bool) {
        guard  let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}

        navBar.backgroundColor = nil
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: CategoryTableViewController.darkModeColor]
        navBar.tintColor = CategoryTableViewController.darkModeColor
    }
    
    
        

    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //nil coalescing operator
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //学习到了继承，这很重要
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row]{
            
            cell.textLabel?.text = "    "+category.name
            
            guard let categoryColor = UIColor(hexString: category.color!) else {
                fatalError("")
            }
            //cell.backgroundColor = categoryColor
            
            //cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            
            let cellImg : UIImageView = UIImageView(frame: CGRect(x: 10, y: 24, width: 12, height: 12))
            cellImg.image = UIImage(named: "blank-square-png-2")
            cellImg.layer.cornerRadius = 6
            cellImg.layer.masksToBounds = true
            cellImg.backgroundColor = categoryColor
            cell.addSubview(cellImg)

        }
        
    
        return cell
    }
    
    
    
    //MARK: - Data Manipulation Methods
    func saveCategory(_ category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error when saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategory(){
        
        categoryArray = realm.objects(Category.self).sorted(byKeyPath: "date", ascending: false)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(_ indexPath: IndexPath){
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        var myText = UITextField()
        
        let alert = UIAlertController(title: "Add Todo Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let category = Category()
            
            category.name = myText.text!
            
            category.color = UIColor.randomFlat().hexValue()
            
            category.date = Date()
            
            self.saveCategory(category)
        }
                
        
        let delete_action = UIAlertAction(title: "Cancel", style: .default) { (_) in}
        
        alert.addTextField { (alartTextField) in
            alartTextField.placeholder = "Create New Category"
            myText = alartTextField
        }
        
        alert.addAction(delete_action)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        //血的教训：这个必须要在preformsegue之后！！！
        //click on one cell, it will turn grey and then come back
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVc = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVc.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    

}

