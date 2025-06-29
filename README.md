# BearTalk

A comprehensive iOS app for controlling and monitoring Lucid vehicles.

## Features

- Real-time vehicle state monitoring
- Remote vehicle control (locks, climate, charging, etc.)
- Apple Watch companion app
- Widget support
- Vehicle location tracking
- Efficiency statistics
- Multiple vehicle support

## Watch App Syncing

The Apple Watch app syncs with the iPhone app to display vehicle state and allow remote control. The syncing has been improved with:

### Improvements Made

1. **Robust Retry Logic**: The watch app now retries failed credential and vehicle state requests
2. **Better Error Handling**: More comprehensive error handling and logging
3. **Proactive Syncing**: The phone app proactively sends vehicle state to the watch
4. **Periodic Sync**: The watch app periodically requests updates every 30 seconds
5. **Manual Refresh**: Users can manually refresh vehicle state by tapping the refresh button
6. **Improved Startup Sequence**: Better timing and coordination during app startup

### Troubleshooting Watch Sync Issues

If the watch app stops syncing:

1. **Check Connectivity**: Ensure both devices are connected and the watch app is installed
2. **Restart Apps**: Force quit and restart both the iPhone and watch apps
3. **Manual Refresh**: Tap the refresh button (circular arrow) in the watch app
4. **Check Logs**: Look for connectivity messages in the Xcode console
5. **Reboot Devices**: As a last resort, restart both devices

### Debug Information

The watch app logs detailed information about:
- Session state (paired, installed, reachable)
- Credential requests and responses
- Vehicle state requests and responses
- Error conditions and retry attempts

Look for these log messages in Xcode console to diagnose issues:
- `WatchConnectivityManager: Session state`
- `VehicleViewModel: Starting setup process`
- `WatchConnectivityManager: Requesting credentials from phone`
- `WatchConnectivityManager: Requesting vehicle state from phone`

## Development

### Requirements

- iOS 17.0+
- watchOS 10.0+
- Xcode 15.0+
- Swift 5.9+

### Setup

1. Clone the repository
2. Open `BearTalk.xcodeproj` in Xcode
3. Configure your development team and bundle identifiers
4. Build and run

### Architecture

The app uses:
- SwiftUI for the user interface
- SwiftData for local data persistence
- WatchConnectivity for iPhone-Watch communication
- GRPC for API communication with Lucid servers
- SceneKit for 3D vehicle visualization

## License

[Add your license information here]
