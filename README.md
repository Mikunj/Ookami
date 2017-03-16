Ookami
===================
An iOS show tracking app which uses Kitsu.io as a backend

## Requirements

 - Xcode 8
 - iOS 9

## Setup

#### Requirements

 - [Cocoapods](https://guides.cocoapods.org/using/getting-started.html)
 - [Cocoapod-Keys](https://github.com/orta/cocoapods-keys)
 - Kitsu.io client key + secret

To setup either clone or download the repo. After `cd` to the repo folder and type:

    pod install
While installing the Cocoapod-Keys plugin will ask you to enter `KitsuClientKey` and `KitsuClientSecret`. Enter the client key and secret respectively.

## Deploying

**Note:** This section is useful only if you are going to submit the app to the Appstore. Please follow the MIT License guidelines if you do decide to publish the app.

**Author Note: Please do not publish the app as-is on the Appstore, make some modifications that will allow people to be able to distinguish the apps.**

This project uses [fastlane](https://fastlane.tools/) for deploying to App store or TestFlight.
However a few things will need to be changed if you decide to build your own version.

#### Requirements
 - [fastlane](https://fastlane.tools/)
 - Apple developer account

Make sure your developer account is valid (has subscription) before attempting to deploy the app.

1. Change the app indentifier from `com.mikunjvarsani.Ookami` to another unique identifier. This can be done easily by opening the project in Xcode and changing it in the project settings. This is to ensure that the app is treated as a whole new unique app.
2. Run `fastlane init` in the project directory and follow the prompts. After completion an `Appfile` will be created with all the necessary information.
3. Copy the contents of `Template-Fastfile` to the newly generated `Fastfile`
4.  run `fastlane deliver init` which will create a `Deliverfile`. A Template `Deliverfile` has been provided, copy the contents of it and paste it in the new `Deliverfile`. Edit the values accordingly.
5.  Finally run `fastlane provision` to create the app in Developer portal and Itunes Connect.

To deploy the app simply run `fastlane release`.

To deploy it for testing, simply run `fastlane beta` instead.

## Author
Mikunj Varsani

## License
Ookami is available under the MIT license. See the LICENSE file for more info.
