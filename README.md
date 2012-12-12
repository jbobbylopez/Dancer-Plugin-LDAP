# About

Simple LDAP authentication plugin for Dancer applications

# Installation

    sudo cpan Dancer::Plugin::LDAP

# Documentation

See [Dancer::Plugin::LDAP](https://github.com/jbobbylopez/Dancer-Plugin-LDAP).
After installation, you can view the documentation by running
`man Dancer::Plugin::LDAP` or `perldoc Dancer::Plugin::LDAP`.

# Usage

    use Dancer::Plugin::LDAP;
    
    my $connection_info = {
        host          => 'ldap.example.com',    # LDAP Server FQDN
        port          => '636',                 # LDAP Port
        domain        => 'example.com',         # LDAP Domain
        timeout       => '30',                  # Connection timeout
        user          => 'someuser',            # LDAP Username
        pass          => '$omePa$$',            # LDAP Password
        secure        => 1                      # Use SSL Encrypted Connection
    };
    
    my $LDAP = Dancer::Plugin::LDAP->new();
    $LDAP->login( $connection_info );
    
    if ( $LDAP->success )
    {
        info "Login successful for $connection_info->{user} ";
        info "(error code: " . $LDAP->errorcode ")";
    }
    else
    {
        info "Login failed (error code: " . $LDAP->errorcode ")";
    }
