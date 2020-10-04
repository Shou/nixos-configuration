{ pkgs ? import <nixpkgs> {}
}:

pkgs.runCommand "kill-bluez" {
  buildInputs = with pkgs; [ killall ];
} ''
  mkdir -p $out/bin

  cat <<-EOF > $out/bin/kill-bluez
  #!/bin/sh
  systemctl restart bluetooth && killall pulseaudio
  EOF

  chmod +x $out/bin/kill-bluez
''
