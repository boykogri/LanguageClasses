//
//  VocabularyViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 07/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import RealmSwift

class VocabularyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBOutlet weak var ascendingBarItem: UIBarButtonItem!
    
    private var ascending = true
    private var cards: Results<Card>!
    private var filteredCards: Results<Card>!
    private var isFiltering: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
        //Получаем все слова
        getAllCards()
        
        //Убираем полоски внизу
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        //Получаем все слова
        getAllCards()
        sortingCards()
        //sortControl.addTarget(self, action: #selector(sortCards), for: .valueChanged)
    }
    
    //MARK: - Setup
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            //topItem.titleView.
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        
        //Название
        title = "Словарь"
    }
    private func setupSearchBar(){
        //searchController.searchBar.scopeButtonTitles = ["Small", "Medium", "Large"]
        
        //Наш класс отвечает за обновление контента
        searchController.searchResultsUpdater = self
        //Убираем затемнение
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9147044166, green: 0.9147044166, blue: 0.9147044166, alpha: 1)
        searchController.searchBar.searchTextField.backgroundColor = #colorLiteral(red: 0.9332197309, green: 0.9333186746, blue: 0.9373039603, alpha: 1)
        //searchController.searchBar.searchTextField.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        //Интегрируем search bar from your search controller
        navigationItem.searchController = searchController
        
        //Опускает строку поиска, при переходе на другой экран
        //definesPresentationContext = true
    }
    
    private func getAllCards(){
        cards = realm.objects(Card.self)
    }
    //MARK: - Sorting
    
    @IBAction func ascendingChanged(_ sender: Any) {
        //Меняет значение на противоположное
        ascending.toggle()
        if ascending { ascendingBarItem.image = #imageLiteral(resourceName: "AZ") }
        else { ascendingBarItem.image = #imageLiteral(resourceName: "ZA") }
        
        sortingCards()
    }
    
    @IBAction func sortSelection(_ sender: Any) {
        sortingCards()
    }
    
    private func sortingCards(){
        switch sortControl.selectedSegmentIndex {
        case 0:
            cards = ascending ? cards.sorted(byKeyPath: "date", ascending: true) : cards.sorted(byKeyPath: "date", ascending: false)
            tableView.reloadData()
        case 1:
            cards = ascending ? cards.sorted(byKeyPath: "word", ascending: true) : cards.sorted(byKeyPath: "word", ascending: false)
            tableView.reloadData()
        default:
            return
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCard"{
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let dvc = segue.destination as! EditCard
            var card = Card()
            if isFiltering{
                card = filteredCards[indexPath.row]
            }else{
                card = cards[indexPath.row]
            }
            dvc.card = card
        }
        if segue.identifier == "addWord"{
            //guard let indexPath = tableView.indexPathForSelectedRow else { return }
            //let dvc = segue.destination as! EditCard
        }
    }
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        tableView.reloadData()
    }
}
//MARK: - UITableViewDataSource
extension VocabularyViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering{
            return filteredCards.count
        }
        return cards.isEmpty ? 0 : cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VocabularyCell
        var card = Card()
        if isFiltering{
            card = filteredCards[indexPath.row]
        }else{
            card = cards[indexPath.row]
        }
        cell.wordLabel.text = card.word
        cell.translateLabel.text = card.translate
        return cell
    }
}
//MARK: - UITableViewDelegate
extension VocabularyViewController: UITableViewDelegate{
    
    //Свайп влево по ячейчке
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let card = cards[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, success) in
            StorageManager.deleteObject(card)
            //Красиво удаляем
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
//MARK: - ResultsUpdating
extension VocabularyViewController: UISearchResultsUpdating{
    
    //Called when the search bar becomes the first responder
    //or when the user makes changes inside the search bar
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text{
            filterCardsForSearchText(text)
        }
        
    }
    private func filterCardsForSearchText(_ searchText: String){
        filteredCards = cards.filter("word CONTAINS[c] %@ OR translate CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
    
}
