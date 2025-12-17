/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class to create a hierachy for sObjects
 * 
 * @todo           Revisit the entire thing and do it properly
 */
public with sharing class HierarchyUtil {
    
    public class TreeNode {
        public Id id;
        public String name;
        public Id parentId;
        public List<TreeNode> children = new List<TreeNode>();
        public String orderPath; // e.g., 1.2.3

        public TreeNode(Id id, String name, Id parentId) {
            this.id = id;
            this.name = name;
            this.parentId = parentId;
        }
    }

    public class TreeResult {
        @AuraEnabled public String ascii;
        @AuraEnabled public Integer totalNodes;
    }

    
    public static TreeResult buildHierarchy(Id schemaMappingId) {

        // Query all mapped sObjects scoped by Schema_Mapping__c
        // Using minimal fields for performance
        List<Mapped_sObject__c> mapped = [
            SELECT Id, Name, Parent_SObject__c, Schema_Mapping__c, Order__c
            FROM Mapped_sObject__c
            WHERE Schema_Mapping__c = :schemaMappingId
        ];

        // Build nodes map
        Map<Id, TreeNode> nodes = new Map<Id, TreeNode>();
        for (Mapped_sObject__c m : mapped) {
            nodes.put(m.Id, new TreeNode(m.Id, m.Name, m.Parent_SObject__c));
        }

        // Build adjacency (children lists) and find roots
        List<TreeNode> roots = new List<TreeNode>();
        for (TreeNode n : nodes.values()) {
            if (n.parentId == null) {
                roots.add(n);
            } else if (nodes.containsKey(n.parentId)) {
                nodes.get(n.parentId).children.add(n);
            } else {
                // Parent missing in scope; treat as root to avoid orphaning
                roots.add(n);
            }
        }

        // Define ordering: within each sibling set, order by Name ascending
        // Assign Order__c path as 1-based indexes joined by dots (parent.child.grandchild)
        // We will also collect updates to persist Order__c
        List<Mapped_sObject__c> updates = new List<Mapped_sObject__c>();

        // Sort children recursively and assign order paths
        sortAndAssignOrder(roots, null, updates);

        // Persist Order__c updates if needed
        if (!updates.isEmpty()) {
            
            // Prevent update side effects and only update the parent
            for(Mapped_sObject__c recordToUpdate : updates){
                recordToUpdate.Ignore_Triggers__c = true;
            }

            update as system updates;

            // Update the parent schema mapping and untick the schema change flag
            Schema_Mapping__c schemaMappingToUpdate = new Schema_Mapping__c();
            schemaMappingToUpdate.Id                    = schemaMappingId;
            schemaMappingToUpdate.Hierarchy_Changed__c  = false;
            //schemaMappingToUpdate.Schema_Changed__c     = [SELECT Schema_Changed__c FROM Schema_Mapping__c WHERE Id = :schemaMappingId LIMIT 1]?.Schema_Changed__c ?? true;
            
            // Update the parent
            update as system schemaMappingToUpdate;
        }

        // Build ASCII in-memory ordering based on TreeNode.orderPath and children after sort
        String ascii = buildAsciiForest(roots);

        TreeResult result = new TreeResult();
        result.ascii = ascii;
        result.totalNodes = nodes.size();
        return result;
    }


    // Sort siblings by Name, assign order path with 1-based index, then recurse
    private static void sortAndAssignOrder(List<TreeNode> siblings, String parentPath, List<Mapped_sObject__c> updates) {
        // stable sort by name ASC (nulls last)
        siblings.sort(new TreeNodeNameComparator());

        Integer i = 0;
        for (TreeNode n : siblings) {
            i++;
            String myIdx = String.valueOf(i);
            n.orderPath = (parentPath == null || parentPath == '') ? myIdx : parentPath + '.' + myIdx;

            // Prepare update for Order__c
            updates.add(new Mapped_sObject__c(Id = n.id, Order__c = n.orderPath));

            if (!n.children.isEmpty()) {
                // Sort and assign for children
                sortAndAssignOrder(n.children, n.orderPath, updates);
            }
        }
    }

    private class TreeNodeNameComparator implements System.Comparator<TreeNode> {
        public Integer compare(TreeNode a, TreeNode b) {
            String an = a != null ? a.name : null;
            String bn = b != null ? b.name : null;
            if (an == bn) return 0;
            if (an == null) return 1;
            if (bn == null) return -1;
            return an.toLowerCase().compareTo(bn.toLowerCase());
        }
    }

    // Render using ASCII-safe characters (+--, \--, |) to ensure consistent display in any console font
    private static String buildAsciiForest(List<TreeNode> roots) {
        String ascii = '';
        // If multiple roots, show each as a top-level tree
        for (Integer r = 0; r < roots.size(); r++) {
            TreeNode root = roots[r];
            // Root line
            ascii += root.name + ' (' + root.orderPath + ')' + '\n';
            // Children
            ascii += renderAscii(root.children, '');
            if (r < roots.size() - 1) {
                // Separate multiple roots with a blank line
                ascii += '\n';
            }
        }
        return ascii;
    }

    private static String renderAscii(List<TreeNode> nodes, String prefix) {
        String ascii = '';
        for (Integer idx = 0; idx < nodes.size(); idx++) {
            Boolean isLast = (idx == nodes.size() - 1);
            TreeNode n = nodes[idx];

            String branch = isLast ? '└── ' : '├─ ';
            ascii += prefix + branch + n.name + ' (' + n.orderPath + ')' + '\n';

            String childPrefix = prefix + (isLast ? '    ' : '│  ');
            if (!n.children.isEmpty()) {
                ascii += renderAscii(n.children, childPrefix);
            }
        }
        return ascii;
    }
}
