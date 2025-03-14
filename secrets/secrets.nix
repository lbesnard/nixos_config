let
  user = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2lrjYana/MjsJoUQEehgsaPRH34Y105ixsVBxJMX6XXMm0O7jtH4/eUqsSTgqO3cpzIPCSd8qy4CJ9u7Hh372SB0WEiunBr0VLa3VjbyG4MfIHkERYOnMh5L7Xb5epHA2wZjvZ2belGTtemgSd4Rc6KIFmeiBMUMg43LOyaBbjysNdJNOJbCwDXor2xz2QjX3K0n91o/Hj377qXo2SgLQ5kInnptQ6O/4+nq22x3af+rEM0HamFHua2zlLBb3r3DVqCNFAUU6dxLQ7LJ9Jt/FVBWZ0rbURkTo2bAFOcmfmmj1dhmCnxP2xKtO69KiX77gcbyHd7W2vfuy0tWpIuU5Q==";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5jsR+dim6hnsEiAP9PP2lIso9ZMk+RBIPhYwkOkVss root@lozdellnixos";
in
{
  "aws_cred.age".publicKeys = [
    user
    system
  ];

  "tailscale_token.age".publicKeys = [
    user
    system
  ];

  "random_secret.age".publicKeys = [ system ];
}
