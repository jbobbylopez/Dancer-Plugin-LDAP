package Dancer::Plugin::LDAP;

use Dancer ':syntax';
use 5.010;
use Net::LDAPS;
use Data::Dumper;

our $VERSION = '0.1';

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = {};
  $self->{success} = undef;
  $self->{errorcode} = undef;
  
  bless $self, $class;
  return $self;
}

sub login
{
    my ( $class, $connection_info ) = @_;
    my $ldap_check = _ldap_credentials( $connection_info );

    $class->{success} = success( $ldap_check );
    $class->{errorcode} = errorcode( $ldap_check );

    return $class;
}

sub success
{
    my $class = shift;
    my $errorcode = $class;

    if ( ref($class) )
    {
        $errorcode = $class->{errorcode};
    }

    return 1 if $errorcode == 0;
    return 0;
}

sub errorcode
{
    my $class = shift;
    my $errorcode = $class;

    if ( ref($class) )
    {
        $errorcode = $class->{errorcode};
    }

    return $errorcode;
}

sub _getLDAPConfig
{
    my ( $connection_info ) = @_;
    my $host    = $connection_info->{'host'};
    my $port    = $connection_info->{'port'};
    my $domain  = $connection_info->{'domain'};
    my $timeout = $connection_info->{'timeout'};
    my $user    = $connection_info->{'user'};
    my $pass    = $connection_info->{'pass'};
    my $secure  = $connection_info->{'secure'};

    return ($host, $port, $domain, $timeout, $user, $pass, $secure);
}

sub _ldap_credentials
{
    my ( $connection_info ) = @_;
    my ( $host, $port, $domain, $timeout, $user, $passwd, $secure ) = _getLDAPConfig( $connection_info );

    debug "LDAP User: $user";
    debug "LDAP Host: $host";
    debug "LDAP Port: $port";
    debug "LDAP Domain: $domain";
    debug "LDAP Secure: $secure";


    if ( $user || $passwd )
    {
        my $ldap;

        if ( defined($secure) && $secure == 0 )
        {
            $ldap = Net::LDAP->new( $host,port=>$port, timeout=>$timeout ) or error "ERROR CONNECTING TO LDAP SERVER $@";
        }
        else
        {
            $ldap = Net::LDAPS->new( $host,port=>$port, timeout=>$timeout ) or error "ERROR CONNECTING TO LDAP SERVER $@";
        }

        my $user_domain = $user .'@' .$domain;
        my $mesg = $ldap->bind( $user_domain, password => $passwd );
        $ldap->unbind;

        if ( $mesg->code eq 49 )
        {
            warning "LDAP Authentication Failed for $user";
        }
        elsif ( $mesg->code eq 0 )
        {
            info "LDAP Authentication Successful for $user";
        }

        return $mesg->code;
    }
    else
    {
        return "no arguments received";
    }
}
1;
