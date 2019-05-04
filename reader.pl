use strict;
use warnings;
use Getopt::Long;
use lib '.';
use WSR;

my $param = "Parameter";
my $desc = "Parameter description";
my $parameter = '';
my $scaleElements = 10;
my $help = 0;
my @availableParametersKeys = qw/pm rain_sum rain wind_max wind_direction wind pressure_QNH pressure humidity dew_point_temp temp/;
my %availableParameters = (
	'pm' => 'pm 10 [µg/m3]',
	'rain_sum' => 'total rain [mm]',
	'rain' => 'rain intensity [mm/h]',
	'wind_max' => 'max wind speed [m/s]',
	'wind_direction' => 'wind direction [°]',
	'wind' => 'wind speed [m/s]',
	'pressure_QNH' => 'atm. pressure reduced to the sea level [hPa]',
	'pressure' => 'atm. pressure [hPa]',
	'humidity' => 'relative humidity [%]',
	'dew_point_temp' => 'dew point temperature [°C]',
	'temp' => 'air temperature [°C]',
);


GetOptions(
	"parameter=s" => \$parameter,
	"scale=s" => \$scaleElements,
	"help" => \$help,
) or die help();

format OUT_DESC =
@<<<<<<<<<<<<< | @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$param, $desc
==============================================================
.

format OUT =
@<<<<<<<<<<<<< | @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$param, $desc
.

if ( $parameter eq '' or $help == 1 )
{
	help();
	exit;
}

sub help
{
	print "Usage:\n\n$0 --parameter [parameter name] --scale [number of scale ticks, default=10]\n\n";
	print "Available parameters:\n\n";


	$~ = "OUT_DESC";
	write;
	$~ = "OUT";

	foreach my $key ( @availableParametersKeys )
	{
		$param = $key;
		$desc = $availableParameters{$key};
		write;
	}
	print "\n";
}

$| = 1;
my $address = 'http://meteo.ftj.agh.edu.pl/meteo/';


my $pogoda = WSR->new({url => $address, step => $scaleElements});
#my @values = $pogoda->getValues();
#print join(", ", @values);
$pogoda->setParameters({ parameter => $parameter });
$pogoda->graph();
#$pogoda->printChart();
