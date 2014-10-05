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
public class Tree {
    /*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

        Node root;
        
        public class Node {
            int data;
            Node nodeLeft;
            Node nodeRight;
            
            Node(){
                Node nodeLeft=null;
                Node nodeRight=null;
                this.data=0;
            }
            
            Node(int d){
                Node nodeLeft=null;
                Node nodeRight=null;
                this.data=d;
            }
            
        }
//Create root element of a tree        
        Tree(){
            this.root=new Node ();
        }
        
        Tree(int d){
            this.root=new Node ();
            this.root.data=d;
        }
        
        void AddNode(Node node,int d){
            System.out.println("DEBUG received node: "+node+", data="+d);

//Check right            
            if(node.data < d){
                System.out.println("DEBUG Going right");
                if(node.nodeRight == null){
                    Node nodeNew=new Node(d);
                    node.nodeRight=nodeNew;
                }
                else {
                    System.out.println("DEBUG Going down. node="+node.nodeRight);
                    AddNode(node.nodeRight,d);
                }
                
            }
            else if (node.data > d){
                System.out.println("DEBUG Going left");
                if(node.nodeLeft == null){
                    Node nodeNew=new Node(d);
                    node.nodeLeft=nodeNew;
                }
                else {
                    System.out.println("DEBUG Going down. node="+node.nodeLeft);
                    AddNode(node.nodeLeft,d);
                }
            
        }
            else{
                System.out.println("DEBUG new data is equal");
            }
        }
        
        int treeHeight(Node node){
            if(node==null) return 0;
            else{
//drill down to left                
                int heightLeft=treeHeight(node.nodeLeft);
//drill down to left    
                int heightRight=treeHeight(node.nodeRight);
//Get max of left and right heights
                int max=(heightLeft > heightRight)?heightLeft:heightRight;
                return 1+max;
            }
        }
}



