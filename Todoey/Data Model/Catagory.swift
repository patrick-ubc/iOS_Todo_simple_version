//
//  Catagory.swift
//  Todoey
//
//  Created by Fengpeng Huang on 2020-06-12.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name:String = ""
    @objc dynamic var color:String?
    @objc dynamic var date:Date?
    let items = List<Item>()
}
