import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import java.util.Comparator;
import java.util.Collections;

enum STATE
{
  UI,
  RUNNING
} 

STATE state = STATE.UI;

Box2DProcessing box2d;

float timeStep = 1.0f / 60;
int steps = 2000;
int stepCount = 0;

GeneticAlgorithm ga;
int populationSize = 32;
int dnaSize = 18;
float mutationRate = 0.1f;

float averageFitness = 0;
float bestFitness = 0;
float worstFitness = 0;

ArrayList<Car> cars;
Terrain terrain;
Car leader = null;
int ENVIRONMENT = 1;
int CAR = 2;

PVector cameraPosition = new PVector();
PVector cameraTarget = new PVector();

boolean lastA = false;
boolean lastD = false;

PVector selectionBoxSize;

Button backButton = new Button(1200, 25, 160, 40, "Back", true);
Button resetButton = new Button(1200, 75, 160, 40, "Reset", true);
Button simulateButton = new Button(1200, 125, 160, 40, "Simulate", true);
Button runButton = new Button(1200, 175, 160, 40, "View", false);
Button breedButton = new Button(1200, 225, 160, 40, "Breed", false);

boolean hoveringSelectionBox = false;
int hoverIndex = -1;

int triggerQuickButton = 0;

ArrayList<Integer> selectedCarIndices;

int seed = 1;

boolean multiSelection = false;

// CONSTRUCTOR
////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup()
{
  populationSize = 32;
  mutationRate = 0.1f;
  multiSelection = false;
  
  size(1400, 834);
  surface.setLocation(90, 0);
  
  frameRate(60);
  
  randomSeed(seed);
  
  selectionBoxSize = new PVector(834, 834);
  
  ga = new GeneticAlgorithm(populationSize, dnaSize, mutationRate);
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld(new Vec2(0, -20));

  terrain = new Terrain(ENVIRONMENT, CAR);
  
  cars = new ArrayList<Car>();
  for(int i = 0; i < populationSize; i++)
  {
    cars.add(new Car(i, 0, height / 4, ga.population.get(i).genes));
  }
  
  // running many ganerations with no rendering and outputting results to csv file.
  if(false)
  {
    int generations = 100;
    Table table = new Table();
    table.addColumn("Generation");
    table.addColumn("Average");
    table.addColumn("Best");
    table.addColumn("Worst");
    for(int i = 0; i < generations; i++)
    {
      quickRun();
      TableRow row = table.addRow();
      row.setInt("Generation", i);
      row.setFloat("Average", averageFitness);
      row.setFloat("Best", bestFitness);
      row.setFloat("Worst", worstFitness);
      destroyCars();
      breed();
      println(i);
    }
    //saveTable(table, "multipleCrossover" + "p" + populationSize + "st" + steps + "m" + mutationRate + "s" + seed + "bumpy" + terrain.bumpy + ".csv");
  }
}


// FITNESS FUNCTION
////////////////////////////////////////////////////////////////////////////////////////////////////////

// just distance
float fitnessFunction(int index)
{
  return  cars.get(index).distance;
}

//float fitnessFunction(int index)
//{
//  return  cars.get(index).distance + cars.get(index).mass;
//}


// SELECTION FUNCTION
////////////////////////////////////////////////////////////////////////////////////////////////////////

int chooseFittest()
{
  int fittestIndex = 0;
  for(int i = 1; i < populationSize; i++)
  {
    if(cars.get(i).distance > cars.get(fittestIndex).distance)
    {
      fittestIndex = i;
    }
  }
  return fittestIndex;
}

int chooseAboveAverage(int fittestIndex)
{
  
  
  
  // Picking above average DNA
  ArrayList<Integer> remainingIndices = new ArrayList<Integer>();
  for(int i = 0; i < populationSize; i++)
  {
    remainingIndices.add(i);
  }
  int[] shuffled = new int[populationSize];
  for(int i = 0; i < populationSize; i++)
  {
    int rand = (int)random(remainingIndices.size());
    shuffled[i] = remainingIndices.get(rand);
    remainingIndices.remove(rand);
  }
  
  for(int i = 0; i < populationSize; i++)
  {
    if(ga.population.get(shuffled[i]).fitness > averageFitness)
    {
      return i;
    }
  }
  return (int)random(ga.population.size()); 
}


// MUTATION FUNCTION
////////////////////////////////////////////////////////////////////////////////////////////////////////

float mutationFunction(int i, float currentGene)
{
  // random mutation
  if(i <= 7)
  {
    return TWO_PI / 8 * i + random(TWO_PI / 8) - TWO_PI / 16;
  }
  else if(i <= 15)
  {
    return random(40) + 50;
  }
  else if(i <= 17)
  {
    return random(70) + 30;
  }
  return -1;
        
  // slight mutation      
  //if(i <= 7)
  //{
  //  return currentGene;// + (random(0.2) - 0.1);
  //}
  //else if(i <= 15)
  //{
  //  return currentGene + (random(6) - 3);
  //}
  //else if(i <= 17)
  //{
  //  return currentGene + (random(6) - 3);
  //}
  //return -1;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////
// HELPER FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////

// resets everything and creates a new population of cars
void newPopulation()
{
  ga = new GeneticAlgorithm(populationSize, dnaSize, mutationRate);
  cars = new ArrayList<Car>();
  for(int i = 0; i < populationSize; i++)
  {
    cars.add(new Car(i, 0, height / 4, ga.population.get(i).genes));
  }
  averageFitness = 0;
  cameraPosition = new PVector(); //<>//
  cameraTarget = new PVector();
  leader = null;
}

// runs a simulation of a generation of cars
void quickRun()
{  
  for(int i = 0; i <= steps; i++)
  {
    box2d.step(timeStep, 10, 8);
  }
  setCarDistances();
  calculateAverageFitness();
  bestFitness = cars.get(leaderIndex()).distance;
  worstFitness = cars.get(worstIndex()).distance;
} //<>//

// stores the distance the box2d body of the car chassis in a variable for later use
void setCarDistances()
{
  for(int i = 0; i < cars.size(); i++)
  {
    //if(cars.get(i).hasBody)
    {
      cars.get(i).distance = box2d.getBodyPixelCoord(cars.get(i).chassis.body).x;
    }
  }
}

void calculateAverageFitness()
{
  averageFitness = 0;
  for(int i = 0; i < populationSize; i++)
  {
    averageFitness +=  cars.get(i).distance;
  }
   averageFitness /= populationSize;
}

void destroyCars()
{
  for(Car car : cars)
  {
    if(car.hasBody)
    {
      box2d.world.destroyBody(car.chassis.body);
      box2d.world.destroyBody(car.frontWheel.body);
      box2d.world.destroyBody(car.backWheel.body);
    }
  }
}

void breed()
{
  ga.newGeneration();
  cars = new ArrayList<Car>(); //<>//
  for(int i = 0; i < populationSize; i++)
  {
    cars.add(new Car(i, 0, height / 4, ga.population.get(i).genes));
  }
  averageFitness = 0;
  bestFitness = 0;
  worstFitness = 0;
}

// returns the index of the car that is in the lead
int leaderIndex()
{
  int index = -1;
  for(int i = 0; i < cars.size(); i++)
  {
    if(cars.get(i).hasBody && index == -1)
    {
      index = i;
    }
    else if(cars.get(i).hasBody)
    {
      if(box2d.getBodyPixelCoord(cars.get(i).chassis.body).x > box2d.getBodyPixelCoord(cars.get(index).chassis.body).x + 50)
      {
        index = i;
      }
    }
  }
  return index;
}

// returns the index of the least fit car
int worstIndex()
{
  int index = -1;
  for(int i = 0; i < cars.size(); i++)
  {
    if(cars.get(i).hasBody && index == -1)
    {
      index = i;
    }
    else if(cars.get(i).hasBody)
    {
      if(cars.get(i).distance < cars.get(index).distance)
      {
        index = i;
      }
    }
  }
  return index;
}

// selects the best x number of cars from the generation
void selectTop(int number)
{
  ArrayList<Car> selectedCars = (ArrayList<Car>)cars.clone();
  Collections.sort(selectedCars, new CarComparator());
  for(int i = 0; i < number; i++)
  {
    cars.get(selectedCars.get(i).ID).selected = true;
  }
}


// UPDATE
////////////////////////////////////////////////////////////////////////////////////////////////////////

void update()
{
  hoveringSelectionBox = mouseX < selectionBoxSize.x && mouseY < selectionBoxSize.y;
  if(hoveringSelectionBox)
  {
    hoverIndex = (int)  (mouseX / (selectionBoxSize.x / 16)) + 
                 (int)  (mouseY / (selectionBoxSize.y / 16)) * 16;
  }
  
  if(state == STATE.UI)
  {
    // hacky way of getting one frame of rendering when the simulation button is pressed.
    // the simulation takes a while to run and freezes the program, this way you get to see you have pressed the button at least.
    if(triggerQuickButton == 1)
    {
      triggerQuickButton++;
    }
    else if(triggerQuickButton == 2)
    {
      quickRun();
      selectTop(5);
      runButton.valid = true;
      //sortButton.valid = true;
      breedButton.valid = true;
      simulateButton.valid = false;
      triggerQuickButton = 0;
    }
  }
  
  else if(state == STATE.RUNNING)
  {
    if(stepCount++ > steps)
    {
      calculateAverageFitness();
      cameraPosition = new PVector();
      cameraTarget = new PVector();
      leader = null;
      state = STATE.UI;
      stepCount = 0;
    }
    
    box2d.step(timeStep,10,8);
    
    leader = cars.get(leaderIndex());
    
    float leaderX = leader.chassis.pos.x;
    float leaderY = leader.chassis.pos.y;
    cameraTarget = new PVector(width / 2 - leaderX - 150, height / 2 - leaderY - 100);
    cameraPosition.lerp(cameraTarget, 0.05);
  }
}


// RENDER
////////////////////////////////////////////////////////////////////////////////////////////////////////

void draw()
{
  update();
  
  // POPULATION
  /////////////////////////////////////////////////////
  if(state == STATE.UI)
  {
    background(255);
    fill(0);
    
    int rows = 16;
    int columns = 16;
    Vec2 offset = new Vec2(28, 28);
    for(int i = 0; i < cars.size(); i++)
    {
      // IMAGE BORDER
      if(cars.get(i).selected)
      {
        noFill();
        stroke(255, 0, 0);
        strokeWeight(2);
        rectMode(CENTER);
        rect(offset.x + (selectionBoxSize.x / columns) * (i % columns), offset.y + (selectionBoxSize.y / rows) * (i / columns), (selectionBoxSize.x / columns), (selectionBoxSize.y / rows));
      }
      // SMALL CAR IMAGES
      pushMatrix();
      translate(offset.x + (selectionBoxSize.x / columns) * (i % columns), offset.y + (selectionBoxSize.y / rows) * (i / columns));
      cars.get(i).renderImage(0.2);
      popMatrix();
    }
    
    // HOVER IMAGE
    if(hoveringSelectionBox && hoverIndex < cars.size())
    {
      pushMatrix();
      translate(width / 4 + 100, height / 8 * 5 - 150);
      cars.get(hoverIndex).renderImage(2);
      fill(0);
      if(cars.get(hoverIndex).distance == 0)
      {
        text("?", 250, -100);
      }
      else
      {
        text(cars.get(hoverIndex).distance, 250, -100);
      }
      //text(cars.get(hoverIndex).mass, 150, 300);
      popMatrix();
    }
    
    resetButton.render();
    simulateButton.render();
    runButton.render();
    breedButton.render();
    
    text("Generation: " + ga.generation, 900, 50);
    
    
    if(bestFitness == 0)
    {
      text("Best: ?", 900, 100);
    }
    else
    {
      text("Best: " + bestFitness, 900, 100);
    }
    
    if(worstFitness == 0)
    {
      text("Worst: ?", 900, 150);
    }
    else
    {
      text("Worst: " + worstFitness, 900, 150);
    }
    if(averageFitness == 0)
    {
      text("Average: ?", 900, 200);
    }
    else
    {
      text("Average: " + averageFitness, 900, 200);
    }
    
  }
  
  // RUNNING
  /////////////////////////////////////////////////////
  else if(state == STATE.RUNNING)
  {
    background(255);
    fill(0);
    textSize(18);
    text(stepCount, 20, 50);
    text((int) frameRate, 20, 20);
    //text(box2d.getBodyPixelCoord(cars.get(0).chassis.body).x, 20, 80);
    
    
    backButton.render();
    
    translate(cameraPosition.x, cameraPosition.y);
    
    for(Car car : cars)
    {
      if(car.selected)
      {
        car.render(1);
      }
    }
    terrain.render();
    
  }
  
}
