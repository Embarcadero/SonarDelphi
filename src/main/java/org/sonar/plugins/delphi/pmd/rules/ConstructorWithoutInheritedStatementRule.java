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
package org.sonar.plugins.delphi.pmd.rules;

import net.sourceforge.pmd.RuleContext;

import org.antlr.runtime.tree.Tree;
import org.sonar.plugins.delphi.antlr.DelphiLexer;
import org.sonar.plugins.delphi.antlr.ast.DelphiPMDNode;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

public class ConstructorWithoutInheritedStatementRule extends NoInheritedStatementRule {

  private static final int MAX_LOOK_AHEAD = 3;

  private List<String> knewRecords = new ArrayList<>();
  private HashSet<String> declaredConstructors = new HashSet<>();

  @Override
  protected void init() {
    super.init();
    knewRecords.clear();
    declaredConstructors.clear();
    setLookFor("constructor");
  }

  @Override
  public void visit(DelphiPMDNode node, RuleContext ctx) {
    if (node.getType() == DelphiLexer.TkRecord) {
      knewRecords.add(node.getParent().getText());
    }

    if (node.getType() == DelphiLexer.CONSTRUCTOR && node.getChildCount() > 0)
      declaredConstructors.add(node.getChild(0).getChild(0).getText());

    super.visit(node, ctx);
  }

  @Override
  protected boolean shouldAddRule(DelphiPMDNode node) {
    if (node.getChild(0).getType() != DelphiLexer.TkFunctionName)
      return super.shouldAddRule(node);
    
    String functionName = node.getChild(0).getChild(0).getText();
    if (knewRecords.contains(functionName))
      return false;

    // Skip class constructor
    if (node.childIndex > 0 && node.getParent().getChild(node.childIndex-1).getType() == DelphiLexer.CLASS) {
      return false;
    }

    if (isConstructorOverloadCalled(node))
      return false;

    return true;
  }

  private boolean isConstructorOverloadCalled(DelphiPMDNode node) {
    // This solution isn't perfect and could miss violations when the constructor
    // calls a function that has the same name as an constructor overload
    Tree beginNode = null;
    for (int i = node.getChildIndex() + 1; i < node.getChildIndex() + MAX_LOOK_AHEAD
      && i < node.getParent().getChildCount(); ++i) {
      if (node.getParent().getChild(i).getType() == DelphiLexer.BEGIN) {
        beginNode = node.getParent().getChild(i);
        break;
      }
    }

    if (beginNode != null) {
      for (int c = 0; c < beginNode.getChildCount(); c++) {
        if (beginNode.getChild(c).getType() == DelphiLexer.TkIdentifier) {
          if (declaredConstructors.contains(beginNode.getChild(c).getText()))
            return true;
        }
      }
    }

    return false;
  }
}
