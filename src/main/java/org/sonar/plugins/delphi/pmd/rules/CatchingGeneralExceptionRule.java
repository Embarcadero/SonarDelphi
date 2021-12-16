package org.sonar.plugins.delphi.pmd.rules;

import net.sourceforge.pmd.RuleContext;
import org.sonar.plugins.delphi.antlr.DelphiLexer;
import org.sonar.plugins.delphi.antlr.ast.DelphiNode;
import org.sonar.plugins.delphi.antlr.ast.DelphiPMDNode;

public class CatchingGeneralExceptionRule extends DelphiRule {

    public CatchingGeneralExceptionRule()
    {
    }

    @Override
    public void visit(DelphiPMDNode node, RuleContext ctx) {

        // Skip if not an except block
        if (node.getType() != DelphiLexer.EXCEPT)
            return;

        int childIndexDelta = 1;
        DelphiPMDNode parent = (DelphiPMDNode) node.getParent();
        DelphiPMDNode nextNode = (DelphiPMDNode) parent.getChild(node.getChildIndex() + childIndexDelta);

        // ... except HandleException ...
        if (nextNode.getType() != DelphiLexer.ON) {
            addViolation(ctx, node);
            return;
        }

        DelphiPMDNode currentNode;
        do {
            currentNode = (DelphiPMDNode) parent.getChild(node.getChildIndex() + childIndexDelta);
            if (currentNode.getType() == DelphiLexer.ON) {
                // ... on Exception ...
                nextNode = (DelphiPMDNode) parent.getChild(currentNode.getChildIndex() + 1);
                if (nextNode.getType() == DelphiLexer.TkIdentifier && nextNode.getText().equals("Exception")) {
                    addViolation(ctx, nextNode);
                    return;
                }

                // ... on E : Exception ...
                nextNode = (DelphiPMDNode) parent.getChild(currentNode.getChildIndex() + 3);
                if (nextNode.getType() == DelphiLexer.TkIdentifier && nextNode.getText().equals("Exception")) {
                    addViolation(ctx, nextNode);
                    return;
                }
            }

            childIndexDelta++;
        } while (currentNode.getType() != DelphiLexer.END);

        // try
        //    ...
        // except
        //     on EZeroDivide do HandleZeroDivide;
        //     on EOverflow do HandleOverflow;
        // else
        //     HandleAllOthers;
        // end;

    }
}