//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 27.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getImpressions(forPin pin: Pin, page: Int = 1, completionHandler: @escaping FlickrDefaultCompletionHandler) {
        
        let parameters = [FlickrClient.URLParameterKeys.APIKey: FlickrClient.Constants.APIKey,
                          FlickrClient.URLParameterKeys.Method: FlickrClient.URLParameterValues.PhotoSearch,
                          FlickrClient.URLParameterKeys.Media: FlickrClient.URLParameterValues.PhotoSearch,
                          FlickrClient.URLParameterKeys.NoJSONCallback: FlickrClient.URLParameterValues.NoJSONCallback,
                          FlickrClient.URLParameterKeys.Format: FlickrClient.URLParameterValues.JSONFormat,
                          FlickrClient.URLParameterKeys.Extras: FlickrClient.URLParameterValues.URLMediumPhoto,
                          FlickrClient.URLParameterKeys.PerPage: String(Constants.imagesPerGallery),
                          FlickrClient.URLParameterKeys.Page: String(page),
                          FlickrClient.URLParameterKeys.Longitude: String(pin.longitude),
                          FlickrClient.URLParameterKeys.Latitude: String(pin.latitude)]
        
        
        taskForGETAndPOST("", parameters: parameters as ParametersArray) { (results, error) in
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            print("results:")
            print(results!)
            
            guard
                let photosDictionary = results?.value(forKey: "photos") as? JSONDictionary,
                let photosArray = photosDictionary["photo"] as? JSONArray
                else {
                    completionHandler(nil, NSError(domain: "getPhotos", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Results"]))
                    return
            }

//            guard let impressions = pin.impressions else {
//                print("something went really wrong")
//                return
//            }
//
            for (index, item) in photosArray.enumerated() {
                print(index)
                print(item)
                
                guard let imageUrl = item[FlickrClient.URLParameterValues.URLMediumPhoto] as? String else {
                    print ("error")
                    return
                }
                print(imageUrl)
                
                let impression = Impression(url: URL(fileURLWithPath: imageUrl), context: self.stack.context)
                impression.pin = pin
                //pin.impressions!.adding(impression)
                
                print(pin.impressions!.count)
                
                    
                    
                //impressions.adding(<#T##anObject: Any##Any#>)
//                guard let student = StudentInformation(dictionary: item) else {
//                    // print error to console only
//                    print("could not create and append student at index: \(index). Incorrect keys.")
//                    continue
//                }

                //students.append(student)
            }
            
            print("Created Objects")
            print(pin.impressions!.count)
            print(pin.impressions!)
            print(pin)
            
            completionHandler(results, nil)
        }
    }
}
