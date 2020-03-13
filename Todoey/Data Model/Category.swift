//
//  Category.swift
//  LiGo
//
//  Created by David Mompoint on 1/09/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
    @objc dynamic var color: String = ""
}
