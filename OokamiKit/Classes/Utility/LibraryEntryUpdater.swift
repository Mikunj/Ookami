//
//  LibraryEntryUpdater.swift
//  Ookami
//
//  Created by Maka on 11/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//A class used for editing and saving library entries on Kitsu
public class LibraryEntryUpdater {
    
    ///The original entry
    fileprivate let originalEntry: LibraryEntry
    
    ///The unmanaged entry we used for updating
    fileprivate var unmanaged: LibraryEntry
    
    ///The edited entry
    public var entry: LibraryEntry {
        return LibraryEntry(value: unmanaged)
    }
    
    /// Create an entry updater
    ///
    /// - Parameter entry: The entry to edit
    public init(entry: LibraryEntry) {
        self.originalEntry = entry
        self.unmanaged = LibraryEntry(value: originalEntry)
    }
    
    /// Check whether the entry was edited
    ///
    /// - Returns: True if entry was edited, false if not.
    public func wasEdited() -> Bool {
        return originalEntry != unmanaged
    }
    
    /// Save the entry on Kitsu.
    ///
    /// - Parameter completion: The completion block which passes back an error if something went wrong.
    public func save(completion: @escaping (Error?) -> Void) {
        LibraryService().update(entry: unmanaged) { entry, error in
            completion(error)
        }
    }
    
    /// Reset any changes made to the entry
    public func reset() {
        self.unmanaged = LibraryEntry(value: originalEntry)
    }
    
}

//MARK:- Updating
extension LibraryEntryUpdater {
    
    /// Update the progress on an entry.
    ///
    /// If progress is max, then the status will be set to `completed`.
    ///
    /// - Parameter progress: The new progress.
    public func update(progress: Int) {
        if let maxProgress = unmanaged.maxProgress() {
            unmanaged.progress = min(maxProgress, max(progress, 0))
            
            //Set to completed if we hit max progress
            if progress == maxProgress {
                update(status: .completed)
            }
        } else {
            unmanaged.progress = progress
        }
    }
    
    /// Update the status on an entry.
    ///
    /// If the status is `completed` then the progress will be set to max if possible.
    /// If entry was being reconsumed, then `reconsumeCount` and `reconsuming` will be updated accordingly
    ///
    /// - Parameter status: The new status.
    public func update(status: LibraryEntry.Status) {
        unmanaged.status = status
        
        //Check for completed
        if status == .completed {
            //If we completed the show then set the progress to max
            if let max = unmanaged.maxProgress() {
                //Change it directly so we don't get recursive loops
                unmanaged.progress = max
            }
            
            
            //We need to update the reconsume count aswell if we were reconsuming
            if unmanaged.reconsuming {
                update(reconsumeCount: unmanaged.reconsumeCount + 1)
                update(reconsuming: false)
            } else {
                //We only want to set the dates if we weren't reconsuming.
                
                //Set the finished date
                if unmanaged.finishedAt == nil {
                    update(finishedAt: Date())
                }
                
                //Set the start date if it hasn't been set
                if unmanaged.startedAt == nil {
                    update(startedAt: Date())
                }
            }
            
        } else if status == .current {
            //Set the start date if it hasn't been set when we move the entry to current
            if unmanaged.startedAt == nil {
                update(startedAt: Date())
            }
        }
    }
    

    
    /// Update the rating on an entry.
    ///
    /// The rating will only be updated if it is between 2 and 20 or 0.
    ///
    /// - Parameter rating: The new rating between 2 and 20 or 0.
    public func update(rating: Int) {
        guard rating == 0 || (rating >= 2 && rating <= 20) else {
            return
        }

        unmanaged.rating = rating
    }
    
    /// Update the notes on the entry.
    ///
    /// - Parameter notes: The notes
    public func update(notes: String) {
        unmanaged.notes = notes
    }
    
    
    /// Update if we are reconsuming the entry.
    ///
    /// If `reconsuming` is set to true and the entry's status is `completed`, it will be moved to `current` and progress will be reset to 0.
    ///
    /// - Parameter reconsuming: Whether we are reconsuming the entry
    public func update(reconsuming: Bool) {
        unmanaged.reconsuming = reconsuming
        
        //If we are reconsuming and the status is completed then set the progress to 0, and set it to current
        //We only do this on completed as the user may have not marked media as reconsuming when it's in a different status.
        if reconsuming, unmanaged.status == .completed {
            update(progress: 0)
            update(status: .current)
        }
    }
    
    /// Update the started at date on the entry.
    ///
    /// - Parameter startedAt: The date.
    public func update(startedAt: Date?) {
        unmanaged.startedAt = startedAt
    }
    
    /// Update the finished at date on the entry.
    ///
    /// - Parameter startedAt: The date.
    public func update(finishedAt: Date?) {
        unmanaged.finishedAt = finishedAt
    }
    
    /// Update the reconsume count on the entry.
    ///
    /// - Parameter reconsumeCount: The new count.
    public func update(reconsumeCount: Int) {
        unmanaged.reconsumeCount = reconsumeCount
    }
    
    /// Update whether entry is private or not.
    ///
    /// - Parameter isPrivate: A bool to indicate if entry is private or not
    public func update(isPrivate: Bool) {
        unmanaged.isPrivate = isPrivate
    }
    
    /// Increment the progress of the entry by 1
    public func incrementProgress() {
        update(progress: unmanaged.progress + 1)
    }
    
    /// Increment the reconsume count of the entry by 1
    public func incrementReconsumeCount() {
        update(reconsumeCount: unmanaged.reconsumeCount + 1)
    }
}
