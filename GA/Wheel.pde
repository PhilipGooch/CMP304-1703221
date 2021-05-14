class Wheel
{
  int ID;
  float x, y;
  float r;
  
  Body body;
  
  RevoluteJoint joint;
  
  // used for setting what the box2d body can interact with
  int categoryBits;
  int maskBits;
  
  Wheel(int ID_, float x_, float y_, float r_, int categoryBits_, int maskBits_)
  {
    ID = ID_;
    x = x_;
    y = y_;
    r = r_;
    categoryBits = categoryBits_;
    maskBits = maskBits_;
  }
  
  // creating the box2d body
  void createBody()
  {
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    Vec2 center = new Vec2(x, y);
    bd.position.set(box2d.coordPixelsToWorld(center));
    body = box2d.createBody(bd);

    CircleShape circle = new CircleShape();
    circle.m_radius = box2d.scalarPixelsToWorld(r / 2);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = circle;
    fd.density = 1;
    fd.friction = 100;
    fd.restitution = 0.3;
    fd.filter.categoryBits = categoryBits;
    fd.filter.maskBits = maskBits;

    body.createFixture(fd);
  }
  
  // destroying the box2d body
  void destroyBody()
  {
    box2d.world.destroyBody(body);
    body = null;
  }
  
  void render(float scale)
  {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    pushMatrix();
    fill(177);
    stroke(0);
    strokeWeight(2);
    translate(pos.x, pos.y);
    rotate(-a);
    
    ellipse(0, 0, r, r);
    line(0, 0, 0, r/2);
    popMatrix();
    
  }
}
