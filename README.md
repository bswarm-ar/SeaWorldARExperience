# SeaWorldARExperience

## Installation

### Using Cocoapods

Simply add the following lines to your podfile

```
pod 'SCNVideoWriter', :git => 'https://github.com/Papercloud/SCNVideoWriter.git'
pod 'Spine', :git => 'https://github.com/Papercloud/Spine.git'
pod 'SeaworldARFramework', :git => 'https://github.com/Papercloud/SeaWorldARExperience.git'
```

### Warning
Both Spine and SCNVideoWriter are 3.2 currently, if you're not using the latest cocoapods the installation will set them to match the project swift version. To fix this add 
```
post_install do |installer|
    # Temporary workaround for old pods - whilst CocoaPods 1.4.0 has support for Swift-Versions
    installer.pods_project.targets.each do |target|
        if ['Spine', 'BrightFutures'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
```
 to the bottom of your podfile

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

## Displaying animations 

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