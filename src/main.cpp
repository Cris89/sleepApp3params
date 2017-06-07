#include <chrono>
#include <random>
#include <thread>
#include <math.h>
#include <iostream>
#include <fstream>

#include "tesiCris_margot_manager.hpp"



void go_to_bed( int sleepTime )
{
	std::this_thread::sleep_for( std::chrono::milliseconds( sleepTime ) );
}



int main()
{



	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////// app test folder
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	system("mkdir -p /home/cris/Documents/tests/sleepApp3params");
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////// app test folder
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////



	std::chrono::steady_clock::time_point tStart = std::chrono::steady_clock::now();

	// variable for throughput monitor
	int num_threads = 1;

	// amount of milliseconds for go_to_bed() function (computed at runtime)
	int sleepTime;

	// error variable (computed at runtime)
	long double error;



	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////// metricsStories
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	std::ofstream errorStory;
	std::ofstream throughputStory;

	errorStory.open( "/home/cris/Documents/tests/sleepApp3params/errorStory.txt", std::ofstream::out | std::ofstream::app );
	throughputStory.open( "/home/cris/Documents/tests/sleepApp3params/throughputStory.txt", std::ofstream::out | std::ofstream::app );
	
	errorStory << "time(microseconds) avg_error param1 param2 param3" << std::endl;
	throughputStory << "time(microseconds) avg_throughput param1 param2 param3" << std::endl;
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////// metricsStories
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////



	// noise generation for sleepTime (--> avg_throughput)
	unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
	std::default_random_engine generator(seed);

	std::gamma_distribution<double> distribution( 1, 0.3 );

	float errorPercentage = 0.1;



	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////// error percentage
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	std::ofstream exec_info_f;
	exec_info_f.open( "/home/cris/Documents/tests/sleepApp3params/info.txt", std::ofstream::out | std::ofstream::app );
	exec_info_f << "error_percentage: " << errorPercentage * 100 << "%" << "\n\n\n" << std::endl;
	exec_info_f.close();
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////// error percentage
	////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////



	// tesiCris and margot initialization
	tesiCris_Margot_Manager tmm;
	tmm.init();

	// application knobs
	int param1;
	int param2;
	int param3;

	std::chrono::time_point<std::chrono::steady_clock> duration = std::chrono::steady_clock::now() + std::chrono::hours(100);

	while( std::chrono::steady_clock::now() < duration )
	{
		// if new OPs are sent by the server_handler, the margot OP list is updated
		tmm.updateOPs();

		//check if the configuration is different wrt the previous one
		if( margot::sleeping::update( param1, param2, param3 ) )
		{
			margot::sleeping::manager.configuration_applied();
		}
		//monitors wrap the autotuned function
		margot::sleeping::start_monitor();


		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////// 1st order with transformations
		////////////////////////////////////////////////////////////////////////////////////////////////////
		sleepTime  = round( 
							( +7.35 * log(param1) ) + 
							( +38.1 * param2 ) +
							( +52.96 * sqrt(param3) ) );

		sleepTime += round( sleepTime * errorPercentage * distribution(generator) );
		// sleepTime += round( sleepTime * errorPercentage * 0.3 );




		error = 1 / (
						( +0.015 * sqrt(param1) ) + 
						( +0.033 * log(param2) ) +
						( +0.028 * log(param3) )
					);
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////// 1st order with transformations
		////////////////////////////////////////////////////////////////////////////////////////////////////



		/*////////////////////////////////////////////////////////////////////////////////////////////////////
		////////// 2nd order
		////////////////////////////////////////////////////////////////////////////////////////////////////
		sleepTime  = round( 
							( +7.4 * param1 * param2 ) + 
							( +2.1 * pow( param3, 2 ) ) );

		sleepTime += round( sleepTime * errorPercentage * distribution(generator) );
		// sleepTime += round( sleepTime * errorPercentage * 0.3 );




		error = 1 / (
						( +0.01 * param1 ) + 
						( +0.7 * log(param2) ) +
						( +0.019 * param3 )
					);
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////// 2nd order
		////////////////////////////////////////////////////////////////////////////////////////////////////*/



		std::cout << "\n\n\nparam1 = " << param1 << std::endl;
		std::cout << "param2 = " << param2 << std::endl;
		std::cout << "param3 = " << param3 << std::endl;
		std::cout << "\n\t...zzz... sleeping for " << sleepTime << " milliseconds ...zzz...\n\n\n" << std::endl;
		go_to_bed( sleepTime );



		margot::sleeping::stop_monitor( num_threads, error );
		margot::sleeping::log();



		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////// metricsStories
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////
		std::chrono::steady_clock::time_point tStop = std::chrono::steady_clock::now();

		uint64_t tEndComputation = std::chrono::duration_cast<std::chrono::microseconds>( tStop - tStart ).count();

		errorStory << tEndComputation << " " << margot::sleeping::avg_error << " " << param1 << " " << param2 << " " << param3 << std::endl;
		throughputStory << tEndComputation << " " << margot::sleeping::avg_throughput << " " << param1 << " " << param2 << " " << param3 << std::endl;
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////// metricsStories
		////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////



		// the OP is sent to the server_handler
		// the order of parameters and features in params_features must be lexicographic, as in the defaultConfiguration
		tmm.sendResult( { param1, param2, param3 }, { margot::sleeping::avg_error, margot::sleeping::avg_throughput } );
	}
}