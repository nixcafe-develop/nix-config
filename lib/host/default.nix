{
  # default vars
  host = {
    # Your name
    name = "example";
    # Your real name (currently used as git name)
    realName = "example";
    # Your email
    email = {
      address = "demo@example.com";
      # smtp.host = "smtp.example.com";
      # imap.host = "imap.example.com";
    };
    # If you want git to use gpg, you can fill in the key id here
    signKey = "";
    # Fill in the key that all your hosts trust.
    # Note that they have large permissions and need to be saved offline.
    authorizedKeys.keys = [ ];
    # starship config, see: https://starship.rs/config/
    starship.settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
  };
}
