[![Build Status](https://travis-ci.org/ekot1/SonarDelphi.svg?branch=master)](https://travis-ci.org/ekot1/SonarDelphi)

SonarQube Delphi
================
Is a SonarQube (http://www.sonarqube.org/) plugin and provides
  * 49 Rules for Delphi
  * TestCoverage using DelphiCodeCoverage or AQtime (license needed)
   * Optional .html output for TestCoverage
  * Unittests results using DUnitX

This is Plugin-Version 1.0 SonarQube 7.9(LTS) or higher is needed (tested with SonarQube 7.9.3 and 8.2.0)
It is is mainly an updated version of https://github.com/fabriciocolombo/sonar-delphi all credit goes to them.
I have hosted it here since the orignal developer isn't active anymore.

This plugin was originally a [Sabre Airline Solutions](http://www.sabreairlinesolutions.com/home/) donation.

License
---------------------------------------------------------------------------------------
The entire PLugin follows the GPL: https://github.com/SandroLuck/SonarDelphi/blob/master/src/LUCK_LICENSE.txt

Steps to Analyze a Delphi Project
------------------------------------------------

1. Install SonarQube Server (see [Setup and Upgrade](http://docs.sonarqube.org/display/SONAR/Setup+and+Upgrade) for more details). Check supported versions of the [latest release](https://github.com/fabriciocolombo/sonar-delphi/releases/latest) of the plugin.
2. Install one of the supported [Runners](#supported-runners) (see below) and be sure you can call it from the directory where you have your source code
3. Install [Delphi Plugin](https://github.com/mendrix/SonarDelphi/releases) (see [Installing a Plugin](http://docs.sonarqube.org/display/SONAR/Installing+a+Plugin)  for more details).
 NOTE: This only applies to SonarQube 7.9(LTS) and heigher. For older versions see [Delphi Plugin](https://github.com/fabriciocolombo/sonar-delphi/releases)
4. Check the sample project corresponding to your Runner to know which config file you need to create. You can find the samples in [sonar-delphi/samples](https://github.com/fabriciocolombo/sonar-delphi/tree/master/samples).
5. Run your Analyzer command from the project root dir
6. Follow the link provided at the end of the analysis to browse your project's quality in SonarQube UI (see: [Browsing SonarQube](http://docs.sonarqube.org/display/SONAR/Browsing+SonarQube))

Supported Runners
----------------------------
 To run an analysis of your Java project, you can use the following Runners:

* [SonarQube Scanner](http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner): recommended for all projects 
* See https://github.com/fabriciocolombo/sonar-delphi for diffrent approacheds which have not been tested yet with 0.3.4

Reporting Issues
----------------------------
SonarQube Delphi Plugin uses GitHub's integrated issue tracking system to record bugs and feature
requests. If you want to raise an issue, please follow the recommendations below:

* Before you log a bug, please [search the issue tracker](https://github.com/SandroLuck/SonarDelphi/issues)
  to see if someone has already reported the problem.
* If the issue doesn't already exist, [create a new issue](https://github.com/SandroLuck/SonarDelphi/issues/new)
* Please provide as much information as possible with the issue report, we like to know
  the version of SonarQube Delphi Plugin that you are using, as well as the SonarQube version.
* If possible try to create a test-case or project that replicates the issue. 

Implemented Features
------------------------------------------

* Counting lines of code, statements, number of files
* Counting number of classes, number of packages, methods, accessors
* Counting number of public API (methods, classes and fields)
* Counting comments ratio, comment lines (including blank lines)
* CPD (code duplication, how many lines, block and in how many files)
* Code Complexity (per method, class, file; complexity distribution over methods, classes and files)
* LCOM4 and RFC
* Code colorization
* Assembler syntax in grammar
* Include statement
* Parsing preprocessor statements
* Rules
* Tagable Issues
* "Dead" code recognition
* Unused files recognition
* Unused functions
* Unused procedures
(Optional with AQtime and DelphiCodeCoverage)
  * Coverage using AQtime
  * Sufficient Coverage on new Code 
(Optional with DUnit)
  * Test results
  
Code Assumptions
----------------------------------

* Grammar is NOT case insensitive, but Delphi code is. Plugin deals with it by DelphiSourceSanitizer class, which feeds ANTLR parser lowercase characters (the "LA" method)
* Number of classes includes: classes, records
* Directory is count as a package. Number of packages equals number of directories.
* Preprocessor definitions between {$if xxx} and {$ifend} are removed (DefineResolver class).
* Sources imported to SonarQube are parsed through IncludeResolver class. It means, that the source will be lowercased and unknown preprocessor definitions will be cut out.

CodeCoverage
-------------------------------
CodeCoverage can be done through the DelphiCodeCoverage tool [https://sourceforge.net/p/delphicodecoverage/git/ci/master/tree/]. Use

	CodeCoverage.exe -xml -xmllines
	
to create a XML output that can be importeded through this plugin. Therefore you have to edit your sonar project properties:

	sonar.delphi.codecoverage.tool=dcc
	sonar.delphi.codecoverage.report=Test/CoverageResults/CodeCoverage_Summary.xml
	
Unittests
-------------------------------
It is also possible to import results from DUnitX [http://docwiki.embarcadero.com/RADStudio/Rio/en/DUnitX_Overview]. Therefore you have to add the file

	DUnitX.Loggers.XML.SonarQube.pas

to your DUnitX project. Then change the .dpr of your application and add functionality for a sources directory (this is used to find the correct .pas file corresponding to the Delphi unit of the unittest):

    TOptionsRegistry.RegisterOption<String>('sources', 's', 'Specify a file with on each line a directory where the PAS-files of the unittests can be found.', procedure (AString: String) begin
      LSourcesDir := AString;
    end);
	sqLogger := TDUnitXXMLSonarQubeFileLogger.Create(LSourcesDir, TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(sqLogger);	

To import the resulting XML file, add the following line to your sonar project properties:

	sonar.testExecutionReportPaths=Test/TEST-dunitx-sqresults.xml

Importing into Eclipse
-------------------------------
First run the eclipse maven goal:

    mvn eclipse:eclipse

The project can then be imported into Eclipse using File -> Import and then selecting General -> Existing Projects into Workspace.

Importing into Intellij
-------------------------------
Simply open the pom.xml in Intellij should solve most dependecies by itself.
