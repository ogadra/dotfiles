{ ... }:
{
  system.defaults.trackpad = {
    # Tap to click
    Clicking = false;

    # Tap to drag
    Dragging = false;

    DragLock = false;

    # Two-finger tap or click as a right click
    TrackpadRightClick = true;

    # 0=disabled, 1=bottom left, 2=bottom right
    TrackpadCornerSecondaryClick = 0;

    # Force click
    ForceSuppressed = true;

    # Haptic feedback
    ActuateDetents = false;

    # 0=silent, 1=normal
    ActuationStrength = 0;

    # 0=light, 1=medium, 2=firm
    FirstClickThreshold = 0;

    # 0=light, 1=medium, 2=firm
    SecondClickThreshold = 0;

    TrackpadMomentumScroll = true;

    # Two-finger pinch to zoom
    TrackpadPinch = true;

    TrackpadRotate = true;

    # Smart zoom
    TrackpadTwoFingerDoubleTapGesture = false;

    # Swipe in from the right edge: 0=disabled, 3=notification center
    TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;

    # 0=disabled, 2=look up
    TrackpadThreeFingerTapGesture = 0;

    TrackpadThreeFingerDrag = false;

    # 0=disabled, 1=switch pages, 2=switch full-screen apps
    TrackpadThreeFingerHorizSwipeGesture = 2;

    # 0=disabled, 2=Mission Control / App Expose
    TrackpadThreeFingerVertSwipeGesture = 2;

    # 0=disabled, 2=switch full-screen apps
    TrackpadFourFingerHorizSwipeGesture = 2;

    # 0=disabled, 2=spread for the desktop and pinch for Launchpad
    TrackpadFourFingerPinchGesture = 0;

    # 0=disabled, 2=Mission Control / App Expose
    TrackpadFourFingerVertSwipeGesture = 0;
  };

  system.defaults.NSGlobalDomain = {
    "com.apple.trackpad.forceClick" = false;

    # Tracking speed
    "com.apple.trackpad.scaling" = 3.0;
  };
}
