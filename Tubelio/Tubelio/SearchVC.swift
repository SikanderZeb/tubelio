//
//  SearchVC.swift
//  Tubelio
//
//  Created by Sikander on 2/24/18.
//  Copyright © 2018 Sikander. All rights reserved.
//

import UIKit
import Firebase

class SearchVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
        self.tabBarController?.tabBar.itemWidth = self.view.bounds.size.width/2
        self.tabBarController?.tabBar.selectionIndicatorImage = UIImage(named: "tabbg_selected")
        FirebaseHelper.shared.dbref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
}

