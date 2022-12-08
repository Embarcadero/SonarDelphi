![Java CI with Maven](https://github.com/JAM-Software/SonarDelphi/workflows/Java%20CI%20with%20Maven/badge.svg)

[Embarcadero](https://www.embarcadero.com/)'s officially version of the **Sonar Delphi** plugin for use to analyze [Delphi](https://www.embarcadero.com/products/delphi) source code with SonarQube. Working to collect updates and contributions from other versions into this one and move if forward with new features. Thanks to [Joachim Marder](https://github.com/joachimmarder) of [JAM Software](http://www.jam-software.com/), and [Laurens van Run](https://github.com/Laurensvanrun) of [Mendrix](http://www.mendrix.nl/) for working with us on this, and everyone else who's contributed to the Sonar-Delphi projects on GitHub.

We are accepting pull requests and looking for more contributors. 

![SonarDelphi](https://raw.githubusercontent.com/Embarcadero/SonarDelphi/master/logos/SonarDelphi%20(black%20text).svg#gh-light-mode-only)![SonarDelphi](https://raw.githubusercontent.com/Embarcadero/SonarDelphi/master/logos/SonarDelphi%20(white%20text).svg#gh-dark-mode-only)

# SonarQube Delphi

Is a [SonarQube](http://www.sonarqube.org/) plugin that provides
  * 49 Rules for Delphi
  * TestCoverage using [DelphiCodeCoverage](https://github.com/DelphiCodeCoverage/DelphiCodeCoverage/releases) or [SmartBear's AQtime](https://smartbear.com/product/aqtime-pro/) (license required)
   * Optional `.html` output for TestCoverage
  * Unit test results using [DUnitX](https://github.com/VSoftTechnologies/DUnitX)

This is Plugin-Version 1.0. SonarQube 7.9(LTS) or higher is needed (tested with SonarQube 7.9.3 and 8.2.0)

## Reporting Issues

SonarQube Delphi Plugin uses GitHub's integrated issue tracking system to record bugs and feature
requests. If you want to raise an issue, please follow the recommendations below:

* Before you log a bug, please [search the issue tracker](https://github.com/Embarcadero/SonarDelphi/issues)
  to see if someone has already reported the problem.
* If the issue doesn't already exist, [create a new issue](https://github.com/Embarcadero/SonarDelphi/issues/new)
* Please provide as much information as possible with the issue report, we like to know
  the version of SonarQube Delphi Plugin that you are using, as well as the SonarQube version.
* If possible try to create a test-case or project that replicates the issue. 

## Implemented Features

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
  
# Steps to Analyze a Delphi Project

1. Install SonarQube Server ([Local Zip is easiest](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/) for more details). Check supported versions of the [latest release](https://github.com/Embarcadero/sonar-delphi/releases/latest) of the plugin.
2. Install the [SonarQube Scanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/) runner and be sure you can call it from the directory where you have your source code
3. Install [Delphi Plugin](https://github.com/Embarcadero/SonarDelphi/releases) (see [Installing a Plugin](https://docs.sonarqube.org/latest/setup/install-plugin/)  for more details).
4. Check the sample project corresponding to your Runner to know which config file you need to create. You can find the samples in [sonar-delphi/samples](https://github.com/Embarcadero/sonar-delphi/tree/master/samples).
5. Run your Analyzer command from the project root dir
6. Follow the link provided at the end of the analysis to browse your project's quality in SonarQube UI (see: [Browsing SonarQube](https://docs.sonarqube.org/latest/project-administration/project-existence/))

## Code Assumptions

* Grammar is NOT case insensitive, but Delphi code is. Plugin deals with it by DelphiSourceSanitizer class, which feeds ANTLR parser lowercase characters (the "LA" method)
* Number of classes includes: classes, records
* Directory is count as a package. Number of packages equals number of directories.
* Preprocessor definitions between {$if xxx} and {$ifend} are removed, the {$else} part is kept. (DefineResolver class).
* Sources imported to SonarQube are parsed through IncludeResolver class. It means, that the source will be lowercased and unknown preprocessor definitions will be cut out.

## CodeCoverage and unit testing

CodeCoverage can be done through the [DelphiCodeCoverage tool](https://github.com/DelphiCodeCoverage/DelphiCodeCoverage/). Use

	CodeCoverage.exe -xml -xmllines
	
to create a XML output that can be importeded through this plugin. Therefore you have to edit your sonar project properties:

	sonar.delphi.codecoverage.tool=dcc
	sonar.delphi.codecoverage.report=Test/CoverageResults/CodeCoverage_Summary.xml

### Unittests with DUnit

To import the testresults from DUnit, you have to use the [DUnit extension] (https://github.com/mendrix/dunit-extension) and use the supplied runner (it is not necessary to change your test classes to TTestCaseExtension).

	ExitCode := TTestRunnerUtils.RunRegisteredTests;

This will run your tests with GUI if no parameters are given. With the parameter `-xml` the tool will create a XML output that is compatible with JUnit for SonarQube. With `-output` your can specify the output directory

	MyTester.exe -xml -output <outputdirectory>

To import these test results, add the following line to your sonar project properties:

	sonar.junit.reportsPath=TestResults

You also have to specify where the plugin can find your testfiles. It is important that the sourcefiles from your tests are EXCLUDED in your sources directory.

	sonar.exclusions=MyTestFiles/*
	sonar.tests=MyTestFiles

### Unittests with DUnitX

It is also possible to import results from [DUnitX](http://docwiki.embarcadero.com/RADStudio/Rio/en/DUnitX_Overview). Therefore you have to add the file

	DUnitX.Loggers.XML.SonarQube.pas

to your DUnitX project. Then change the .dpr of your application and add functionality for a sources directory (this is used to find the correct .pas file corresponding to the Delphi unit of the unittest):

    TOptionsRegistry.RegisterOption<String>('sources', 's', 'Specify a file with on each line a directory where the PAS-files of the unittests can be found.', procedure (AString: String) begin
      LSourcesDir := AString;
    end);
	sqLogger := TDUnitXXMLSonarQubeFileLogger.Create(LSourcesDir, TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(sqLogger);	

To import the resulting XML file, add the following line to your sonar project properties:

	sonar.testExecutionReportPaths=Test/TEST-dunitx-sqresults.xml

### Unittests with code coverage example

To have both codecoverage and unittests results for SonarQube, you have to combine above options. For example:

	CodeCoverage.exe -e MyTester.exe -m MyTester.map -a ^^-xml^^ ^^-output TestResults^^ -ife -spf sourcedirs.txt -uf unitstotest.txt -od CoverageResults\ -html -xml -xmllines

# How to build the plugin

## Prerequisites

To build a plugin, you need Java 8 and Maven 3.1 (or greater).
- [JDK](https://jdk.java.net/)
- [Maven](https://maven.apache.org/)

## Compile and test

    mvn compile
    mvn test

### Package as plugin

    mvn package

Now you can copy the plugin from the ```/target/``` directory to the SonarQube plugin directory.

### Importing into Eclipse

First run the eclipse maven goal:

    mvn eclipse:eclipse

The project can then be imported into Eclipse using File -> Import and then selecting General -> Existing Projects into Workspace.

### Importing into Intellij

Simply open the pom.xml in Intellij should solve most dependecies by itself.

# How to develop and debug the plugin

SonarQube has great documentation about [developing a plugin](https://docs.sonarqube.org/latest/extend/developing-plugin/). To debug this plugin with the SonarQube scanner you to just set the following environment variable (on Windows):

    SET SONAR_SCANNER_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000"

Now you attach your Eclipse (or other) debugger to port 8000 to start debugging.

## Changing the grammar with ANLTRWorks

The plugin uses an ANTLR3 grammar to parse the Delphi language. The [grammar definition](https://github.com/Embarcadero/SonarDelphi/blob/main/src/main/antlr3/org/sonar/plugins/delphi/antlr/Delphi.g) can be found in `/src/main/antlr3/org/sonar/plugins/delphi/antlr/delphi.g`. An easy way to check and modify this grammar is using [ANTLRWorks](https://www.antlr3.org/works/). Here you can test your grammar on new files and implement new language definitions.

After successfully changing and testing the Delphi.g grammar you have to generate the new parser code (menu Generate, option Generate Code). Now copy the files **DelphiLexer.java** and **DelphiParser.java** from `/src/main/antlr3/org/sonar/plugins/delphi/antlr/output/` to `/src/main/java/org/sonar/plugins/delphi/antlr/` and (re)build the plugin.

**Note:** it is important to make sure your new grammar changes are also tested. If you only have to make sure that they can be parsed without errors, you can add your new language features to one of the existing grammar files in **/src/main/java/org/sonar/plugins/delphi/antlr** (the newest is **GrammarTest2020.pas**).

## Credits and notable contributors

* [Sabre Airline Solutions](http://www.sabreairlinesolutions.com/home/)
* [Joachim Marder](https://github.com/joachimmarder) of [JAM Software](http://www.jam-software.com/)
* [Laurens van Run](https://github.com/Laurensvanrun) of [MendriX](http://www.mendrix.nl/)
* [Sandro Luck](https://github.com/SandroLuck/SonarDelphi)
* [Fabricio Colombo](https://github.com/fabriciocolombo/sonar-delphi)
