//
//  Text.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 06/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import RealmSwift

class Text: Object {
     @objc dynamic var title: String = ""
     @objc dynamic var text: String = ""
     convenience init(_ title: String, _ text: String) {
        self.init()
        self.title = title
        self.text = text
     }
}
