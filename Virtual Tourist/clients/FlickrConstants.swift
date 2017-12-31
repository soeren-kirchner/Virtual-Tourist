//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 26.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        static let APIKey = "25c44890414aaf5d99cfb193ea237396"
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
        static let imagesPerGallery = 18
    }
    
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    struct URLParameterKeys {
        static let Accuracy = "accuracy"
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let Format = "format"
        static let Extras = "extras"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Media = "media"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    struct URLParameterValues {
        static let JSONFormat = "json"
        static let NoJSONCallback = "1"
        static let URLMediumPhoto = "url_m"
        static let PhotoSearch = "flickr.photos.search"
        static let MediaPhotos = "photos"

    }
    
}
