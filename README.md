# myNursingSpots
**Udacity iOS Nanodegree final project - my idea**

The idea of this app is to help you to save your spots where you can nurse or play with your baby. 
  The idea came when I got my kid and when I was going out I really wanted to find some place with baby facilities, good coffee and seat and enjoy in peace and quiet. 
  
  In my app I show the user two tabs of UITabController. On the first a map and search bar. On the map I show his location but first ask for his permission to use his location. In the search bar users can search for the name of places they know or see on the map. The search network requests are made to apple and they return list of places. When the user selects one of those places he can make a review for it and save it to his spots. On the review he can add images, write some notes or remarks, rate the baby facilities, the hygiene, comfort and privacy. All this data is saved locally with Core Data. All the saved spots are shown on the map with pins and if the user selects it he can see his review of the place or get distance, time estimation and directions to the place. On the second tab all the saved data is listed in a collection view and the data is ordered by closest to the user.

This is the first version where data is saved locally and my idea is to use Firebase in order to make it a social platform where parents can help each other.
