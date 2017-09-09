//
//  API.swift
//  ESEOmega
//
//  Created by Tomn on 09/09/2017.
//  Copyright © 2017 Tomn. All rights reserved.
//

import UIKit

/// Describes *any* JSON message from API
protocol APIResult: Decodable {
    
    /// Whether API request was valid
    var success: Bool { get }
    
}


/// Tools to contact the server
class API {
    
    /// Common URL for all API requests
    static private let url     = "https://api.bdeeseo.fr/"
    static private let version = "1"
    
    
    /// Available API endpoints
    enum Path: String {
        
        /// Connect user
        case userLogin    = "me/login"
        
        /// List of IngeNews editions
        case ingenews     = "ingenews"
        
        /// List of rooms
        case rooms        = "rooms"
        
        /// Information about a family
        case family       = "family"
        
        /// Search a student name for their family
        case familySearch = "family/search"
        
        /// MessagesExtension, list of stickers
        case stickers     = "stickers"
        
    }
    
    
    /// Describes a JSON error message from API
    struct ErrorResult: APIResult, Decodable {
        
        /// Whether API request was valid
        let success: Bool
        
        /// Failure info if request was not valid
        let error: Error?
        
        /// Inner error info
        struct Error: Decodable {
            
            /// Type of error
            let uid: Int?
            
            /// Detailed message
            let devMessage: String?
            
            /// Message to be displayed
            let userMessage: String?
            
        }
        
    }
    
    typealias APIError = (message: String, code: Int?)
    
    
    /// Contacts the API
    ///
    /// - Parameters:
    ///   - apiPath: Requested component
    ///   - getParameters:  List of GET  parameters that will get encoded and packed
    ///   - postParameters: List of POST parameters that will get encoded and packed
    ///   - completed: Called when request got data and no error
    ///   - failure: Called when request failed, no data or error
    ///   - noCache: Ignore local cache when making the request
    static func request(_ apiPath: API.Path,
                        get  getParameters:  [String : String] = [:],
                        post postParameters: [String : String] = [:],
                        completed: @escaping (Foundation.Data) -> (),
                        failure: ((Error?, Foundation.Data?) -> ())? = nil,
                        noCache: Bool = false) {
        
        let cachePolicy: NSURLRequest.CachePolicy = noCache ? .reloadIgnoringLocalCacheData
                                                            : .useProtocolCachePolicy
        
        /* URL + GET */
        var urlComponents = URLComponents(string: url + apiPath.rawValue)!
        urlComponents.queryItems = getParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        var request = URLRequest(url: urlComponents.url ?? URL(string: url + apiPath.rawValue)!,
                                 cachePolicy: cachePolicy,
                                 timeoutInterval: 60)
        request.setValue(key,     forHTTPHeaderField: "API-key")
        request.setValue(version, forHTTPHeaderField: "API-version")
        
        /* POST */
        if !postParameters.isEmpty {
            request.httpMethod       = "POST"
            urlComponents.queryItems = postParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            let postString           = urlComponents.query ?? ""
            request.httpBody         = postString.data(using: .utf8)
        }
        
        /* Configure completion */
        let defaultSession = URLSession(configuration: .default,
                                        delegate: nil,
                                        delegateQueue: nil)  // create new queue
        let dataTask = defaultSession.dataTask(with: request) { data, _, error in
            
            Utils.requiresActivityIndicator(false)
            
            guard let d = data, error == nil else {
                failure?(error, data)
                return
            }
            
            completed(d)
        }
        
        /* Fire! */
        Utils.requiresActivityIndicator(true)
        dataTask.resume()
    }
    
    
    /// Tries to analyse bad API response data to at least get an error message.
    ///
    /// - Parameters:
    ///   - data: API response data
    static func handleFailure(data: Foundation.Data) -> APIError {
        
        guard let baseError = try? JSONDecoder().decode(API.ErrorResult.self, from: data),
              let error = baseError.error,
              let cause = error.userMessage else {
                return APIError(message: "Appelez Champollion, impossible de déchiffrer la réponse du serveur.",
                                code: nil)
        }
        
        return APIError(message: cause, code: error.uid)
    }

}