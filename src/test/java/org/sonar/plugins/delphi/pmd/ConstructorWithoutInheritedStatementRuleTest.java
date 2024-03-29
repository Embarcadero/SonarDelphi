/*
 * Sonar Delphi Plugin
 * Copyright (C) 2015 Fabricio Colombo
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
 */
package org.sonar.plugins.delphi.pmd;

import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

import java.io.IOException;

import org.junit.Test;

public class ConstructorWithoutInheritedStatementRuleTest extends BasePmdRuleTest {

  @Test
  public void validRule() {
    DelphiUnitBuilderTest builder = new DelphiUnitBuilderTest();

    builder.appendDecl("type");
    builder.appendDecl("  TTestConstructor = class");
    builder.appendDecl("  public");
    builder.appendDecl("    constructor Create;");
    builder.appendDecl("  end;");

    builder.appendImpl("constructor TTestConstructor.Create;");
    builder.appendImpl("begin");
    builder.appendImpl("  inherited;");
    builder.appendImpl("  Writeln('do something');");
    builder.appendImpl("end;");

    execute(builder);

    assertThat(issues, is(empty()));
  }

/*  @Test
  public void constructorMissingInheritedShouldAddIssue() {
    DelphiUnitBuilderTest builder = new DelphiUnitBuilderTest();

    builder.appendDecl("type");
    builder.appendDecl("  TTestConstructor = class");
    builder.appendDecl("  public");
    builder.appendDecl("    constructor Create;");
    builder.appendDecl("  end;");

    builder.appendImpl("constructor TTestConstructor.Create;");
    builder.appendImpl("begin");
    builder.appendImpl("  Writeln('do something');");
    builder.appendImpl("end;");

    analyse(builder);

    assertThat(toString(issues), issues, hasSize(1));
    assertThat(toString(issues), issues, hasItem(allOf(hasRuleKey("ConstructorWithoutInheritedStatementRule"),
      hasRuleLine(builder.getOffSet() + 1))));
  }*/

  @Test
  public void recordConstructorShouldNotAddIssue() {
    DelphiUnitBuilderTest builder = new DelphiUnitBuilderTest();

    builder.appendDecl("type");
    builder.appendDecl("  TTestRecord = record");
    builder.appendDecl("    FData : Integer;");
    builder.appendDecl("    constructor Create(aData : Integer);");
    builder.appendDecl("  end;");

    builder.appendImpl("constructor TTestRecord.Create(aData : Integer);");
    builder.appendImpl("begin");
    builder.appendImpl("  FData := aData;");
    builder.appendImpl("end;");

    execute(builder);

    assertThat(issues, is(empty()));
  }
  
  @Test
  public void classConstructor_NoIssue() throws IOException {
    RuleVerifier.newVerifier()
    .onFile("/org/sonar/plugins/delphi/PMDTest/ConstructorWithoutInheritedStatementRule_ClassConstructor.pas")
    .withCheck("ConstructorWithoutInheritedStatementRule")
    .verifyNoIssues();
  }
  
    @Test
    public void overloadedConstructorCalled_NoIssue() throws IOException {
      RuleVerifier.newVerifier()
                  .onFile("/org/sonar/plugins/delphi/PMDTest/ConstructorWithoutInheritedStatementRule_OverloadConstructorCalled.pas")
                  .withCheck("ConstructorWithoutInheritedStatementRule")
                  .verifyNoIssues();
    }
}
