class Node {
    ArrayList<Edge> edges;
    int id;
    int mass;
    PVector pos;
    float diameter;
    PVector acceleration;
    PVector velocity;
    float time;
    
    float edgeForce = 0.0;
    PVector totalForce = new PVector(0,0);
    

    Node(int nodeId, int nodeMass) {
        edges = new ArrayList<Edge>();
        id = nodeId;
        mass = nodeMass;
        diameter = 7 * mass;
        acceleration = new PVector(0,0);
        velocity = new PVector(0, 0);
        time = 1.0;
        
        // generate a random X & Y position
        int xPos = (int)random(0, w);
        int yPos = (int)random(0, h);
        pos = new PVector(xPos, yPos);
       
    }
    
    /* GETTERS AND SETTERS */
    int getMass() { return mass; }
    void setDiameter(float nDiameter) { diameter = nDiameter; }
    
    
    void drawNode() {
        float textXPos = pos.x + diameter/2 + 2;
        if(checkHover()){
            if(isSpaceMode && pos.y < height*.55){
                // use orange font if the node is over black space.
                // otherwise make text black when its over earth
                textFont(boldFont);
                fill(hoverTextSpaceColor);
            }else{
                fill(0);
            }
            String xText = String.format("%.5g", totalForce.x);
            String yText = String.format("%.5g", totalForce.y);
            String hoverText = "id: "  + id + " mass: " + mass + " \nX Force: " 
                + xText + "\nY Force: " + yText;
            text(hoverText, textXPos, pos.y);
            
            // set color & stroke for node's ellipse
            fill(highlightColor);
            stroke(highlightColor);
        }else{
            fill(nodeColor);
            if(isSpaceMode){
                stroke(178,223,138);  // green outline on Node
            }else{
                stroke(0);
            }
        }
       
        strokeWeight(1);      
        ellipse(pos.x, pos.y, diameter, diameter);        
    }
    
    boolean checkHover(){
        boolean isHovering = false;

        if((mouseX > pos.x-diameter/2 && mouseX < pos.x + diameter/2) && mouseY > pos.y - diameter/2 && mouseY < pos.y + diameter/2){
            isHovering = true;
        }
        return isHovering;
    }
    
    /************* CALCULATE FUNCTIONS ******************/
    /* Describes the forces exerted from springs 
       f = k1 * delta_length */
    void calcHookesLaw(){
        totalForce.x = 0.0;
        totalForce.y= 0.0;
        
        boolean isStretched = false;
        
        for(int i=0; i < edges.size(); i++){
            float deltaLength = edges.get(i).currentLength - edges.get(i).edgeLength;
            
            if (deltaLength > 0) {
                isStretched = true;
            } else {
                isStretched = false;
            }

            edgeForce = abs(k1 * deltaLength);
            
            Node neighborNode;
            if(edges.get(i).startNode.id == id){
                neighborNode =  edges.get(i).endNode;
            } else{
                neighborNode = edges.get(i).startNode;
            }
            
            totalForce.x += calcXForce(neighborNode, edgeForce, edges.get(i).currentLength, isStretched);
            totalForce.y += calcYForce(neighborNode, edgeForce, edges.get(i).currentLength, isStretched);
        }
    }
    
    float calcXForce(Node otherNode, float edgeForce, int eLength, boolean isStretched){
        float xDelta = pos.x - otherNode.pos.x;
        
        // We need to reverse the sign of the xForce (i.e. multiply by -1) so that it applies the force
        // in the correct location otherwise its always reversed.
        float xForce = 0.0;
        float hypotenuse = (float)eLength;
        if (isStretched) {
            if (eLength != 0)
                xForce = -1 * (xDelta/hypotenuse) * edgeForce;
        } else {
             if (eLength != 0)
                xForce = (xDelta/hypotenuse) * edgeForce;
        }
     
        if(abs(xForce) < (float)(.001)){
            xForce = 0;
        }
        return xForce;
    }
    
    float calcYForce(Node otherNode, float edgeForce, int eLength, boolean isStretched){
        float yDelta = pos.y - otherNode.pos.y;
        float yForce = 0.0;
        float hypotenuse = (float)eLength;
        
        // We need to reverse the sign of the xForce (i.e. multiply by -1) so that it applies the force
        // in the correct location otherwise its always reversed. 
        if (isStretched) {
            if (eLength != 0)
                yForce = -1 * (yDelta/hypotenuse) * edgeForce;
        } else {
             if (eLength != 0)
                yForce = (yDelta/hypotenuse) * edgeForce;
        }
        
        if(abs(yForce) < (float)(.001)){
            yForce = 0;
        }
        return yForce;
    }
    
    /* Repulses particles away from each other
       f=k2/distance   */
    void calcCoulombsLaw(Node[] allNodes){
        for(int i=0; i < allNodes.length; i++) {
            // DO NOT calculate coulombs law on itself
            if(id != allNodes[i].id){
                PVector nodePos = pos.copy();
                float dist = nodePos.dist(allNodes[i].pos);
                
                if(dist!=0){
                  float cForce = (float)k2/(dist*dist);
                  
                  // Calculate xForce & yForce
                  float xDist = abs(allNodes[i].pos.x - nodePos.x);
                  float xForce = (xDist * cForce) / dist;
                  float yDist = abs(allNodes[i].pos.y - nodePos.y);
                  float yForce = (yDist * cForce) / dist;
                  // current node is to the left of the node it's being compared to
                  if (nodePos.x < allNodes[i].pos.x) {
                      xForce = -1 * xForce;
                  }
                  // current node is above the node it's being compared to
                  if (nodePos.y < allNodes[i].pos.y) {
                      yForce = -1 * yForce;
                  }
                  PVector coulombForce = new PVector(xForce, yForce);
                  totalForce.add(coulombForce);
                }
            }
        }
    }
    
    /* f = ma, a = f/m) */
    void calcAcceleration(){
          PVector force = totalForce.copy();
          force.div(mass);
          acceleration.set(force);
    }
    
    /* v1 = v0 + at */
    void calcVelocity() {

        /* v1 = v0 + at
         * velocity.x = velocity.x + (acceleration.x * time);
         * velocity.y = velocity.y + (acceleration.y * time);
         */
        PVector at = acceleration.copy().mult(time);
        velocity.add(at);
    }
    
    /* s1 = s0 + vt + (1/2)at^2 */
    void calcPosition() {
        PVector vt = velocity.copy().mult(time);
        PVector at2 = acceleration.mult(time*time).mult(.5);
        
        // s1 = s0 + vt + 1/2*at^2
        pos.add(vt);  // s0 + vt
        pos.add(at2); // + 1/2*at^2
    }  
    
    // dampen the velocity by a % c
    void calcDamping() {        
        //velocity.x *= c;
        //velocity.y *= c;
        velocity.mult(c);
    }
}