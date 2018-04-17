//
//  HomeVC.swift
//  Tubelio
//
//  Created by Sikander Zeb on 3/13/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit
import Firebase

class HomeVC : BaseVC {
    
    @IBOutlet weak var table: UITableView!
    var currentlyPlayingIndexPath : IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
        self.tabBarController?.tabBar.itemWidth = self.view.bounds.size.width/2
        self.tabBarController?.tabBar.selectionIndicatorImage = UIImage(named: "tabbg_selected")
        FirebaseHelper.shared.dbref = Database.database().reference()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utilities.shared.updateProducts {
            self.table.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func highFiveTapped(_ sender: UIButton) {
        let v = Utilities.shared.productsArray![(sender.superview?.superview?.tag)!]
        let user = Auth.auth().currentUser
        guard (v.likes.filter({$0.id == user?.uid}).first != nil) else {
            let u = UserEntity(id: (user?.uid)!, dict: ["name":(user?.email?.substring(to: (user?.email?.index(of: "@"))!))!,
                                                        "email":(user?.email)!])
            
            v.likes.append(u)
            self.table.reloadData()
            
            FirebaseHelper.shared.dbref.child("posts/\(v.id)/likes").childByAutoId().setValue(["userid":(user?.uid)])
            return
        }
    }
    
    @IBAction func commenTapped(_ sender: UIButton) {
        let v = Utilities.shared.productsArray![(sender.superview?.superview?.tag)!]
        let user = Auth.auth().currentUser
        guard (v.likes.filter({$0.id == user?.uid}).first != nil) else {
            let alert = UIAlertController(title: "Comment", message: "Type your comment please", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                let textfield = alert.textFields![0]
                if !Utilities.isEmpty(textfield.text!) {
                    let child = FirebaseHelper.shared.dbref.child("posts/\(v.id)/comments").childByAutoId()
                    let d = ["id":child.key,
                             "comment":textfield.text!,
                             "uid":(user?.uid)!]
                    let c = Comment(dict: d)
                    v.comments.append(c)
                    self.table.reloadData()
                    child.setValue(d)
                }
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        let v = Utilities.shared.productsArray![(sender.superview?.superview?.tag)!]
        
        let controller = UIActivityViewController(activityItems: ["Tubelio Video \(v.caption)"], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Utilities.shared.productsArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PostCell
        cell.delegate = self
        cell.tag = indexPath.row
        //let the cell know its indexPath
        cell.indexPath = indexPath
        cell.configCell(with: Utilities.shared.productsArray![indexPath.row], shouldPlay: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
}
extension HomeVC : PostCellProtocol {
    func playVideoForCell(with indexPath: IndexPath) {
        self.currentlyPlayingIndexPath = indexPath
        //reload tableView
        
        self.table.reloadRows(at: self.table.indexPathsForVisibleRows!, with: .none)
    }
}
