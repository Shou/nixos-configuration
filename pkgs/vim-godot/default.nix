{ vimUtils
, fetchFromGitHub
, lib
}:

vimUtils.buildVimPlugin rec {
  name = "vim-godot";

  src = fetchFromGitHub {
    owner = "habamax";
    repo = name;
    rev = "326ee7e3c5162a2aa22617f1e0b74ee6d4b4a567";
    sha256 = "0w8v21w5330v29krhhnbzy20rvvkqbv0gk11rzbgm9ggc2i1yp3c";
  };
}
