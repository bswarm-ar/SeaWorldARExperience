//
//  ViewController.swift
//  SeaworldARDemo
//
//  Created by ChristianBieniak on 18/12/17.
//  Copyright © 2017 Papercloud. All rights reserved.
//

import UIKit
import SeaworldARFramework

class ViewController: UIViewController {

    @IBOutlet weak var animationListTableView: UITableView!
    
    var networkController: NetworkController = NetworkController()
    var animations: [String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.networkController.allAnimations {
            self.animations = $0.value!
            self.animationListTableView.reloadData()
        }
        self.animationListTableView.dataSource = self
        self.animationListTableView.delegate = self
        self.animationListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let recipient = segue.destination as? DisplayAnimationViewController {
            recipient.animationId = (sender as! String).lowercased().replacingOccurrences(of: " ", with: "-")
        }
        
        if let recipient = segue.destination as? FetchAnimViewController {
            recipient.networkController = self.networkController
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.textLabel?.text = animations[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowAnimation", sender: animations[indexPath.row])
    }
}
