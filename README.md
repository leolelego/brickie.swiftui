
> Brickie is searching minifigs to help improve the app. I'm currently not really available and I can be able to validate and checks PR but I have less time to improve the app itself. So if you love SwiftUI and bricks, feel **free to add your own touch to the app!**


# Brickie: The BrickSet Companion for iOS

Brickie is an iOS application powered by the BrickSet API which permits to manage your Lego of sets and minifigures collection. 

## Open Source, Technologies and Privacy

As this project is a side project I decided to use the last tech made by Apple (2020) to do it. So it's full of SwiftUI, Combine and SDKs are powered by Swift Package Manager. 

This project is Open source and I will love you to give me help to imporve this app. If you knows some Swift and iOS things, feel free to fork and make any PR! I will review them with pleasure. 
Please don't copy this app, I do open-source to offert something to LEGO fans like me, the app is free, so help to make it awesome! 

You don't know sh*t about iOS, no worries, tell me any ideas you have thought a **Github Issue** and I will do my best if it's revelant!

### Download the app

- Download the app on the [App Store](https://apps.apple.com/gb/app/brickie-brickset-companion/id1512743668)
- Participate by beta testing using [TestFlight](https://testflight.apple.com/join/9IE197Mt) (available)

### Privacy Policy

**We do not collect any of your data**. The only data collected is collected from within the app itself and only stored locally like your owned and wanted sets/figs. 
We don't dislay any ads or send anything to any server. So we don't track you using an advertising identifier or anything. 

### Screenshots

![Home](https://www.dropbox.com/s/01rb1io6bh8f5e0/1%20-%20home.png?raw=1)
![Home](https://www.dropbox.com/s/xr5651otlmkma2y/2%20-%20set%20detail.png?raw=1)


## How to Compile and Run

#### Pre-requisits

- a macOS Big Sure 
- Xcode 13 Minimum
- an account at [BrickSet](https://brickset.com) and [request an API key](https://brickset.com/tools/webservices/v3)
- an Apple Developer Account (even Free) 

#### Build

- clone the project
- add a `Secrets.xcconfig` file at this path : `./sources/assets` with the following content

```
BRICKSET_API_KEY = MyKey
```

 - change the bundle and the signing team in Xcode
 - wait that all the Swift Package are downloaded or force in Xcode via `File -> Swift Packages -> Resolve Package Version`
 - run baby! 🦄
 
 
## Credits and Thanks

Thanks first to **BrickSet** and Huw for is support in this implementation. Thanks to Will from HMWK Family for it helps and Apple Account. 
