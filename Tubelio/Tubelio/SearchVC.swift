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
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    var postArray:[Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.white
        self.tabBarController?.tabBar.itemWidth = self.view.bounds.size.width/2
        self.tabBarController?.tabBar.selectionIndicatorImage = UIImage(named: "tabbg_selected")
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postArray = Utilities.shared.productsArray!
        table.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func textDidChange(_ sender: UITextField) {
        search()
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        search()
        return true
    }
    
    func search() {
        let text = searchBar.text
        if Utilities.isEmpty(text!) {
            postArray = Utilities.shared.productsArray!
        }
        else {
            postArray = Utilities.shared.productsArray!.filter({$0.caption.lowercased().range(of: text!.lowercased()) != nil})
        }
        self.table.reloadData()
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PostCell
        //cell.delegate = self
        //let the cell know its indexPath
        cell.indexPath = indexPath
        cell.configCell(with: postArray[indexPath.row], shouldPlay: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
}

