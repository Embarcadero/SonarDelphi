package org.sonar.plugins.delphi.pmd;

import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Collection;
import java.util.Collections;

import org.apache.commons.io.FileUtils;
import org.junit.Assert;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.fs.internal.TestInputFileBuilder;
import org.sonar.api.batch.rule.ActiveRules;
import org.sonar.api.batch.sensor.internal.SensorContextTester;
import org.sonar.api.batch.sensor.issue.Issue;
import org.sonar.plugins.delphi.DelphiTestUtils;
import org.sonar.plugins.delphi.core.DelphiLanguage;
import org.sonar.plugins.delphi.core.helpers.DelphiProjectHelper;
import org.sonar.plugins.delphi.pmd.profile.DelphiPmdProfileExporter;
import org.sonar.plugins.delphi.project.DelphiProject;
import org.sonar.plugins.delphi.utils.DelphiUtils;

public class RuleVerifier {
    private static final String ROOT_NAME = "/org/sonar/plugins/delphi/PMDTest";

    private String delphiRuleName;
    private String filePath;

    private RuleVerifier() {
    }

    public static RuleVerifier newVerifier() {
        return new RuleVerifier();
    }

    public RuleVerifier onFile(String filePath) {
        this.filePath = filePath;
        return this;
    }

    public RuleVerifier withCheck(String delphiRuleName) {
        this.delphiRuleName = delphiRuleName;
        return this;
    }

    public void verifyNoIssues() throws IOException {
        Collection<Issue> issues = getIssues();
        long issuesFound = issues.stream().filter(issue -> issue.ruleKey().rule().equals(delphiRuleName)).count();
        Assert.assertEquals("Found some issues, but expected zero.", 0, issuesFound); 
    }

    private Collection<Issue> getIssues() throws IOException {
        File baseDir = DelphiUtils.getResource(ROOT_NAME);
        File srcFile = DelphiUtils.getResource(filePath);
                
        final InputFile inputFile = TestInputFileBuilder.create("ROOT_KEY_CHANGE_AT_SONARAPI_5", baseDir, srcFile)
                .setModuleBaseDir(baseDir.toPath())
                .setLanguage(DelphiLanguage.KEY)
                .setType(InputFile.Type.MAIN)
                .setContents(DelphiUtils.readFileContent(srcFile, Charset.defaultCharset().name()))
                .build();

        DelphiProject delphiProject = new DelphiProject("Default Project");
        delphiProject.setSourceFiles(Collections.singletonList(srcFile));      
        
        
        ActiveRules activeRules = mock(ActiveRules.class);
        DelphiPmdProfileExporter profileExporter = createDelphiPmdProfileExporterMock(activeRules);
        DelphiProjectHelper delphiProjectHelper = createDelphiProjectHelperMock(delphiProject, inputFile);
        
        SensorContextTester sensorContext = SensorContextTester.create(baseDir);
        sensorContext.setActiveRules(activeRules);

        DelphiPmdSensor sensor = new DelphiPmdSensor(delphiProjectHelper, sensorContext, profileExporter);
        sensor.execute(sensorContext);
        
        return sensorContext.allIssues();
    }

    private DelphiProjectHelper createDelphiProjectHelperMock(DelphiProject delphiProject, InputFile inputFile) {
        DelphiProjectHelper delphiProjectHelper = DelphiTestUtils.mockProjectHelper();

        // Don't pollute current working directory
        when(delphiProjectHelper.workDir()).thenReturn(new File("target"));

        when(delphiProjectHelper.getWorkgroupProjects()).thenReturn(Collections.singletonList(delphiProject));
        when(delphiProjectHelper.getFile(anyString())).thenAnswer(new Answer<InputFile>() {
            @Override
            public InputFile answer(InvocationOnMock invocation) {
                return inputFile;
            }
        });

        return delphiProjectHelper;
    }

    private DelphiPmdProfileExporter createDelphiPmdProfileExporterMock(ActiveRules activeRules) {
        DelphiPmdProfileExporter profileExporter = mock(DelphiPmdProfileExporter.class);

        String fileName = getClass().getResource("/org/sonar/plugins/delphi/pmd/rules.xml").getPath();
        File rulesFile = new File(fileName);
        String rulesXmlContent;
        try {
            rulesXmlContent = FileUtils.readFileToString(rulesFile);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        when(profileExporter.exportActiveRulesToString(activeRules)).thenReturn(rulesXmlContent);
        return profileExporter;
    }
}