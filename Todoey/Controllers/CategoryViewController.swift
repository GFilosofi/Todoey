//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 15/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    var realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        // Get our Realm file's parent directory (only for development)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
   }

    //MARK - TableView DataSource and Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1    //here we use the nil coalescing operator a??b
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories found yet"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let category = categoryArray?[indexPath.row] {
                do {
                    try realm.write {
                        for item in category.items {
                            realm.delete(item)  //remove all child items
                        }
                        realm.delete(category)
                        tableView.reloadData()
                    }
                } catch {
                    print("Error in Deleting category, \(error)")
                }
            }
        }
    }
        
    //MARK - Manage Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? TodoListViewController {
                    destinationVC.selectedCategory = categoryArray?[indexPath.row]
                }
            }
        }
    }
    
    //MARK - Data Manipulation Methods
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
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
    
    func deleteCategory () {
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
            self.saveCategory(category: category)
            self.tableView.reloadData()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}
