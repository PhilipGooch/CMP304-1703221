void mousePressed()
{
  if(mouseButton == LEFT)
  {
    if(state == STATE.UI)
    {
      if(hoveringSelectionBox && hoverIndex < populationSize)
      {
        cars.get(hoverIndex).selected = !cars.get(hoverIndex).selected;
      }
      
      // RESET
      if(resetButton.hit() && resetButton.valid)
      {
        resetButton.pressed = true;
        newPopulation();
        simulateButton.valid = true;
        runButton.valid = true;
        breedButton.valid = false;
      }
      
      // SIMULATE
      if(simulateButton.hit() && simulateButton.valid)
      {
        simulateButton.valid = false;
        simulateButton.pressed = true;
        triggerQuickButton = 1;
        
      }
      
      // RUN
      if(runButton.hit() && runButton.valid)
      {
        runButton.pressed = true;
        breedButton.valid = true;
        //sortButton.valid = true;
        simulateButton.valid = false;
        selectedCarIndices = new ArrayList<Integer>();
        for(int i = 0; i < cars.size(); i++)
        {
          cars.get(i).destroyBody();
          if(cars.get(i).selected)
          {
            cars.get(i).createBody();
            selectedCarIndices.add(i);
          }
        }
        state = STATE.RUNNING;
      }
     
      
      // BREED
      if(breedButton.hit() && breedButton.valid)
      {
        destroyCars();
        breed();
        breedButton.pressed = true;
        breedButton.valid = false;
        simulateButton.valid = true;
        runButton.valid = true;
      }
    }
    else if(state == STATE.RUNNING)
    {
      // BACK
      if(backButton.hit() && backButton.valid)
      {
        backButton.pressed = true;
        cameraPosition = new PVector();
        cameraTarget = new PVector();
        leader = null;
        state = STATE.UI;
        stepCount = 0;
      }
    }
  }
}

void mouseReleased()
{
  resetButton.pressed = false;
  simulateButton.pressed = false;
  runButton.pressed = false;
  breedButton.pressed = false;
  backButton.pressed = false;
}

void mouseDragged()
{
  // RESET
  if(resetButton.pressed && !resetButton.hit())
  {
    resetButton.pressed = false;
  }
  // QUICK
  else if(simulateButton.pressed && !simulateButton.hit())
  {
    simulateButton.pressed = false;
  }
  // RUN
  else if(runButton.pressed )
  {
    print("x");
    if(!runButton.hit())
      runButton.pressed = false;
  }
  // BREED
  else if(breedButton.pressed && !breedButton.hit())
  {
    breedButton.pressed = false;
  }
  // BACK
  else if(backButton.pressed && !backButton.hit())
  {
    backButton.pressed = false;
  }
}

void keyPressed()
{
  if(key == ' ')
  {
    state = STATE.UI;
  }
  if(key == 'a' && lastA == false)
  {
    lastA = true;
  }
  if(key == 'd' && lastD == false)
  {
    lastA = true;
  }
}

void keyReleased()
{
  if(key == 'a')
  {
    lastA = false;
    print("A");
  }
  if(key == 'd')
  {
    lastD = false;
  }
}
