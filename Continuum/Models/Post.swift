//
//  Post.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post: SearchableRecord {
    
    var caption: String
    var timestamp: Date
    var comments: [Comment]
    var photoData: Data?
    var commentCount: Int
    var recordID: CKRecord.ID
    var photo: UIImage? {
        get {
            guard let photoData = photoData else
            {return nil}
            return UIImage(data: photoData)
        }
        
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = [], commentCount: Int = 0, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.commentCount = commentCount
        self.recordID = recordID
        self.photo = photo
    }
    
    convenience init?(record: CKRecord) {
        guard let caption = record[PostConstants.captionKey] as? String,
            let timestamp = record[PostConstants.timestampKey] as? Date,
            let commentCount = record[PostConstants.commentCountKey] as? Int,
            let comments = record[PostConstants.commentsKey] as? [Comment],
            let imageAsset = record[PostConstants.photoKey] as? CKAsset else {return nil}
        
        guard let photoData = try? Data(contentsOf: imageAsset.fileURL!),
         let photo = UIImage(data: photoData) else {return nil}
        
        self.init(photo: photo, caption: caption, timestamp: timestamp, comments: comments, commentCount: commentCount, recordID: record.recordID)
    }

//    init?(record: CKRecord) {
//        guard let caption = record[PostConstants.captionKey] as? String,
//        let timestamp = record[PostConstants.timestampKey] as? Date,
//        let comments = record[PostConstants.commentsKey] as? [Comment],
//            let imageAsset = record[PostConstants.photoKey] as? CKAsset else {return nil}
//
//        self.caption = caption
//        self.timestamp = timestamp
//        self.comments = comments
//        self.recordID = record.recordID
//
//        do {
//            try self.photoData = Data(contentsOf: imageAsset.fileURL!)
//        } catch {
//            print("error ⏹")
//        }
    
    var imageAsset: CKAsset? {
        get {
            // Declare temp local storage
            let tempDirectory = NSTemporaryDirectory()
            // Create file url
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            // create filepath
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                // write the photo data to the file
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp URL \(error) \(error.localizedDescription)")
            }
            // package the file into a CKAsset
            return CKAsset(fileURL: fileURL)
        }
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            for comment in comments {
                if comment.text.lowercased().contains(searchTerm.lowercased()) {
                    return true
                }
            }
        }
        return false
    }
}

struct PostConstants {
    static let typeKey = "Post"
    fileprivate static var captionKey = "Caption"
    fileprivate static var timestampKey = "Timestamp"
    fileprivate static var commentsKey = "Comments"
    fileprivate static var photoKey = "Photo"
    fileprivate static var commentCountKey = "CommentCount"
}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostConstants.typeKey, recordID: post.recordID)
        self.setValue(post.caption, forKey: PostConstants.captionKey)
        self.setValue(post.comments, forKey: PostConstants.commentsKey)
        self.setValue(post.commentCount, forKey: PostConstants.commentCountKey)
        self.setValue(post.timestamp, forKey: PostConstants.timestampKey)
        self.setValue(post.imageAsset, forKey: PostConstants.photoKey)
    }
}
