//
//  TranslateCardViewController.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 06/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import UIKit


class TranslateCardViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var translateTV: UITextView!

    @IBOutlet weak var translateTF: UITextField!
    @IBOutlet weak var wordTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    var translate: NSMutableAttributedString!
    var key: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        translateTV.attributedText = translate
        wordTF.text = key
        addButton.isEnabled = false
        //Добавляем слушателя
        translateTF.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        // Распознователь нажатий
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapResponse))
        //Устанавливаем наш класс делигатом распознователя нажатий
        tap.delegate = self
        translateTV.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func addWord(_ sender: Any) {
        StorageManager.saveObject(Card(wordTF.text!, translateTF.text!))
    }
    @objc func tapResponse(_ recognizer: UITapGestureRecognizer) {
        
        let location: CGPoint = recognizer.location(in: translateTV)
        let position: CGPoint = CGPoint(x: location.x, y: location.y)
        // Return the position in a document that is closest to a specified point.
        let tapPosition: UITextPosition? = translateTV.closestPosition(to: position)
        guard tapPosition != nil else { return }
        //Диапазон глубиной в слово от позиция нажатия
        // inDirection??? направление текста?
        let textRange: UITextRange? = translateTV.tokenizer.rangeEnclosingPosition(tapPosition!, with: UITextGranularity.word, inDirection: UITextDirection(rawValue: 1))
        // Если мы нажали на слово
        
        if let range = textRange{
            let tappedWord: String? = translateTV.text(in: range)
            translateTF.text = tappedWord!
            touchOnTheWord()
            
            
        }
        
    }
    
        
}
// Mark: — Text Field Delegate
extension TranslateCardViewController: UITextFieldDelegate{
    //Если есть текст в текстовом поле, то активна кнопка add word
    // По нажатию на слово
    func touchOnTheWord(){
        if translateTF.text?.isEmpty == false {
            addButton.isEnabled = true
        }else{
            addButton.isEnabled = false
        }
    }
    //Если есть текст в текстовом поле, то активна кнопка add word
    @objc private func textFieldChange() {
        if translateTF.text?.isEmpty == false {
            addButton.isEnabled = true
        }else{
            addButton.isEnabled = false
        }
    }
}
