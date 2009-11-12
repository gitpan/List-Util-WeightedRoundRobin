package List::Util::WeightedRoundRobin;

$VERSION = 0.1;

use strict;


sub new {
    my $class = shift;

    my $self = {
        weighted_list   => [],
    };
    bless $self, $class;

    return( $self );
};


sub initialize_sources {
    my $self = shift;
    my $sources = shift;

    # The weighting of one source is a list 
    # containing only that source
    if( @{$sources} == 1 ) {
        $self->{weighted_list} = [ $sources->[0]->{name} ];
        return( 1 );
    };

    $sources = $self->_reduce_and_sort_weightings( $sources );

    foreach my $source ( @{$sources} ) {
        my $total_weight = scalar @{$self->{weighted_list}};
        my $frequency = $total_weight / $source->{weight};

        # If we haven't yet added elements, add all of the first source
        unless( $total_weight ) {
            for( my $count = 0; $count < $source->{weight}; $count++ ) {
                push @{$self->{weighted_list}}, $source->{name};
            };
            next;
        };

        for( my $count = $source->{weight}; $count > 0; $count-- ) {
            my $tmp = sprintf( "%.f", $count * $frequency );
            splice( @{$self->{weighted_list}}, $tmp, 0, $source->{name} );
        };

    };

    return( 1 );
};


sub get_list { return( $_[0]->{weighted_list} ) };


sub _reduce_and_sort_weightings {
    my $self = shift;
    my $sources = shift;

    my @weights = ();

    foreach my $source ( @{$sources} ) {
        push @weights, $source->{weight};
    };   

    my $common_factor = multigcf( @weights );

    my $sorted_sources = [];

    foreach my $source ( sort sort_weights_descending(@{$sources}) ) {
        $source->{weight} /= $common_factor;
        push @{$sorted_sources}, $source;
    };   

    return( $sorted_sources );
};


sub sort_weights_descending { $a->{weight} <=> $b->{weight}; };


# Taken from: http://www.perlmonks.org/?node=greatest%20common%20factor
sub gcf {
    my ($x, $y) = @_;
    ($x, $y) = ($y, $x % $y) while $y;
    return $x;
}

sub multigcf {
    my $x = shift;
    $x = gcf($x, shift) while @_;
    return $x;
};

1;