# The Wheather Station Reader module
package WSR;
use strict;
use warnings;
use LWP::Simple;
use Time::HiRes qw(usleep);


sub new
{
	my $class = shift;
	my $args = shift;
	if ( !exists $args->{url} )
	{
		print "The url was not specified.\n";
		exit;
	}
	
	my $self = {
		'url' => $args->{url},
		'parameter' => '',
		'paramKey' => 'pm',
		'sourceCode' => get($args->{url}),
		'step' => $args->{step} || 10,
	};
	
	if ( !exists $self->{sourceCode} ) {
		print "\e[31mWARNING:\e[0m cannot get the web content.\n";
		exit;
	}
	
	
	bless $self, $class;
	$self->setParameters({parameter => $self->{paramKey}});

	return $self;
}

sub graph
{
	my $self = shift;
	my @values = $self->getValues();
	my @valuesSorted = sort { $a <=> $b } @values;
	my $valuesMin = $valuesSorted[0];
	my $valuesMax = $valuesSorted[ scalar(@valuesSorted) - 1 ];

	my @scale = range($valuesMin, $valuesMax, $self->{step});

	@scale = sort { $b <=> $a } @scale;
	
	my @closest = ();
	foreach my $value ( @values )
	{
		push @closest, closest(\@scale, $value);
	}
	system('clear');
	printChart( \@scale, \@closest, $self->{step}, $self->{paramKey}, $self->{sourceCode} );
}

sub printChart
{
	my ( $scale, $closest, $step, $parameter, $sourceCode ) = @_;
	#system("clear");
	my $scaleMaxValueNoOfDigits = (sort{ $b <=> $a } map { scalar( split("", $_) ) } @$closest )[0];
	
	my $NoOfColumns = @$closest;
	
	#for ( my $i = scalar(@$scale) - 1; $i >= 0; $i-- )
	
	for ( my $i = 0; $i < scalar(@$scale); $i++ )
	{
		print "$$scale[$i]\n";
	}
	
	for ( my $x = 0; $x < $NoOfColumns; $x++ )
	{
		my $xMod = $x + $scaleMaxValueNoOfDigits + 2;
		
		for ( my $y = 0; $y < $step; $y++ )
		{
			my $yMod = $y + 1;
			print "\e[$yMod;$xMod" . "H";
			
			if ( !defined $$scale[$y] ) { print "scale $y\n"; exit }
			if ( !defined $$closest[$x] ) { print "closest $x\n"; exit }
			if ( $$scale[$y] <= $$closest[$x] )
			{
				print "|";
			}
			else
			{
				print " ";
			}
		}
		usleep(20000);
	}
	print "\n" . "=" x 66 . "\n";
	printDescription($parameter);
	printDate($sourceCode);
}

sub printDescription
{
	my $parameter = shift;

	my %availableParameters = (
		'pm' => 'Pył zawieszony [µg/m3] - ostatnie 60 min',
		'rain_sum' => 'Opad dobowy narastająco [mm] - ostatnie 60 min',
		'rain' => 'Intensywność opadu [mm/h] - ostatnie 60 min',
		'wind_max' => 'Prędkość wiatru (max) [km/h] - ostatnie 60 min',
		'wind_direction' => 'Kierunek wiatru [°] - ostatnie 60 min',
		'wind' => 'Prędkość wiatru [km\h] - ostatnie 60 min',
		'pressure_QNH' => 'Ciśnienie zredukowane do poziomu morza [hPa] - ostatnie 60 min',
		'pressure' => 'Ciśnienie atmosferyczne [hPa] - ostatnie 60 min',
		'humidity' => 'Wilgotność względna [%] - ostatnie 60 min',
		'dew_point_temp' => 'Temperatura punktu rosy [°C] - ostatnie 60 min',
		'temp' => 'Temperatura powietrza [°C] - ostatnie 60 min',
	);
	print "$availableParameters{$parameter}\n\n";
}

sub range # the subroutine returns the range of $elements elements bewteen $from and $to
{
	my ($from, $to, $elements) = @_; # $elements - liczba elementów w zakresie określonym przez zmienne $from oraz $to
	my @range = ();
	my $value = ($to - $from) / ($elements - 1);
	my $count = 1;
	my $accuracy = "%.1f";
	$accuracy = "%.2f" if ( $value < 0.1 );
	
	while ( $count < $elements )
	{
		push @range, $from;
		$from += $value;
		$from = sprintf($accuracy, $from);
		$count++;
	}
	push @range, $to;
	return @range;
}

sub closest # the subroutine returns the value from the array that is closest to the checking value
{
	my ($ref, $val) = @_; # $ref - reference to the array of values; $val - the value
	my %min = ();
	foreach my $value ( @$ref )
	{
		my $diff;
		if ( $value < $val )
		{
			$diff = $val - $value;
		}
		else
		{
			$diff = $value - $val;
		}
		
		$min{$diff} = $value;
	}
	
	my $minIndex = ( sort { $a <=> $b } keys %min )[0];
	return $min{$minIndex};
}

sub setParameters
{
	my $self = shift;
	my $args = shift;
	
	if ( exists $args->{parameter} )
	{
		my %parametersAll = (
			'pm' => 'pm 10<',
			'rain_sum' => 'Opad dobowy narastaj',
			'rain' => 'Intensywno.. opadu<',
			'wind_max' => 'Pr.dko.. wiatru (max)<',
			'wind_direction' => 'Kierunek wiatru<',
			'wind' => 'Pr.dko.. wiatru<',
			'pressure_QNH' => 'Ci.nienie zredukowane do poziomu morza<',
			'pressure' => 'Ci.nienie atmosferyczne<',
			'humidity' => 'Wilgotno.. wzgl.dna<',
			'dew_point_temp' => 'Temperatura punktu rosy<',
			'temp' => 'Temperatura powietrza<',
		);
		
		if ( !exists $parametersAll{ $args->{parameter} } )
		{
			print "The parameter - $args->{parameter} - does not exist.\n";
			exit;
		}
		
		$self->{parameter} = $parametersAll{ $args->{parameter} };
		$self->{paramKey} = $args->{parameter};
	}
	
	if ( exists $args->{step} )
	{
		$self->{step} = $args->{step};
	}
}

sub getValues
{
	my $self = shift;

	my @sourceCodeLines = split("\n", $self->{sourceCode});

	my $check = 0;
	my @values = ();
	foreach my $line ( @sourceCodeLines )
	{
		if ( $line =~ /$self->{parameter}/ )
		{
			$check = 1;
		}
		
		if ( $check == 1 )
		{
			if ( $line =~ /values/ )
			{				
				$line =~ s/[^\d\.,]//g;
				push @values, split(",", $line);
				last;
			}
		}
	}
	
	return @values;
}

sub printDate
{
	my @sourceCodeLines = split("\n", $_[0]);

	my $date = '';
	foreach my $line ( @sourceCodeLines )
	{
		if ( $line =~ /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\+/ )
		{
			$date = $line;
			$date =~ s/^\s+//g;
		}
	}
	
	print "Data ostatniego pomiaru: $date\n\n";
}

1;
