//
//  FeaturedDishCollectionViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/23/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class FeaturedDishCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dishImage: UIImageView!
    @IBOutlet weak var dishName: UITextView!
//    @IBOutlet weak var dishDescription: UILabel!
    @IBOutlet weak var dishPrice: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.cornerRadius = Constants.cornerRadius
        dishImage.clipsToBounds = true
        dishImage.layer.cornerRadius = Constants.cornerRadius
        dishImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
}
