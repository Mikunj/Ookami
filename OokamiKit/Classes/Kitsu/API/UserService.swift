//
//  UserService.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

public class UserService: BaseService {
    
    //MARK: GET
    public typealias UserCompletion = (User?, Error?) -> Void
    
    /// Perform a get request for a user
    ///
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The completion block which passes back a user or error if it occured
    func get(request: NetworkRequest, completion: @escaping UserCompletion) {
        let operation = NetworkOperation(request: request, client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, ServiceError.error(description: "Invalid JSON recieved - User Service GET"))
                return
            }
            
            Parser().parse(json: json) { parsed in
                self.database.addOrUpdate(parsed)
                
                //Get the user we parsed
                let user = parsed.first { $0 is User } as? User
                completion(user, nil)
            }
        }
        
        queue.addOperation(operation)
    }
    
    /// Get a user with the given id
    ///
    /// - Parameters:
    ///   - id: The user id
    ///   - completion: The completion block which passes back a user or error
    public func get(id: Int, completion: @escaping UserCompletion) {
        let endpoint = Constants.Endpoints.users
        let request = NetworkRequest(relativeURL: "\(endpoint)/\(id)", method: .get)
        get(request: request, completion: completion)
    }
    
    /// Get a user with the given name
    ///
    /// - Parameters:
    ///   - name: The user name
    ///   - completion: The completion block which passes back a user or error
    public func get(name: String, completion: @escaping UserCompletion) {
        let endpoint = Constants.Endpoints.users
        let request = KitsuRequest(relativeURL: endpoint)
        request.filter(key: "name", value: name)
        get(request: request.build(), completion: completion)
    }
    
    
    /// Get the current logged in user.
    /// If no user is logged in then passes an authentication error
    ///
    /// - Parameter completion: The completion block which passes back the logged in user or error
    public func getSelf(_ completion: @escaping UserCompletion) {
        let endpoint = Constants.Endpoints.users
        let request = KitsuRequest(relativeURL: endpoint, needsAuth: true)
        request.filter(key: "self", value: true)
        get(request: request.build(), completion: completion)
    }
    
    /// Update the rating system used by the current user.
    ///
    /// - Parameters:
    ///   - ratingSystem: The new rating system.
    ///   - completion: The completion block which passes an error if it occured.
    public func update(ratingSystem: User.RatingSystem, completion: @escaping (Error?) -> Void) {
        //Check if the current rating system is the same as the one we want to update to
        //If so we can just complete straight away
        guard CurrentUser().user?.ratingSystem != ratingSystem else {
            completion(nil)
            return
        }
        
        guard let id = CurrentUser().userID else {
            completion(ServiceError.error(description: "Current User id is not set!"))
            return
        }
        
        // users/<id>
        let endpoint = Constants.Endpoints.users
        let url = "\(endpoint)/\(id)"
        
        let params: [String: Any] = ["data": ["id": id,
                                              "type": User.typeString,
                                              "attributes": ["ratingSystem": ratingSystem.rawValue]]]
        
        let request = NetworkRequest(relativeURL: url, method: .patch, parameters: params, needsAuth: true)
        let operation = NetworkOperation(request: request, client: client) { json, error in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let json = json else {
                completion(ServiceError.error(description: "Invalid JSON recieved - Update Rating System"))
                return
            }
            
            Parser().parse(json: json) { parsed in
                self.database.addOrUpdate(parsed)
                completion(nil)
            }
        }
        
        queue.addOperation(operation)
    }
    
    
}
