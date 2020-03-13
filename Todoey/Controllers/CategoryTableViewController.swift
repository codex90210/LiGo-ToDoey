//
//  CategoryTableViewController.swift
//  LiGo
//
//  Created by David Mompoint on 1/08/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?
    let randomColors = Category()
    let categoryFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
         guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        navBar.backgroundColor = UIColor(hexString: "4C9EDB")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            guard let contrastColorCat = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = contrastColorCat
            cell.textLabel?.textColor = ContrastColorOf(contrastColorCat, returnFlat: true)
        }
        return cell
    }
    
// MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            //tableView.reloadData()
        }
    }
    
    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if  let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

     //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryText = UITextField()
        categoryText.text = ""
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            
            if categoryText.text == "" {
                let okAlert = UIAlertController(title: "Can't Add an Empty List", message: "", preferredStyle: .alert)
                let okCancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                okAlert.addAction(okCancel)
                
                self.present(okAlert, animated: true, completion: nil)
            } else {
                    let newCategory = Category()
                    newCategory.name = categoryText.text!
                    newCategory.color = UIColor.randomFlat().hexValue()
                    
                    self.save(category: newCategory)
                }
            }
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create New Category"
            categoryText = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

