package Buckets;

use strict;
use warnings;
use Data::Dumper;    # just for debugging
use DateTime;
#use Time::HiRes qw(gettimeofday tv_interval usleep);

use vars qw($VERSION @EXPORT @EXPORT_OK @ISA);
$VERSION = "0.1";

BEGIN {
	require Exporter;
	@ISA       = qw(Exporter);
	@EXPORT    = ();
	@EXPORT_OK = ();
}

sub new {
	my $class = shift;
	my $self  = {
#		_target => shift,
#		_create => shift || 0,
		buckets	=> {},
		debug   => 0,
	};

	bless $self, $class;

	# boilerplate
	return $self;
}

sub add {
	my ( $obj, @items ) = @_;
	die "not a ref" unless ref $obj;

	foreach my $item (@items) {
		# is it a valid item?
		die "no when" unless defined $item->{when};
		my $when = $item->{when};
		die "bad when" unless $when =~ /^\d+(\.\d+)?/;

		die "no what" unless defined $item->{what};
		my $what = $item->{what};
		die "bad what" unless $what =~ /^\d+(\.\d+)?/;

		# does it need a new bucket?
		my $last_minute = $obj->last_minute();
		my $when_obj = DateTime->new(epoch => $when);
		die "bad when obj" unless defined $when_obj;
	die "unimplemented add()";    # TODO: implement something

		$obj->bucket_maintenance(); # keep everything where it belongs
	}
}

sub bucket_maintenance {
	my ( $obj ) = @_;
	die "not a ref" unless ref $obj;
	die "unimplemented bucket_maintenance()";    # TODO: implement something
}

sub last_minute {
	my ( $obj ) = @_;
	die "not a ref" unless ref $obj;
	return undef unless defined $obj->{buckets}->{minute};

	my $minutes = $obj->{buckets}->{minute};

	my $max = 0;
	foreach my $m (keys %$minutes) {
		$max = $m if $m > $max;
	}
	return $max;
}

sub summarize {
	my ( $obj ) = @_;
	die "not a ref" unless ref $obj;
	die "unimplemented add()";    # TODO: implement something
}

#
# utility functions
#

sub format_seconds {
	my ($raw_seconds) = @_;
	return sprintf( "%.8f", $raw_seconds );
}


1;

__END__

=head1 NAME

Buckets - bucket time series data

=head1 SYNOPSIS

   use Buckets;


   my $qps_bucket = new Buckets();

   $qps_bucket->add({
       when => time,
       what => rand(10),
   });

   my $summary = $qps_bucket->summarize();

=head1 DESCRIPTION

Keep a history of some value in buckets.

=head2 ITEMS

Items are passed around as hash references.
One requried field is C<when> which contains the time of the event in UNIX seconds.
Another requried field is C<what> which contains the numeric value being tracked.


=head2 METHODS

=head3 new

Create a new object.  Takes no arguments yet.

=head3 add

Add an item.  See L</ITEMS> for fields in the item.

=head3 summarize

Get a summary of the bucket for various time periods.
Returns a hashref with C<minute>, C<hour>, C<day>, C<week>, and C<older>.


=head1 TODO

=over 4

=item * make it work

=item * write some tests

=back

=head1 SEE ALSO

Manpages: 

=head1 AUTHOR

Christopher Hicks E<lt>chicks.net@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Christopher Hicks

This software is licensed under the same terms as Perl.
