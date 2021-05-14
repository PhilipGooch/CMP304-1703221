

class Car 
{
  int ID;
  float x, y;
  boolean selected = false;
  
  Wheel frontWheel;
  Wheel backWheel;
  Chassis chassis;
  
  float dna [];
  
  RevoluteJoint frontWheelJoint;
  RevoluteJoint backWheelJoint;
  
  boolean hasBody = false;
  
  float distance;
  
  float mass;

  public Car(int ID_, float x_, float y_, float[] dna_)
  {
    ID = ID_;
    x = x_;
    y = y_;
    y = 300;
    dna = dna_;
    
    // 0 - 7 : chassis angles
    // 8 - 15 : chassis distances
    // 16 : front wheel size
    // 17 : back wheel size
    
    // splitting DNA arraylist into smaller arrays to be passed to each component of the car
    float[] chassisAngleDNA = new float[8];
    chassisAngleDNA[0] = dna[0];
    chassisAngleDNA[1] = dna[1];
    chassisAngleDNA[2] = dna[2];
    chassisAngleDNA[3] = dna[3];
    chassisAngleDNA[4] = dna[4];
    chassisAngleDNA[5] = dna[5];
    chassisAngleDNA[6] = dna[6];
    chassisAngleDNA[7] = dna[7];
    
    float[] chassisDistanceDNA = new float[8];
    chassisDistanceDNA[0] = dna[8];
    chassisDistanceDNA[1] = dna[9];
    chassisDistanceDNA[2] = dna[10];
    chassisDistanceDNA[3] = dna[11];
    chassisDistanceDNA[4] = dna[12];
    chassisDistanceDNA[5] = dna[13];
    chassisDistanceDNA[6] = dna[14];
    chassisDistanceDNA[7] = dna[15];
    
    chassis = new Chassis(ID, x, y, chassisAngleDNA, chassisDistanceDNA, CAR, ENVIRONMENT);
    
    frontWheel = new Wheel(ID, x + chassis.pixelVertices[0].x, y + chassis.pixelVertices[0].y, dna[16], CAR, ENVIRONMENT);
    backWheel = new Wheel(ID, x + chassis.pixelVertices[4].x, y + chassis.pixelVertices[4].y, dna[17], CAR, ENVIRONMENT);
    
    createBody();
  }
  
  // creating the box2d body
  void createBody()
  {
    if(!hasBody)
    {
      chassis.createBody();
      frontWheel.createBody();
      backWheel.createBody();
      mass = chassis.body.getMass() + frontWheel.body.getMass() + backWheel.body.getMass();
      createJoints();
      hasBody = true;
    }
  }
  
  // destroying the box2d body
  void destroyBody()
  {
    if(hasBody)
    {
      destroyJoints();
      chassis.destroyBody();
      frontWheel.destroyBody();
      backWheel.destroyBody();
      hasBody = false;
    }
  }
  
  // joints that connect the wheels to the chassis
  void createJoints()
  {
    // variables for the "engine" of the revolute joint
    float speed = PI * 3;
    float torque = 7000;
    
    RevoluteJointDef frontRJD = new RevoluteJointDef();
    frontRJD.initialize(frontWheel.body, chassis.body, frontWheel.body.getWorldCenter());
    frontRJD.motorSpeed = speed;       
    frontRJD.maxMotorTorque = torque; 
    frontRJD.enableMotor = true;      
    frontWheelJoint = (RevoluteJoint) box2d.world.createJoint(frontRJD);
    
    RevoluteJointDef backRJD = new RevoluteJointDef();
    backRJD.initialize(backWheel.body, chassis.body, backWheel.body.getWorldCenter());
    backRJD.motorSpeed = speed;       
    backRJD.maxMotorTorque = torque; 
    backRJD.enableMotor = true;      
    backWheelJoint = (RevoluteJoint) box2d.world.createJoint(backRJD);
  }
  
  void destroyJoints()
  {
    if(frontWheelJoint != null)
    {
      box2d.world.destroyJoint(frontWheelJoint);
      frontWheelJoint = null;
    }
    if(backWheelJoint != null)
    {
      box2d.world.destroyJoint(backWheelJoint);
      backWheelJoint = null;
    }
  }
  
  void renderImage(float scale)
  {
    chassis.generateImageVertices(scale);
    chassis.renderImage();
    strokeWeight(1);
    ellipse(chassis.imagePixelVertices[0].x, chassis.imagePixelVertices[0].y, frontWheel.r * scale, frontWheel.r * scale);
    line(chassis.imagePixelVertices[0].x, chassis.imagePixelVertices[0].y, chassis.imagePixelVertices[0].x, chassis.imagePixelVertices[0].y + frontWheel.r / 2 * scale);
    ellipse(chassis.imagePixelVertices[4].x, chassis.imagePixelVertices[4].y, backWheel.r * scale, backWheel.r * scale);
    line(chassis.imagePixelVertices[4].x, chassis.imagePixelVertices[4].y, chassis.imagePixelVertices[4].x, chassis.imagePixelVertices[4].y + backWheel.r / 2 * scale);
  }
  
  void render(float scale)
  {
    
    chassis.render(scale);
    frontWheel.render(scale);
    backWheel.render(scale);
    
  }
  
}

// comparator class used for sorting a list of car objects by fitness
class CarComparator implements Comparator<Car> {
 int compare(Car a, Car b) {
   return (int)b.distance - (int)a.distance;
 }
}
