//
//  MainScreenTableViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 06/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import RealmSwift

class MainScreenTableViewController: UITableViewController {
    
    var texts: Results<Card>!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Убираем полоски внизу
        tableView.tableFooterView = UIView()
        setupNavigationBar()
        
    }
    
    private func setupNavigationBar(){
        //navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2190827583, green: 0.5534923909, blue: 0.833327566, alpha: 1)
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.2190827583, green: 0.5534923909, blue: 0.833327566, alpha: 1)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
    // MARK: - Table view data source
    
    
}
