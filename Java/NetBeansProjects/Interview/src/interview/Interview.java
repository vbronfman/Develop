/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package interview;

/**
 *
 * @author vbronfman
 */
public class Interview {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        
        Tree root= new Tree(3);
        for(int i=1;i<=7;i++){
            root.AddNode(root.root,i);
        }
        root.AddNode(root.root,0);
        
        System.out.println("DEBUG Height="+root.treeHeight(root.root));
    }
    
}
