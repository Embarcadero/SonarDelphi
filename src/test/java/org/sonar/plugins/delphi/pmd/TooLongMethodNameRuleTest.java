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

public class TooLongMethodNameRuleTest extends BasePmdRuleTest {

  @Test
  public void testValidRule() {
    DelphiUnitBuilderTest builder = new DelphiUnitBuilderTest();
    builder.appendImpl("function Foo: Integer;");
    builder.appendImpl("begin");
    builder.appendImpl(" Result := 1;");
    builder.appendImpl("end;");

    execute(builder);

    assertThat(issues, is(empty()));
  }

/*  @Test
  public void testTooLongMethod() {
    DelphiUnitBuilderTest builder = new DelphiUnitBuilderTest();
    builder.appendImpl("function Foo: Integer;");
    builder.appendImpl("begin");
    for (int i = 1; i <= 101; i++) {
      builder.appendImpl(" Result := Result + 1;");
    }
    builder.appendImpl("end;");

    analyse(builder);

    assertThat(issues, hasItem(IssueMatchers.hasRuleKeyAtLine("TooLongMethodRule", builder.getOffSet() + 1)));
  }*/
}
