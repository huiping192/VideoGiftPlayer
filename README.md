# VideoGiftPlayer

[![CI Status](https://img.shields.io/travis/huiping192/VideoGiftPlayer.svg?style=flat)](https://travis-ci.org/huiping192/VideoGiftPlayer)
[![Version](https://img.shields.io/cocoapods/v/VideoGiftPlayer.svg?style=flat)](https://cocoapods.org/pods/VideoGiftPlayer)
[![License](https://img.shields.io/cocoapods/l/VideoGiftPlayer.svg?style=flat)](https://cocoapods.org/pods/VideoGiftPlayer)
[![Platform](https://img.shields.io/cocoapods/p/VideoGiftPlayer.svg?style=flat)](https://cocoapods.org/pods/VideoGiftPlayer)

VideoGiftPlayer is simple aplha mp4 player.  Inspire by [Kitsunebi](https://github.com/noppefoxwolf/Kitsunebi).

## Features

- [x]   H264 base and alpha mp4 playback
- [x]   metal support
- [ ]   opengl support
- [x]   Error handling
- [x]   Sound Effect support
- [x]   hevc with alpha video support
- [ ]   alpha mp4 file compression support
- [ ]   custom texture support


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
## Usage


Configure VideoGiftPlayerView.

```swift

import VideoGiftPlayer

class ViewController: UIViewController {
    
    var playerView: VideoGiftPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView = VideoGiftPlayerView()
        
        view.addSubview(playerView)
        
        // autolayout
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
```

Play video effect.


base,alpha mp4
```swift
// local video file only
let baseUrl = Bundle.main.url(forResource: "base", withExtension: "mp4")!
let alphaUrl = Bundle.main.url(forResource: "mask", withExtension: "mp4")!
playerView.play(baseVideo: baseUrl, alphaVideo: alphaUrl)
```

hevc with alpha

```swift
// local video file only
let hevcUrl = Bundle.main.url(forResource: "hevc", withExtension: "mov")!
playerView.play(hevcVideo: hevcUrl)
```

## Requirements

## Installation

VideoGiftPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VideoGiftPlayer'
```

## Author

huiping_guo, huiping192@gmail.com

## License

VideoGiftPlayer is available under the MIT license. See the LICENSE file for more info.
