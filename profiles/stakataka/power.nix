{ ... }:
{
  # 電源管理 (pmset)
  # AC電源・バッテリー駆動を問わず、スリープと蓋閉じスリープを無効化し、
  # WiFi接続・バックグラウンド処理を継続させる。
  system.activationScripts.pmset.text = ''
    echo "Applying pmset power management settings..."

    /usr/bin/pmset -a sleep 0
    /usr/bin/pmset -a disksleep 0
    /usr/bin/pmset -a displaysleep 30
    /usr/bin/pmset -a disablesleep 1
    /usr/bin/pmset -a tcpkeepalive 1
    /usr/bin/pmset -a powernap 1
    /usr/bin/pmset -a womp 1
  '';
}
