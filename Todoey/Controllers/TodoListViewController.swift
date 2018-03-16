//
//  ViewController.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 08/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()

    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    lazy var viewContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        //reload the item list from the database
        loadItems()
    }
    
    //MARK - TableView DataSource and Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //itemArray[indexPath.row].setValue("Completed", forKey: "title")
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewContext.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveItems()
            tableView.reloadData()
        }
    }

    //MARK - Data Manipulation Methods
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        //we have to join two predicates
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try viewContext.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    func saveItems() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context to persistent container, \(error)")
        }
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var localTextField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { (field) in
            field.placeholder = "Create new item"
            field.textAlignment = .center
            localTextField = field
        })
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let item = Item(context: self.viewContext)
            item.title = localTextField.text!
            item.done = false
            item.parentCategory = self.selectedCategory
            
            self.itemArray.append(item)
            self.tableView.reloadData()
            self.saveItems()
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK - Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let fetchSearchedItems: NSFetchRequest<Item> = Item.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchSearchedItems.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        loadItems(with: fetchSearchedItems, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //when user clicks cross button all items are reloaded in the table view
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
