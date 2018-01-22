//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Sören Kirchner on 26.12.17.
//  Copyright © 2017 Sören Kirchner. All rights reserved.
//

import Foundation

typealias FlickrDefaultCompletionHandler = (_ result: AnyObject?, _ error: NSError?) -> Void

class FlickrClient: NSObject {
    
    // MARK: shared Instance (Singleton)
    
    private override init() {}
    static let shared = FlickrClient()
    
    // MARK: - Properties
    
    var session = URLSession.shared
    let stack = CoreDataStack.shared
    
    func taskForGETAndPOST(_ method: String, httpMethod: String = "GET", parameters: ParametersArray? = nil, jsonBody: String? = nil, completionHandler: @escaping FlickrDefaultCompletionHandler) {
        
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters, withPathExtension: method))
        
        request.httpMethod = httpMethod
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let data = self.checkForErrors(data: data, response: response, error: error, completionHandler: completionHandler) {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
            }
        }
        task.resume()
    }
    
    // MARK: helpers
    
    func checkForErrors(data: Data?, response: URLResponse?, error: Error?, domainForError: String = #function, completionHandler: FlickrDefaultCompletionHandler) -> Data? {
        guard (error == nil) else {
            self.sendError("There was an error with your request: \(error!)", domain: domainForError, code: 11, completionHandler: completionHandler)
            return nil
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            self.sendError("Your request returned a status code other than 2xx!", domain: domainForError, code: 12, completionHandler: completionHandler)
            return nil
        }
        
        guard let data = data else {
            self.sendError("No data was returned by the request!", domain: domainForError, code: 13, completionHandler: completionHandler)
            return nil
        }
        return data
    }
    
    func sendError(_ error: String, domain: String = #function, code: Int = 1, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        print("ERROR: \(error)")
        print("IN DOMAIN: \(domain)")
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandler(nil, NSError(domain: domain, code: code, userInfo: userInfo))
    }
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    private func flickrURLFromParameters(_ parameters: ParametersArray?, withPathExtension pathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath + (pathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        print(components.url!)
        return components.url!
    }
    
}
