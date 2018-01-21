//
//  PhotoAlbumCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 01.01.18.
//  Copyright © 2018 Sören Kirchner. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool{
        didSet{
            // TODO: ternary operator
//            if self.isSelected {
//                imageView.alpha = 0.5
//            }
//            else {
//                imageView.alpha = 1
//            }
            imageView.alpha = isSelected ? 0.5 : 1
        }
    }
    
}
