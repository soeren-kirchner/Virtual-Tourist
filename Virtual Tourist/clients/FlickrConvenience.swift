//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 27.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getImpressions(forPin pin: Pin, completionHandler: @escaping FlickrDefaultCompletionHandler) {
        
        var parameters = [FlickrClient.URLParameterKeys.APIKey: FlickrClient.Constants.APIKey,
                          FlickrClient.URLParameterKeys.Method: FlickrClient.URLParameterValues.PhotoSearch,
                          FlickrClient.URLParameterKeys.Media: FlickrClient.URLParameterValues.PhotoSearch,
                          FlickrClient.URLParameterKeys.NoJSONCallback: FlickrClient.URLParameterValues.NoJSONCallback,
                          FlickrClient.URLParameterKeys.Format: FlickrClient.URLParameterValues.JSONFormat,
                          FlickrClient.URLParameterKeys.Extras: FlickrClient.URLParameterValues.URLMediumPhoto,
                          FlickrClient.URLParameterKeys.PerPage: String(Constants.imagesPerGallery),
                          FlickrClient.URLParameterKeys.Longitude: String(pin.longitude),
                          FlickrClient.URLParameterKeys.Latitude: String(pin.latitude)]
        
        // get pages count for random page
        taskForGETAndPOST("", parameters: parameters as ParametersArray) { (results, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard
                let photosDictionary = results?.value(forKey: "photos") as? JSONDictionary,
                let pages = photosDictionary["pages"] as? Int
                else {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Results"]))
                    return
            }

            parameters[FlickrClient.URLParameterKeys.Page] = String(self.getRandomPage(maxPage: pages))
            
            // download random page
            self.taskForGETAndPOST("", parameters: parameters as ParametersArray) { (results, error) in
                
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }

                guard
                    let photosDictionary = results?.value(forKey: "photos") as? JSONDictionary,
                    let photosArray = photosDictionary["photo"] as? JSONArray
                    else {
                        completionHandler(nil, NSError(domain: "getPhotos", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Results"]))
                        return
                }
                
                for item in photosArray {

                    guard let imageUrl = item[FlickrClient.URLParameterValues.URLMediumPhoto] as? String else {
                        return
                    }
                    
                    let impression = Impression(url: URL(string: imageUrl)!, context: self.stack.context)
                    impression.pin = pin
                }
             
                completionHandler(results, nil)
            }
        }
    }
    
    
    func downloadImage(fromUrl url: URL, completionHandler: @escaping FlickrDefaultCompletionHandler) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = self.checkForErrors(data: data, response: response, error: error, completionHandler: completionHandler) {
                completionHandler(data as AnyObject, nil)
            }
        }
        task.resume()
    }
    
    func getRandomPage(maxPage: Int) -> Int {
        return Int(arc4random_uniform(UInt32(maxPage))) + 1
    }
    
}
