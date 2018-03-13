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
        Utilities.shared.updateProducts {
            self.table.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Utilities.shared.productsArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PostCell
        cell.delegate = self
        //let the cell know its indexPath
        cell.indexPath = indexPath
        cell.configCell(with: Utilities.shared.productsArray![indexPath.row], shouldPlay: true)
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
