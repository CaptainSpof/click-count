with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    maven
    awsebcli
  ];
}
