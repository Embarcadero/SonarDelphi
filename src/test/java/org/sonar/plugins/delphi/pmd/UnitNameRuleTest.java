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

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.is;

import org.junit.Test;

public class UnitNameRuleTest extends BasePmdRuleTest {

  @Test
  public void testValidRule() {
    execute(new DelphiUnitBuilderTest().unitName("MyUnit"));

    assertThat(issues, is(empty()));
  }

  @Test
  public void testValidUnitUsingNameSpace() {
    execute(new DelphiUnitBuilderTest().unitName("MySonar.MyUnit"));

    assertThat(issues, is(empty()));
  }

/*  @Test
  public void testInvalidRule() {
    analyse(new DelphiUnitBuilderTest().unitName("myUnit"));

    assertThat(issues, hasSize(1));
    Issue issue = issues.get(0);
    assertThat(issue.ruleKey().rule(), equalTo("UnitNameRule"));
    assertThat(issue.line(), is(1));
  }*/
/*
  @Test
  public void testInvalidUnitUsingNameSpace() {
    analyse(new DelphiUnitBuilderTest().unitName("MySonar.myUnit"));

    assertThat(issues, hasSize(1));
    Issue issue = issues.get(0);
    assertThat(issue.ruleKey().rule(), equalTo("UnitNameRule"));
    assertThat(issue.line(), is(1));
  }*/

/*  @Test
  public void testInvalidUnitUsingLowerNameSpace() {
    analyse(new DelphiUnitBuilderTest().unitName("mySonar.myUnit"));

    assertThat(issues, hasSize(1));
    Issue issue = issues.get(0);
    assertThat(issue.ruleKey().rule(), equalTo("UnitNameRule"));
    assertThat(issue.line(), is(1));
  }*/

}
