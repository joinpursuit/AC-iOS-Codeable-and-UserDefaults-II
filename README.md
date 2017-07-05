# AC-iOS Codable and UserDefaults: Part II JSON Codables (Swift 4.x)

---
### Readings
1. [Ultimate Guide to Parsing With Swift](http://benscheirman.com/2017/06/ultimate-guide-to-json-parsing-with-swift-4/?utm_campaign=iOS%2BDev%2BWeekly&utm_medium=email&utm_source=iOS_Dev_Weekly_Issue_306)
1. [An Introduction to NSUserDefaults](http://www.codingexplorer.com/nsuserdefaults-a-swift-introduction/)


### 0. Overall Goals

1. Become familiar with using `UserDefaults` to store data
2. Understand that `UserDefaults` is a light-weight, persistant storage option for small amounts of data that relate to how your app should be configured, based on the user's selection/choices.
3. Become with the `Codable` protocol that allows for easy conversion between Swift objects and storeable `Data`


---
###  1. `Codable` with `JSON`

Now for some real magic: we can use Codable to serialize and deserialize JSON incredibly easily.

#### The Old Way

As we have in the past, we're going to use the [RandomUser API](https://randomuser.me/documentation) for these examples. First, we're going to make a simple request to receive a JSON object of a single user's name information:

`https://randomuser.me/api/?inc=name&noinfo`

1. The `inc` key lets you specify the information your specifically interested in receiving, in this case we just want randomly generated `name` info
2. The `noinfo` removes additional unnecessary key/values from the response as well.

> Note: Go ahead and plug in the above URL into postman to observer the results. Below is an example of the full JSON we will receive.

```json
{
    "results": [
        {
            "name": {
                "title": "mr",
                "first": "simon",
                "last": "bernard"
            }
        }
    ]
}
```

As a reminder, here is the code we're previously used in order to parse JSON and define a model object (I've provided you with a sample `User` struct)

```swift
struct User {
	let title: String
	let firstName: String
	let lastName: String

	var fullName: String {
		return "\(title.capitalized) \(firstName.capitalized) \(lastName.capitalized)"
	}
}

// Function calls the API and returns Optional Data
func makeRequest(completion: @escaping (Data?)-> Void) {

	let session = URLSession.shared
	session.dataTask(with: URL(string: "https://randomuser.me/api/?inc=name&noinfo")!) { (data: Data?, _, _) in
		completion(data)
	}.resume()
}

// Function starts the process for getting a single user, parses out data from makeRequest if not nil
func retrieveUser() {
	makeRequest { (data: Data?) in
		if data != nil {
			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]

				if let resultsJSON = json["results"] as? [[String:AnyObject]] {
					for result in resultsJSON {
						if let nameJSON = result["name"] as? [String:String] {
							guard let title = nameJSON["title"],
								let first = nameJSON["first"],
								let last = nameJSON["last"] else {
									return
							}

							let newUser = User(title: title, firstName: first, lastName: last)
							print("Hi, i'm \(newUser.fullName)")
						}
					}
				}

			}
			catch {
				print("Error casting from Data to JSON \(error)")
			}
		}
	}
}
```

We've even taken things one step further by adding an additional `init(json: [String:String])` to our `User` struct and removing some of that nasty, typecasting code out of our API request functions:

```swift
struct User {
	let title: String
	let firstName: String
	let lastName: String

	var fullName: String {
		return "\(title.capitalized) \(firstName.capitalized) \(lastName.capitalized)"
	}

	// For simplicity, we force unwrap here, but you should unwrap optionals safely under normal circumstance
	init(json: [String:AnyObject]) {
		let nameJSON = json["name"] as! [String:String]
		let title = nameJSON["title"]
		let first = nameJSON["first"]
		let last = nameJSON["last"]

		self.init(title: title!, first: first!, last: last!)
	}

	// The initializer we get for "free" needs to be re-added should we add our own custom inits
	init(title: String, first: String, last: String) {
		self.title = title
		self.firstName = first
		self.lastName = last
	}
}

func retrieveUser() {
	makeRequest { (data: Data?) in
		if data != nil {
			do {
				let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]

				if let resultsJSON = json["results"] as? [[String:AnyObject]] {
					for result in resultsJSON {
						let newUser = User(json: result)
						print("Hi, i'm \(newUser.fullName)")
					}
				}
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
```

#### The Codable Way

JSON is at its core a `Dictionary`, and all of our parsing from `Data` to `Dictionary<Hashable:Any>` involves traversing through its dictionary-like structure once we convert raw serialized data from a `URLRequest` into `Data` and from `Data` into `Any`. Having `Codable` makes this conversion trivial. Let's take a look:

```swift
struct User: Codable {
	let title: String
	let firstName: String
	let lastName: String

	var fullName: String {
		return "\(title.capitalized) \(firstName.capitalized) \(lastName.capitalized)"
	}

	// Remember, we lose our free init for structs when we add Codable, since Codable comes with an init
	init(title: String, firstName: String, lastName: String) {
		self.title = title
		self.firstName = firstName
		self.lastName = lastName
	}
}
```

*Eventually*, we're going to want to convert the `Data?` returned from a `URLRequest` into one or more `User`.

 But first we should attempt converting a `User` into `Data` to make sure we have that implementation working :

```swift
let user = User(title: "Mr", firstName: "Louis", lastName: "Tur")
let encodedUserData = try! PropertyListEncoder().encode(user)

print("\n\n\n\n\nThe user is now data: \(encodedUserData)")
```

Ok, that was easy enough. How about doing the reverse now:

```swift
let decodedUser = try! PropertyListDecoder().decode(User.self, from: encodedUserData)
print("The user is no longer data: \(decodedUser)")
```

![Converting User using Codable](./Images/user_to_data_and_back.png)

#### Using `User: Codable` with actual requests

Notice how we just used `PropertyListDecoder`? That's about to change a little.

To make use of the `Codable` protocol with respect to JSON, we use `JSONDecoder` instead of `PropertyListDecoder`. `JSONDecoder` is a subclass of `PropertyListDecoder` that's built to specifically deal with the deserialization of JSON-back `Data`. Update your code inside of `retrieveUser` to now use `JSONDecoder` instead of `JSONSerialization`:

```swift
func retrieveUser() {
	makeRequest { (data: Data?) in
		if data != nil {
			do {
				// 👍 so much less code to write! 👍
				let json = try JSONDecoder().decode(User.self, from: data!)
				print(json)
			}
			catch {
				print("Error casting from Data to JSON \(error)")
			}
		}
	}
}
```

Run the project at this point and check out the output to console...

> `Error casting from Data to JSON keyNotFound(CodingKeys in User #1 in Codeable_and_UserDefaults.AppDelegate.application...`


<details>
<summary>Q: We get an error, but why? Think about the JSON structure that's returned in an API request</summary>
<br><br>
The API sends back a nested structure, but our code isn't currently ready to handle that!
<br><br>
</details>

#### Dealing with `[User]`

We've already handled a situation where we have an array of `Codable` objects that are being parsed when working with the `Cart` and `CartStorageManager` earlier. We just need to adapt our code to do the same.







>>>> TODO:
1. Attempt to update code in existing request
2. explain need for nesting considerations
3. exercises! include nesting, using custom keys, enums/structs, and advanced will be dynamic keys
4. Split into 2 lessons...