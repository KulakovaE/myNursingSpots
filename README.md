# myNursingSpots
**Udacity iOS Nanodegree final project - my idea**

The idea of this app is to help you to save your spots where you can nurse or play with your baby. 
  The idea came when I got my kid and when I was going out I really wanted to find some place with baby facilities, good coffee and seat and enjoy in peace and quiet. 
  
  In my app I show the user two tabs of UITabController. On the first tab a map and search bar. On the map I show his location but first ask for his permission to use his location. In the search bar users can search for the name of places they know or see on the map. When the user is using this app, in the search bar can write the name of the spot, the search network requests are made to apple and they return list of places, select it, make a review for it and save it. On the review the user can add images, write some notes or remarks, rate the baby facilities, the hygiene, comfort and privacy. User can also check the spot on Foursquare and on the view it will be shown popular pictures and tips and reviews for that spot. We make network request to Foursquare using their endpoints. All the saved spots are shown on the map with pins and if the user selects it, can see his review of the place or get distance and directions to the place. The user can also edit the review that he has made before. The user can list all spots on map or in list. On the second tab all the saved reviews is listed in a table view. The user can see the distance from his current location spot to the saved spot.

This is the first version where data is saved locally with Core Data and my idea is to use Firebase or iCloud in order to make it a social platform where parents can help each other.

The iOS development target is iOS and this app can be used on iPhones and iPads in portrait and landscape mode. It is built with Swift 5.0 on Xcode 10.2.1.
