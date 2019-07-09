//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Nic Gibson on 7/9/19.
//  Copyright © 2019 Nic Gibson. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedInstance.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        cell.post = PostController.sharedInstance.posts[indexPath.row]
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailTableView" {
            guard let index = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? PostDetailTableViewController else {return}
            let post = PostController.sharedInstance.posts[index.row]
            destinationVC.postLandingPad = post
        }
    }
}
