# SeaWorldARExperience

## Installation

### Using Cocoapods

Simply add the following lines to your podfile

```
pod 'SCNVideoWriter', :git => 'https://github.com/Papercloud/SCNVideoWriter.git'
pod 'Spine', :git => 'https://github.com/json-api-ios/Spine.git'
pod 'SeaworldARFramework', :git => 'https://github.com/Papercloud/SeaWorldARExperience.git'
```

## Syncing animations

The `FetchAnimViewController` Class can handle syncing entirely however it's not pretty, you may prefer to implement a view controller around the `SeaworldSyncEngine` yourself.

Set it's `NetworkController` to the one provided by SeaWorldARExperience and implement the `percentageCompleteWasUpdated` block and call sync
```
 syncEngine.syncAnimations(completion: { result in
            //handle result
        })
        
        syncEngine.percentageCompleteWasUpdated = {
            //handle percentage complete
        }
```

### SyncResult
Each SyncResult contains a list of all the operations its performed, as well as an error field that will be filled if the syncEngine fails at the bulk operation stage. ie bad implementation of fetchRequiredOperations.

The results field is a record of each operations result,it is keyed by the name of animation. Each keys value is a `Result<URL?,SyncError>`. If the operation is a deletion operation the url will be nil otherwise the url will point to the local location of the animation.

## NetworkController

`NetworkController` will allow you access to the bswarm animation api.

It has two main methods
```
/// Fetches a list of all Markers for Seaworld
///
/// - Parameter result: result is either a list of markers or the error that occurred
public func allMarkers(result: @escaping ((Result<([Marker]), SpineError>) -> ()))

/// Fetches a list of all animation's names from the backend
///
/// - Parameter result: result is either a list of names or the error that occurred
public func allAnimations(result: @escaping ((Result<([RemoteAnimation]), SpineError>) -> ()))
```

These methods will allow you to get a list of Marker objects as well as a list of all animation objects.

Please only keep one instance of NetworkController alive at a time.


## DisplayAnimationViewController

DisplayAnimationViewController is provided to make displaying animations as easy as possible. Simply pass through the animation file name
```
let vc = DisplayAnimationViewController.instance()
vc.animationId = self.animations[indexPath.row].animationFileName
```
There is an example of this in `ViewController` of the demo project


## Manually Displaying animations 

As is shown in the `DisplayAnimationViewController` in the demo projects, displaying animations should be simple.

Set a view to be a `AnimationView` and then call `start`

SeaWorldARExperience also provides a convienience method for displaying the animation purely of the id received as `displayFromDefaultDirectory(_ id:String)`
This will cause the animation chosen to be displayed

## Capture

Calling `func screenshot() -> UIImage?` at any time will result in a UIImage representation of the view.

Alternatively you can record the view with
`public func startRecording()`
and finish the recording with
`public func stopRecording(completion:@escaping ((URL) -> ()))`
this will result in a completion being called with a local url of the video saved to the temp directory.

You can also check if its currently recording using the flag `isRecording`

