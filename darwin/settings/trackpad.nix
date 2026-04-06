{ ... }:
{
  system.defaults.trackpad = {
    # タップでクリック
    Clicking = false;

    # タップでドラッグ
    Dragging = false;

    # ドラッグロック
    DragLock = false;

    # 2本指タップ/クリックで右クリック
    TrackpadRightClick = true;

    # コーナーで右クリック
    # 0=無効, 1=左下, 2=右下
    TrackpadCornerSecondaryClick = 0;

    # 強押しクリックを無効化
    ForceSuppressed = true;

    # ハプティックフィードバック
    ActuateDetents = false;

    # クリック音
    # 0=サイレント, 1=通常
    ActuationStrength = 0;

    # クリックの強さ
    # 0=弱い, 1=中, 2=強い
    FirstClickThreshold = 0;

    # 強押しの強さ
    # 0=弱い, 1=中, 2=強い
    SecondClickThreshold = 0;

    # 慣性スクロール
    TrackpadMomentumScroll = true;

    # 2本指ピンチでズーム
    TrackpadPinch = true;

    # 2本指回転ジェスチャー
    TrackpadRotate = true;

    # 2本指ダブルタップでスマートズーム
    TrackpadTwoFingerDoubleTapGesture = false;

    # 2本指で右端からスワイプ
    # 0=無効, 3=通知センター
    TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;

    # 3本指タップ
    # 0=無効, 2=調べる
    TrackpadThreeFingerTapGesture = 0;

    # 3本指ドラッグ
    TrackpadThreeFingerDrag = false;

    # 3本指横スワイプ
    # 0=無効, 1=ページ切替, 2=フルスクリーンアプリ切替
    TrackpadThreeFingerHorizSwipeGesture = 2;

    # 3本指縦スワイプ
    # 0=無効, 2=Mission Control / App Expose
    TrackpadThreeFingerVertSwipeGesture = 2;

    # 4本指横スワイプ
    # 0=無効, 2=フルスクリーンアプリ切替
    TrackpadFourFingerHorizSwipeGesture = 2;

    # 4本指ピンチ
    # 0=無効, 2=開くとデスクトップ / 閉じるとLaunchpad
    TrackpadFourFingerPinchGesture = 0;

    # 4本指縦スワイプ
    # 0=無効, 2=Mission Control / App Expose
    TrackpadFourFingerVertSwipeGesture = 0;
  };
}
