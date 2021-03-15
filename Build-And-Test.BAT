ECHO Start ANTLWRKS and press CTRL+Shift+G to generate new code
PAUSE
COPY /Y src\main\antlr3\org\sonar\plugins\delphi\antlr\output\Delphi*.java src\main\java\org\sonar\plugins\delphi\antlr
CALL mvn compile test
START "LOG" "C:\Program Files\Notepad++\notepad++.exe" Target\surefire-reports\TEST-org.sonar.plugins.delphi.antlr.GrammarTest.xml
pause