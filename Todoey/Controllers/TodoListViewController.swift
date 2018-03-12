//
//  ViewController.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 08/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

//    var itemArray = [String]()
    var itemArray = [Item]()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
        let item1 = Item()
        item1.title = "asdlksjdlksa"
        item1.done = true
        itemArray.append(item1)

        let item2 = Item()
        item2.title = "asdsa"
        item2.done = false
        itemArray.append(item2)
    }
    
    //MARK - Table View Data Source methods
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
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var localTextField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        alert.addTextField(configurationHandler: { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            alertTextField.textAlignment = .center
            localTextField = alertTextField
        })
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let item = Item()
            //item.title = alert.textFields![0].text!
            item.title = localTextField.text!
            item.done = false
            self.itemArray.append(item)
            self.tableView.reloadData()
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

