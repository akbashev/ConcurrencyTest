<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
     <img src="https://img.shields.io/badge/platforms-ios-brightgreen.svg?style=flat" alt="iOS" />
     <img src="https://img.shields.io/badge/iOS-%3E%3D17.0-brightgreen" alt="iOS version"/>
     <img src="https://img.shields.io/badge/platforms-macos-brightgreen.svg?style=flat" alt="macOS" />
     <img src="https://img.shields.io/badge/macOS-%3E%3D14.0-brightgreen" alt="macOS version"/>
</p>

# ConcurrencyTest

## Requirements
Works on iOS 17 and macOS 14. Just open `ConcurrencyTest.xcodeproj` in `App` folder with Xcode and run the app.

## App
Simple test to check different concurrency strategies in Swift when an app have high CPU load.
Examples are:
* Run on main thread
* Run on custom thread[^1]
* Run on regular async/await
* Run on actor
* Run on actor using worker pool pattern
* High cpu loader is an actor with custom executor[^2]
* Run on actor using worker pool pattern, where each worker is high cpu loader actor with custom executor[^2]

## Results
Screenshots of the app and CPU usage:

<img src="https://github.com/akbashev/ConcurrencyTest/assets/5507330/97a83521-cf52-474a-ae39-fd39d0c5ccaa" width="300">

<img src="https://github.com/akbashev/ConcurrencyTest/assets/5507330/92a951db-56a1-4258-a89a-61256f36fef4" width="400">

On the left it's regular async/actor stuff. It's actually quite heavy and even makes M1 life a bit hard. You can notice it when running an app on macOS and sending app to background and back again.
On the right it's 2 workers with custom threads, it takes longer to run execution, but everything is completely smooth.

[^1]: Custom thread is just a simple wrapper arround `OperationQueue` with `maxConcurrentOperationCount=1`
[^2]: Custom exector uses custom thread to enqueue job.
