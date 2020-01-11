{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-date = true;
    };
    "org/gnome/desktop/calendar".show-weekdate = true;
    "org/gnome/desktop/wm/preferences".resize-with-right-button = true;
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>c"];
      switch-to-workspace-down = ["<Super>j"];
      switch-to-workspace-up = ["<Super>k"];
      move-to-workspace-down = ["<Super><Shift>j"];
      move-to-workspace-up = ["<Super><Shift>k"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      switch-to-workspace-7 = ["<Super>7"];
      switch-to-workspace-8 = ["<Super>8"];
      switch-to-workspace-9 = ["<Super>9"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      move-to-workspace-5 = ["<Super><Shift>5"];
      move-to-workspace-6 = ["<Super><Shift>6"];
      move-to-workspace-7 = ["<Super><Shift>7"];
      move-to-workspace-8 = ["<Super><Shift>8"];
      move-to-workspace-9 = ["<Super><Shift>9"];
    };
    "org/gnome/terminal/legacy".default-show-menubar = false;
    "desktop/ibus/general".preload-engines = [ "mozc-jp" "xkb:us:altgr-intl:eng" ];
  };
}
