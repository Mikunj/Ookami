//
//  UserService.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

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
                completion(nil, ServiceError.error(description: "Invalid JSON recieved"))
                return
            }
            
            let parsed = Parser().parse(json: json)
            self.database.addOrUpdate(parsed)
            
            //Get the user we parsed
            let user = parsed.first { $0 is User } as? User
            completion(user, nil)
            
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
        let params = ["filter": ["name": name]]
        let request = NetworkRequest(relativeURL: endpoint, method: .get, parameters: params)
        get(request: request, completion: completion)
    }
    
    
    /// Get the current logged in user.
    /// If no user is logged in then passes an authentication error
    ///
    /// - Parameter completion: The completion block which passes back the logged in user or error
    public func getSelf(_ completion: @escaping UserCompletion) {
        let endpoint = Constants.Endpoints.users
        let params = ["filter": ["self": true]]
        let request = NetworkRequest(relativeURL: endpoint, method: .get, parameters: params, needsAuth: true)
        get(request: request, completion: completion)
    }
    
    
}
