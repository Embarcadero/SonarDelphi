/*
 * Sonar Delphi Plugin
 * Copyright (C) 2011 Sabre Airline Solutions and Fabricio Colombo
 * Author(s):
 * Przemyslaw Kociolek (przemyslaw.kociolek@sabre.com)
 * Michal Wojcik (michal.wojcik@sabre.com)
 * Fabricio Colombo (fabricio.colombo.mva@gmail.com)
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
package org.sonar.plugins.delphi.pmd.profile;

import org.sonar.api.profiles.ProfileExporter;
import org.sonar.api.profiles.RulesProfile;
import org.sonar.api.batch.rule.ActiveRules;
import org.sonar.api.rule.Severity;
import org.sonar.plugins.delphi.core.DelphiLanguage;
import org.sonar.plugins.delphi.pmd.DelphiPmdConstants;
import org.sonar.plugins.delphi.pmd.xml.DelphiRule;
import org.sonar.plugins.delphi.pmd.xml.DelphiRulesUtils;
import org.sonar.plugins.delphi.pmd.xml.Property;
import org.sonar.plugins.delphi.pmd.xml.Ruleset;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * exports Delphi rules profile into Sonar
 */
public class DelphiPmdProfileExporter extends ProfileExporter {

  /**
   * ctor
   */
  public DelphiPmdProfileExporter() {
    super(DelphiPmdConstants.REPOSITORY_KEY, DelphiPmdConstants.REPOSITORY_NAME);
    setSupportedLanguages(DelphiLanguage.KEY);
    setMimeType("application/xml");
  }

  @Override
  public void exportProfile(RulesProfile profile, Writer writer) {
    throw new IllegalArgumentException("Cannot export profile " + profile);
  }

  public void exportActiveRules(ActiveRules activeRules, Writer writer) {
    try {
      writer.write(DelphiRulesUtils.buildXmlFromRuleset(buildRulesetFromActiveProfile(activeRules)));
    } catch (IOException e) {
      throw new IllegalArgumentException("Fail to export activerules " + activeRules, e);
    }
  }

  private static Ruleset buildRulesetFromActiveProfile(ActiveRules activeRules) {
    Ruleset ruleset = new Ruleset();
    for (org.sonar.api.batch.rule.ActiveRule activeRule : activeRules.findByRepository(DelphiPmdConstants.REPOSITORY_KEY)) {
      String key = activeRule.ruleKey().rule();
      
      String priority = severityToLevel(activeRule.severity()).toString();
      List<Property> properties = new ArrayList<>();

      DelphiRule delphiRule = new DelphiRule(activeRule.internalKey(), priority);
      delphiRule.setName(key);
      for (Map.Entry<String, String> entry: activeRule.params().entrySet()) {
        properties.add(new Property(entry.getKey(), entry.getValue()));
      }
      delphiRule.setProperties(properties);
      delphiRule.setMessage(activeRule.ruleKey().rule());
      ruleset.addRule(delphiRule);
    }
    return ruleset;
  }
  
  private static Integer severityToLevel(String severity) {
    switch (severity) {
      case Severity.INFO:
        return 1;
      case Severity.MINOR:
        return 2;
      case Severity.MAJOR:
        return 3;
      case Severity.CRITICAL:
        return 4;
      case Severity.BLOCKER:
        return 5;
      default:
        return 0;
    }
  }  

  public String exportActiveRulesToString(ActiveRules rules) {
    StringWriter writer = new StringWriter();
    exportActiveRules(rules, writer);
    return writer.toString();
  }}
