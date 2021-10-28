# Eventr-App

# [App functionality showcase](https://youtu.be/hRAXYQlB8f4)

# Completed features

* User input validation using regular expressions
* User SignIn and SignUp done through Firebase
* Event creation, editing, deletion and fetching done through Firestore
* Determining at app launch what controller should be the root based on whether a user is signed in or not
* Navigation between controllers through a Tab Bar Controller
* Presenting an alert sheet on tapping an event cell with the options of editing and deleting the selected event (Manage Events tab)
* Splitting the area specific and joined events in Browse Events tab using Segmented Control
* Communicating event participation changes between segment controllers
* Map View with address annotations
  * Controlls toggled on/off based on the controller user is accessing the map from
  * Current location displayed if location services enabled and authorization granted by user (otherwise an alert with information regarding the use of location services presented to user)
* Address search from user provided query
* Displaying activity indicators for the duration of network reliant actions
* Getting the location for event fetch through an alert
  * Using either a user provided string or device location based on the selected alert action
* Settings panel based on segmented Table View
  * Interactable cells displaying current values of user profile properties (excluding password)
  * On tapping the accessory button an alert for editing the selected property gets presented (performing the change requires the user to provide current password)
* Replace the detail disclosure in setting cells with a custom button using delegation for alert presentation

# To Do

* Limiting the number of documents per fetch and paginating the Table View
* Archiving events
* Displaying participants in event cells
* Implementing app specific local settings
* Password reset view
* Filtering fetched events by different parameters
* Deleting all events made by the user on account deletion
* Sending all event participants notifications
  * On change of any event field
  * At set amount of time before event takes place
 
