//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 15/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    lazy var viewContext: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
   }

    //MARK - TableView DataSource and Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath.row)")
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //MARK - Data Manipulation Methods
    func loadCategories (with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try viewContext.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    func saveCategories() {
        do {
            try self.viewContext.save()
        } catch {
            print("Error in saving context, \(error)")
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
            let category = Category(context: self.viewContext)
            category.setValue(localTextField.text, forKey: "name")
            
            self.saveCategories()
            self.categoryArray.append(category)
            self.tableView.reloadData()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}
