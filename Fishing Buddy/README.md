# Fishing Buddy Description

Fishing Buddy is a social fishing app. It allows the user to log the location and pertinent details of their catches both in a map and list format.  The user can also see the location of catches that other users have made which are stored in a backend database using Firebase as the database solution

# User Instructions

When Fishing Buddy starts up the user is first presented with the Map View.  They can then navigate to either the List view or the settings using the Tab Bar Controller.  Within the Map View the user will see pins for all of their catches as well as other user's catches. The users catches pins will be of one color while the other's catches will be of another color.  The desired pin colors can be changed via the settings tab. 

Viewing details of a catch:
    To view the details of a particular catch the user simply taps the desired pin.

Adding a new catch:
    1. To add a new catch the user taps the plus symbol in the toolbar at the top of the page
    2. The user is then presented with a page where the catch can be located on the map and details provided
    3. The catch location pin on the presented map is automatically shown at the user's currrent location but can be moved to a new location by holding the pin and dragging.
    4. Once the pin location is satisfactory the other details of the catch can be filled in by using the provided picker views.  If the user desires to share their catch to the Firebase database so others can view it then the share switch should be selected.
    5. Once everything is complete the user taps the Save button and the catch is added to the map view as well as posted to the Firebase database.

List View:
    1. To view catches in list format the user taps the List tab on the bottom. The table view is presented and catches are grouped into sections by "My Catches" and "Other User's Catches"  
    2. To refresh the list and pull the most recent catch information the user taps the refresh button on the left of the toolbar.
    3. To delete a catch the user swipes left on the desired catch. Note that only catches shown in the 'My Catches' section can be deleted.
    4. To add a catch, tap the plus symbol on the right side of the toolbar. The add catch view is presented and the catch should be added per the instructions in the previous section.

Settings:
    On the settings tab the user can select settings for the desired pin colors for user catches as well as other's catches.  In addition the user can select whether they want their location displayed on the map view.'

