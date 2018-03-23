//
//  ViewController.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 08/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()

    var items: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //reload the item list from the database
        loadItems()
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let hexColor = selectedCategory?.color else {fatalError()}
        navBarSetup(withColor: hexColor)
        searchBar.barTintColor = UIColor(hexString: hexColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navBarSetup(withColor: "1D98F6")
    }
    
    //MARK - Nav Bar Setup Methods
    func navBarSetup(withColor colorHex: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        guard let color = UIColor(hexString: colorHex) else {fatalError()}
        navBar.barTintColor = color
        navBar.prefersLargeTitles = true
        navBar.tintColor = ContrastColorOf(color, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor :
            ContrastColorOf(color, returnFlat: true)]
    }

    //MARK - TableView DataSource and Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            let categoryColor = UIColor(hexString: (selectedCategory?.color)!)
            if let bgColor = categoryColor?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
                cell.backgroundColor = bgColor
                cell.textLabel?.textColor = ContrastColorOf(bgColor, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items found yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error while saving done status, \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK - Delete Data from Swipe
    override func updateDataModel(at indexPath: IndexPath) {
        super.updateDataModel(at: indexPath)
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
    //MARK - Data Manipulation Methods
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = localTextField.text!
                        item.creationDate = Date()
                        currentCategory.items.append(item)
                    }
                } catch {
                    print("Error saving new item to persistent container, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK - Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "creationDate", ascending: true)
        tableView.reloadData()
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

