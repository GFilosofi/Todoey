//
//  Category.swift
//  Todoey
//
//  Created by Gabriele Filosofi on 17/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}

