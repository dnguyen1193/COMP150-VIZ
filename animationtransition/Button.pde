class Button
{
   int xpos;
   int ypos;
   int rWidth = 50;
   int rHeight = 30;
   String rText;
   
   Button(int x, int y, String text){
     xpos = x;
     ypos = y;
     rText = text;
   }
   
   void make(){
     fill(200,100,0);
     rect(xpos, ypos, rWidth, rHeight);
     fill(0,0,0);
     textAlign(CENTER);
     text(rText, xpos + rWidth/2, ypos + rHeight/2);
   }
   
   Boolean clicked() {
     if (mouseX >= xpos && mouseX <= (xpos + rWidth)
      && mouseY >= ypos && mouseY <= (ypos + rHeight)){
        return true;
      }
     else{
       return false;
     }
   }
    
}