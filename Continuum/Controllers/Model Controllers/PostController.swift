//
//  PostController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


class PostController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //Singleton
    static let sharedInstance = PostController()
    
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    // S. O. T.
    var posts: [Post] = []
    
    // CRUD Functions
    
    // Create
    func createComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        let record = CKRecord(comment: comment)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let record = record else { completion (nil) ; return }
            let comment = Comment(record: record, post: post)
            self.incrementCommentCount(for: post, completion: nil)
            completion(comment)
        }
    }
    
    func incrementCommentCount(for post: Post, completion: ((Bool) -> Void)?) {
        post.commentCount += 1
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
        CKContainer.default().publicCloudDatabase.add(modifyOperation)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(photo: image, caption: caption)
        posts.append(post)
        let record = CKRecord(post: post)
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let record = record,
                let post = Post(record: record) else { completion (nil) ; return }
            completion(post)
        }
    }
    
    // Read
    func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let records = records else {return}
            let posts = records.compactMap{Post(record: $0)}
            self.posts = posts
            completion(posts)
        }
    }
    func fetchComments(for post: Post, completion: @escaping ([Comment]?) -> Void) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postReference)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicate2])
        let query = CKQuery(recordType: CommentConstants.typeKey, predicate: compoundPredicate)
        publicDB.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let records = record else {completion(nil) ; return}
            let comments = records.compactMap{Comment(record: $0, post: post)}
            post.comments.append(contentsOf: comments)
            completion(comments)
        }
        
        // Update
        
        // Delete
        
    }
    
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: PostConstants.typeKey, predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion?(false, error)
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        let postRecordID = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postRecordID)
        let subscription = CKQuerySubscription(recordType: CommentConstants.typeKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "A new comment was added to a post you follow"
        notification.shouldSendContentAvailable = true
        notification.desiredKeys = nil
        subscription.notificationInfo = notification
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion?(false, error)
            }
            completion?(true, nil)
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool) -> Void)?) {
        let subID = post.recordID.recordName
        publicDB.delete(withSubscriptionID: subID) { (_, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion?(false)
                return
            } else {
                completion?(true)
            }
        }
    }
    
    func checkSubscription(to post: Post, completion: ((Bool) -> Void)?) {
        let subID = post.recordID.recordName
        publicDB.fetch(withSubscriptionID: subID) { (_, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) : \(error.localizedDescription)")
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        checkSubscription(to: post) { (isSubscribed) in
            if isSubscribed {
                self.removeSubscriptionTo(commentsForPost: post, completion: { (success) in
                    if success {
                        print("Unsubbed!")
                        completion?(true, nil)
                    } else {
                        print("Couldn't unsub :(")
                        completion?(false, nil)
                    }
                })
            } else {
                self.addSubscriptionTo(commentsForPost: post, completion: { (success, error) in
                    if let error = error {
                        print("\(error.localizedDescription)")
                        completion?(false, error)
                        return
                    }
                    if success{
                        print("Successfully added the subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    }else{
                        print("Whoops somthing went wrong adding the subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                })
            }
        }
    }
}
