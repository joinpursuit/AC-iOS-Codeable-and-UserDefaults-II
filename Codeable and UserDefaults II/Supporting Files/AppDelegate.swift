//
//  AppDelegate.swift
//  Codeable and UserDefaults II
//
//  Created by Louis Tur on 7/5/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	// Example URLs
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		struct UserDecoder: Codable {
			let results: [NameDecoder]
		}
		
		struct NameDecoder: Codable {
			let name: User
		}
		
		struct User: Codable {
			let title: String
			let first: String
			let last: String
			
			var fullName: String {
				return "\(title.capitalized) \(first.capitalized) \(last.capitalized)"
			}
			
			init(json: [String:AnyObject]) {
				let nameJSON = json["name"] as! [String:String]
				let title = nameJSON["title"]
				let first = nameJSON["first"]
				let last = nameJSON["last"]
				
				self.init(title: title!, first: first!, last: last!)
			}
			
			init(title: String, first: String, last: String) {
				self.title = title
				self.first = first
				self.last = last
			}
		}
		
		//		let user = User(title: "Mr", firstName: "Louis", lastName: "Tur")
		//		let encodedUserData = try! PropertyListEncoder().encode(user)
		//
		//		print("\n\n\n\n\nThe user is now data: \(encodedUserData)")
		//
		//		let decodedUser = try! PropertyListDecoder().decode(User.self, from: encodedUserData)
		//		print("The user is no longer data: \(decodedUser)")
		
		func retrieveUser() {
			makeRequest { (data: Data?) in
				if data != nil {
					do {
						let json = try JSONDecoder().decode(UserDecoder.self, from: data!)
						print(json)
					}
					catch {
						print("Error casting from Data to JSON \(error)")
					}
				}
			}
		}
		
		func makeRequest(completion: @escaping (Data?)-> Void) {
			let session = URLSession.shared
			session.dataTask(with: URL(string: "https://randomuser.me/api/?inc=name&noinfo")!) { (data: Data?, _, _) in
				completion(data)
				}.resume()
		}
		
//		retrieveUser()
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

