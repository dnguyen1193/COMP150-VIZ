class Node{
  // initialize variables to -1 
  String id = "";
  int value = -1;
  String parentID = "";
  int depth = 0;
  ArrayList childIDs = new ArrayList();
  
  // constructor with just id (for parents)
  Node(String nid){
    id = nid;
  }
  
  // constructor with id, value (for leaves)
  Node(String nid, int nvalue){
    id = nid;
    value = nvalue;
  }
  
  // add child to node
  void addChild(String nid){
    childIDs.add(nid);
  }
   
  void printNode(){
    println(id + ": " + id + 
            "\n\tvalue: " + value + "\n\t parent: " + parentID + "\n\tchildren " + childIDs);
  }
  
  //recursively sort everything max->min
  void sortChildren(){
    //sort own children, then call sortChildren on children?
    int currMax;
    for (int i = 0; i < childIDs.size()-1; i++){
      currMax = i;
      for (int j = i + 1; j < childIDs.size(); j++){
        if (controller.sTreeMap.getValue((String)childIDs.get(j)) > controller.sTreeMap.getValue((String)childIDs.get(currMax))){
         currMax = j; 
        }
      }
      if (currMax != i){
        //swap childIDs[i], childIDs[currMax]
        String temp = (String)childIDs.get(currMax);
        childIDs.set(currMax, childIDs.get(i));
        childIDs.set(i, temp);
      }
    }
    //call on children
    for (int i = 0; i < childIDs.size(); i++){
      int index = controller.sTreeMap.getNodeIndex((String)childIDs.get(i));
      controller.sTreeMap.nodes[index].sortChildren(); 
    }
  }
};