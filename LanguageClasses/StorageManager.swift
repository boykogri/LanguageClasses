//
//  StorageManager.swift
//  LanguageClasses
//
//  Created by Бойко Григорий on 07/06/2020.
//  Copyright © 2020 Бойко Григорий. All rights reserved.
//

import RealmSwift

//Сама базза данных
let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ obj: Object) {
        try! realm.write {
            realm.add(obj)
        }
    }
    
    static func deleteObject(_ obj: Object){
        try! realm.write {
            realm.delete(obj)
        }
    }
}
