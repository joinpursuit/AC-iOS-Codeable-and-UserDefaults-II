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
	
	let example1URL = URL(string: "https://api.myjson.com/bins/tq46v")!
	let example2URL = URL(string: "https://api.myjson.com/bins/182vl3")!
	let example3URL = URL(string: "https://api.myjson.com/bins/n8pev")!
	let example4URL = URL(string: "https://api.myjson.com/bins/mn9t3")!
	let example5URL = URL(string: "https://api.myjson.com/bins/18qgcn")!
	let example6URL = URL(string: "https://api.myjson.com/bins/7xv5z")!
	
	func example1Request() {
		urlSession.dataTask(with: example1URL) { (data: Data?, _, _) in
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
	
//	func example2Request() {
//		urlSession.dataTask(with: example2URL) { (data: Data?, _, _) in
//			if data != nil {
//				do {
//					let podInfo = try JSONDecoder().decode(PodInfo.self, from: data!)
//					print("Podcast made: ", podInfo.pod.podcast)
//				}
//				catch {
//					print("Error converting Data into PodCast!", error)
//				}
//			}
//			}.resume()
//	}
	
	func example3Request() {
		urlSession.dataTask(with: example3URL) { (data: Data?, _, _) in
			if data != nil {
				do {
					let episode = try JSONDecoder().decode(Episode.self, from: data!)
					print("Episode made: ", episode.title)
				}
				catch {
					print("Error converting Data into PodCast!", error)
				}
			}
			}.resume()
	}
	
//	func example4Request() {
//		urlSession.dataTask(with: example4URL) { (data: Data?, _, _) in
//			if data != nil {
//				do {
//					let podInfo = try JSONDecoder().decode(PodInfo.self, from: data!)
//					print("Pod created: ", podInfo.pod.podcast)
//					for episode in podInfo.pod.episodes {
//						print("Episode: ", episode)
//					}
//				}
//				catch {
//					print("Error converting Data into Cat!")
//				}
//			}
//			}.resume()
//	}
	
	func example5Request() {
		urlSession.dataTask(with: example5URL) { (data: Data?, _, _) in
			if data != nil {
				do {
					let pods = try JSONDecoder().decode(PodInfo.self, from: data!)
					for pod in pods.pods {
						print("Podcast: ", pod.podcast)
					}
				}
				catch {
					print("Error converting Data into PodCast!", error)
				}
			}
			}.resume()
	}
	
	func example6Request() {
		urlSession.dataTask(with: example6URL) { (data: Data?, _, _) in
			if data != nil {
				do {
					let pods = try JSONDecoder().decode(PodInfo.self, from: data!)
					print("Pod Meta: ", pods.meta.date_requested)
					for pod in pods.pods {
						print("Podcast: ", pod.podcast)
					}
				}
				catch {
					print("Error converting Data into PodCast!", error)
				}
			}
		}.resume()
	}
	
	func example6AdvancedRequest() {
		urlSession.dataTask(with: example6URL) { (data: Data?, _, _) in
			if data != nil {
				do {
					// 1. Create a DateFormatter
					let decodeDateFormatter = DateFormatter()
					
					// 2. Set the initial format for the date string received from the request
					//    "date_requested" : "2017-07-07 17:23:50 +0000"
					decodeDateFormatter.dateFormat = "yyyy-dd-MM HH:mm:ss z"
					
					// 3. Create the JSONDecoder, set its dateDecodingStrategy to .formatted(DateFormatter)
					let decoder = JSONDecoder()
					decoder.dateDecodingStrategy = .formatted(decodeDateFormatter)
					
					// 4. Decode the Data object
					let pods = try decoder.decode(PodInfoAdvanced.self, from: data!)
					
					// 5. pods.meta now should have parsed the string into a proper Date object
					// 	To get the correct formatting, we update the .dateFormat of the dateFormatter
					//  to match the desired string representation of the Date object.
					decodeDateFormatter.dateFormat = "MMMM d, yyyy <h:mm a>"
					
					// 6. Now that .dateFormat is updated, we call on the DateFormatter to convert
					// our Date object (PodMeta.date_requested) into a string
					let formattedDate = decodeDateFormatter.string(from: pods.meta.date_requested)
					
					print("Pod Meta: ", formattedDate)
					for pod in pods.pods {
						print("Podcast: ", pod.podcast)
					}
				}
				catch {
					print("Error converting Data into PodCast!", error)
				}
			}
			}.resume()
	}
}
