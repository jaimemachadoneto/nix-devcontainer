# default.nix
{ lib
, writeShellApplication
, fzf
, bat
}:
(writeShellApplication {
  name = "findin";
  runtimeInputs = [ fzf bat ];
  text = builtins.readFile ./myfindin;
})
  // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
