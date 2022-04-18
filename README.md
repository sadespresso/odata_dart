# OData Dart
OData Dart is a library to make fetching data from OData Rest APIs slightly easier. (Slightly 😅)

## Compatibility
Compatible with OData v4.0 and v4.01

## Usability
Not usable for production, this version is experimental

## Usage
To get data, you will create queries first. There are 2 types of queries, `Query<T>` and `ColletionQuery<T>`.

```dart
  final instance = OData("api.example.com/v1");

  final ODataResponse simpleExample = await instance
      .single("/api/Person(1)") // Returns Query
      .select("Oid, Name, Age, Phone") // Sets $select fields, fields are seperated by comma. Returns the Query (URL QUERY => $select=Oid,Name,Age,Phone)
      .expand("Facebook") // Sets $expand field, you may use multiple expands, but must set one at a time. (URL QUERY => $expand=Facebook)
      .fetch(); // Fetches [baseUrl]/api/Person(1)?$select=Oid,Name,Age,Phone&$expand=Facebook

  final ODataResponse<LoginDetails> loginExample = await instance
      .single(
        "api/Authentication/Login",
        options: QueryOptions(
          method: "POST",
          requestBody: {
            "Username": "TestUser1234", // I don't like how C# standardizes capitalized variable names :((((
            "Password": "••••••••",
          },
          convertor: (json) => LoginDetails.fromJson(json),
        )
      )
      .fetch();
  
  // You need to set Cookie and the Bearer if needed.

  instance.setBearer(loginExample.data.token);
  instance.setCookie(loginExample.response.headers["set-cookie"]); // Now Bearer token and Cookie are appended in the request HEADER by default. Set QueryOptions.tryUseAuth to false to omit it from the header

  final ODataResponse<Person> convertorExample = await instance
      .single(
        "/api/Person(1)",
        options: QueryOptions(
        convertor: (json) => Person.fromJson(json),
      ))
      .select("Oid, Name, Age, Phone")
      .expand("Facebook")
      .fetch();

  final ODataCollectionResponse<Person> complexExample = await instance
      .collection(
        "/api/Person",
        tryUseAuth: false,
        options: CollectionQueryOptions(
          tryUseAuth: false, // When true, adds Cookie and Bearer token in the header if available. True by default.
          convertor: (json) => Person.fromJson(json), // Convertor function; must pass convertor for single instance.
        ),
      ) // Returns CollectionQuery<T>
      .select("Oid,Username,Name,Age"), 
      // .selectList(["Oid", "Username", "Name", "Age"]) // Alternative option
      .expand(
        "ConnectedAccounts"
        .expand() // This creates ExpandQueryField(), which is special class to handle nested $expand, $select, etc.
        .select("Oid") // This selects single field, "Oid", from /api/Person/ModifiedBy
        .expand("Facebook".expand()) //
        .expand("Google".expand().select("email")))
      .count() // This ensures @odata.count is included in collection queries
      .fetch(); 
```