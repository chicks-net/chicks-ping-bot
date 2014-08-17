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

	my $count = 0;

	foreach my $item (@items) {
		# is it a valid item?
		die "no when" unless defined $item->{when};
		my $when = $item->{when};
		die "bad when" unless $when =~ /^\d+(\.\d+)?/;

		die "no what" unless defined $item->{what};
		my $what = $item->{what};
		die "bad what" unless $what =~ /^\d+(\.\d+)?/;

		my $when_obj = DateTime->from_epoch(epoch => $when);
		die "bad when obj" unless defined $when_obj;

		# add it
		my $when_minute = minute_start($when);
		push(@{ $obj->{buckets}->{minute}->{$when_minute} },$item);
		$count++;
	}

	$obj->bucket_maintenance(); # keep everything where it belongs

	return $count;
}

sub bucket_maintenance {
	my ( $obj ) = @_;
	die "not a ref" unless ref $obj;
	die "unimplemented bucket_maintenance()";    # TODO: implement something
}

sub minute_start {
	my ( $time ) = @_;
	die "class methods should not get a ref" if ref $time;

	my $time_obj = DateTime->from_epoch(epoch => $time);
	my $seconds = $time_obj->second();
	$time_obj->subtract(seconds => $seconds);
	return $time_obj->epoch();
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

Add an item.  See L</ITEMS> for fields in the item.  Returns the number of items added.

=head3 summarize

Get a summary of the bucket for various time periods.
Returns a hashref with C<minute>, C<hour>, C<day>, C<week>, and C<older>.

=head2 BUCKETS

Buckets should not need to be accessed directly, but 
this is how the data is stored.

C<minute> buckets are keyed by the epoch time for the beginning of the minute.
C<minute> buckets contain individual results that occurred within that minute.

C<hour> buckets contain summaries of every minute within the hour.  They are keyed by
the epoch time of the beginning of the hour.

C<day> buckets contain summaries of every hour within the day.  They are keyed by
the epoch time of the beginning of the day.

C<week> buckets contain summaries of every day within the week.  They are keyed by
the epoch time of the beginning of the week.

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
