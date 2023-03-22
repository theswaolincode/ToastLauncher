# Toast Launcher
> This package will delight you with freshly baked toasts 🍞

## Table of Contents
* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Features](#features)
* [Example Video](#example-video)
* [Setup](#setup)
* [Usage](#usage)
* [Project Status](#project-status)
* [Room for Improvement](#room-for-improvement)
* [Acknowledgements](#acknowledgements)
* [Contact](#contact)
* [License](#license)

## General Information
- Toast Launcher is a package that will make easy presenting overlay views from any point of the screen
- It reunites all the posible scenarios when presenting this type os views such as popovers, toasts, ect..
- I created this to help devs to optimize their time when presenting overlay views

## Technologies Used
- Swift
- SwiftUI
- SPM

## Features
List the ready features here:
- Supports iOS 15
- You might indicate the viewAlignment: Alignment
- You might indicate an animationStart: AnyTransition
- You might indicate an animationEnd: AnyTransition
- The ToastView is an example on how you might create your desired overlay view

## Example Video

https://user-images.githubusercontent.com/7537081/226557157-7d05967f-3bc3-47b9-8669-25b2929f2c73.mp4

## Setup
install this package in XCode as you would normally do using this URL -> https://github.com/imediayala/ToastLauncher

## Usage
As easy as implementing a modifier as you would normally do when presenting sheet, fullScreenCover, ect..

    .toastView(isPresented: $isPresentingView,
                   alignment: viewAlignment,
                   animationStart: animationStart,
                   animationEnd: animationEnd,
                   content: {
            ToastView(style: toastStyle, onDismiss: { dismissToastView() }) })


## Project Status
Project is: _in progress_

## Room for Improvement
Feel 🆓

Room for improvement:
- It might have sense at some ponit to enable dragging views to dismiss

## Acknowledgements
Give credit here.
- This project was inspired by me 😜

## Contact
- Created by [@DanielAyala](https://stackoverflow.com/users/4768370/daniel-ayala)
- You can help me growing my community by following my [github-profile](https://github.com/imediayala)
- Feel free to contact me!


## License
This project is open source and available under the [MIT License]().

