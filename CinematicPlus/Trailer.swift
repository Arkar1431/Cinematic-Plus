//
//  Trailer.swift
//  CinematicPlus
//
//  Created by Mac on 9/11/24.
//

import Foundation


struct TrailerResponse: Codable {
    let results: [Trailer]
}


struct Trailer: Codable {
    let key: String
    let name: String
    let site: String

    private enum CodingKeys: String, CodingKey {
        case key
        case name
        case site
    }
}
