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
package org.sonar.plugins.delphi.pmd;

import net.sourceforge.pmd.*;
import net.sourceforge.pmd.lang.ast.ParseException;
import net.sourceforge.pmd.lang.Language;
import net.sourceforge.pmd.lang.ast.Node;
import net.sourceforge.pmd.lang.LanguageRegistry;
import org.antlr.runtime.tree.CommonTree;
import org.sonar.plugins.delphi.antlr.DelphiLexer;
import org.sonar.plugins.delphi.antlr.ast.ASTTree;
import org.sonar.plugins.delphi.antlr.ast.DelphiAST;
import org.sonar.plugins.delphi.antlr.ast.DelphiPMDNode;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Preforms PMD check for Delphi source files
 */
public class DelphiPMD {

  private Report report = new Report();

  /**
   * Processes the file read by the reader against the rule set.
   * 
   * @param pmdFile input source file
   * @param ruleSets set of rules to process against the file
   * @param ctx context in which PMD is operating. This contains the Renderer and whatnot
   * @param encoding Encoding to use
   */
  public void processFile(File pmdFile, RuleSets ruleSets, RuleContext ctx, String encoding) {
    ctx.setSourceCodeFile(pmdFile);
    ctx.setReport(report);

    if (ruleSets.applies(ctx.getSourceCodeFile())) {

      Language language = LanguageRegistry.getLanguage(DelphiLanguageModule.NAME);
      ctx.setLanguageVersion(language.getDefaultVersion());

      DelphiAST ast = new DelphiAST(pmdFile, encoding);
      if (ast.isError()) {
        throw new ParseException("grammar error");
      }

      if (isDeprecatedOrExperimental(ast))
        return;

      List<Node> nodes = getNodesFromAST(ast);
      ruleSets.apply(nodes, ctx, language);
    }

  }

  /**
   * @param ast AST tree
   * @return AST tree nodes ready for parsing by PMD
   */
  public List<Node> getNodesFromAST(ASTTree ast) {
    List<Node> nodes = new ArrayList<>();

    for (int i = 0; i < ast.getChildCount(); ++i) {
      indexNode((CommonTree) ast.getChild(i), nodes);
    }

    return nodes;
  }

  /**
   * Adds children nodes to list
   * 
   * @param node Parent node
   * @param list List
   */
  public void indexNode(CommonTree node, List<Node> list) {
    if (node == null) {
      return;
    }

    if (node instanceof DelphiPMDNode) {
      list.add((DelphiPMDNode) node);
    } else {
      list.add(new DelphiPMDNode(node));
    }

    for (int i = 0; i < node.getChildCount(); ++i) {
      indexNode((CommonTree) node.getChild(i), list);
    }
  }

  /**
   * Checks whether the unit represented by the specified AST is marked as 
   * deprecated or experimental.
   * 
   * @return 
   * True if unit is marked as deprecated or experimental; otherwise, false.
   */
  private boolean isDeprecatedOrExperimental(ASTTree ast) {
    if (ast.getChild(0).getType() != DelphiLexer.UNIT)
      return false;

    CommonTree unitNode = (CommonTree)ast.getChild(0);
    for (Object child : unitNode.getChildren()) {
      CommonTree node = (CommonTree)child;
      
      if (node.getType() == DelphiLexer.DEPRECATED || node.getType() == DelphiLexer.EXPERIMENTAL)
        return true;
    }

    return false;
  }

  /**
   * Gets generated report
   * 
   * @return Report
   */
  public Report getReport() {
    return report;
  }
}
