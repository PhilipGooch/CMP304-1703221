class Terrain
{
  ArrayList<Vec2> surface;
  
  Body body;
  boolean bumpy = true;

  Terrain(int categoryBits, int maskBits) {
    
    surface = new ArrayList<Vec2>();
    
    // populating a list of vertices describing the shape of the terrain. this array is used for rendering.
    if(bumpy)
    {
      int start = -300;
      int interval = 10;
      float count = 0;
      //noiseSeed(4);
      noiseSeed(4);
      for(float i = 0; i <= 1000; i++)
      {
         surface.add(new Vec2(i * interval + start, height/2 + (noise(count) - 0.5) * 100));
         count += 0.1;
      }
    }
    else
    {
      int start = -300;
      int interval = 10;
      //noiseSeed(4);
      noiseSeed(4);
      surface.add(new Vec2(start, height / 2));
      for(float i = 0; i <= 1000; i++)
      {
         surface.add(new Vec2(300 + i * interval, height/2 - i * 3));
      }
    }
    
    // creating a box2d chain shape for the terrain.
    
    BodyDef bd = new BodyDef();
    body = box2d.world.createBody(bd);

    ChainShape chain = new ChainShape();

    // populating a new array of vertices. These are converted from pixel space into box2d world space
    Vec2[] vertices = new Vec2[surface.size()];
    for (int i = 0; i < vertices.length; i++) {
      vertices[i] = box2d.coordPixelsToWorld(surface.get(i));
    }

    chain.createChain(vertices, vertices.length);

    FixtureDef fd = new FixtureDef();
    fd.shape = chain;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 100;
    fd.restitution = 0.3;
    fd.filter.categoryBits = categoryBits;
    fd.filter.maskBits = maskBits;

    body.createFixture(fd);
  }

  // A simple function to just draw the edge chain as a series of vertex points
  void render() {
    strokeWeight(1);
    stroke(0);
    fill(0);
    beginShape();
    for (Vec2 v: surface) {
      vertex(v.x, v.y);
    }
    vertex(10000, height * 2);
    vertex(-3000, height * 2);
    endShape(CLOSE);
  }
}
