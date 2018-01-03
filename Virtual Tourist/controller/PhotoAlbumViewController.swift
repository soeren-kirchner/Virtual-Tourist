//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 01.01.18.
//  Copyright © 2018 Sören Kirchner. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "PhotoAlbumCollectionViewCell"

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        //cell.memeImageView.image = appDelegate!.memes[indexPath.row].memedImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
}
