//
//  Character.swift
//  TestCombine+RestAPI
//
//  Created by pavel on 21.11.23.
//

import Foundation

struct Character: Codable {
    var id: Int?
    var name: String?
    var status: String?
    var species: String?
    var type: String?
    var gender: String?
    var origin: Origin?
    var location: Location?
    var image: String?
    var episode: [String]?
    var url: String?
    var created: String?
}

struct Origin: Codable {
    var name: String?
    var url: String?
}

struct Location: Codable {
    var name: String?
    var url: String?
}
