//
//  Card.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 07/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import RealmSwift

class Card: Object{
    @objc dynamic var word: String = ""
    @objc dynamic var translate: String = ""
    @objc dynamic var date = Date()
    convenience init(_ word: String, _ translate: String) {
        self.init()
        self.word = word
        self.translate = translate
    }
    
}
