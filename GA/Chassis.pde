class Chassis
{
  int ID;
  float x, y;
  
  Body body;
  
  Vec2 pos = new Vec2();
  
  Vec2 pixelVertices[];
  
  float[] angleDNA;
  float[] distanceDNA;
  
  // used for setting what the box2d body can interact with
  int categoryBits;
  int maskBits;
  
  Vec2 imagePixelVertices[];
  Vec2 iworldVertices[];
  
  Vec2 ipos = new Vec2();
  
  Chassis(int ID_, float x_, float y_, float[] angleDNA_, float[] distanceDNA_, int categoryBits_, int maskBits_)
  {
    ID = ID_;
    x = x_;
    y = y_;
    angleDNA = angleDNA_;
    distanceDNA = distanceDNA_;
    categoryBits = categoryBits_;
    maskBits = maskBits_;
    
    generatePixelVertices();
  }
  
  // creating the box2d body
  void createBody()
  {
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    body = box2d.createBody(bd);
    
    // creating the body out of 8 triangles as box2d does not handle concave shapes.
    // any concave shape can be made up of multiple convex shapes.
    PolygonShape triangles [] = new PolygonShape[8];
    for(int i = 0; i < 7; i++)
    {
      triangles[i] = new PolygonShape();
      Vec2 worldVertices[] = new Vec2[3];
      worldVertices[0] = new Vec2(0, 0); 
      worldVertices[1] = new Vec2(box2d.scalarPixelsToWorld(cos(angleDNA[i]) * distanceDNA[i]), box2d.scalarPixelsToWorld(sin(angleDNA[i]) * distanceDNA[i])); 
      worldVertices[2] = new Vec2(box2d.scalarPixelsToWorld(cos(angleDNA[i + 1]) * distanceDNA[i + 1]), box2d.scalarPixelsToWorld(sin(angleDNA[i + 1]) * distanceDNA[i + 1])); 
      triangles[i].set(worldVertices, 3);
      
      FixtureDef fd = new FixtureDef();
      fd.shape = triangles[i];
      fd.density = 1;
      fd.friction = 0.1;
      fd.restitution = 0.3;
      fd.filter.categoryBits = categoryBits;
      fd.filter.maskBits = maskBits;
      body.createFixture(fd);
    }
  }
  
  // destroying the box2d body
  void destroyBody()
  {
    box2d.world.destroyBody(body);
    body = null;
  }
  
  // generating vertices for a polygon shape to draw the chassis
  void generatePixelVertices()
  {
    pixelVertices = new Vec2[8];
    for(int i = 0; i < 8; i++)
    {
      pixelVertices[i] = new Vec2(cos(-angleDNA[i]) * distanceDNA[i], sin(-angleDNA[i]) * distanceDNA[i]); 
    }
  }
  
  // generating vertices for the small images of the chassis
  void generateImageVertices(float scale)
  {
    imagePixelVertices = new Vec2[8];
    for(int i = 0; i < 8; i++)
    {
      imagePixelVertices[i] = new Vec2(cos(-angleDNA[i]) * distanceDNA[i] * scale, sin(-angleDNA[i]) * distanceDNA[i] * scale); 
    }
  }
  
  // small images for ui state
  void renderImage()
  {
    
    pushMatrix();
    fill(177);
    stroke(0);
    strokeWeight(1);
    rectMode(CENTER);
    
    beginShape();
    for (Vec2 v: imagePixelVertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    for (Vec2 v: imagePixelVertices) {
      line(0, 0, v.x, v.y);
    }
    popMatrix();
  }
  
  void render(float scale)
  {
    pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    
    pushMatrix();
    fill(177);
    stroke(0);
    strokeWeight(2);
    rectMode(CENTER);
    
    translate(pos.x, pos.y);
    rotate(-a);
    beginShape();
    for (Vec2 v: pixelVertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    for (Vec2 v: pixelVertices) {
      line(0, 0, v.x, v.y);
    }
    popMatrix();
  }
}
