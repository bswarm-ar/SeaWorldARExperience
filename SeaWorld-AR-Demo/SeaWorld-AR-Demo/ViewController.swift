//
//  ViewController.swift
//  SeaworldARDemo
//
//  Created by ChristianBieniak on 18/12/17.
//  Copyright © 2017 Papercloud. All rights reserved.
//

import UIKit
import SeaworldARFramework
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var animationListTableView: UITableView!
    var networkController: NetworkController = NetworkController()
    var seaworldSyncEngine: SeaworldSyncEngine = SeaworldSyncEngine(retryCount: 3)
    var animations: [RemoteAnimation]! = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.animationListTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let recipient = segue.destination as? FetchAnimViewController {
            recipient.networkController = self.networkController
        }
        
        if let recipient = segue.destination as? MarkerViewController {
            recipient.networkController = self.networkController
        }
    }
    
    fileprivate func checkForCameraAccess(success: @escaping (()->())) {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied:
            self.showCameraDeniedPopup()
            break
        case .authorized:
            success()
            break
        case .restricted:
            self.showCameraDeniedPopup()
            break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    success()
                } else {
                    self.showCameraDeniedPopup()
                }
            }
        }
    }
    
    //Show Camera Unavailable Alert
    
    fileprivate func showCameraDeniedPopup() {
        //Camera not available - Alert
        let cameraUnavailableAlertController = UIAlertController (title: "Camera Access Denied", message: "Please allow camera permissions in settings to access this feature", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = URL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                DispatchQueue.main.async() {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(settingsAction)
        cameraUnavailableAlertController .addAction(cancelAction)
        self.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        let animation = animations[indexPath.row]
        cell.textLabel?.text = animation.title
        let isSynced = !self.seaworldSyncEngine.isRemoteFetchRequired(for: animation.animationFileName!)
        cell.accessoryType = isSynced ? .checkmark : .detailButton
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.checkForCameraAccess {
            DispatchQueue.main.async {
                let vc = DisplayAnimationViewController.instance()
                vc.animationId = self.animations[indexPath.row].animationFileName
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
}
