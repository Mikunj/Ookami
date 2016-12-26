//
//  UserService.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

public class UserService: BaseService {
    
    //Errors
    public enum Errors: Error {
        case failedToParseUser
        case invalidJSONRecieved
    }
    
    //MARK: GET
    public typealias UserCompletion = (User?, Error?) -> Void
    
    /// Perform a get request for a user
    ///
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The completion block which passes back a user or error if it occured
    func get(request: NetworkRequest, completion: @escaping UserCompletion) {
        //TODO: Maybe abstarct this out to NetworkParsingOperation which combines network operation and parsing operation
        let operation = NetworkOperation(request: request, client: client) { json, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let json = json else {
                completion(nil, Errors.invalidJSONRecieved)
                return
            }
            
            let parsingOp = ParsingOperation(json: json, realm: RealmProvider.realm) { objects, errors in
                guard let users = objects?[User.typeString] else {
                    completion(nil, Errors.failedToParseUser)
                    return
                }
                
                //Get the user we parsed
                let id: Int = users.first as! Int
                completion(User.get(withId: id), nil)
            }
            self.queue.addOperation(parsingOp)
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
