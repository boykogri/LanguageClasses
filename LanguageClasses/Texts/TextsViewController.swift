//
//  TextsViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 06/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import RealmSwift

class TextsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    var texts: Results<Text>!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        //Получаем все тексты
        texts = realm.objects(Text.self)
        
        
        //Убираем полоски внизу
        tableView.tableFooterView = UIView()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.isEmpty ? 0 : texts.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TextsTableViewCell
        cell.titleLabel.text = texts[indexPath.row].title
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "textSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let dvc = segue.destination as! ViewController
            dvc.article = texts[indexPath.row]
        }
        
    }
    
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        //Название
        title = "Статьи"
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
