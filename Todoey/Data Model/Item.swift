//
//  Item.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 17/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var creationDate: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
