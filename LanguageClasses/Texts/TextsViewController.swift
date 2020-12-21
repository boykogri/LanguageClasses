//
//  TextsViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 06/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class TextsViewController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var texts: Results<Text>!
    
    var items = [RSSItem]()
    let url = "http://feeds.bbci.co.uk/news/technology/rss.xml"
    let parameters: [String: String] = [
        "yandexPassportOauthToken": ""
    ]
    public static var token: String = ""
    var html: NSAttributedString!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        //Получаем все тексты
        texts = realm.objects(Text.self)
        self.view.setActivityIndicator()
        self.view.activityStartAnimating()
        
        DispatchQueue.global().async {
            self.fetchNews()
            self.getToken()
        }
        
        
        //Убираем полоски внизу
        tableView.tableFooterView = UIView()
        

        
    }
    
    
    //MARK: - Work with Internet
    private func fetchNews(){
        
        let rssParser = RSSParser()
        if let url = URL(string: url){
            rssParser.startParsingWithContentsOfURL(rssUrl: url) {(isSuccessful) in
                if isSuccessful {
                    print("Успешно распарсили")
                    items = rssParser.rssItems
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        self.tableView.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        self.setUIWithInternetProblem()
                    }
                    print("Не удалось распарсить")
                }
                
            }
            
        }
        
    }
    func getToken(){
        AF.request("https://iam.api.cloud.yandex.net/iam/v1/tokens",
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.prettyPrinted).validate().responseDecodable(of: Token.self)
                   { response in
                    switch response.result {
                    case .success:
                        guard let value = response.value else { debugPrint(response); return }
                        TextsViewController.token = value.iamToken
                        print("token = \(value.iamToken)")
                        
                    case let .failure(error):
                        print(error)
                        
                    }
        }
    }
    //MARK: - Work with UI
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        //Название
        title = "Статьи"
    }
    
    private func setUIWithInternetProblem(){
        let internetErrorLabel = UILabel()
        internetErrorLabel.text = """
        Не удалость получить новости :(
        Проверьте соединение с интернетом
        """
        internetErrorLabel.numberOfLines = 0
        internetErrorLabel.sizeToFit()
        
        let button = UIButton()
        button.setTitle("Попробовать еще раз", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(self.pressedButton), for: .touchUpInside)
        // Padding
        button.contentEdgeInsets = UIEdgeInsets(top: 10,left: 7,bottom: 10,right: 7)
        
        
        let stackView = UIStackView(arrangedSubviews: [internetErrorLabel, button])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 15
        stackView.tag = 525
        
        self.view.addSubview(stackView)
        // autolayout constraint
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
    }
    @objc func pressedButton(){
        if let stackView = self.view.viewWithTag(525){
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    stackView.removeFromSuperview()
                    self.view.activityStartAnimating()
                }
                self.fetchNews()
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "textSegue" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: indexPath, animated: true)
            let dvc = segue.destination as! TextViewController
            //dvc.article = texts[indexPath.row]
            dvc.newItem = items[indexPath.row]
            dvc.tokenYa = TextsViewController.token
        }
        
    }
    
    
}
//MARK: - UITableViewDataSource
extension TextsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.isEmpty ? 0 : items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TextsTableViewCell
        cell.titleLabel.text = items[indexPath.row].title
        cell.pubDateLabel.text = items[indexPath.row].pubDate
        return cell
    }
}
