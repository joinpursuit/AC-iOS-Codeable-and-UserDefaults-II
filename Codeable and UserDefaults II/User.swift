//
//  User.swift
//  Codeable and UserDefaults II
//
//  Created by Louis Tur on 7/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation

struct User: Codable {
	struct Name: Codable {
		let title: String
		let first: String
		let last: String
	}
	struct Picture: Codable {
		let large: String
		let medium: String
		let thumbnail: String
	}
	
	let name: Name
	let gender: String
	let email: String
	let registered: String
	let picture: Picture
}

struct APIResult: Codable {
	let results: [User]
	let info: Info
}

struct Info: Codable {
	let seed: String
	let results: Int
	let page: Int
	let version: String
}

class UserRequester {
	let session = URLSession(configuration: .default)
	let url = URL(string: "https://randomuser.me/api/?nat=us&inc=gender,name,email,registered,picture")!
	
	func makeRequest() {
		session.dataTask(with: url) { (data: Data?, _, _) in
			if data != nil {
				do {
					let results = try JSONDecoder().decode(APIResult.self, from: data!)
					
					let users = results.results
					let info = results.info
					
					for user in users {
						print(user)
					}
					
					print(info)
				}
				catch {
					print("error parsing data into User: ", error)
				}
				
			}
		}.resume()
	}
}
