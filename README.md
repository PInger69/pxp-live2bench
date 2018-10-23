# Avoca My Play-by-Play Live2Bench

This codebase implements the Avoca mypXp Live2Bench iPad app. 

mypXp Live2Bench is an iPad app that supports video review of filmed events -- primarily
sports events, but other events such as medical procedures and the like are valid as well.

## Getting Started

The codebase has been updated to support CocoaPods. To get the code going:

1. Install CocoaPods, using the [instructions](https://guides.cocoapods.org/using/getting-started.html) on the CocoaPods website.
2. Check out the code from git.
3. In the project base directory, run the `pod install` command.
4. Open the `Live2Bench.xcworkspace` workspace file in XCode.

Note that when this repository was moved to github, it containined a single binary file that exceeded Github's 100mb upload limit. Accordingly, the offending file was scrubbed from the repository and will need to be added manually. The filename is 'libavcodec.a' and should be placed in the following directory:
- FBTraining/videokit/3rd-party/ffmpeg/lib/libavcodec.a 
The .gitignore file has been updated to ignore this file, so it will not be included as a new file in your git status output.
