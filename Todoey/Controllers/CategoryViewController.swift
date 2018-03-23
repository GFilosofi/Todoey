//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 15/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
   }

    //MARK - TableView DataSource and Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1    //here we use the nil coalescing operator a??b
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Categories found yet"
        if let bgColor = UIColor(hexString: (category?.color)!) {
            cell.backgroundColor = bgColor
            cell.textLabel?.textColor = ContrastColorOf(bgColor, returnFlat: true)
        } else {
            cell.backgroundColor = UIColor(hexString: "1164B2")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK - Manage Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? TodoListViewController {
                    destinationVC.selectedCategory = categories?[indexPath.row]
                }
            }
        }
    }
    
    //MARK - Data Manipulation Methods
    func loadCategories() {
        categories = realm.objects(Category.self)
    }
    
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error in saving data, \(error)")
        }
    }
    
    //MARK - Delete Data From Swipe
    override func updateDataModel(at indexPath: IndexPath) {
        super.updateDataModel(at: indexPath)
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    for item in category.items {
                        self.realm.delete(item)
                    }
                    self.realm.delete(category)
                }
            } catch {
                print("Error in deleting category, \(error)")
            }
        }
    }
    
    //MARK - Add New Categories
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        var localTextField = UITextField()

        alert.addTextField { (field) in
            field.placeholder = "Create new category"
            field.textAlignment = .center
            localTextField = field
        }
        
        let alertAction = UIAlertAction(title: "Add Category", style: UIAlertActionStyle.default) { (action) -> Void in
            let category = Category()
            category.name = localTextField.text!
            category.color = UIColor.randomFlat.hexValue()
            self.saveCategory(category: category)
            self.tableView.reloadData()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK - SwipeCellKit methods
//extension CategoryViewController: SwipeTableViewCellDelegate {
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else {return nil}
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            //app dependent code follows:
//            if let category = self.categoryArray?[indexPath.row] {
//                do {
//                    try self.realm.write {
//                        for item in category.items {
//                            self.realm.delete(item)
//                        }
//                        self.realm.delete(category)
//                    }
//                } catch {
//                    print("Error in deleting category, \(error)")
//                }
//            }
//        }
//        deleteAction.image = UIImage(named: "trash-icon")
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
//        var options = SwipeTableOptions()
//        options.expansionStyle = SwipeExpansionStyle.destructive
//        //options.transitionStyle = .border
//        return options
//    }
//}

