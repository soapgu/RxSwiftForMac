//
//  Photo.swift
//  SwiftForMac
//
//  Created by guhui on 2022/1/17.
//

import Foundation

struct Photo:Codable{
    var id: String
    var width: Int
    var height: Int
    
    var description: String?
    var urls: PhotoUrl
}
