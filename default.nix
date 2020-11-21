with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    maven
    awscli2
    awsebcli
    terraform_0_13
  ];
}
