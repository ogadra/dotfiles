{ ... }:
{
  system.defaults.trackpad = {
    # Tap to click
    Clicking = false;

    # Tap to drag
    Dragging = false;

    # Drag lock
    DragLock = false;

    # Two-finger tap or click as a right click
    TrackpadRightClick = true;

    # Right click in a corner: 0=disabled, 1=bottom left, 2=bottom right
    TrackpadCornerSecondaryClick = 0;

    # Force click
    ForceSuppressed = true;

    # Haptic feedback
    ActuateDetents = false;

    # Click sound: 0=silent, 1=normal
    ActuationStrength = 0;

    # Click pressure: 0=light, 1=medium, 2=firm
    FirstClickThreshold = 0;

    # Force click pressure: 0=light, 1=medium, 2=firm
    SecondClickThreshold = 0;

    # Momentum scrolling
    TrackpadMomentumScroll = true;

    # Two-finger pinch to zoom
    TrackpadPinch = true;

    # Two-finger rotate
    TrackpadRotate = true;

    # Two-finger double tap for smart zoom
    TrackpadTwoFingerDoubleTapGesture = false;

    # Two-finger swipe from the right edge: 0=disabled, 3=notification center
    TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;

    # Three-finger tap: 0=disabled, 2=look up
    TrackpadThreeFingerTapGesture = 0;

    # Three-finger drag
    TrackpadThreeFingerDrag = false;

    # Three-finger horizontal swipe: 0=disabled, 1=switch pages, 2=switch full-screen apps
    TrackpadThreeFingerHorizSwipeGesture = 2;

    # Three-finger vertical swipe: 0=disabled, 2=Mission Control / App Expose
    TrackpadThreeFingerVertSwipeGesture = 2;

    # Four-finger horizontal swipe: 0=disabled, 2=switch full-screen apps
    TrackpadFourFingerHorizSwipeGesture = 2;

    # Four-finger pinch: 0=disabled, 2=spread for the desktop and pinch for Launchpad
    TrackpadFourFingerPinchGesture = 0;

    # Four-finger vertical swipe: 0=disabled, 2=Mission Control / App Expose
    TrackpadFourFingerVertSwipeGesture = 0;
  };

  system.defaults.NSGlobalDomain = {
    # Force click
    "com.apple.trackpad.forceClick" = false;

    # Trackpad tracking speed
    "com.apple.trackpad.scaling" = 3.0;
  };
}
