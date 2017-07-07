# Exercise Solutions

### Example 1

```swift
struct Podcast: Codable {
	let podcast: String
	let producer: String
	let url: String
}

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
```

### Example 2

```swift
struct PodInfo: Codable {
	let pod: Podcast
}

func example2Request() {
	urlSession.dataTask(with: example2URL) { (data: Data?, _, _) in
		if data != nil {
			do {
				let podInfo = try JSONDecoder().decode(PodInfo.self, from: data!)
				print("Podcast made: ", podInfo.pod.podcast)
			}
			catch {
				print("Error converting Data into PodCast!", error)
			}
		}
		}.resume()
}
```

### Example 3

```swift
struct Episode: Codable {
	let title: String
	let time: String
	let released: String
	let number: Int
}

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
```

### Example 4

```swift
struct Podcast: Codable {
	let podcast: String
	let producer: String
	let url: String
	let episodes: [Episode]
}

func example4Request() {
	urlSession.dataTask(with: example4URL) { (data: Data?, _, _) in
		if data != nil {
			do {
				let podInfo = try JSONDecoder().decode(PodInfo.self, from: data!)
				print("Pod created: ", podInfo.pod.podcast)
				for episode in podInfo.pod.episodes {
					print("Episode: ", episode)
				}
			}
			catch {
				print("Error converting Data into Cat!")
			}
		}
		}.resume()
}
```

### Example 5

```swift
struct PodInfo: Codable {
	let pods: [Podcast]
}

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
```

### Example 6

```swift
struct PodInfo: Codable {
	let meta: PodMeta
	let pods: [Podcast]
}

struct PodMeta: Codable {
	let date_requested: String
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
```

### Once More!

```swift
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
```




---
### Advanced

```swift
// Update date_requested to be of type Date
struct PodMeta: Codable {
	let date_requested: Date
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
				let pods = try decoder.decode(PodInfo.self, from: data!)

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
```