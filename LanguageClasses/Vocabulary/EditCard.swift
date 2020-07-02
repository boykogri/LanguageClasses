//
//  EditCard.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 07/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit

class EditCard: UIViewController {

    @IBOutlet weak var wordTF: UITextField!
    @IBOutlet weak var translateTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    var card: Card?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addButton.isEnabled = false
        if let card = card {
            wordTF.text = card.word
            translateTF.text = card.translate
            addButton.setTitle("Сохранить", for: .normal)
            title = "Изменить слово"
        }
        
        //Добавляем слушателя
        translateTF.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        wordTF.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
    }
    
    @IBAction func addWordAction(_ sender: Any) {
        let newCard = Card(wordTF.text!, translateTF.text!)
        if card != nil {
            try! realm.write {
                card?.word = newCard.word
                card?.translate = newCard.translate
            }
        }else {
            StorageManager.saveObject(newCard)
        }
    }
    
    private func setupNavigationBar(){
        //Настраиваем кнопку назад
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
 

}
// Mark: — Text Field Delegate
extension EditCard: UITextFieldDelegate{
    //Если есть текст в текстовом поле, то активна кнопка add word
    @objc private func textFieldChange() {
        if !translateTF.text!.isEmpty && !wordTF.text!.isEmpty{
            addButton.isEnabled = true
        }else{
            addButton.isEnabled = false
        }
    }
}
