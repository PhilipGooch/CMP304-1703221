class Button
{
  int x, y;
  int w, h;
  String string;
  boolean valid = true;
  boolean pressed = false;
  
  Button(int x_, int y_, int w_, int h_, String string_, boolean valid_)
  {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    string = string_;
    valid = valid_;
  }
  
  // checking if the mouse is hovering over the button's hitbox
  boolean hit()
  {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
  
  void render()
  {
    rectMode(CORNER);
    pushMatrix();
    translate(x, y);
    stroke(0);
    strokeWeight(2);
    if(pressed)
      fill(235);
    else if(valid)
      fill(177);
    else
      fill(100);
    rect(0, 0, w, h);
    textSize(26);
    
    fill(0);
    text(string, 10, h - 10);
    popMatrix();
  }
}
