# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
###API REFERENCE: https://otrs.github.io/doc/api/otrs/stable/Perl/index.html 

##BACKEND VALUE
### /opt/otrs/bin/otrs.Console.pl Maint::Stats::Generate --number 10012 --target-directory /opt/otrs/ --params "Year=2016&Month=07&ToMonth=12&Ticket_Type=1,2,3"

package Kernel::System::Stats::Static::HandlingSQL6;
## nofilter(TidyAll::Plugin::OTRS::Perl::Time)

use strict;
use warnings;
use List::Util qw( first );

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

use Time::Piece;

our @ObjectDependencies = (
	'Kernel::Config',
    'Kernel::Language',
    'Kernel::System::DB',
    'Kernel::System::Time',
	###to calling ticket attributes
	'Kernel::System::Ticket',
	###to calling ticket type attributes
	'Kernel::System::Type',
	###enable it to calling ticket queue attributes 
	#'Kernel::System::Queue',
	###enable it to calling customer user attributes
	#'Kernel::System::CustomerUser',
	
	
	
);

sub new {
    my ( $Type, %Param ) = @_;

    ### allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );
	
	
	return $Self;
}

sub GetObjectBehaviours {
    my ( $Self, %Param ) = @_;

    my %Behaviours = (
        ProvidesDashboardWidget => 0,
    );

    return %Behaviours;
}

sub Param {
    my $Self = shift;
	
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	 
	###define ticket object
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	
	###define ticket type object
	my $TypeObject = $Kernel::OM->Get('Kernel::System::Type');
	
	###enable it to define ticket queue object
	# my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
	
	###enable it to define customer user object
	# my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
	
	###enable it to define dynamic field object
	# my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	# my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	
    # get time object
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

  
	# get current time
    my ( $s, $m, $h, $D, $M, $Y ) = $TimeObject->SystemTime2Date(
        SystemTime => $TimeObject->SystemTime(),
    );
	
	# get current year
    my $SelectedYear  = $M == 1 ? $Y - 1 : $Y;
	# get one month before
    my $SelectedMonth = $M == 1 ? 12     : $M - 1;
	# get current month
	my $SelectedMonth2 = $M == 1 ? 12     : $M - 0;

    # create possible time selections
    my %Year = map { $_ => $_; } ( $Y - 10 .. $Y );
    my %Month = map { $_ => sprintf( "%02d", $_ ); } ( 1 .. 12 );
	my %ToMonth = map { $_ => sprintf( "%02d", $_ ); } ( 1 .. 12 );
	
	###Get a list of ticket type
	my %Ticket_Type = $TypeObject->TypeList(
            Valid => 1,
        );
		
	###Enable it to Get a list of queue	
	# my %Ticket_Queue = $QueueObject->QueueList( 
	# 		Valid => 1,	
	#  	);	
	
	###Enable it to Get a list of customer user (might be depricated)
	# my %List = $CustomerUserObject->CustomerUserList(
    #     Valid => 1, # not required
    # );
		
	###Enable it to Get a specific ticket dynamic field (dropdown) parameter
	# my $DFEngineer = $DynamicFieldObject->DynamicFieldGet(
    #     Name => 'Engineer',
    # );
	# #get possible data of df engineer
	# my $PossibleValues = $BackendObject->PossibleValuesGet(
    #     DynamicFieldConfig => $DFEngineer,       
    # );	
	
	
	my @Params = (
	
		{
            Frontend   => 'Year',
            Name       => 'Year',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedYear,
            Data       => \%Year,
        },
        {
            Frontend   => 'From Month',
            Name       => 'Month',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedMonth,
            Data       => \%Month,
        },
		{
            Frontend   => 'To Month',
            Name       => 'ToMonth',
            Multiple   => 0,
            Size       => 0,
            SelectedID => $SelectedMonth2,
            Data       => \%ToMonth,
        },
		
		###get selection field of type
		{
            Frontend   => 'Ticket Type',
            Name       => 'Ticket_Type',
            Multiple   => 1,
            Size       => 0,
            SelectedID => 1,
			Data       => \%Ticket_Type,
        },
		
		###Enable block to below to get selection field of queue
		# {
        #    Frontend   => 'Ticket Queue',
        # 	Name       => 'Ticket_Queue',
        # 	Multiple   => 1,
        # 	Size       => 0,
        # 	SelectedID => 1,
        # 	Data       => \%Ticket_Queue,
        # },
		
		###Enable block to below to get selection field of customer user
		# {
        # 	Frontend   => 'Customer User',
        # 	Name       => 'CustomerUser',
        # 	Multiple   => 1,
        # 	Size       => 0,
        # 	SelectedID => 1,
        # 	Data       => \%List,
        # },

		###Enable block to below to get selection field of specific ticket dynamic field
		# {
        #     Frontend   => 'Engineer',
        #     Name       => 'Engineer',
        #     Multiple   => 1,
        #     Size       => 0,
        #     SelectedID => '-',
        #     Data       => \%{$PossibleValues},
        # },
		
		###For your own predefined dropdown/multiselect field
		# {
        # Frontend   => 'Company',
        # Name       => 'Company',
        # Multiple   => 1,
        # Size       => 0,
        # SelectedID => 0,
        # Data       => {
		# 			A => 'Site A',
		# 			B => 'Site B',
		# 			C => 'Site C',
		# 			  },
        # },
		

    );
    return @Params;
	
	
}

sub Run {
   my ( $Self, %Param ) = @_;

    my $Year  = $Param{Year};
    my $Month = sprintf( "%02d", $Param{Month});
	my $ym = $Year.'-'.$Month.'-01'; 
	my $ToMonth = sprintf( "%02d", $Param{ToMonth});
	my $ytm = $Year.'-'.$ToMonth.'-31';
	
	#Some selected/submitted ticket attributes (E.g: type, queue) will contain an ID instead of name. 
	#You need to using an id in SQL statement later
	#If the input field is mutiselect, the value will be in array. You have to format it to string (something meaningfull to SQL)
	my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
		
	#getting value from submitted selected value and format it to ('a','b','c')
	#for ticket type
	my @tt = $Param{Ticket_Type};
	my $tt2 = (${\(join "','", sort @{$tt[0]})});
	my $tt3 = $DBObject->QueryStringEscape(
        QueryString => $tt2,
    );
	
	#for ticket queue
	# my @tq = $Param{Ticket_Queue};
	# my $tq2 = (${\(join "','", sort @{$tq[0]})});
	# my $tq3 = $DBObject->QueryStringEscape(
    # 			QueryString => $tq2,
    # );
	
	#for ticket customer
	# my @cu = $Param{CustomerUser};
	# my $cu2 = (${\(join "','", sort @{$cu[0]})});
	# my $cu3 = $DBObject->QueryStringEscape(
    # 			QueryString => $cu2,
    # );
	
    #for specific dynamic field
	# my @engineer = $Param{Engineer};
	# my $engineer2 = (${\(join "','", sort @{$engineer[0]})});
	# my $engineer3 = $DBObject->QueryStringEscape(
    # 			QueryString => $engineer2,
    # );
	
	#for predifined field above. Eg: company
	# my @company = $Param{Company};
	# my $company2 = (${\(join "','", sort @{$company[0]})});
	# my $company3 = $DBObject->QueryStringEscape(
    # 			QueryString => $company2,
    # );
	
	my $Title = "- Year $Year from Month $Month to $ToMonth"; 
	my @Stats = ();

	#example of sql. get handling time, 
	my $SQL = "SELECT CONCAT_WS(' ', u.first_name,u.last_name) AS OWNER,
t.tn AS OTRS_TICKET_NUMBER,
t.title AS TITLE,
q.name AS 'QUEUE',
t.create_time AS OPEN_TIME,
CASE WHEN th.history_type_id IN ('1','27') AND th.state_id IN ('2','3') THEN MAX(th.create_time) ELSE NULL END AS CLOSE_TIME,
CASE WHEN th2.history_type_id IN ('8') THEN MIN(th2.create_time) ELSE NULL END AS AGENT_RESPONSE_TIME,
tt.name AS 'TYPE',
s.name AS 'SERVICE',
sla.name AS 'SLA',
ts.name AS 'STATE',
t.customer_id AS CUSTOMER_ID,
t.customer_user_id AS ALIAS
FROM ticket t
LEFT JOIN ticket_state ts ON (t.ticket_state_id=ts.id)
LEFT JOIN queue q ON (t.queue_id=q.id)
LEFT JOIN ticket_type tt ON (tt.id=t.type_id)
LEFT JOIN service s ON (t.service_id=s.id)
LEFT JOIN sla ON (t.sla_id=sla.id)
LEFT JOIN users u ON (t.user_id=u.id)
LEFT JOIN ticket_history th ON (t.id=th.ticket_id AND th.history_type_id IN ('1','27') AND th.state_id IN ('2','3'))
LEFT JOIN ticket_history th2 ON (t.id=th2.ticket_id AND th2.history_type_id IN ('8'))
LEFT JOIN customer_user cu ON (t.customer_user_id=cu.login)
WHERE ( CAST(t.create_time AS DATE) BETWEEN ? AND ?)  AND tt.id IN ('$tt3')
GROUP BY t.tn
ORDER BY OWNER";

	$DBObject->Prepare( SQL => $SQL,
	Bind => [ \$ym, \$ytm ]
	);
	
	my @HeadData = $DBObject->GetColumnNames();
	$_ = uc for @HeadData;
	my %Stats;
	
	my $count = 0;
    while ( my @Row = $DBObject->FetchrowArray() ) { 
		push @Stats, \@Row;
		$count++;
    }
	
	unless ($count) {
	undef @HeadData;
	my @NODATA = "Sorry 0 Result" ;
	push @Stats, \@NODATA;
	}

	return ([$Title],[$Title],[@HeadData], @Stats); 
}

1;
