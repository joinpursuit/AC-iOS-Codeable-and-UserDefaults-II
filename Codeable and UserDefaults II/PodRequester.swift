//
//  PodRequester.swift
//  Codeable and UserDefaults II
//
//  Created by Louis Tur on 7/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation

class PodRequester  {
	let urlSession = URLSession(configuration: .default)
	
	func example1Request() {
		let url = URL(string: "https://api.myjson.com/bins/tq46v")!
		urlSession.dataTask(with: url) { (data: Data?, _, _) in
			if data != nil {
				do {
					let podcast = try JSONDecoder().decode(Podcast.self, from: data!)
					print("Podcast made: ", podcast.podcast)
				}
				catch {
					print("Error converting Data into PodCast!", error)
				}
			}
			}.resume()
	}
}
