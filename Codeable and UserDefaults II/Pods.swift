//
//  Pods.swift
//  Codeable and UserDefaults II
//
//  Created by Louis Tur on 7/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation

struct Podcast: Codable {
	let podcast: String
	let producer: String
	let url: String
	let episodes: [Episode]
}

struct PodInfo: Codable {
	let meta: PodMeta
	let pods: [Podcast]
}

struct Episode: Codable {
	let title: String
	let time: String
	let released: String
	let number: Int
}

struct PodMeta: Codable {
	let date_requested: String
}

// MARK: - Structs for Advanced Example
struct PodInfoAdvanced: Codable {
	let meta: PodMetaAdvanced
	let pods: [Podcast]
}

struct PodMetaAdvanced: Codable {
	let date_requested: Date
}
