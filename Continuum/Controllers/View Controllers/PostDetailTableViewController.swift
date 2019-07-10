//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController, UITextFieldDelegate {

    var postLandingPad: Post? {
        didSet {
            loadViewIfNeeded()
            self.updateViews()
        }
    }
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Leave a comment 🤪", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) -> Void in
            textField.delegate = self
            textField.placeholder = "Insert comment..."
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let addComment = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let comment = alertController.textFields?.first?.text,
                let post = self.postLandingPad else {return}
            if comment != "" {
                PostController.sharedInstance.addComment(text: comment, post: post, completion: { (comment) in
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title:"Cancel", style: .destructive)
        
        alertController.addAction(addComment)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func followPostButtonTapped(_ sender: Any) {
    
    }
    
    func updateViews() {
        photoImageView.image = postLandingPad?.photo
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = postLandingPad?.comments else {return 0}
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comments = postLandingPad?.comments[indexPath.row]
        cell.textLabel?.text = comments?.text
        cell.detailTextLabel?.text = comments?.timestamp.formatDate()
        

        return cell
    }
}
