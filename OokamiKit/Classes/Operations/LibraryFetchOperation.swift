//
//  LibraryFetchOperation.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

/// Operation to fetch all the entries in a library
public class LibraryFetchOperation: AsynchronousOperation {
    
    var queue = OperationQueue()
    let request: LibraryGETRequest
    let fetchComplete: (Results<LibraryEntry>) -> Void
    
    /// Create a library fetch operation
    /// Note that this will use a new copy of the request passed in.
    ///
    /// - Parameter request: The request
    /// - Parameter completion: The completion block. Passes a realm result which then can be subscribed to for notifications.
    init(request: LibraryGETRequest, completion: @escaping (Results<LibraryEntry>) -> Void) {
        self.request = request.copy() as! LibraryGETRequest
        self.fetchComplete = completion
        
        //Make it serial
        queue.maxConcurrentOperationCount = 1
    }
    
    override public func main() {
        
    }
}
