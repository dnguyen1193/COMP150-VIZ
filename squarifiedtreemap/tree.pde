// node class
class Node{
  // initialize variables to -1 
  int id = -1;
  int value = -1;
  int parentID = -1;
  ArrayList childIDs = new ArrayList();
  
  // constructor with just id (for parents)
  Node(int nid){
    id = nid;
  }
  
  // constructor with id, value (for leaves)
  Node(int nid, int nvalue){
    id = nid;
    value = nvalue;
  }
  
  // add child to node
  void addChild(int nid){
    childIDs.add(nid);
  }
   
  void printNode(){
    println(id + ": " + " value: " + value + "; parent: " + parentID + "; children " + childIDs);
  }
  
  // get value of node
  int computeValue(){
   // if node is a leaf, return value
   if (value != -1 &&  childIDs.isEmpty()){
     return value;
   }
   // else, recursively calculate the value and return
   int sum = 0;
   // loop through all nodes, add a node's value to sum if it's a child
   for (int j = 0; j < nodes.length; j++){
     if (childIDs.contains(nodes[j].id)){
       sum += nodes[j].computeValue();
     }
   }
   value = sum;
   return sum;
  }
  
  //recursively sort everything max->min
  void sortChildren(){
    //sort own children, then call sortChildren on children?
    int currMax;
    for (int i = 0; i < childIDs.size()-1; i++){
      currMax = i;
      for (int j = i + 1; j < childIDs.size(); j++){
        if (getValue((int)childIDs.get(j)) > getValue((int)childIDs.get(currMax))){
         currMax = j; 
        }
      }
      if (currMax != i){
        //swap childIDs[i], childIDs[currMax]
        int temp = (int)childIDs.get(currMax);
        childIDs.set(currMax, childIDs.get(i));
        childIDs.set(i, temp);
      }
    }
    
    //call on children
    for (int i = 0; i < childIDs.size(); i++){
      int index = getNodeIndex((int)childIDs.get(i));
      nodes[index].sortChildren(); 
    }
  }
  
  
  
};