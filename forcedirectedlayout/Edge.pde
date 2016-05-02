class Edge {
    Node startNode;
    Node endNode; 
    int edgeLength;
    
    int currentLength;
    
    Edge(Node node1, Node node2, int eLength) {
        this.startNode = node1;
        this.endNode = node2;
        this.edgeLength = eLength;
    }
    
    // Updates the current length for the edge before drawing it
    // and displays hover text if the showEdgeData toggle button is ON
    void drawEdge() {
        if(isSpaceMode){
            stroke(204,0,0); // red edge color
        }else{
            fill(0);
            stroke(0);
        }
        
        // Update the current length of the line & draw it
        currentLength = (int)dist(startNode.pos.x, startNode.pos.y, 
                endNode.pos.x, endNode.pos.y);
        line(startNode.pos.x, startNode.pos.y, endNode.pos.x, endNode.pos.y);
        
        // Only show edge data if the toggle button is ON
        if(showEdgeData){
            String hoverText = "edge<"+startNode.id+","+endNode.id+"> (" + edgeLength + 
                    ", " + currentLength + ")";
             
            int xMid = (int)(startNode.pos.x + endNode.pos.x)/2;
            int yMid = (int)(startNode.pos.y + endNode.pos.y)/2;
            if(isSpaceMode){
              
              if(yMid< height * .55){
                  textFont(boldFont);
                  fill(hoverTextSpaceColor);
              }else{
                  textFont(defaultFont);
                  fill(0);
              }
            }else{
                textFont(defaultFont);
            }
            text(hoverText, xMid, yMid);
        } 
    }
}