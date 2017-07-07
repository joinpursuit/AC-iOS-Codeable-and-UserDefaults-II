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
###  1. `JSONDecoder` and `Codable`

`Codeable` makes a world of difference when it comes to working with JSON. Rather than using our old friend `JSONSerialization`, we use `JSONDecoder` when we can guarantee that the object we're creating conforms to `Codable`. Let's start off with a simple eample using another old friend, `Cat`! (conveniently provided as its own file in the starter project):

```swift
struct Cat: Codable {
	let name: String
	let breed: String
	let snack: String
}
```

We'll be using the provided `CatRequester` to make our API requests. At the top of the class you'll notice a list of `URL` to use for various examples:

```swift
	let example1URL = URL(string: "https://api.myjson.com/bins/1h4707")!
	let example2URL = URL(string: "https://api.myjson.com/bins/fq67r")!
	let example3URL = URL(string: "https://api.myjson.com/bins/oatbr")!
	let example4URL = URL(string: "https://api.myjson.com/bins/vg0l3")!
```

#### Basic JSON Request

We're first going fill out the function labeled `makeBasicCatRequest` and make a request using `example1URL`. If we plug in `example1URL` into Postman, we get

```json
{
    "name": "Miley",
    "breed": "American Shorthair",
    "snack": "Chicken"
}
```

The key to using a model that conforms to `Codable` along with `JSONDecoder` is to ensure that the names of instance properties of the model match the keys in the JSON response. Our `Cat` model has three properties, `name, breed, snack` which correspond to the keys being returned in the JSON response, `name, breed` and snack. You don't have to know the full details yet on how this works, but just understand that this is how you make this kind of decoding work.

Now, we'll do a basic `URLSession` data task to make a model:

```swift
func makeBasicCatRequest() {
	urlSession.dataTask(with: example1URL) { (data: Data?, _, _) in
		if data != nil {
			do {
				let cat = try JSONDecoder().decode(Cat.self, from: data!)
				print("\n\nNice to meet you, I'm ", cat.name)
			}
			catch {
				print("Error converting Data into Cat!", error)
			}
		}
	}.resume()
}
```

> Image

#### Incorrectly Named JSON Keys

Ok, now replace `example1URL` with `example2URL` and observe the difference. Putting in `example2URL` into Postman gives us:

```json
{
    "fullname": "Miley",
    "breed": "American Shorthair",
    "snack": "Chicken"
}
```

With `fullname` no longer matching a `Cat.name` property, attempting to decode results in an error.

> Image

#### Nested JSON Structure

Let's now take a look at a nested dictionary structure. Replace `example2URL` with `example3URL` and verify that in Postman you're getting this JSON response:

```json
{
  "cat": {
    "name": "Miley",
    "breed": "American Shorthair",
    "snack": "Chicken"
  }
}
```

In this example, our `Cat` dictionary is wrapped up using a `"cat"` key/value pair. To access the deeper level of the dictionary, (to get `name`, `breed`, and `snack`) we can simply create a wrapper struct like so:

```swift
// Nested Cat object wrapped in a "cat" key
struct CatContainer: Codable {
	let cat: Cat
}
```

Now, we just need to update the code so that `JSONDecoder` expects to decode a `CatContainer` rather than a `Cat` directly.

```swift
	// just change the expected type from `Cat` to `CatContainer`!
	let catContainer = try JSONDecoder().decode(CatContainer.self, from: data!)
	print("\n\nNice to meet you, I'm ", catContainer.cat.name)
```

#### JSON Array Structure

Let's look at one more example where the root object is an array of `Cats`. We're going to use `example4URL` which should have a JSON response like:

```json
{
  "cats": [
    {
      "name": "Miley",
      "breed": "American Shorthair",
      "snack": "Chicken"
    },
    {
      "name": "Bale",
      "breed": "Russian Blue",
      "snack": "Kibble"
    }
  ]
}
```

 You might already be able to guess what needs to be done for this to work... make a wrapper struct!

```swift
struct CatArrayContainer: Codable {
	let cats: [Cat]
}
```

And now we just update our `JSONDecoder` code to make use of the new wrapper:

```swift
let catArrayContainer = try JSONDecoder().decode(CatArrayContainer.self, from: data!)
for cat in catArrayContainer.cats {
	print("\n\nNice to meet you, I'm ", cat.name)
}
```

> Image


### 2. Exercises

For each of these exercises, make sure that you're checking out the JSON response for each URL using Postman. You will need that information in order to correctly create your data models.

#### Pod(s) Save America

---
*Example 1*: `https://api.myjson.com/bins/tq46v`

- Create a new model, `Podcast` that conforms to `Codable`
- Make a request the the URL listed and create an instance of `Podcast`

```json
{
    "podcast": "Pod Save America",
    "producer": "Crooked Media",
    "url": "https://itunes.apple.com/us/podcast/pod-save-america/id1192761536?mt=2"
}
```

---
*Example 2*: https://api.myjson.com/bins/182vl3

-  Create a new wrapper, `PodInfo` to house a `Podcast` object

```json
{
    "pod": {
        "podcast": "Pod Save America",
        "producer": "Crooked Media",
        "url": "https://itunes.apple.com/us/podcast/pod-save-america/id1192761536?mt=2"
    }
}
```

---
*Example 3*: https://api.myjson.com/bins/n8pev

- Create a new struct, `Episode`

```json
{
  "title": "Making Redistricting Sexy Again...",
  "time": "1hr 19min",
  "released": "June 6 2017",
  "number": 1
}
```

---
*Example 4*: https://api.myjson.com/bins/mn9t3

- Expand `Pod` to include `[Episode]`

```json
{
    "pod": {
        "podcast": "Pod Save America",
        "producer": "Crooked Media",
        "url": "https://itunes.apple.com/us/podcast/pod-save-america/id1192761536?mt=2",
        "episodes": [
            {
                "title": "Making Redistricting Sexy Again...",
                "time": "1hr 19min",
                "released": "June 6 2017",
                "number": 1
            }
        ]
    }
}
```

---
*Example 5*: https://api.myjson.com/bins/18qgcn

- Create a new wrapper struct, `Pods`

```json
{
  "pods": [
    {
      "podcast": "Pod Save America",
      "producer": "Crooked Media",
      "url": "https://itunes.apple.com/us/podcast/pod-save-america/id1192761536?mt=2",
      "episodes": [
        {
          "title": "Making Redistricting Sexy Again...",
          "time": "1hr 19min",
          "released": "June 6 2017",
          "number": 1
        }
      ]
    },
    {
      "podcast": "The Daily",
      "producer": "New York Times",
      "url": "https://itunes.apple.com/us/podcast/the-daily/id1200361736?mt=2",
      "episodes": [
        {
          "title": "Friday July 7th",
          "time": "22min",
          "released": "June 7 2017",
          "number": 1
        }
      ]
    }
  ]
}
```

---
*Example 6*: https://api.myjson.com/bins/7xv5z

- Extend `Pods` to have a new property for `meta` data

```json
{
    "meta": {
        "date_requested": "2017-07-07 17:23:50 +0000"
    },
    "pods": [
        {
            "podcast": "Pod Save America",
            "producer": "Crooked Media",
            "url": "https://itunes.apple.com/us/podcast/pod-save-america/id1192761536?mt=2",
            "episodes": [
                {
                    "title": "Making Redistricting Sexy Again...",
                    "time": "1hr 19min",
                    "released": "June 6 2017",
                    "number": 1
                }
            ]
        },
        {
            "podcast": "The Daily",
            "producer": "New York Times",
            "url": "https://itunes.apple.com/us/podcast/the-daily/id1200361736?mt=2",
            "episodes": [
                {
                    "title": "Friday July 7th",
                    "time": "22min",
                    "released": "June 7 2017",
                    "number": 1
                }
            ]
        }
    ]
}
```

---
#### *Advanced*: Formatting Time

In example 6, you received a new key `meta` that had a single key/value `date`. That problem only requires you to express the date passed as a `String` but now you are tasked with parsing the value as a `Date` instead. You must convert the formatted date by using `DateFormatter` so that it reads: "Month Day, Year  <Hour:Minute>" in console.

#### Resources For Advanced

1. [Ultimate Guide to JSON Parsing with Swift 4](http://benscheirman.com/2017/06/ultimate-guide-to-json-parsing-with-swift-4/?utm_campaign=iOS%2BDev%2BWeekly&utm_medium=email&utm_source=iOS_Dev_Weekly_Issue_306)
2. [NSDateFormatter.com](http://nsdateformatter.com/)























### 2. RandomUser API and `Codable`

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