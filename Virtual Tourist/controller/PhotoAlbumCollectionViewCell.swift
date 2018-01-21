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
            imageView.alpha = isSelected ? 0.5 : 1
        }
    }
    
}
