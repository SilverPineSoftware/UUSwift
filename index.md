Useful Utilities is a collection of helper classes that extend or complement existing UIKit framework classes. UUSwift has been used in hundreds of shipping macOS and iOS apps.

UUSwift brings together into one package several sub-packages, specifically:
- [UUSwiftCore](https://github.com/SilverPineSoftware/UUSwiftCore)
- [UUSwiftNetworking](https://github.com/SilverPineSoftware/UUSwiftNetworking)
- [UUSwiftImage](https://github.com/SilverPineSoftware/UUSwiftImage)
- [UUSwiftUX](https://github.com/SilverPineSoftware/UUSwiftUX)

# Installation

### Swift Package Manager

UUSwift has native SPM support. The individual sub-projects are also part of the [Swift Package Index](https://swiftpackageindex.com) project:
- [UUSwiftCore](https://swiftpackageindex.com/SilverPineSoftware/UUSwiftCore)
- [UUSwiftNetworking](https://swiftpackageindex.com/SilverPineSoftware/UUSwiftNetworking)
- [UUSwiftImage](https://swiftpackageindex.com/SilverPineSoftware/UUSwiftImage)
- [UUSwiftUX](https://swiftpackageindex.com/SilverPineSoftware/UUSwiftUX)

### Carthage

UUSwift may also be installed via [Carthage](https://github.com/Carthage/Carthage). To install it, simply add the following line to your `Cartfile`:

```
github "SilverPineSoftware/UUSwift"
```

Then, following the instructions for [integrating Carthage frameworks into your app](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos), link the `UUSwift` framework into your project.

## Requirements

This library requires a deployment target of iOS 10.0 or greater or OSX 10.10 or greater.
UUSwift currently supports Swift version 4.0 

## Contributing

Please **open pull requests against the `develop` branch**

## Swift

UUSwift is written entirely in Swift and currently does not support Objective-C interoperability.

## Inspiration

UUSwift is an updated implementation of the Objective-C classes available here:
[https://github.com/cheesemaker/toolbox](https://github.com/cheesemaker/toolbox)

## License

UUSwift is available under the MIT license. See [`LICENSE.md`](https://github.com/SilverPineSoftware/UUSwift/blob/master/LICENSE.md) for more information.

## Contributors

[A list of contributors is available through GitHub.](https://github.com/SilverPineSoftware/UUSwift/graphs/contributors)
