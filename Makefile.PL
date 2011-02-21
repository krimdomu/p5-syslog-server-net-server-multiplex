use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'Syslog::Server::Net::Server::Multiplex',
   VERSION_FROM => 'lib/Syslog/Server/Net/Server/Multiplex.pm',
   PREREQ_PM => {'Net::Server' => '0'},
   LICENSE => 'perl'
);

