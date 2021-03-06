//
//  AddToCartVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/19/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

class AddToCartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var viewCartButton: UIButton!
    @IBOutlet weak var cartSubtotal: UILabel!
    @IBOutlet weak var viewCartButtonView: UIView!
    @IBOutlet weak var viewCartView: UIView!
    @IBOutlet weak var viewCartViewToBottom: NSLayoutConstraint!

    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    let realm = try! Realm() // Initialize Realm
    
    var cart = Order()
    var sides = List<Side>()
    var sideCategories = [String]()
    var extras = List<Side>()
    var sectionTitles = [String]()
    
    // Passed from MenuCategoryVC
    var menuItem = MenuItem()
    var menuItemID = ""
    var restaurantID = ""
    
    // Passed from Checkout
    var passedMenuItemID = ""
    var comingFromCheckout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Realm
        setupRealm()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
        
        // Calculate initial item price
        calculateSubtotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRealm() {
        
        // Get selected restaurant and menu categories
        if comingFromCheckout {
            
            let predicate = NSPredicate(format: "isInCart = %@ AND id = %@", NSNumber(booleanLiteral: true), passedMenuItemID)
            menuItem = realm.objects(MenuItem.self).filter(predicate).first!
        } else {
            
            let predicate = NSPredicate(format: "id = %@", menuItemID)
            menuItem = realm.objects(MenuItem.self).filter(predicate).first!
        }
        
        // Section "Details" (Always)
        
        // Section "Sides" (Sometimes)
        if menuItem.sides.count > 0 {
            sides = menuItem.sides
            print("SIDES FOR \(menuItem.name)")
            print(menuItem.sides)
            setupSides()
        }
        
        // Section "Extras" (Sometimes)
        if menuItem.extras.count > 0 {
            extras = menuItem.extras
            print("EXTRAS FOR \(menuItem.name):")
            print(menuItem.extras)
        }
        
        // Section "Special Instructions" (Always)
        
        // Section "Quantity" (Always)
        
        
    }
    
    /* Populate sideCategories array with menuItem's categories (must be unique) */
    func setupSides() {
        
        // Loop through sides and parse out the different side categories
        for side in sides {
            if !sideCategories.contains(side.sideCategory) {
                sideCategories.append(side.sideCategory)
            }
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        self.title = menuItem.name
        
        viewCartButtonView.layer.cornerRadius = Constants.cornerRadius
        viewCartView.layer.shadowColor = Constants.lightGray.cgColor
        viewCartView.layer.shadowOpacity = 1
        viewCartView.layer.shadowRadius = Constants.shadowRadius
        viewCartView.layer.shadowOffset = CGSize.zero
        
        checkButtonStatus()
    }
    
    /* Customize tableView attributes and populate sectionTitles array with headers */
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 150
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
        // Set up tableview headers
        sectionTitles.append("Description")
        if sideCategories.count > 0 {
            for sideCategory in sideCategories {
                // let numAllowed =
                sectionTitles.append(sideCategory)// + "Pick \(numAllowed)"
            }
        }
        if extras.count > 0 {
            sectionTitles.append("Extras")
        }
        sectionTitles.append("Special Instructions")
        sectionTitles.append("Quantity")
        
    }
    
    /* Iterate over selected extras and add to item price, then calculate subtotal by multiplying by quantity */
    func calculateSubtotal() -> Double {
        
        // Calculate total price of menu item and selected sides
        var totalForSingleItem = menuItem.price
        for extra in menuItem.extras {
            if extra.isSelected {
                totalForSingleItem += extra.price
            }
        }
        
        // Multiply by quantity
        let subtotal = totalForSingleItem * Double(menuItem.quantity)
        cartSubtotal.text = "$" + String(format: "%.2f", subtotal)
        
        return subtotal
    }
    
    func checkButtonStatus() {
        
        var numSelected = 0
        for side in sides {
            if side.isSelected {
                numSelected += 1
            }
        }
        
        if numSelected < menuItem.numRequiredSides {
            
            viewCartButton.isEnabled = false
            viewCartButtonView.backgroundColor = Constants.red
            viewCartButton.setTitle("Please select all required sides.", for: .normal)
        } else {
            
            viewCartButton.isEnabled = true
            viewCartButtonView.backgroundColor = Constants.green
           
            if comingFromCheckout {
                viewCartButton.setTitle("Update Item", for: .normal)
            }else {
                viewCartButton.setTitle("Add to Cart", for: .normal)
            }
        }
    }
    
    /* Create shallow Realm copies to differentiate between the normal menu item and the item in the cart (necessary for future Realm queries), then add those copies to the order (if one exists, else create new order as well) */
    func addToCart() {
        
        // STEP 1: Create Realm copies for the cart
        
        let newMenuItem = MenuItem()
        newMenuItem.id = menuItem.id
        newMenuItem.name = menuItem.name
        newMenuItem.details = menuItem.details
        newMenuItem.price = menuItem.price
        newMenuItem.groupings = menuItem.groupings
        newMenuItem.numRequiredSides = menuItem.numRequiredSides
        newMenuItem.quantity = menuItem.quantity
        newMenuItem.totalCost = calculateSubtotal()
        newMenuItem.isInCart = true
        
        // Retrieve special instructions if available
        let indexPath = IndexPath(row: 0, section: sectionTitles.count - 2)
        let cell = myTableView.cellForRow(at: indexPath) as! SpecialInstructionsTableViewCell!
        if cell != nil && cell?.specialInstructions.text != nil {
            newMenuItem.specialInstructions = (cell?.specialInstructions.text!)!
        } else {
            newMenuItem.specialInstructions = ""
        }

        for side in sides {
            
            
            let newSide = Side()
            newSide.id = side.id
            newSide.name = side.name
            newSide.isRequired = side.isRequired
            newSide.sideCategory = side.sideCategory
            newSide.price = side.price
            newSide.isSelected = side.isSelected
            newSide.isInCart = true
            
            newMenuItem.sides.append(newSide)
            
        }
        
        for extra in menuItem.extras {
                
            let newExtra = Side()
            newExtra.id = extra.id
            newExtra.name = extra.name
            newExtra.isRequired = extra.isRequired
            newExtra.sideCategory = extra.sideCategory
            newExtra.price = extra.price
            newExtra.isSelected = extra.isSelected
            newExtra.isInCart = true
            
            newMenuItem.sides.append(newExtra)
            
        }
        
        // Save new menu item as new object in Realm
        try! realm.write {
            realm.add(newMenuItem)
        }
        
        // STEP 2: Add copies to order
        
        // Check if an order already exists
        let predicate = NSPredicate(format: "restaurantID = %@ && isComplete = %@", restaurantID, NSNumber(booleanLiteral: false))
        let filteredOrders = realm.objects(Order.self).filter(predicate)
        
        try! realm.write {
            if filteredOrders.count > 0 {
                
                // Cart already exists
                print("Cart already exists. Adding new menu item.")
                
                let order = filteredOrders.first!
                order.menuItems.append(newMenuItem)
                order.subtotal += newMenuItem.totalCost
                
            } else {
                
                // Cart doesn't exist yet
                print("Cart does not exist. Creating new one.")
                
                let deliveryFee = realm.object(ofType: Restaurant.self, forPrimaryKey: restaurantID)?.deliveryFee
                
                let order = Order()
                order.restaurantID = restaurantID
                order.menuItems.append(newMenuItem)
                order.subtotal += newMenuItem.totalCost
                order.deliveryFee = deliveryFee!
                order.isComplete = false
                
                realm.add(order)
            }
        }
    }
    
    
    /* Delete all updated values in original MenuItem and Sides objects so it looks untouched */
    func cleanUpRealm() {
        
        try! realm.write {
            
            menuItem.specialInstructions = ""
            menuItem.quantity = 1
            
            for side in sides {
                side.isSelected = false
            }
            
            for extra in menuItem.extras {
                extra.isSelected = false
            }
        }
    }
    
    @IBAction func addToCartButtonTapped(_ sender: UIButton) {
        
        if !comingFromCheckout {
            addToCart()
            cleanUpRealm()
        } else {
            
            try! realm.write {
//                menuItem.quantity = 
                
                // Retrieve special instructions if available
                let indexPath = IndexPath(row: 0, section: sectionTitles.count - 2)
                let cell = myTableView.cellForRow(at: indexPath) as! SpecialInstructionsTableViewCell!
                if cell != nil && cell?.specialInstructions.text != nil {
                    menuItem.specialInstructions = (cell?.specialInstructions.text!)!
                } else {
                    menuItem.specialInstructions = ""
                }
                
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionTitles[section] == "Description" {
            return 1
        } else if sectionTitles[section] == "Extras" {
            return extras.count
        } else if sectionTitles[section] == "Special Instructions" {
            return 1
        } else if sectionTitles[section] == "Quantity" {
            return 1
        } else {
            let predicate = NSPredicate(format: "sideCategory = %@", sectionTitles[section])
            return sides.filter(predicate).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if sectionTitles[indexPath.section] == "Description" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            
            if menuItem.details == "" {
                cell.textLabel?.text = "No description but we promise it's good:)"
            } else {
                cell.textLabel?.text = menuItem.details
            }
            
            return cell
            
        } else if sectionTitles[indexPath.section] == "Extras" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "extrasCell", for: indexPath)
            
            cell.textLabel?.text = menuItem.extras[indexPath.row].name
            let price = Double(menuItem.extras[indexPath.row].price)
            print(price)
            if price != 0.0 {
                cell.detailTextLabel?.text = "+$" + String(format: "%.2f", price)
            } else {
                cell.detailTextLabel?.text = "Free"
            }
            
            // Change checkmark color
            cell.tintColor = Constants.green
            
            // Show checkmark if cell is selected
            if menuItem.extras[indexPath.row].isSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell

        } else if sectionTitles[indexPath.section] == "Special Instructions" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "specialInstructionsCell", for: indexPath) as! SpecialInstructionsTableViewCell
            
            if comingFromCheckout {
                cell.specialInstructions.text = menuItem.specialInstructions
            }
            
            return cell

        } else if sectionTitles[indexPath.section] == "Quantity" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "quantityCell", for: indexPath) as! QuantityTableViewCell
            
            cell.value.text = String(menuItem.quantity)
            cell.delegate = self
            
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sidesCell", for: indexPath)
            
            let predicate = NSPredicate(format: "sideCategory = %@", sectionTitles[indexPath.section])
            let filteredSide = sides.filter(predicate)[indexPath.row]
            
            cell.textLabel?.text = filteredSide.name
            
            // Change checkmark color
            cell.tintColor = Constants.green
            
            // Show checkmark if cell is selected
            if filteredSide.isSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sectionTitles[section] != "Description" && sectionTitles[section] != "Special Instructions" && sectionTitles[section] != "Quantity" && sectionTitles[section] != "Extras" {
            
            if sectionTitles[section] != "Sides" {
                return sectionTitles[section] + " (Pick 1)"
            } else {
                
                // Calculate number of sides that can be selected in "Sides" section
                let numToPick = menuItem.numRequiredSides - sideCategories.count + 1
                return sectionTitles[section] + " (Pick \(numToPick))"
            }
        } else {
            return sectionTitles[section]
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = UIColor.white
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    /* Calculate what to do about cell selection based on section and the max number allowed to be selected */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if sectionTitles[indexPath.section] != "Description" && sectionTitles[indexPath.section] != "Special Instructions" && sectionTitles[indexPath.section] != "Quantity" {
            
            if sectionTitles[indexPath.section] == "Extras" {
                
                for i in 0..<menuItem.extras.count {
                    if i == indexPath.row && menuItem.extras[i].isSelected {
                        try! self.realm.write() {
                            
                            menuItem.extras[i].isSelected = false
                            print("Deselected \(menuItem.extras[i])")
                        }
                    } else if i == indexPath.row && !menuItem.extras[i].isSelected {
                        try! self.realm.write() {
                            menuItem.extras[i].isSelected = true
                            print("Selected \(menuItem.extras[i])")
                        }
                    }
                }
                
                calculateSubtotal()
                
            } else if !sectionTitles[indexPath.section].contains("Sides") {
                print("Selecting row in \(sectionTitles[indexPath.section]) (NOT in sides)")
                
                let predicate = NSPredicate(format: "sideCategory = %@", sectionTitles[indexPath.section])
                let filteredSides = sides.filter(predicate)
                
                for i in 0..<filteredSides.count {
                    if i == indexPath.row {
                        try! self.realm.write() {
                            
                            filteredSides[i].isSelected = true
                            print("Selected \(filteredSides[i])")
                        }
                    } else {
                        try! self.realm.write() {
                            filteredSides[i].isSelected = false
                            print("Deselected \(filteredSides[i])")
                        }
                    }
                }
  
            } else {
                
                print("Selecting row in \(sectionTitles[indexPath.section])")
                
                let predicate = NSPredicate(format: "sideCategory = %@", sectionTitles[indexPath.section])
                let filteredSides = sides.filter(predicate)
                
                let numToPick = menuItem.numRequiredSides - sideCategories.count + 1
                var numSelected = 0
                
                for filteredSide in filteredSides {
                    if filteredSide.isSelected {
                        numSelected += 1
                    }
                }
                
                print("numToPick: \(numToPick)")
                print("numSelected: \(numSelected)")
                
                for i in 0..<filteredSides.count {
                    // If selected row is already selected, deselect it
                    if i == indexPath.row && filteredSides[i].isSelected {
                        try! self.realm.write() {
                            filteredSides[i].isSelected = false
                            print("Deselected \(filteredSides[i])")
                        }
                    }
                    // Else if allowed to select row, select it
                    else if numToPick > numSelected && i == indexPath.row {
                        try! self.realm.write() {
                            
                            filteredSides[i].isSelected = true
                            print("Selected \(filteredSides[i])")
                        }
                    }
                }
            }
            
        }
        
        checkButtonStatus()
        
        myTableView.deselectRow(at: indexPath, animated: true)
        myTableView.reloadData()
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        if !comingFromCheckout {
            cleanUpRealm()
        }
        
        self.dismiss(animated: true, completion: nil)
    }

}

extension AddToCartVC: QuantityCellDelegate {
    
    func minusButtonTapped(cell: QuantityTableViewCell) {
        var value = menuItem.quantity
        if value > 1 {
            value -= 1
            try! realm.write {
                menuItem.quantity = value
            }
            calculateSubtotal()
            cell.value.text = String(describing: value)
        }
    }
    
    func plusButtonTapped(cell: QuantityTableViewCell) {
        var value = menuItem.quantity
        value += 1
        try! realm.write {
            menuItem.quantity = value
        }
        calculateSubtotal()
        cell.value.text = String(describing: value)
    }
}
