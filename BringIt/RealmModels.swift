//
//  RealmModels.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation
import RealmSwift

// User Model
class User: Object {
    dynamic var isCurrent = false
    dynamic var id = ""
    dynamic var fullName = ""
    dynamic var email = ""
    dynamic var password = "" // KEEP THIS???
    dynamic var phoneNumber = ""
    let addresses = List<Address>()
    dynamic var isFirstOrder = false
    let pastOrders = List<Order>()
    dynamic var paymentMethod = ""
    
    // TO-DO: Add more demographic data here if necessary
}

// Address Model
class Address: Object {
    dynamic var user: User?
    dynamic var campus = ""
    dynamic var streetAddress = ""
    dynamic var roomNumber = ""
    dynamic var isCurrent = false
}


// Restaurant Model
class Restaurant: Object {
    dynamic var id = ""
    dynamic var image: NSData?
    dynamic var name = ""
    dynamic var cuisineType = ""
    dynamic var restaurantHours = "" // TO-DO: Maybe change the formatting? Here or in a method
    dynamic var deliveryFee = "" // TO-DO: Should this be a string or a Double?
    let promotions = List<Promotion>()
    let mostPopularDishes = List<MenuItem>()
    let menuCategories = List<MenuCategory>()
}

// Menu Category Model
class MenuCategory: Object {
    dynamic var restaurant: Restaurant?
    dynamic var id = ""
    dynamic var name = ""
    let menuItems = List<MenuItem>()
}

// Menu Item Model
class MenuItem: Object {
    dynamic var id = ""
    dynamic var menuCategory: MenuCategory?
    dynamic var image: NSData?
    dynamic var name = ""
    dynamic var details = ""
    dynamic var price = "" // TO-DO: Should this be a string or a Double?
    dynamic var groupings = 0
    dynamic var numRequiredSides = 0
    let sides = List<Side>()
    let extras = List<Side>()
    
    // For Cart items only
    dynamic var specialInstructions = ""
    dynamic var quantity = 1
    
    // TO-DO: Add a method to calculate and return total price??
}

// Side Model
class Side: Object {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var isRequired = false
    dynamic var sideCategory = ""
    dynamic var price = "" // TO-DO: Should this be a string or a Double?
    dynamic var isSelected = false
}

// Promotions Model
class Promotion: Object {
    dynamic var restaurant: Restaurant?
    dynamic var image: NSData?
    dynamic var title = ""
    dynamic var details = ""
    
    // TO-DO: Will need to add some sort of linking capability to go to the right VC upon tap
}

// Order Model
class Order: Object {
    dynamic var id = ""
    dynamic var restaurant: Restaurant? // TO-DO: Should I have this or just restaurantID?
    dynamic var orderTime: NSDate?
    dynamic var address: Address?
    dynamic var paymentMethod = ""
    let menuItems = List<MenuItem>()
    dynamic var subtotal = "" // TO-DO: Should this be a string or a Double?
    dynamic var isComplete = false
}


