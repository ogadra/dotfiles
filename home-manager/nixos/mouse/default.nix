{ ... }:
{
  xdg.configFile."kcminputrc".text = ''
    [Keyboard]
    RepeatDelay=200

    [Libinput][1267][12693][ELAN0676:00 04F3:3195 Touchpad]
    NaturalScroll=true
    PointerAcceleration=1.0

    [Libinput][1390][306][ELECOM TrackBall Mouse DEFT Pro TrackBall]
    PointerAcceleration=1.0
  '';
}
